SPO sqld360_create_sql_baseline.log;
SET DEF ON TERM OFF ECHO ON FEED OFF VER OFF HEA ON LIN 2000 PAGES 100 LONG 8000000 LONGC 800000 TRIMS ON TI OFF TIMI OFF SERVEROUT ON SIZE 1000000 NUM 20 SQLP SQL>;
SET SERVEROUT ON SIZE UNL;
REM
REM
REM DESCRIPTION
REM This script is designed to populate a STS for a specific SQL_ID / PLAN_HASH_VALUE  
REM It also provides the steps to create a SQL Plan Baseline for it in the current 
REM or alternative system.
REM 
REM Largely inspired to SPM scripts by Carlos Sierra
REM
REM PRE-REQUISITES
REM   1. SQL_ID present in memory or AWR.
REM      Starting 11.2 you need ONLY Diagnostic Pack license to create a Baseline from AWR,
REM      STS is free starting 11.2 and starting 12.2 no need to use STS anymore.
REM
REM PARAMETERS
REM   1. SQL_ID (required)
REM   2. Oracle License [N|D|T] (required)
REM   2. PLAN_HASH_VALUE (required)
REM
REM EXECUTION
REM   1. Connect into SQL*Plus as user with access to data dictionary
REM      and privileges to create SQL Plan Baselines. Do not use SYS.
REM   2. Execute script sqld360_create_sql_baseline.sql passing three
REM      parameters inline or until requested by script.
REM
REM EXAMPLE
REM   # sqlplus system
REM   SQL> START sqld360_create_sql_baseline.sql 5bc0v4my7dvr5 T 3724264953
REM   SQL> START sqld360_create_sql_baseline.sql
REM
REM NOTES
REM   1. This script works on 11.2 or higher.
REM   2. For possible errors see sqld360_create_sql_baseline.log
REM   3. Use a DBA user but not SYS. Do not connect as SYS as the staging
REM      table cannot be created in SYS schema and you will receive an error:
REM      ORA-19381: cannot create staging table in SYS schema
REM
SET TERM ON ECHO OFF;
PRO
PRO Parameter 1:
PRO SQL_ID (required)
PRO
COL sql_id new_V sql_id FOR A15;
SELECT TRIM('&1.') sql_id FROM DUAL;
WHENEVER SQLERROR EXIT;
DECLARE
  sqlid_length NUMBER;
BEGIN
  SELECT LENGTH(TRANSLATE('&&sql_id.',
                   'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHJKLMNOPQRSTUVWXYZ-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?',
                   'abcdefghijklmnopqrstuvwxyz0123456789')) 
    INTO sqlid_length
    FROM DUAL;

  -- SQLID should be 13 chars, at least today in 2016 :-)
  IF sqlid_length <> 13 THEN
    RAISE_APPLICATION_ERROR(-20100, 'SQL ID provided looks incorrect!!!');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;
PRO
PRO Parameter 2:
PRO Oracle Pack License? (Tuning, Diagnostics or None) [ T | D | N ] (required)
PRO
COL license_pack NEW_V license_pack FOR A1;
SELECT NVL(UPPER(SUBSTR(TRIM('&2.'), 1, 1)), '?') license_pack FROM DUAL;
WHENEVER SQLERROR EXIT SQL.SQLCODE;
BEGIN
  IF NOT '&&license_pack.' IN ('T', 'D', 'N') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Invalid Oracle Pack License "&&license_pack.". Valid values are T, D and N.');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;
PRO
WITH p AS (-- This block is used to make sure we have the plan for this SQL (outline)
           SELECT plan_hash_value
             FROM gv$sql_plan
            WHERE sql_id = TRIM('&&sql_id.')
              AND other_xml IS NOT NULL
            UNION 
            SELECT plan_hash_value
              FROM dba_hist_sql_plan
             WHERE sql_id = TRIM('&&sql_id.')
               AND other_xml IS NOT NULL
               AND '&&license_pack.' IN ('D','T')),
     m AS (-- this block computes the avg elapsed / exec per phv, imprecise as usual because of v$sql / awr nature
           SELECT plan_hash_value, SUM(elapsed_time)/SUM(executions) avg_et_secs
             FROM (SELECT plan_hash_value, elapsed_time, executions
                     FROM gv$sql s
                    WHERE sql_id = TRIM('&&sql_id.')
                      AND executions > 0
                    UNION ALL
                   SELECT plan_hash_value, elapsed_time_delta, executions_delta
                     FROM dba_hist_sqlstat
                    WHERE sql_id = TRIM('&&sql_id.')
                      AND executions_delta > 0
                      AND '&&license_pack.' IN ('D','T'))
            GROUP BY plan_hash_value)
SELECT p.plan_hash_value, ROUND(m.avg_et_secs/1e6, 3) avg_et_secs
  FROM p, m
 WHERE p.plan_hash_value = m.plan_hash_value
 ORDER BY avg_et_secs NULLS LAST;
PRO
PRO Parameter 3:
PRO PLAN_HASH_VALUE (required)
PRO
DEF plan_hash_value = '&3';
PRO
PRO Values passed to sqld360_create_sql_baseline:
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO SQL_ID: "&&sql_id."
PRO LICENSE_PACK: "&&license_pack."
PRO PLAN_HASH_VALUE: "&&plan_hash_value."
PRO
WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET TERM OFF ECHO ON;

-- open log file
SPO sqld360_create_sql_baseline_&&sql_id..log;
GET sqld360_create_sql_baseline.log;
.

SET TERM ON ECHO OFF

-- get user
COL connected_user NEW_V connected_user FOR A30;
SELECT USER connected_user FROM DUAL;

-- create STS to freeze the desired plan
COL sqlset_name NEW_V sqlset_name;
SELECT 's_&&sql_id._&&plan_hash_value.' sqlset_name FROM DUAL;
SET SERVEROUT ON;

DECLARE
  l_sqlset_name      VARCHAR2(30) := '&&sqlset_name.';
  l_description      VARCHAR2(256);
  sts_cur            SYS.DBMS_SQLTUNE.SQLSET_CURSOR;
  l_begin_snap       NUMBER;
  l_end_snap         NUMBER;
  l_statement_loaded NUMBER;
BEGIN
  l_description := 'From SQLd360 - SQL_ID:&&sql_id., PHV:&&plan_hash_value.';

  BEGIN
    DBMS_OUTPUT.put_line('dropping sqlset: '||l_sqlset_name);
    SYS.DBMS_SQLTUNE.drop_sqlset(sqlset_name => l_sqlset_name, sqlset_owner => USER);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLERRM||' while trying to drop STS: '||l_sqlset_name||' (safe to ignore)');
  END;

  l_sqlset_name := SYS.DBMS_SQLTUNE.create_sqlset(sqlset_name => l_sqlset_name, description => l_description, sqlset_owner => USER);
  DBMS_OUTPUT.put_line('created sqlset: '||l_sqlset_name);

  OPEN sts_cur FOR
    SELECT VALUE(p)
      FROM TABLE(DBMS_SQLTUNE.select_cursor_cache(
      'sql_id = ''&&sql_id.'' AND plan_hash_value = TO_NUMBER(''&&plan_hash_value.'') AND loaded_versions > 0',
      NULL, NULL, NULL, NULL, 1, NULL, 'ALL')) p;

  SYS.DBMS_SQLTUNE.load_sqlset(sqlset_name => l_sqlset_name, populate_cursor => sts_cur);
  DBMS_OUTPUT.put_line('loaded sqlset from Cursor Cache: '||l_sqlset_name);

  -- need to check if we loaded it already
  -- can't use sts_cur%ROWCOUNT here since it returns 0
  SELECT statement_count
    INTO l_statement_loaded
    FROM dba_sqlset
   WHERE name = l_sqlset_name;

  -- no plan found from memory, trying from AWR 
  IF l_statement_loaded = 0 AND '&&license_pack.' IN ('D','T') THEN

    CLOSE sts_cur;

    SELECT MIN(snap_id), MAX(snap_id)
      INTO l_begin_snap, l_end_snap
      FROM dba_hist_sqlstat
     WHERE sql_id = '&&sql_id.';

    OPEN sts_cur FOR
      SELECT VALUE(p)
        FROM TABLE(DBMS_SQLTUNE.select_workload_repository(l_begin_snap, l_end_snap,
        'sql_id = ''&&sql_id.'' AND plan_hash_value = TO_NUMBER(''&&plan_hash_value.'') AND loaded_versions > 0',
        NULL, NULL, NULL, NULL, 1, NULL, 'ALL')) p;
    
    SYS.DBMS_SQLTUNE.load_sqlset(sqlset_name => l_sqlset_name, populate_cursor => sts_cur);
    DBMS_OUTPUT.put_line('loaded sqlset from AWR: '||l_sqlset_name);

  END IF;
  
  CLOSE sts_cur;
END;
/


PRO
PRO ****************************************************************************
PRO * Plan Hash Value &&plan_hash_value. saved into SQL Tuning Set &&sqlset_name. 
PRO ****************************************************************************
PRO
PRO If you need to implement a SQL Plan Baseline in the current system then execute the following commands: 
PRO
PRO var loaded_plans NUMBER
PRO exec :loaded_plans := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(sqlset_name => '&&sqlset_name.', sqlset_owner => '&&connected_user.');;
PRO print :loaded_plans
PRO
PRO ****************************************************************************
PRO
PRO If you need to implement this SQL Plan Baseline on a similar system, pack, export/import and unpack the SQL Tuning Set using the following commands:
PRO
PRO exec DBMS_SQLTUNE.CREATE_STGTAB_SQLSET(table_name => 'STGTAB_STS_&&sql_id.', schema_name => '&&connected_user.');;
PRO exec DBMS_SQLTUNE.PACK_STGTAB_SQLSET(sqlset_name => '&&sqlset_name.', sqlset_owner => '&&connected_user.', staging_table_name => 'STGTAB_STS_&&sql_id.', staging_schema_owner => '&&connected_user.');;
PRO exp &&connected_user. file=STGTAB_STS_&&sql_id..dmp tables=STGTAB_STS_&&sql_id. statistics=NONE indexes=N constraints=N grants=N triggers=N
PRO << move file STGTAB_STS_&&sql_id..dmp to the target system >>
PRO imp &&connected_user. file=STGTAB_STS_&&sql_id..dmp tables=STGTAB_STS_&&sql_id. ignore=Y
PRO exec DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET(replace => TRUE, staging_table_name => 'STGTAB_STS_&&sql_id.', staging_schema_owner => '&&connected_user.');;
PRO var loaded_plans NUMBER
PRO exec :loaded_plans := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(sqlset_name => '&&sqlset_name.', sqlset_owner => '&&connected_user.');;
PRO print :loaded_plans
PRO
SPO OFF;
SET DEF ON TERM ON ECHO OFF FEED 6 VER ON HEA ON LIN 80 PAGES 14 LONG 80 LONGC 80 TRIMS OFF TI OFF TIMI OFF SERVEROUT OFF NUM 10 SQLP SQL>;
SET SERVEROUT OFF;
UNDEFINE 1 2 3 sql_id license_pack plan_hash_value
CL COL
PRO
PRO sqld360_create_sql_baseline completed.