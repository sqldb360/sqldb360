-- setup
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') sqld360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET HEA OFF;
SET TERM ON;

-- log
SPO &&sqld360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&hh_mm_ss.
PRO Extracting table list

-- number of tables, needed for second level reporting
VAR num_tables NUMBER;

EXEC :num_tables := 0;
-- get list of tables from execution plan
-- format (('owner', 'table_name'), (), ()...)
DECLARE
  l_pair VARCHAR2(32767);
BEGIN

  FOR i IN (WITH object AS (
        SELECT /*+ MATERIALIZE */
               object_owner owner, object_name name
          FROM gv$sql_plan
         WHERE inst_id IN (SELECT inst_id FROM gv$instance)
           AND sql_id = '&&sqld360_sqlid.'
           AND object_owner IS NOT NULL
           AND object_name IS NOT NULL
         UNION
        SELECT object_owner owner, object_name name
          FROM dba_hist_sql_plan
         WHERE '&&diagnostics_pack.' = 'Y'
           AND &&sqld360_dbid. = dbid
           AND sql_id = '&&sqld360_sqlid.'
           AND object_owner IS NOT NULL
           AND object_name IS NOT NULL
&&sqld360_skip_obj_ashbased.         UNION
&&sqld360_skip_obj_ashbased.        SELECT o.owner, o.object_name name
&&sqld360_skip_obj_ashbased.          FROM plan_table pt,
&&sqld360_skip_obj_ashbased.               dba_objects o
&&sqld360_skip_obj_ashbased.         WHERE '&&diagnostics_pack.' = 'Y'
&&sqld360_skip_obj_ashbased.           AND pt.statement_id LIKE 'SQLD360_ASH_DATA%'
&&sqld360_skip_obj_ashbased.           AND pt.remarks = '&&sqld360_sqlid.'
&&sqld360_skip_obj_ashbased.           AND pt.object_instance > 0
&&sqld360_skip_obj_ashbased.           AND o.object_id = pt.object_instance
&&sqld360_skip_obj_ashbased.           AND pt.other_tag IN ('Application', 'Cluster', 'Concurrency', 'User I/O') 
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.   UNION 
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.   SELECT SUBSTR(owner,1,30) object_owner, SUBSTR(name,1,30) object_name
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.     FROM v$db_object_cache  -- it's intentional here to use V$ instead of GV$ to keep the plan easy 
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.    WHERE type IN ('TABLE','VIEW') 
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.      AND hash_value IN (SELECT to_hash
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.                           FROM v$object_dependency 
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.                          WHERE from_hash IN (SELECT hash_value
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.                                                FROM v$sqlarea  
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.                                               WHERE sql_id IN ('&&sqld360_sqlid.', '&&sqld360_xplan_sqlid.')))
        )
        SELECT 'TABLE', o.owner, o.name table_name
          FROM dba_tables t,   
               --dba_tab_statistics t, -- include fixed objects
               object o
         WHERE t.owner = o.owner
           AND t.table_name = o.name
         UNION 
        SELECT 'VIEW', o.owner, o.name 
          FROM dba_views v,  
               object o
         WHERE v.owner = o.owner
           AND v.view_name = o.name
         UNION
        SELECT 'TABLE', i.table_owner, i.table_name
          FROM dba_indexes i,    
               object o
         WHERE i.owner = o.owner
           AND i.index_name = o.name
         UNION
        SELECT 'TABLE', o.owner, o.name
          FROM dba_mviews m,  
               object o
         WHERE m.owner = o.owner
           AND m.mview_name = o.name)
  LOOP

    -- this is to support SQLs on LOTS of objects (or same SQL executed in tons of schemas)
    INSERT INTO plan_table (statement_id, remarks, object_owner, object_name) VALUES ('LIST_OF_TABLES','&&sqld360_sqlid.', i.owner, i.table_name);
    :num_tables := :num_tables + 1;
  END LOOP;

END;
/

--COL tables_list NEW_V tables_list FOR A32767 NOPRI;
--SELECT :tables_list tables_list FROM DUAL;
--COL tables_list_s NEW_V tables_list_s FOR A32767 NOPRI;
--SELECT :tables_list_s tables_list_s FROM DUAL;
  
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') sqld360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;  

PRO Done extracting table list
PRO &&hh_mm_ss.
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
SPO OFF
