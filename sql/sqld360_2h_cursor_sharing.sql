DEF section_id = '2h';
DEF section_name = 'Cursor Sharing';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Non-sharing reasons summary';
DEF main_table = 'GV$SQL_SHARED_CURSOR';
-- this is the same approach used in https://carlos-sierra.net/2017/09/01/poors-man-script-to-summarize-reasons-why-cursors-are-not-shared/
BEGIN
 :sql_text := 'SELECT COUNT(*) cursors, inst_id, reason_not_shared FROM gv$sql_shared_cursor UNPIVOT (value FOR reason_not_shared IN ';
 FOR i IN (SELECT CHR(10)||CASE WHEN ROWNUM = 1 THEN '( ' ELSE ', ' END||column_name column_name
             FROM dba_tab_columns
            WHERE table_name = 'V_$SQL_SHARED_CURSOR'
              AND owner = 'SYS'
              AND data_type = 'VARCHAR2'
              AND data_length = 1) LOOP
      :sql_text := :sql_text||i.column_name;
 END LOOP;
 :sql_text := :sql_text || q'[ )) WHERE value = 'Y' AND sql_id = '&&sqld360_sqlid.' GROUP BY inst_id,reason_not_shared ORDER BY inst_id, cursors DESC, reason_not_shared ]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Non-sharing reasons details';
DEF main_table = 'GV$SQL_SHARED_CURSOR';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_shared_cursor 
 WHERE sql_id = '&&sqld360_sqlid.'
 ORDER BY inst_id, child_number
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'ACS Histogram';
DEF main_table = 'GV$SQL_CS_HISTOGRAM';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_cs_histogram 
 WHERE sql_id = '&&sqld360_sqlid.'
 ORDER BY inst_id, child_number, bucket_id
]';
END;
/
@@&&skip_10g.sqld360_9a_pre_one.sql


DEF title = 'ACS Statistics';
DEF main_table = 'GV$SQL_CS_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_cs_statistics 
 WHERE sql_id = '&&sqld360_sqlid.'
 ORDER BY inst_id, child_number
]';
END;
/
@@&&skip_10g.sqld360_9a_pre_one.sql


DEF title = 'ACS Selectivity';
DEF main_table = 'GV$SQL_CS_SELECTIVITY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_cs_selectivity 
 WHERE sql_id = '&&sqld360_sqlid.'
 ORDER BY inst_id, child_number, range_id, predicate
]';
END;
/
@@&&skip_10g.sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;