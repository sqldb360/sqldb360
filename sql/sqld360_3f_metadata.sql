DEF section_id = '3f';
DEF section_name = 'Metadata';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Metadata script';
DEF main_table = 'DBMS_METADATA';

@@sqld360_0s_pre_nondef

VAR mymetadata CLOB;

SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SET TERM OFF
SPO sqld360_metadata_&&sqld360_sqlid._driver.sql
DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN

 FOR i IN (SELECT * 
             FROM (SELECT owner object_owner, table_name object_name, 'TABLE' object_type
                     FROM dba_tables
                    WHERE (owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
                   UNION 
                   SELECT owner object_owner, index_name object_name, 'INDEX' object_type
                     FROM dba_indexes
                    WHERE (table_owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
                   UNION 
                   SELECT owner object_owner, view_name object_name, 'VIEW' object_type
                     FROM dba_views
                    WHERE (owner, view_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
                   UNION 
                   SELECT owner object_owner, mview_name object_name, 'MATERIALIZED_VIEW' object_type
                     FROM dba_mviews
                    WHERE (owner, mview_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.   UNION 
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.   SELECT SUBSTR(owner,1,30) object_owner, SUBSTR(name,1,30) object_name, SUBSTR(type,1,30) object_type
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.     FROM v$db_object_cache -- it's intentional here to use V$ instead of GV$ to keep the plan easy 
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.    WHERE type IN ('INDEX', 'TABLE', 'CLUSTER', 'VIEW', 'SYNONYM', 'SEQUENCE', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY' ) 
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.      AND hash_value IN (SELECT to_hash
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.                           FROM v$object_dependency
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.                          WHERE from_hash IN (SELECT hash_value
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.                                                FROM v$sqlarea
&&skip_10g.&&skip_11r1.&&sqld360_skip_objd.                                               WHERE sql_id IN ('&&sqld360_sqlid.', '&&sqld360_xplan_sqlid.')))
                  )
            WHERE object_owner NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES',
                                       'MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS', 'PUBLIC',
                                       'SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL')
            ORDER BY object_owner, CASE WHEN object_type = 'TABLE' THEN 'AAA' ELSE object_type END, object_name) 
   LOOP
    put('BEGIN');
    put(':mymetadata :=');
    put('DBMS_METADATA.GET_DDL');
    put('( object_type => '''||i.object_type|| '''');
    put(', name => '''       ||i.object_name|| '''');
    put(', schema => '''     ||i.object_owner||''');');
    put('END;');
    put('/');
    put('PRINT :mymetadata;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;  

SPO &&one_spool_filename..txt
@sqld360_metadata_&&sqld360_sqlid._driver.sql
SPO OFF;

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SPO OFF;
SET TERM OFF PAGES 50000

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..txt">txt</a>
PRO </li>
PRO </ol>
SPO OFF;
HOS zip -jq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_metadata_&&sqld360_sqlid._driver.sql
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..txt
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
