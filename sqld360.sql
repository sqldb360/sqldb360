/*****************************************************************************************
   
    SQLD360 - Enkitec's Oracle SQL 360-degree View
    Copyright (C) 2015  Mauro Pagano

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*****************************************************************************************/

PRO If SQLd360 disconnects right after this message it means the user executing it
PRO owns a table called PLAN_TABLE that is not the Oracle seeded GTT plan table
PRO owned by SYS (PLAN_TABLE$ table with a PUBLIC synonym PLAN_TABLE).
PRO SQLd360 requires the Oracle seeded PLAN_TABLE, consider dropping the one in this schema.

WHENEVER SQLERROR EXIT;
DECLARE
 is_plan_table_in_usr_schema NUMBER; 
BEGIN
 SELECT COUNT(*)
   INTO is_plan_table_in_usr_schema
   FROM user_tables
  WHERE table_name = 'PLAN_TABLE';

  -- user has a physical table called PLAN_TABLE, abort
  IF is_plan_table_in_usr_schema > 0 THEN
    RAISE_APPLICATION_ERROR(-20100, 'PLAN_TABLE physical table present in user schema. ');
  END IF;

END;
/
WHENEVER SQLERROR CONTINUE;

-- The script creates a driver based on the rows inside the plan table and the according flags+days stored in column options 
-- the flags right now are 3 "000" plus 3 chars for the number of days
-- the first "bit" is for diagnostics_pack
-- the second "bit" is for tuning_pack
-- the third "bit" is for TCB
-- the next 3 chars are used for number of days
-- so ie. if customer has no license, wants TCB and 31 days then it would be 001031
SET TERM OFF
COL driver_time NEW_V driver_time
SELECT TO_CHAR(SYSDATE, 'HH24MISS') driver_time FROM DUAL;
SPO sqld360_driver_&&driver_time..sql
SET SERVEROUT ON FEED OFF DEF OFF TIMI OFF
DECLARE 
  num_sqlids NUMBER;
  license    VARCHAR2(1);
  num_days   NUMBER;
  container  VARCHAR2(128);
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN

  put('PRO Please Wait ...');

  SELECT count(*)
    INTO num_sqlids
    FROM plan_table
   WHERE statement_id = 'SQLD360_SQLID'
     AND remarks IS NULL;

  -- 1708 - Extracting calling container (only in 12c)
  BEGIN
    SELECT SYS_CONTEXT('USERENV','CON_NAME') 
      INTO container
      FROM v$instance 
     WHERE version LIKE '12%';
  EXCEPTION 
     WHEN NO_DATA_FOUND THEN container := ''; -- not in 12c
  END;

  IF num_sqlids = 0 THEN
    -- this is a standalone execution, just proceed without values
    -- for standalone execution leave the variable for TCB alone
    put('DEF sqld360_container='''||container||'''');
    put('DEF skip_tcb=''''');
    put('DEF from_edb360=''''');
    put('DEF sqld360_fromedb360_days=''''');
    put('@@sql/sqld360_0a_main.sql');
    put('HOS unzip -l &&sqld360_main_filename._&&sqld360_file_time.');
  ELSE
    -- disable "non desired" report sections when called from eDB360
    put('DEF from_edb360=''--''');

    /*
     * The following code is to handle the timeout from eDB360    
     * Column COST is "time to go" from eDB360, Cardinality is time left
     *
     * To future Mauro, this is because the SQLPlus variables gave you trouble when coming out of a SQLd360 execution
     * Even though the variable were defined, it wasn't possible to overwrite their value, so used plan_table to count down time
     */
    put('INSERT INTO plan_table (statement_id, cost, cardinality) VALUES (''EDB360_SECS2GO'', &&edb360_secs2go., &&edb360_secs2go.);');
    put('COMMIT;');

    -- this execution is from edb360, call SQLd360 several times passing the appropriare flag
    --  the DISTINCT here is to make sure we run SQLd360 once even though the SQL is top in multiple categories (e.g. signature and dbtime)
    FOR i IN (SELECT operation, options, object_node 
                FROM plan_table 
               WHERE statement_id = 'SQLD360_SQLID' 
               ORDER BY id) LOOP

       -- check if need to run TCB 
       IF SUBSTR(i.options,3,1) = 0 THEN
         put('DEF skip_tcb=''--''');
       ELSE
         put('DEF skip_tcb=''''');
       END IF;

       -- check the license to use
       IF SUBSTR(i.options,2,1) = 1 THEN
          -- if T is enabled then D is enabled too
          license := 'T';
       ELSIF SUBSTR (i.options,1,1) = 1 THEN
           -- no tuning but diagnostics
          license := 'D';
       ELSE
           -- no license
           license := 'N';
       END IF;

       num_days := TO_NUMBER(TRIM(SUBSTR(i.options,4,3)));
       put('DEF sqld360_fromedb360_days='''||num_days||'''');

       -- the following code is to handle the timeout from eDB360
       put('COL secs2go_starttime NEW_V secs2go_starttime');
       put('COL skip_sqld360 NEW_V skip_sqld360');
       put('SELECT TO_CHAR(sysdate,''YYYYMMDDHH24MISS'') secs2go_starttime, ');
       put('       CASE WHEN cardinality <= 0 THEN ''--'' ELSE NULL END skip_sqld360 ');
       put('  FROM plan_table ');
       put(' WHERE statement_id = ''EDB360_SECS2GO'';');

       -- plan_table.object_node is used to store the PDB
       IF i.object_node IS NOT NULL THEN
           put('ALTER SESSION SET CONTAINER='||i.object_node||';');
       END IF;
       -- v1708 - variable to keep track of the PDB/CDB we are in so that later 
       --  the code can switch back to CDB to update the right plan table with the file name
       put('DEF sqld360_container='''||container||'''');

       put('@@&&skip_sqld360.sql/sqld360_0a_main.sql '||i.operation||' '||license||' NULL');
       put('HOS unzip -l &&sqld360_main_filename._&&sqld360_file_time.');

       -- the following code is to handle the timeout from eDB360
       put('SET DEF @');
       put('UPDATE plan_table ');
       put('   SET cardinality = cardinality - ((sysdate - TO_DATE(''@@secs2go_starttime.'', ''YYYYMMDDHH24MISS''))*86400) ');
       put(' WHERE statement_id = ''EDB360_SECS2GO'' ');
       put('   AND cardinality > 0;');
       -- This COMMIT is to avoid ORA-65023 when called from eDB360 in CDB
       put('COMMIT;');
       put('SET DEF &');

    END LOOP;
      
  END IF;

END;
/
SPO OFF 
SET DEF ON TERM ON
@sqld360_driver_&&driver_time..sql
HOS rm sqld360_driver_&&driver_time..sql