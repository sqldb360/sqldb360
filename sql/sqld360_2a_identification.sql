DEF section_id = '2a';
DEF section_name = 'Identification';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

@@sqld360_2a_formatted.sql 
@@sqld360_2a_standalone.sql
@@&&skip_10g.&&skip_11r1.sqld360_2a_xpand.sql

-- to clean environment after 3 standalone scripts
SET HEAD ON PAGES &&def_max_rows.; 

COL address NOPRI
COL hash_value NOPRI
COL sql_id NOPRI

DEF title = 'SQL Text';
DEF main_table = 'V$SQLTEXT_WITH_NEWLINES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM v$sqltext_with_newlines
 WHERE sql_id = '&&sqld360_sqlid.'
 ORDER BY piece
]';
END;
/
@@sqld360_9a_pre_one.sql

COL address PRI
COL hash_value PRI
COL sql_id PRI


DEF title = 'SQL Text from AWR';
DEF main_table = 'DBA_HIST_SQLTEXT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM dba_hist_sqltext
 WHERE sql_id = '&&sqld360_sqlid.'
]';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;