DEF section_id = '2f';
DEF section_name = 'SQL Monitor';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

COL SQL_ID NOPRI
COL SQL_TEXT NOPRI

DEF title = 'SQL Monitor';
DEF main_table = 'GV$SQL_MONITOR';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sql_monitor
 WHERE sql_id = '&&sqld360_sqlid.'
 ORDER BY inst_id, sid, sql_exec_id desc, sql_exec_start desc
]';
END;
/
@@sqld360_9a_pre_one.sql

COL SQL_ID PRI
COL SQL_TEXT PRI


DEF title = 'SQL Plan Monitor';
DEF main_table = 'GV$SQL_PLAN_MONITOR';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sql_plan_monitor
 WHERE sql_id = '&&sqld360_sqlid.'
 ORDER BY inst_id, sid, sql_exec_id desc, sql_exec_start desc, plan_line_id
]';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;