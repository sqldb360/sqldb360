DEF section_id = '1e';
DEF section_name = 'NLS Settings';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Session Parameters';
DEF main_table = 'NLS_SESSION_PARAMETERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM nls_session_parameters
 ORDER BY parameter
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Instance Parameters';
DEF main_table = 'NLS_INSTANCE_PARAMETERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM nls_instance_parameters
 ORDER BY parameter
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Database Parameters';
DEF main_table = 'NLS_DATABASE_PARAMETERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM nls_database_parameters
 ORDER BY parameter
]';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;
