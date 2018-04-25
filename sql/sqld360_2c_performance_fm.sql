DEF section_id = '2c';
DEF section_name = 'Force Matching SQLs Performance';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

COL sql_text NOPRI
COL optimizer_env NOPRI
COL bind_data NOPRI

DEF title = 'SQL Statistics from Memory';
DEF main_table = 'GV$SQL';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sql
 WHERE force_matching_signature = TRIM('&&force_matching_signature.')
   AND sql_id <> '&&sqld360_sqlid.'
 ORDER BY inst_id, sql_id, child_number
]';
END;
/
@@sqld360_9a_pre_one.sql

COL sql_text PRI
COL optimizer_env PRI
COL bind_data PRI



--COL sql_text NOPRI
--
--DEF title = 'SQL Statistics from Memory (SQLSTATS)';
--DEF main_table = 'GV$SQLSTATS';
--BEGIN
--  :sql_text := '
--SELECT /*+ &&top_level_hints. */
--       *
--  FROM gv$sqlstats
-- WHERE sql_id IN (SELECT sql_id 
--                    FROM gv$sql 
--                   WHERE force_matching_signature = '&&force_matching_signature.'
--                     AND sql_id <> '&&sqld360_sqlid.')
-- ORDER BY inst_id, sql_id
--';
--END;
--/
--@@sqld360_9a_pre_one.sql
--
--COL sql_text PRI
--
--
DEF title = 'SQL Plan Statistics from Memory';
DEF main_table = 'GV$SQL_PLAN_STATISTICS_ALL';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sql_plan_statistics_all
 WHERE sql_id IN (SELECT sql_id 
                    FROM gv$sqlarea 
                   WHERE force_matching_signature = TRIM('&&force_matching_signature.')
                     AND sql_id <> '&&sqld360_sqlid.')
 ORDER BY inst_id, sql_id, plan_hash_value, child_number, id
]';
END;
/
@@sqld360_9a_pre_one.sql
--
--
--COL sql_text NOPRI
--
--DEF title = 'SQL Plan Statistics from Memory (SQLSTATS)';
--DEF main_table = 'GV$SQLSTATS_PLAN_HASH';
--BEGIN
--  :sql_text := '
--SELECT /*+ &&top_level_hints. */
--       *
--  FROM gv$sqlstats_plan_hash
-- WHERE sql_id IN (SELECT sql_id 
--                    FROM gv$sql 
--                   WHERE force_matching_signature = '&&force_matching_signature.'
--                     AND sql_id <> '&&sqld360_sqlid.')
-- ORDER BY inst_id, sql_id, plan_hash_value
--';
--END;
--/
--@@sqld360_9a_pre_one.sql
--
--COL sql_text PRI


COL bind_data NOPRI

DEF title = 'SQL Statistics from History';
DEF main_table = 'DBA_HIST_SQLSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM dba_hist_sqlstat
 WHERE force_matching_signature = TRIM('&&force_matching_signature.')
   AND sql_id <> '&&sqld360_sqlid.'
   AND '&&diagnostics_pack.' = 'Y'
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. 
 ORDER BY snap_id desc, instance_number, sql_id, plan_hash_value
]';
END;
/
@@sqld360_9a_pre_one.sql

COL bind_data PRI



DEF title = 'SQL Plan Statistics from History';
DEF main_table = 'DBA_HIST_SQL_PLAN';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM dba_hist_sql_plan
 WHERE sql_id IN (SELECT sql_id 
                    FROM dba_hist_sqlstat 
                   WHERE force_matching_signature = TRIM('&&force_matching_signature.')
                     AND sql_id <> '&&sqld360_sqlid.')
   AND '&&diagnostics_pack.' = 'Y'
 ORDER BY plan_hash_value, id
]';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;
