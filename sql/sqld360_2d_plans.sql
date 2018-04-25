DEF section_id = '2d';
DEF section_name = 'Execution Plans';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


COL num_plans NEW_V num_plans
SELECT TRIM(LEAST((COUNT(plan_hash_value)), TO_NUMBER('&&sqld360_num_plan_details.'))) num_plans
  FROM (SELECT plan_hash_value
          FROM gv$sql
         WHERE sql_id = '&&sqld360_sqlid.'
        UNION
        SELECT plan_hash_value
          FROM dba_hist_sqlstat
         WHERE sql_id = '&&sqld360_sqlid.'
           AND '&&diagnostics_pack.' = 'Y'
        UNION
        SELECT /*cost*/ bytes plan_hash_value
          FROM plan_table
         WHERE statement_id LIKE 'SQLD360_ASH_DATA%'
           AND '&&diagnostics_pack.' = 'Y'
           AND remarks = '&&sqld360_sqlid.')
 --WHERE ('&&sqld360_is_insert.' IS NULL AND plan_hash_value <> 0) OR ('&&sqld360_is_insert.' = 'Y')
/

DEF title= 'Plan Details'
DEF main_table = 'GV$SQL_PLAN'

--this one initiated a new file name, need it in the next anchor
@@sqld360_0s_pre_nondef
SET TERM OFF ECHO OFF 
-- need to fix the file name for the partitions
SPO &&sqld360_main_report..html APP;
PRO <li>Plans Details 
PRO <a href="&&one_spool_filename..html">page</a> <small><em>(&&num_plans.)</em></small> 
PRO </li>
SPO OFF;

-- this is hardcoded because there are 5 reports in 2a
EXEC :repo_seq_bck := :repo_seq+5;

@@sqld360_2f_plans_analysis.sql

-------------

DEF title = 'Plans from Memory';
DEF main_table = 'GV$SQL_PLAN_STATISTICS_ALL';

@@sqld360_0s_pre_nondef


SPO &&one_spool_filename..txt;
PRO &&title.&&title_suffix. (&&main_table.) 
PRO &&abstract.
PRO &&abstract2.

COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;
SET PAGES 0;

WITH v AS (
SELECT /*+ MATERIALIZE */
       DISTINCT sql_id, inst_id, child_number, child_address 
  FROM gv$sql
 WHERE sql_id = '&&sqld360_sqlid.'
   AND loaded_versions > 0
   AND is_obsolete = 'N'
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */
       RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, 
       t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 
       'inst_id='||v.inst_id||' AND sql_id='''||v.sql_id||''' AND child_number='||v.child_number||' AND child_address='''||v.child_address||'''')) t
/

WITH v AS (
SELECT /*+ MATERIALIZE */
       DISTINCT sql_id, inst_id, child_number, child_address
  FROM gv$sql
 WHERE sql_id = '&&sqld360_sqlid.'
   AND loaded_versions > 0
   AND is_obsolete = 'N'
   AND '&&skip_10g' IS NULL AND '&&skip_10g' IS NULL
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */
       RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, 
       t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST ADAPTIVE', 
       'inst_id='||v.inst_id||' AND sql_id='''||v.sql_id||''' AND child_number='||v.child_number||' AND child_address='''||v.child_address||'''')) t
/

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..txt">text</a>
SPO OFF;
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..txt
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO </li>
SPO OFF;
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html


-----------------------------------
-----------------------------------

DEF title = 'Plans from History';
DEF main_table = 'DBA_HIST_SQL_PLAN';

@@sqld360_0s_pre_nondef


SPO &&one_spool_filename..txt;
PRO &&title.&&title_suffix. (&&main_table.) 
PRO &&abstract.
PRO &&abstract2.

COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;
SET PAGES 0;

WITH v AS (
SELECT /*+ MATERIALIZE */ 
       DISTINCT sql_id, plan_hash_value, dbid
  FROM dba_hist_sql_plan 
 WHERE '&&diagnostics_pack.' = 'Y'
   AND dbid = '&&sqld360_dbid.' 
   AND sql_id = '&&sqld360_sqlid.'
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */ t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED')) t;

WITH v AS (
SELECT /*+ MATERIALIZE */ 
       DISTINCT sql_id, plan_hash_value, dbid
  FROM dba_hist_sql_plan 
 WHERE '&&diagnostics_pack.' = 'Y'
   AND dbid = '&&sqld360_dbid.' 
   AND sql_id = '&&sqld360_sqlid.'
   AND '&&skip_10g' IS NULL AND '&&skip_10g' IS NULL
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */ t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED +ADAPTIVE')) t;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt
SET PAGES 50000

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..txt">text</a>
SPO OFF;
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..txt
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO </li>
SPO OFF;
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html


-----------------------------------
-----------------------------------

DEF title = 'Plan from Plan Table';
DEF main_table = 'PLAN_TABLE';

@@sqld360_0s_pre_nondef


SPO &&one_spool_filename..txt;
PRO &&title.&&title_suffix. (&&main_table.) 
PRO &&abstract.
PRO &&abstract2.

SET TERM OFF 
-- first two lines below are redundant since we do the same in 0b_pre too
COL xplan_sql NEW_V xplan_sql
SELECT :sqld360_fullsql xplan_sql FROM DUAL;
ALTER SESSION SET CURRENT_SCHEMA = &&xplan_user.;
EXPLAIN PLAN FOR &&xplan_sql.
/
SET TERM ON 
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY);
ALTER SESSION SET CURRENT_SCHEMA = &&current_user.;


SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt
SET PAGES 50000

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..txt">text</a>
SPO OFF;
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..txt
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO </li>
SPO OFF;
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
-----------------------------------
-----------------------------------

DEF title = 'Plans from Baseline';
DEF main_table = 'DBA_SQL_PLAN_BASELINES';

@@sqld360_0s_pre_nondef


SPO &&one_spool_filename..txt;
PRO &&title.&&title_suffix. (&&main_table.) 
PRO &&abstract.
PRO &&abstract2.

COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;
SET PAGES 0;

WITH v AS (
SELECT /*+ MATERIALIZE */ 
       DISTINCT sql_handle
  FROM dba_sql_plan_baselines 
 WHERE signature = '&&exact_matching_signature.')
SELECT /*+ ORDERED USE_NL(t) */ t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(v.sql_handle, NULL, 'ADVANCED')) t;


SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt
SET PAGES 50000

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..txt">text</a>
SPO OFF;
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..txt
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO </li>
SPO OFF;
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html


--------------------------------------
--------------------------------------

DEF title = 'Plans from SQL Tuning Sets';
DEF main_table = 'DBA_SQLSET_STATEMENTS';

@@sqld360_0s_pre_nondef


SPO &&one_spool_filename..txt;
PRO &&title.&&title_suffix. (&&main_table.) 
PRO &&abstract.
PRO &&abstract2.

COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;
SET PAGES 0;

WITH v AS (
SELECT /*+ MATERIALIZE */ 
       DISTINCT sqlset_name, sqlset_owner, sql_id, plan_hash_value
  FROM dba_sqlset_statements 
 WHERE sql_id = '&&sqld360_sqlid.')
SELECT /*+ ORDERED USE_NL(t) */ t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY_SQLSET(sqlset_name => v.sqlset_name, sql_id => v.sql_id, plan_hash_value => v.plan_hash_value, format => 'ADVANCED',sqlset_owner => v.sqlset_owner)) t;


SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt
SET PAGES 50000

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..txt">text</a>
SPO OFF;
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..txt
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO </li>
SPO OFF;
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html



--------------------------------------
--------------------------------------

-- the +1 is to make the <LI> start from the next value
EXEC :repo_seq := :repo_seq_bck+1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;