@@&&edb360_0g.tkprof.sql
DEF section_id = '2a';
DEF section_name = 'Database Administration';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Latches';
DEF main_table = '&&gv_view_prefix.LATCH';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
select v.*
from 
  (select 
      name, inst_id,
      gets,
      misses,
      round(misses*100/(gets+1), 3) misses_gets_pct,
      spin_gets,
      sleep1,
      sleep2,
      sleep3,
      wait_time,
      round(wait_time/1000000) wait_time_seconds,
   rank () over
     (order by wait_time desc) as misses_rank
   from
      &&gv_object_prefix.latch
   where gets + misses + sleep1 + wait_time > 0
   order by
      wait_time desc
  ) v
where
   misses_rank <= 25
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Invalid Objects';
DEF main_table = '&&dva_view_prefix.OBJECTS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.objects
 WHERE status = 'INVALID'
 ORDER BY
       owner,
       object_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Disabled Constraints';
DEF main_table = '&&dva_view_prefix.CONSTRAINTS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.constraints
 WHERE status = 'DISABLED'
   AND NOT (owner = 'SYSTEM' AND constraint_name LIKE 'LOGMNR%')
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       constraint_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Enabled and not Validated Constraints';
DEF main_table = '&&dva_view_prefix.CONSTRAINTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.constraints
 WHERE status = 'ENABLED'
   AND validated = 'NOT VALIDATED'
   AND constraint_type != 'O'
   AND NOT (owner = 'SYSTEM' AND constraint_name LIKE 'LOGMNR%')
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       constraint_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Non-indexed FK Constraints';
DEF main_table = '&&dva_view_prefix.CONSTRAINTS';
COL constraint_columns FOR A200;
BEGIN
  :sql_text := q'[
-- based on "Oracle Database Transactions and Locking Revealed" book by Thomas Kyte  
WITH
ref_int_constraints AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       col.owner,
       col.table_name,
       col.constraint_name,
       con.status,
       con.r_owner,
       con.r_constraint_name,
       COUNT(*) col_cnt,
       MAX(CASE col.position WHEN 01 THEN col.column_name END) col_01,
       MAX(CASE col.position WHEN 02 THEN col.column_name END) col_02,
       MAX(CASE col.position WHEN 03 THEN col.column_name END) col_03,
       MAX(CASE col.position WHEN 04 THEN col.column_name END) col_04,
       MAX(CASE col.position WHEN 05 THEN col.column_name END) col_05,
       MAX(CASE col.position WHEN 06 THEN col.column_name END) col_06,
       MAX(CASE col.position WHEN 07 THEN col.column_name END) col_07,
       MAX(CASE col.position WHEN 08 THEN col.column_name END) col_08,
       MAX(CASE col.position WHEN 09 THEN col.column_name END) col_09,
       MAX(CASE col.position WHEN 10 THEN col.column_name END) col_10,
       MAX(CASE col.position WHEN 11 THEN col.column_name END) col_11,
       MAX(CASE col.position WHEN 12 THEN col.column_name END) col_12,
       MAX(CASE col.position WHEN 13 THEN col.column_name END) col_13,
       MAX(CASE col.position WHEN 14 THEN col.column_name END) col_14,
       MAX(CASE col.position WHEN 15 THEN col.column_name END) col_15,
       MAX(CASE col.position WHEN 16 THEN col.column_name END) col_16,
       par.owner parent_owner,
       par.table_name parent_table_name,
       par.constraint_name parent_constraint_name
  FROM &&dva_object_prefix.constraints  con,
       &&dva_object_prefix.cons_columns col,
       &&dva_object_prefix.constraints par
 WHERE con.constraint_type = 'R'
   AND con.owner NOT IN &&exclusion_list.
   AND con.owner NOT IN &&exclusion_list2.
   AND col.owner = con.owner
   AND col.constraint_name = con.constraint_name
   AND col.table_name = con.table_name
   AND par.owner(+) = con.r_owner
   AND par.constraint_name(+) = con.r_constraint_name
 GROUP BY
       col.owner,
       col.constraint_name,
       col.table_name,
       con.status,
       con.r_owner,
       con.r_constraint_name,
       par.owner,
       par.constraint_name,
       par.table_name
),
ref_int_indexes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.owner,
       r.constraint_name,
       c.table_owner,
       c.table_name,
       c.index_owner,
       c.index_name,
       r.col_cnt
  FROM ref_int_constraints r,
       &&dva_object_prefix.ind_columns c,
       &&dva_object_prefix.indexes i
 WHERE c.table_owner = r.owner
   AND c.table_name = r.table_name
   AND c.column_position <= r.col_cnt
   AND c.column_name IN (r.col_01, r.col_02, r.col_03, r.col_04, r.col_05, r.col_06, r.col_07, r.col_08,
                         r.col_09, r.col_10, r.col_11, r.col_12, r.col_13, r.col_14, r.col_15, r.col_16)
   AND i.owner = c.index_owner
   AND i.index_name = c.index_name
   AND i.table_owner = c.table_owner
   AND i.table_name = c.table_name
   AND i.index_type != 'BITMAP'
 GROUP BY
       r.owner,
       r.constraint_name,
       c.table_owner,
       c.table_name,
       c.index_owner,
       c.index_name,
       r.col_cnt
HAVING COUNT(*) = r.col_cnt
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM ref_int_constraints c
 WHERE NOT EXISTS (
SELECT NULL
  FROM ref_int_indexes i
 WHERE i.owner = c.owner
   AND i.constraint_name = c.constraint_name
)
 ORDER BY
       1, 2, 3
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unusable Indexes';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.indexes
 WHERE status = 'UNUSABLE'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Invisible Indexes';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.indexes
 WHERE visibility = 'INVISIBLE'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       index_name
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Function-based Indexes';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.indexes
 WHERE index_type LIKE 'FUNCTION-BASED%'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Bitmap Indexes';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.indexes
 WHERE index_type LIKE '%BITMAP'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Reversed Indexes';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.indexes
 WHERE index_type LIKE '%REV'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Fat Indexes';
DEF main_table = '&&dva_view_prefix.IND_COLUMNS';
BEGIN
  :sql_text := q'[
WITH 
indexes_list AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       index_owner owner, /*index_name,*/ COUNT(*) columns
  FROM &&dva_object_prefix.ind_columns
 WHERE index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
 GROUP BY
       index_owner, index_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       SUM(CASE columns WHEN  1 THEN 1 ELSE 0 END) "1 Col",
       SUM(CASE columns WHEN  2 THEN 1 ELSE 0 END) "2 Cols",     
       SUM(CASE columns WHEN  3 THEN 1 ELSE 0 END) "3 Cols",     
       SUM(CASE columns WHEN  4 THEN 1 ELSE 0 END) "4 Cols",     
       SUM(CASE columns WHEN  5 THEN 1 ELSE 0 END) "5 Cols",     
       SUM(CASE columns WHEN  6 THEN 1 ELSE 0 END) "6 Cols",
       SUM(CASE columns WHEN  7 THEN 1 ELSE 0 END) "7 Cols",
       SUM(CASE columns WHEN  8 THEN 1 ELSE 0 END) "8 Cols",
       SUM(CASE columns WHEN  9 THEN 1 ELSE 0 END) "9 Cols",
       SUM(CASE columns WHEN 10 THEN 1 ELSE 0 END) "10 Cols",
       SUM(CASE columns WHEN 11 THEN 1 ELSE 0 END) "11 Cols",
       SUM(CASE columns WHEN 12 THEN 1 ELSE 0 END) "12 Cols",     
       SUM(CASE columns WHEN 13 THEN 1 ELSE 0 END) "13 Cols",     
       SUM(CASE columns WHEN 14 THEN 1 ELSE 0 END) "14 Cols",     
       SUM(CASE columns WHEN 15 THEN 1 ELSE 0 END) "15 Cols",     
       SUM(CASE columns WHEN 16 THEN 1 ELSE 0 END) "16 Cols",
       SUM(CASE columns WHEN 17 THEN 1 ELSE 0 END) "17 Cols",
       SUM(CASE columns WHEN 18 THEN 1 ELSE 0 END) "18 Cols",
       SUM(CASE columns WHEN 19 THEN 1 ELSE 0 END) "19 Cols",
       SUM(CASE columns WHEN 20 THEN 1 ELSE 0 END) "20 Cols",
       SUM(CASE columns WHEN 21 THEN 1 ELSE 0 END) "21 Cols",
       SUM(CASE columns WHEN 22 THEN 1 ELSE 0 END) "22 Cols",     
       SUM(CASE columns WHEN 23 THEN 1 ELSE 0 END) "23 Cols",     
       SUM(CASE columns WHEN 24 THEN 1 ELSE 0 END) "24 Cols",     
       SUM(CASE columns WHEN 25 THEN 1 ELSE 0 END) "25 Cols",     
       SUM(CASE columns WHEN 26 THEN 1 ELSE 0 END) "26 Cols",
       SUM(CASE columns WHEN 27 THEN 1 ELSE 0 END) "27 Cols",
       SUM(CASE columns WHEN 28 THEN 1 ELSE 0 END) "28 Cols",
       SUM(CASE columns WHEN 29 THEN 1 ELSE 0 END) "29 Cols",
       SUM(CASE columns WHEN 30 THEN 1 ELSE 0 END) "30 Cols",
       SUM(CASE columns WHEN 31 THEN 1 ELSE 0 END) "31 Cols",
       SUM(CASE columns WHEN 32 THEN 1 ELSE 0 END) "32 Cols",     
       SUM(CASE columns WHEN 33 THEN 1 ELSE 0 END) "33 Cols",     
       SUM(CASE columns WHEN 34 THEN 1 ELSE 0 END) "34 Cols",     
       SUM(CASE columns WHEN 35 THEN 1 ELSE 0 END) "35 Cols",     
       SUM(CASE columns WHEN 36 THEN 1 ELSE 0 END) "36 Cols",
       SUM(CASE columns WHEN 37 THEN 1 ELSE 0 END) "37 Cols",
       SUM(CASE columns WHEN 38 THEN 1 ELSE 0 END) "38 Cols",
       SUM(CASE columns WHEN 39 THEN 1 ELSE 0 END) "39 Cols",
       SUM(CASE columns WHEN 40 THEN 1 ELSE 0 END) "40 Cols",
       SUM(CASE WHEN columns > 40 THEN 1 ELSE 0 END) "Over 40 Cols"
  FROM indexes_list
 GROUP BY
       owner
 ORDER BY
       owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Columns with Histogram on Long String';
DEF main_table = '&&dva_view_prefix.TAB_COLS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.tab_cols
 WHERE num_buckets BETWEEN 2 AND 253
   AND data_type LIKE '%CHAR%'
   AND char_length > 32
   AND avg_col_len > 6
   AND data_length > 32
 ORDER BY 
       owner, table_name, column_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Hidden Columns';
DEF main_table = '&&dva_view_prefix.TAB_COLS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.tab_cols
 WHERE hidden_column = 'YES'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       table_name,
       column_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Virtual Columns';
DEF main_table = '&&dva_view_prefix.TAB_COLS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.tab_cols
 WHERE virtual_column = 'YES'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       table_name,
       column_name
]';
END;
/
@@edb360_9a_pre_one.sql
       
DEF title = 'Tables not recently used';
DEF main_table = '&&dva_view_prefix.TABLES';
DEF abstract = 'Be aware of false positives. List of tables not referenced in &&history_days. days.<br />';
BEGIN
  :sql_text := q'[
WITH 
obj AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       object_name,
       object_id,
       last_ddl_time
  FROM &&dva_object_prefix.objects
 WHERE object_type LIKE 'TABLE%'
   AND last_ddl_time IS NOT NULL
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
),
ash AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       current_obj#,
       MAX(CAST(sample_time AS DATE)) sample_date
  FROM &&awr_object_prefix.active_sess_history h
 WHERE current_obj# > 0
   AND sql_plan_operation LIKE '%TABLE%'
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       current_obj#
),
sta1 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       table_name,
       MAX(last_analyzed) last_analyzed
  FROM &&dva_object_prefix.tab_statistics
 WHERE last_analyzed IS NOT NULL
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 GROUP BY
       owner,
       table_name
),
sta2 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       table_name,
       last_analyzed
  FROM &&dva_object_prefix.tables
 WHERE last_analyzed IS NOT NULL
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
),
sta3 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       table_owner owner,
       table_name,
       MAX(timestamp) last_date
  FROM &&dva_object_prefix.tab_modifications
 WHERE timestamp IS NOT NULL
   AND table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
 GROUP BY
       table_owner,
       table_name
),
grp AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       object_name table_name,
       MAX(last_ddl_time) last_date
  FROM obj
 GROUP BY
       owner,
       object_name
 UNION 
SELECT obj.owner,
       obj.object_name table_name,
       MAX(sample_date) last_date
  FROM ash, obj
 WHERE obj.object_id = ash.current_obj#
 GROUP BY
       obj.owner,
       obj.object_name
 UNION 
SELECT owner,
       table_name,
       last_analyzed last_date
  FROM sta1
 UNION 
SELECT owner,
       table_name,
       last_analyzed last_date
  FROM sta2
 UNION 
SELECT owner,
       table_name,
       last_date
  FROM sta3
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       MAX(last_date) last_date,
       owner,
       table_name
  FROM grp
 GROUP BY
       owner,
       table_name
HAVING MAX(last_date) < SYSDATE - &&history_days.
 ORDER BY
       1, 2, 3
]';
END;
/
@@&&skip_diagnostics.&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Indexes not recently used';
DEF main_table = '&&dva_view_prefix.INDEXES';
DEF abstract = 'Be aware of false positives. Turn index monitoring on for further analysis.<br />';
BEGIN
  :sql_text := q'[
WITH
objects AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       object_id,
       owner,
       object_name
  FROM &&dva_object_prefix.objects
 WHERE object_type LIKE 'INDEX%'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
),
/*
ash_mem AS (
SELECT /*+ &&sq_fact_hints. * /
       DISTINCT current_obj# 
  FROM &&gv_object_prefix.active_session_history
 WHERE sql_plan_operation = 'INDEX'
   AND current_obj# > 0
),
*/
ash_awr AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       DISTINCT current_obj# 
  FROM &&awr_object_prefix.active_sess_history h
 WHERE sql_plan_operation = 'INDEX'
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND current_obj# > 0
),
/*
sql_mem AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. * /
       DISTINCT object_owner, object_name
  FROM &&gv_object_prefix.sql_plan 
WHERE operation = 'INDEX'
),
*/
sql_awr AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       DISTINCT object_owner, object_name
  FROM &&awr_object_prefix.sql_plan
 WHERE operation = 'INDEX' AND dbid = &&edb360_dbid.
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       i.table_owner,
       i.table_name,
       i.index_name
  FROM &&dva_object_prefix.indexes i
 WHERE (index_type LIKE 'NORMAL%' OR index_type = 'BITMAP'  OR index_type LIKE 'FUNCTION%')
   AND i.table_owner NOT IN &&exclusion_list.
   AND i.table_owner NOT IN &&exclusion_list2.
   --AND (i.owner, i.index_name) NOT IN ( SELECT o.owner, o.object_name FROM ash_mem a, objects o WHERE o.object_id = a.current_obj# )
   AND (i.owner, i.index_name) NOT IN ( SELECT o.owner, o.object_name FROM ash_awr a, objects o WHERE o.object_id = a.current_obj# )
   --AND (i.owner, i.index_name) NOT IN ( SELECT object_owner, object_name FROM sql_mem)
   AND (i.owner, i.index_name) NOT IN ( SELECT object_owner, object_name FROM sql_awr)
 ORDER BY
       i.table_owner,
       i.table_name,
       i.index_name
]';
END;
/
@@&&skip_diagnostics.&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Redundant Indexes(1)';
DEF main_table = '&&dva_view_prefix.INDEXES';
COL redundant_index FOR A200;
COL superset_index FOR A200;
BEGIN
  :sql_text := q'[
WITH
indexed_columns AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       col.index_owner,
       col.index_name,
       col.table_owner,
       col.table_name,
       idx.index_type,
       idx.uniqueness,
       MAX(CASE col.column_position WHEN 01 THEN      col.column_name END)||
       MAX(CASE col.column_position WHEN 02 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 03 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 04 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 05 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 06 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 07 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 08 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 09 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 10 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 11 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 12 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 13 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 14 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 15 THEN ':'||col.column_name END)||
       MAX(CASE col.column_position WHEN 16 THEN ':'||col.column_name END)
       indexed_columns
  FROM &&dva_object_prefix.ind_columns col,
       &&dva_object_prefix.indexes idx
 WHERE col.table_owner NOT IN &&exclusion_list.
   AND col.table_owner NOT IN &&exclusion_list2.
   AND idx.owner = col.index_owner
   AND idx.index_name = col.index_name
 GROUP BY
       col.index_owner,
       col.index_name,
       col.table_owner,
       col.table_name,
       idx.index_type,
       idx.uniqueness
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       r.table_owner,
       r.table_name,
       r.index_type,
       r.index_name||' ('||r.indexed_columns||')' redundant_index,
       i.index_name||' ('||i.indexed_columns||')' superset_index
  FROM indexed_columns r,
       indexed_columns i
 WHERE i.table_owner = r.table_owner
   AND i.table_name = r.table_name
   AND i.index_type = r.index_type
   AND i.index_name != r.index_name
   AND i.indexed_columns LIKE r.indexed_columns||':%'
   AND r.uniqueness = 'NONUNIQUE'
 ORDER BY
       r.table_owner,
       r.table_name,
       r.index_name,
       i.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Redundant Indexes(2)';
DEF main_table = '&&dva_view_prefix.INDEXES';
DEF abstract = 'Considers descending indexes (function-based), visibility of redundant indexes, and whether there are extended statistics.<br />';
BEGIN
  :sql_text := q'[
-- requested by David Kurtz
WITH f AS ( /*function expressions*/
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ 
       owner, table_name, extension, extension_name
FROM   &&dva_object_prefix.stat_extensions
where  creator = 'SYSTEM' /*exclude extended stats*/
), ic AS ( /*list indexed columns getting expressions from stat_extensions*/
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       i.table_owner, i.table_name,
       i.owner index_owner, i.index_name,
       i.index_type, i.uniqueness, i.visibility,
       c.column_position,
       CASE WHEN f.extension IS NULL THEN c.column_name
            ELSE CAST(SUBSTR(REPLACE(SUBSTR(f.extension,2,LENGTH(f.extension)-2),'"',''),1,128) AS VARCHAR2(128))
       END column_name
  FROM &&dva_object_prefix.indexes i
     , &&dva_object_prefix.ind_columns c
       LEFT OUTER JOIN f
       ON f.owner = c.table_owner
       AND f.table_name = c.table_name
       AND f.extension_name = c.column_name
 WHERE c.table_owner NOT IN &&exclusion_list.
   AND c.table_owner NOT IN &&exclusion_list2.
   AND i.table_name = c.table_name
   AND i.owner = c.index_owner
   AND i.index_name = c.index_name
   AND i.index_type like '%NORMAL'
), i AS ( /*construct column list*/
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ic.table_owner, ic.table_name,
       ic.index_owner, ic.index_name,
       ic.index_type, ic.uniqueness, ic.visibility,
       listagg(ic.column_name,',') within group (order by ic.column_position) AS column_list,
       '('||listagg('"'||ic.column_name||'"',',') within group (order by ic.column_position)||')' AS extension,
       count(*) num_columns
FROM ic
GROUP BY 
       ic.table_owner, ic.table_name,
       ic.index_owner, ic.index_name,
       ic.index_type, ic.uniqueness, ic.visibility
), e AS ( /*extended stats*/
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner, table_name, CAST(SUBSTR(extension,1,128) AS VARCHAR2(128)) extension, extension_name
FROM   &&dva_object_prefix.stat_extensions
where  creator = 'USER' /*extended stats not function based indexes*/
) 
SELECT r.table_owner, r.table_name,
       i.index_name||' ('||i.column_list||')' superset_index,
       r.index_name||' ('||r.column_list||')' redundant_index,
       c.constraint_type, c.constraint_name,
       r.index_type, r.visibility, e.extension_name
  FROM i r
       LEFT OUTER JOIN e
         ON  e.owner = r.table_owner
         AND e.table_name = r.table_name
         AND e.extension = r.extension
       LEFT OUTER JOIN &&dva_object_prefix.constraints c
         ON c.table_name = r.table_name
         AND c.index_owner = r.index_owner
         AND c.index_name = r.index_name
         AND c.owner = r.table_owner
         AND c.constraint_type IN('P','U')
     , i
 WHERE i.table_owner = r.table_owner
   AND i.table_name = r.table_name
   AND i.index_name != r.index_name
   AND i.column_list LIKE r.column_list||',%'
   AND i.num_columns > r.num_columns
 ORDER BY r.table_owner, r.table_name, r.index_name, i.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with more than 5 Indexes';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       COUNT(*) indexes,
       table_owner,
       table_name,
       SUM(CASE WHEN index_type LIKE 'NORMAL%' THEN 1 ELSE 0 END) type_normal,
       SUM(CASE WHEN index_type LIKE 'BITMAP%' THEN 1 ELSE 0 END) type_bitmap,
       SUM(CASE WHEN index_type LIKE 'FUNCTION-BASED%' THEN 1 ELSE 0 END) type_fbi,
       SUM(CASE WHEN index_type LIKE 'CLUSTER%' THEN 1 ELSE 0 END) type_cluster,
       SUM(CASE WHEN index_type LIKE 'IOT%' THEN 1 ELSE 0 END) type_iot,
       SUM(CASE WHEN index_type LIKE 'DOMAIN%' THEN 1 ELSE 0 END) type_domain,
       SUM(CASE WHEN index_type LIKE 'LOB%' THEN 1 ELSE 0 END) type_lob,
       SUM(CASE WHEN partitioned LIKE 'YES%' THEN 1 ELSE 0 END) partitioned,
       SUM(CASE WHEN temporary LIKE 'Y%' THEN 1 ELSE 0 END) temporary,
       SUM(CASE WHEN uniqueness LIKE 'UNIQUE%' THEN 1 ELSE 0 END) is_unique,
       SUM(CASE WHEN uniqueness LIKE 'NONUNIQUE%' THEN 1 ELSE 0 END) non_unique,
       SUM(CASE WHEN status LIKE 'VALID%' THEN 1 ELSE 0 END) valid,
       SUM(CASE WHEN status LIKE 'N/A%' THEN 1 ELSE 0 END) status_na,
       &&skip_10g_column.SUM(CASE WHEN visibility LIKE 'VISIBLE%' THEN 1 ELSE 0 END) visible,
       &&skip_10g_column.SUM(CASE WHEN visibility LIKE 'INVISIBLE%' THEN 1 ELSE 0 END) invisible,
       SUM(CASE WHEN status LIKE 'UNUSABLE%' THEN 1 ELSE 0 END) unusable
  FROM &&dva_object_prefix.indexes
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
 GROUP BY 
       table_owner,
       table_name
HAVING COUNT(*) > 5 
 ORDER BY
       1 DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables on KEEP Buffer Pool';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       table_name,
       num_rows,
       blocks
  FROM &&dva_object_prefix.tables
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND buffer_pool = 'KEEP'
 ORDER BY
       owner,
       table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables on RECYCLE Buffer Pool';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       table_name,
       num_rows,
       blocks
  FROM &&dva_object_prefix.tables
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND buffer_pool = 'RECYCLE'
 ORDER BY
       owner,
       table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables to be CACHED in Buffer Cache';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       table_name,
       num_rows,
       blocks
  FROM &&dva_object_prefix.tables
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND TRIM(cache) = 'Y'
 ORDER BY
       owner,
       table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables on KEEP Flash Cache';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       table_name,
       num_rows,
       blocks
  FROM &&dva_object_prefix.tables
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND flash_cache = 'KEEP'
 ORDER BY
       owner,
       table_name
]';
END;
/
@@&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

DEF title = 'Tables on KEEP Cell Flash Cache';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       table_name,
       num_rows,
       blocks
  FROM &&dva_object_prefix.tables
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND cell_flash_cache = 'KEEP'
 ORDER BY
       owner,
       table_name
]';
END;
/
@@&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

DEF title = 'Tables set for Compression';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       table_name,
       compress_for,
       num_rows,
       blocks
  FROM &&dva_object_prefix.tables
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND compression = 'ENABLED'
 ORDER BY
       owner,
       table_name
]';
END;
/
@@&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

DEF title = 'Partitions set for Compression';
DEF main_table = '&&dva_view_prefix.TAB_PARTITIONS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       table_owner,
       table_name,
       compress_for,
       COUNT(*),
       MIN(partition_position) min_part_pos,
       MAX(partition_position) max_part_pos
  FROM &&dva_object_prefix.tab_partitions
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
   AND compression = 'ENABLED'
 GROUP BY
       table_owner,
       table_name,
       compress_for
 ORDER BY
       table_owner,
       table_name,
       compress_for
]';
END;
/
@@&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

REM DMK 25.6.2018
DEF title = 'Unindexed Partition Key Columns';
DEF main_table = '&&dva_view_prefix.PART_KEY_COLUMNS';
column table_owner heading 'Table|Owner'
column table_name  heading 'Table Name'
column index_owner heading 'Index|Owner'
column index_name  heading 'Index Name'
column index_type  heading 'Index Type'
column column_list heading 'Index Column List'
column part_level  heading 'Partition|Level'
column locality    heading 'Locality'
column partitioning_type    heading 'Partition|Type'
column partition_count      heading 'Partition|Count'
column part_column_position heading 'Part|Col|Pos' 
column part_column_name     heading 'Partitioning|Column Name'
BEGIN
  :sql_text := q'[
with k as (
select 	k.*, 'Partition' part_level
from 	&&dva_object_prefix.part_key_columns k
union all
select 	k.*, 'Subpartition' 
from 	&&dva_object_prefix.subpart_key_columns k
)
SELECT  /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
	i.table_owner, i.table_name
, 	i.owner index_owner
, 	i.index_name
, 	i.index_type
,	'Partition' part_level
,	p.locality
,	p.partitioning_type 
,	p.partition_count
, 	k.column_position part_column_position
,	k.column_name part_column_name
,	(	SELECT  LISTAGG(NVL(ie.extension,ic.column_name),',') WITHIN GROUP (ORDER BY ic.column_position)
		FROM	&&dva_object_prefix.ind_columns ic
			LEFT OUTER JOIN &&dva_object_prefix.stat_extensions ie
			ON ie.owner = ic.table_owner
			AND ie.table_name = ic.table_name
			AND ie.extension_name = ic.column_name
		where	i.owner = ic.index_owner
		and 	i.index_name = ic.index_name
		and	i.table_owner = ic.table_owner
		and	i.table_name = ic.table_name
	) column_list
from	&&dva_object_prefix.indexes i
,	&&dva_object_prefix.part_indexes p
,	k
where	i.table_owner NOT IN &&exclusion_list.
AND 	i.table_owner NOT IN &&exclusion_list2.
and	i.index_type NOT IN('LOB')
AND     k.owner = i.owner
and	k.name = i.index_name
and 	k.object_type = 'INDEX'
and	i.partitioned = 'YES'
and	p.owner = i.owner
and	p.index_name = i.index_name
and	p.table_name = i.table_name
and not exists (
	select 'x'
	from 	&&dva_object_prefix.ind_columns ic
	where	i.owner = ic.index_owner
	and 	i.index_name = ic.index_name
	and	i.table_owner = ic.table_owner
	and	i.table_name = ic.table_name
	and	ic.column_name = k.column_name)
order by 1,2,3,4,5,6
]';
END;
/

@@edb360_9a_pre_one.sql
column table_owner clear
column table_name  clear
column index_owner clear
column index_name  clear
column index_type  clear
column column_list clear
column part_level  clear
column locality    clear
column partitioning_type    clear
column partition_count      clear
column part_column_position clear
column part_column_name     clear


DEF title = 'Subpartitions set for Compression';
DEF main_table = '&&dva_view_prefix.TAB_SUBPARTITIONS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       table_owner,
       table_name,
       compress_for,
       COUNT(*),
       MIN(subpartition_position) min_part_pos,
       MAX(subpartition_position) max_part_pos
  FROM &&dva_object_prefix.tab_subpartitions
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
   AND compression = 'ENABLED'
 GROUP BY
       table_owner,
       table_name,
       compress_for
 ORDER BY
       table_owner,
       table_name,
       compress_for
]';
END;
/
@@&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

DEF title = 'Segments with non-default Buffer Pool';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       buffer_pool, owner, segment_name, partition_name, segment_type, blocks
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND TRIM(buffer_pool) != 'DEFAULT'
 ORDER BY
       buffer_pool,
       owner,
       segment_name,
       partition_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Segments with non-default Flash Cache';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       flash_cache, owner, segment_name, partition_name, segment_type, blocks
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND TRIM(flash_cache) != 'DEFAULT'
 ORDER BY
       flash_cache,
       owner,
       segment_name,
       partition_name
]';
END;
/
@@&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

DEF title = 'Segments with non-default Cell Flash Cache';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       cell_flash_cache, owner, segment_name, partition_name, segment_type, blocks
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND TRIM(cell_flash_cache) != 'DEFAULT'
 ORDER BY
       cell_flash_cache,
       owner,
       segment_name,
       partition_name
]';
END;
/
@@&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

DEF title = 'Degree of Parallelism DOP on Tables';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       SUM(CASE WHEN TRIM(degree) = 'DEFAULT' THEN 1 ELSE 0 END) "DEFAULT",
       SUM(CASE WHEN TRIM(degree) = '0' THEN 1 ELSE 0 END) "0",
       SUM(CASE WHEN TRIM(degree) = '1' THEN 1 ELSE 0 END) "1",
       SUM(CASE WHEN TRIM(degree) = '2' THEN 1 ELSE 0 END) "2",
       SUM(CASE WHEN TRIM(degree) IN ('3', '4') THEN 1 ELSE 0 END) "3-4",
       SUM(CASE WHEN TRIM(degree) IN ('5', '6', '7', '8') THEN 1 ELSE 0 END) "5-8",
       SUM(CASE WHEN TRIM(degree) IN ('9', '10', '11', '12', '13', '14', '15', '16') THEN 1 ELSE 0 END) "9-16",
       SUM(CASE WHEN LENGTH(TRIM(degree)) = 2 AND TRIM(degree) BETWEEN '17' AND '32' THEN 1 ELSE 0 END) "17-32",
       SUM(CASE WHEN LENGTH(TRIM(degree)) = 2 AND TRIM(degree) BETWEEN '33' AND '64' THEN 1 ELSE 0 END) "33-64",
       SUM(CASE WHEN (LENGTH(TRIM(degree)) = 2 AND TRIM(degree) BETWEEN '65' AND '99') OR
                     (LENGTH(TRIM(degree)) = 3 AND TRIM(degree) BETWEEN '100' AND '128') THEN 1 ELSE 0 END) "65-128",
       SUM(CASE WHEN LENGTH(TRIM(degree)) = 3 AND TRIM(degree) BETWEEN '129' AND '256' THEN 1 ELSE 0 END) "129-256",
       SUM(CASE WHEN LENGTH(TRIM(degree)) = 3 AND TRIM(degree) BETWEEN '257' AND '512' THEN 1 ELSE 0 END) "257-512",
       SUM(CASE WHEN (LENGTH(TRIM(degree)) = 3 AND TRIM(degree) > '512') OR
                     (LENGTH(TRIM(degree)) > 3 AND TRIM(degree) != 'DEFAULT') THEN 1 ELSE 0 END) "HIGHER"
  FROM &&dva_object_prefix.tables
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
HAVING COUNT(*) > SUM(CASE WHEN TRIM(degree) IN ('0', '1') THEN 1 ELSE 0 END)
 GROUP BY
       owner
 ORDER BY
       owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with DOP Set';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       degree,
       owner,
       table_name,
       blocks,
       partitioned
  FROM &&dva_object_prefix.tables
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND TRIM(degree) NOT IN ('0', '1')
 ORDER BY
       LENGTH(TRIM(degree)) DESC,
       degree DESC,
       owner,
       table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Degree of Parallelism DOP on Indexes';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       SUM(CASE WHEN TRIM(degree) = 'DEFAULT' THEN 1 ELSE 0 END) "DEFAULT",
       SUM(CASE WHEN TRIM(degree) = '0' THEN 1 ELSE 0 END) "0",
       SUM(CASE WHEN TRIM(degree) = '1' THEN 1 ELSE 0 END) "1",
       SUM(CASE WHEN TRIM(degree) = '2' THEN 1 ELSE 0 END) "2",
       SUM(CASE WHEN TRIM(degree) IN ('3', '4') THEN 1 ELSE 0 END) "3-4",
       SUM(CASE WHEN TRIM(degree) IN ('5', '6', '7', '8') THEN 1 ELSE 0 END) "5-8",
       SUM(CASE WHEN TRIM(degree) IN ('9', '10', '11', '12', '13', '14', '15', '16') THEN 1 ELSE 0 END) "9-16",
       SUM(CASE WHEN LENGTH(TRIM(degree)) = 2 AND TRIM(degree) BETWEEN '17' AND '32' THEN 1 ELSE 0 END) "17-32",
       SUM(CASE WHEN LENGTH(TRIM(degree)) = 2 AND TRIM(degree) BETWEEN '33' AND '64' THEN 1 ELSE 0 END) "33-64",
       SUM(CASE WHEN (LENGTH(TRIM(degree)) = 2 AND TRIM(degree) BETWEEN '65' AND '99') OR
                     (LENGTH(TRIM(degree)) = 3 AND TRIM(degree) BETWEEN '100' AND '128') THEN 1 ELSE 0 END) "65-128",
       SUM(CASE WHEN LENGTH(TRIM(degree)) = 3 AND TRIM(degree) BETWEEN '129' AND '256' THEN 1 ELSE 0 END) "129-256",
       SUM(CASE WHEN LENGTH(TRIM(degree)) = 3 AND TRIM(degree) BETWEEN '257' AND '512' THEN 1 ELSE 0 END) "257-512",
       SUM(CASE WHEN (LENGTH(TRIM(degree)) = 3 AND TRIM(degree) > '512') OR
                     (LENGTH(TRIM(degree)) > 3 AND TRIM(degree) != 'DEFAULT') THEN 1 ELSE 0 END) "HIGHER"
  FROM &&dva_object_prefix.indexes
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND index_type != 'LOB'
 GROUP BY
       owner
HAVING COUNT(*) > SUM(CASE WHEN TRIM(degree) IN ('0', '1') THEN 1 ELSE 0 END)
 ORDER BY
       owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Indexes with DOP Set';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       degree,
       owner,
       index_name,
       leaf_blocks,
       partitioned
  FROM &&dva_object_prefix.indexes
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND index_type != 'LOB'
   AND TRIM(degree) NOT IN ('0', '1')
 ORDER BY
       LENGTH(TRIM(degree)) DESC,
       degree DESC,
       owner,
       index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unused Columns';
DEF main_table = '&&dva_view_prefix.UNUSED_COL_TABS';
BEGIN
  :sql_text := q'[
-- requested by Mike Moehlman
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.unused_col_tabs
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Columns with multiple Data Types';
DEF main_table = '&&dva_view_prefix.TAB_COLUMNS';
BEGIN
  :sql_text := q'[
WITH 
tables AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       t.owner,
       t.table_name
  FROM &&dva_object_prefix.tables t
 WHERE t.owner NOT IN &&exclusion_list.
   AND t.owner NOT IN &&exclusion_list2.
   AND t.table_name NOT LIKE 'BIN%'
),
columns AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       c.owner,
       c.table_name,
       c.column_name,
       c.data_type
  FROM &&dva_object_prefix.tab_columns c
 WHERE c.owner NOT IN &&exclusion_list.
   AND c.owner NOT IN &&exclusion_list2.
   AND c.data_type != 'UNDEFINED'
   AND c.table_name NOT LIKE 'BIN%'
   AND c.data_type != 'UNDEFINED'
),
table_columns AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       c.column_name, COUNT(*) typ_cnt, c.data_type,  
       MIN(c.owner||'.'||c.table_name) min_table_name, 
       MAX(c.owner||'.'||c.table_name) max_table_name
  FROM columns c,
       tables t
 WHERE t.owner = c.owner -- this to filter out views
   AND t.table_name = c.table_name -- this to filter out views
 GROUP BY
       c.column_name, c.data_type
),
more_than_one_type AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       column_name, SUM(typ_cnt) col_cnt
  FROM table_columns
 GROUP BY
       column_name
HAVING COUNT(*) > 1
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       m.col_cnt, c.*
  FROM table_columns c,
       more_than_one_type m
 WHERE m.column_name = c.column_name
 ORDER BY
       m.col_cnt DESC,
       c.column_name,
       c.typ_cnt DESC,
       c.data_type
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Jobs';
DEF main_table = '&&dva_view_prefix.JOBS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.jobs
 ORDER BY
       job
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Jobs Running';
DEF main_table = '&&dva_view_prefix.JOBS_RUNNING';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.jobs_running
 ORDER BY
       job
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Jobs';
DEF main_table = '&&dva_view_prefix.SCHEDULER_JOBS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.scheduler_jobs
 ORDER BY
       owner,
       job_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Jobs PDBs';
DEF main_table = 'CDB_SCHEDULER_JOBS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM cdb_scheduler_jobs
 ORDER BY
       con_id,
       owner,
       job_name
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Scheduler Job Log for past 7 days';
DEF main_table = '&&dva_view_prefix.SCHEDULER_JOB_LOG';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.scheduler_job_log
 WHERE log_date > SYSDATE - 7
 ORDER BY
       log_id DESC,
       log_date DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Job Log for past 7 days PDBs';
DEF main_table = 'CDB_SCHEDULER_JOB_LOG';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM cdb_scheduler_job_log
 WHERE log_date > SYSDATE - 7
 ORDER BY
       con_id,
       log_id DESC,
       log_date DESC
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Scheduler Windows';
DEF main_table = '&&dva_view_prefix.SCHEDULER_WINDOWS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.scheduler_windows
 ORDER BY
       window_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Windows PDBs';
DEF main_table = 'CDB_SCHEDULER_WINDOWS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM cdb_scheduler_windows
 ORDER BY
       con_id,
       window_name
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Scheduler Window Group Members';
DEF main_table = '&&dva_view_prefix.SCHEDULER_WINGROUP_MEMBERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.scheduler_wingroup_members
 ORDER BY
       1,2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Window Group Members PDBs';
DEF main_table = 'CDB_SCHEDULER_WINGROUP_MEMBERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM cdb_scheduler_wingroup_members
 ORDER BY
       con_id, 1,2
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Advisor Parameters';
DEF main_table = '&&dva_view_prefix.ADVISOR_PARAMETERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.advisor_parameters
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Advisor Execution Types';
DEF main_table = '&&dva_view_prefix.ADVISOR_EXECUTION_TYPES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.advisor_execution_types
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Advisor Tasks';
DEF main_table = '&&dva_view_prefix.ADVISOR_TASKS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.advisor_tasks
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Advisor Executions';
DEF main_table = '&&dva_view_prefix.ADVISOR_EXECUTIONS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.advisor_executions
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Tasks';
DEF main_table = '&&dva_view_prefix.AUTOTASK_CLIENT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.autotask_client
 ORDER BY
       client_name
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Tasks PDBs';
DEF main_table = 'CDB_AUTOTASK_CLIENT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM cdb_autotask_client
 ORDER BY
       con_id,
       client_name
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Task Tasks';
DEF main_table = '&&dva_view_prefix.AUTOTASK_TASK';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.autotask_task
 ORDER BY
       client_name
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Task Tasks PDBs';
DEF main_table = 'CDB_AUTOTASK_TASK';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM cdb_autotask_task
 ORDER BY
       con_id,
       client_name
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Tasks History';
DEF main_table = '&&dva_view_prefix.AUTOTASK_CLIENT_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.autotask_client_history
 ORDER BY
       window_start_time DESC 
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Tasks History PDBs';
DEF main_table = 'CDB_AUTOTASK_CLIENT_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM cdb_autotask_client_history
 ORDER BY
       con_id,
       window_start_time DESC 
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Auto Task Job History';
DEF main_table = '&&dva_view_prefix.AUTOTASK_JOB_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.autotask_job_history
 ORDER BY
       window_start_time DESC 
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Auto Task Job History PDBs';
DEF main_table = 'CDB_AUTOTASK_JOB_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM cdb_autotask_job_history
 ORDER BY
       con_id,
       window_start_time DESC 
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Current Blocking Activity';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
a.sid, a.sql_id sql_id_a, a.state, a.blocking_session, b.sql_id sql_id_b, b.prev_sql_id, 
a.blocking_session_status, a.seconds_in_wait
 FROM &&gv_object_prefix.session a, &&gv_object_prefix.session b
where a.blocking_session is not null
and a.blocking_session = b.sid
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sequences';
DEF main_table = '&&dva_view_prefix.SEQUENCES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.*,
       ROUND(100 * (s.last_number - s.min_value) / GREATEST((s.max_value - s.min_value), 1), 1) percent_used /* requested by Mike Moehlman */
from &&dva_object_prefix.sequences s
where
   s.sequence_owner not in &&exclusion_list.
and s.sequence_owner not in &&exclusion_list2.
and s.max_value > 0
order by s.sequence_owner, s.sequence_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sequences used over 20%';
DEF main_table = '&&dva_view_prefix.SEQUENCES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       ROUND(100 * (s.last_number - s.min_value) / GREATEST((s.max_value - s.min_value), 1), 1) percent_used, /* requested by Mike Moehlman */
       s.*
from &&dva_object_prefix.sequences s
where
   s.sequence_owner not in &&exclusion_list.
and s.sequence_owner not in &&exclusion_list2.
and s.max_value > 0
and ROUND(100 * (s.last_number - s.min_value) / GREATEST((s.max_value - s.min_value), 1), 1) > 20
order by 
ROUND(100 * (s.last_number - s.min_value) / GREATEST((s.max_value - s.min_value), 1), 1) DESC, /* requested by Mike Moehlman */
s.sequence_owner, s.sequence_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sequences prone to contention';
DEF main_table = '&&dva_view_prefix.SEQUENCES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       (s.last_number - CASE WHEN s.increment_by > 0 THEN s.min_value ELSE s.max_value END) / s.increment_by times_used, s.*
  FROM &&dva_object_prefix.sequences s
 WHERE s.sequence_owner not in &&exclusion_list.
   AND s.sequence_owner not in &&exclusion_list2.
   AND (s.cache_size <= 1000 OR s.order_flag = 'Y')
   AND s.min_value != s.last_number
   AND s.max_value != s.last_number
   AND (s.last_number - CASE WHEN s.increment_by > 0 THEN s.min_value ELSE s.max_value END) / s.increment_by >= 10000
 ORDER BY 1 DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with more than 255 Columns';
DEF main_table = '&&dva_view_prefix.TAB_COLUMNS';
DEF abstract = 'Tables with more than 255 Columns are subject to intra-block chained rows. Continuation pieces could be stored on other blocks, even on different storage units. See MOS 9373758 and 18940497<br />';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       COUNT(*) columns,
       c.owner,
       c.table_name,
       t.avg_row_len
  FROM &&dva_object_prefix.tab_columns c,
       &&dva_object_prefix.tables t
 WHERE c.owner NOT IN &&exclusion_list.
   AND c.owner NOT IN &&exclusion_list2.
   AND c.table_name NOT LIKE 'BIN%'
   AND t.owner = c.owner 
   AND t.table_name = c.table_name
   AND NOT EXISTS
       (SELECT NULL FROM &&dva_object_prefix.views v WHERE v.owner = c.owner AND v.view_name = c.table_name)
 GROUP BY
       c.owner, c.table_name, t.avg_row_len
HAVING COUNT(*) > 255
 ORDER BY
       1 DESC, 
       c.owner,
       c.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL using Literals or many children (by COUNT)';
DEF main_table = '&&gv_view_prefix.SQL';
COL force_matching_signature FOR 99999999999999999999 HEA "SIGNATURE";
BEGIN
  :sql_text := q'[
WITH
lit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       force_matching_signature, COUNT(*) cnt, MIN(sql_id) min_sql_id, MAX(sql_id) max_sql_id
  FROM &&gv_object_prefix.sql
 WHERE force_matching_signature > 0
   AND UPPER(sql_text) NOT LIKE '%EDB360%'
 GROUP BY
       force_matching_signature
HAVING COUNT(*) > 99
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       DISTINCT lit.cnt, s.force_matching_signature, s.parsing_schema_name owner,
       CASE WHEN o.object_name IS NOT NULL THEN o.object_name||'('||s.program_line#||')' END source,
       lit.min_sql_id,
       lit.max_sql_id,
       s.sql_text
  FROM lit, &&gv_object_prefix.sql s, &&dva_object_prefix.objects o
 WHERE s.force_matching_signature = lit.force_matching_signature
   AND s.sql_id = lit.min_sql_id
   AND o.object_id(+) = s.program_id
 ORDER BY 
       1 DESC, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL using Literals or many children (by OWNER)';
DEF main_table = '&&gv_view_prefix.SQL';
COL force_matching_signature FOR 99999999999999999999 HEA "SIGNATURE";
BEGIN
  :sql_text := q'[
WITH
lit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       force_matching_signature, COUNT(*) cnt, MIN(sql_id) min_sql_id, MAX(sql_id) max_sql_id
  FROM &&gv_object_prefix.sql
 WHERE force_matching_signature > 0
   AND UPPER(sql_text) NOT LIKE '%EDB360%'
 GROUP BY
       force_matching_signature
HAVING COUNT(*) > 99
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       DISTINCT s.parsing_schema_name owner, lit.cnt, s.force_matching_signature,
       CASE WHEN o.object_name IS NOT NULL THEN o.object_name||'('||s.program_line#||')' END source,
       lit.min_sql_id,
       lit.max_sql_id,
       s.sql_text
  FROM lit, &&gv_object_prefix.sql s, &&dva_object_prefix.objects o
 WHERE s.force_matching_signature = lit.force_matching_signature
   AND s.sql_id = lit.min_sql_id
   AND o.object_id(+) = s.program_id
 ORDER BY 
       1, 2 DESC, 3
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL consuming over 10GB of TEMP space';
DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       h.sql_id,
       ROUND(MAX(h.temp_space_allocated)/POWER(10,9),1) max_temp_space_gb,
       DBMS_LOB.SUBSTR(s.sql_text, 1000) sql_text
  FROM &&awr_object_prefix.active_sess_history h,
       &&awr_object_prefix.sqltext s 
 WHERE h.temp_space_allocated > 10*POWER(10,9)
   AND h.sql_id IS NOT NULL
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.sql_id(+) = h.sql_id AND s.dbid(+) = &&edb360_dbid.
   &&skip_11g_column.&&skip_10g_column.AND s.con_id(+) = h.con_id
 GROUP BY
       h.sql_id,
       DBMS_LOB.SUBSTR(s.sql_text, 1000)
 ORDER BY
       2 DESC, 1
]';
END;
/
@@&&skip_diagnostics.&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

DEF title = 'SQL with over 2GB of PGA allocated memory';
DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF abstract = '&&abstract_uom.';
BEGIN
  :sql_text := q'[
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       h.sql_id,
       ROUND(MAX(h.pga_allocated)/POWER(2,30),1) max_pga_gb,
       DBMS_LOB.SUBSTR(s.sql_text, 1000) sql_text
  FROM &&awr_object_prefix.active_sess_history h,
       &&awr_object_prefix.sqltext s 
 WHERE h.pga_allocated > 2*POWER(2,30)
   AND h.sql_id IS NOT NULL
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.sql_id(+) = h.sql_id AND s.dbid(+) = &&edb360_dbid.
   &&skip_11g_column.&&skip_10g_column.AND s.con_id(+) = h.con_id
 GROUP BY
       h.sql_id,
       DBMS_LOB.SUBSTR(s.sql_text, 1000) 
 ORDER BY
       2 DESC, 1
]';
END;
/
@@&&skip_diagnostics.&&skip_10g_script.&&skip_11r1_script.edb360_9a_pre_one.sql

DEF title = 'Opened Cursors Current - Count per Session';
DEF main_table = '&&gv_view_prefix.SESSTAT';
DEF abstract = 'Open cursors for each session<br />';
BEGIN
  :sql_text := q'[
-- from http://www.orafaq.com/node/758
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       to_number(a.value) opened_cursors_current, a.inst_id, 
       s.sid, s.serial#, s.username, s.machine, s.program, s.module, s.action
from &&gv_object_prefix.sesstat a, &&gv_object_prefix.statname b, &&gv_object_prefix.session s
where a.statistic# = b.statistic#  
  and a.inst_id = b.inst_id
  and s.sid=a.sid
  and s.inst_id = a.inst_id
  and b.name = 'opened cursors current'
  and to_number(a.value) < 1.844E+19 -- bug
  and to_number(a.value) > 0
order by 1 desc, 2, 3
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Cached Cursors Count per Session';
DEF main_table = '&&gv_view_prefix.OPEN_CURSOR';
DEF abstract = 'Cursors in the "session cursor cache" for each session<br />';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       COUNT(*) cached_cursors, inst_id, sid, user_name
  FROM &&gv_object_prefix.open_cursor
 GROUP BY
       inst_id, sid, user_name
 ORDER BY 
       1 DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Cached Cursors Count per SQL_ID';
DEF main_table = '&&gv_view_prefix.OPEN_CURSOR';
DEF abstract = 'SQL statements with more than 50 cached cursors in the "session cursor cache".<br />';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       COUNT(*) cached_cursors, COUNT(DISTINCT inst_id||'.'||sid) sessions, sql_id, hash_value, sql_text, cursor_type,
       MIN(user_name) min_user_name, MAX(user_name) max_user_name, MAX(last_sql_active_time) last_sql_active_time
  FROM &&gv_object_prefix.open_cursor
 GROUP BY
       sql_id, hash_value, sql_text, cursor_type
HAVING COUNT(*) >= 50
   AND COUNT(*) > COUNT(DISTINCT inst_id||'.'||sid)
 ORDER BY 
       1 DESC
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Cached Cursors List per Session';
DEF main_table = '&&gv_view_prefix.OPEN_CURSOR';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM &&gv_object_prefix.open_cursor
 ORDER BY 
       inst_id, sid, sql_id
       &&skip_10g_column., sql_exec_id
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Session Cursor Cache Misses per Session';
DEF main_table = '&&gv_view_prefix.SESSTAT';
BEGIN
  :sql_text := q'[
WITH 
session_cache AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       p.value - c.value session_cache_misses,
       c.value session_cache_hits,
       p.value total_parse_count,
       c.inst_id,
       c.sid
  FROM &&gv_object_prefix.sesstat c,
       &&gv_object_prefix.statname n1,
       &&gv_object_prefix.sesstat p,
       &&gv_object_prefix.statname n2
 WHERE n1.inst_id = c.inst_id
   AND n1.statistic# = c.statistic#
   AND n1.name = 'session cursor cache hits'
   AND n2.inst_id = p.inst_id
   AND n2.statistic# = p.statistic#
   AND n2.name = 'parse count (total)'
   AND p.inst_id = c.inst_id
   AND p.sid = c.sid
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       c.session_cache_misses,
       c.session_cache_hits,
       c.total_parse_count,
       c.inst_id,
       c.sid,
       s.serial#,
       s.username,
       s.machine,
       s.program,
       s.module,
       s.action
  FROM session_cache c,
       &&gv_object_prefix.session s
 WHERE c.session_cache_misses > 0
   AND s.inst_id = c.inst_id
   AND s.sid = c.sid
 ORDER BY
       c.session_cache_misses DESC,
       c.session_cache_hits, c.total_parse_count
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'High Cursor Count';
DEF main_table = '&&gv_view_prefix.SQL';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       v1.sql_id,
       COUNT(*) child_cursors,
       MIN(inst_id) min_inst_id,
       MAX(inst_id) max_inst_id,
       MIN(child_number) min_child,
       MAX(child_number) max_child,
       v1.sql_text
  FROM &&gv_object_prefix.sql v1
 GROUP BY
       v1.sql_id,
       v1.sql_text
HAVING COUNT(*) > 99
 ORDER BY
       child_cursors DESC,
       v1.sql_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL with 100 or more unshared child cursors';
DEF main_table = '&&gv_view_prefix.SQL_SHARED_CURSOR';
BEGIN
  :sql_text := q'[
WITH
not_shared AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       sql_id, COUNT(*) child_cursors,
       RANK() OVER (ORDER BY COUNT(*) DESC NULLS LAST) AS sql_rank
  FROM &&gv_object_prefix.sql_shared_cursor
 GROUP BY
       sql_id
HAVING COUNT(*) > 99
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       DISTINCT
       ns.sql_rank,
       ns.child_cursors,
       ns.sql_id,
       s.sql_text
  FROM not_shared ns,
       &&gv_object_prefix.sql s
 WHERE s.sql_id(+) = ns.sql_id
 ORDER BY
       ns.sql_rank,
       ns.child_cursors DESC,
       ns.sql_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Top SQL by Buffer Gets consolidating duplicates';
DEF main_table = '&&gv_view_prefix.SQL';
COL total_buffer_gets NEW_V total_buffer_gets;
COL total_disk_reads NEW_V total_disk_reads;
SELECT SUM(buffer_gets) total_buffer_gets, SUM(disk_reads) total_disk_reads FROM &&gv_object_prefix.sql;
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
   FORCE_MATCHING_SIGNATURE,
   duplicate_count cnt,
   min_sql_id,
   max_sql_id,
   distinct_phv phv_cnt,
   executions,
   buffer_gets,
   buffer_gets_per_exec,
   disk_reads,
   disk_reads_per_exec,
   rows_processed,
   rows_processed_per_exec,
   elapsed_seconds,
   elapsed_seconds_per_exec,
   pct_total_buffer_gets,
   pct_total_disk_reads,
   min_sql_text
from
  (select
      FORCE_MATCHING_SIGNATURE,
      count(*) duplicate_count,
      min(sql_id) min_sql_id,
      max(sql_id) max_sql_id,
      count(distinct plan_hash_value) distinct_phv,
      sum(executions) executions,
      sum(buffer_gets) buffer_gets,
      ROUND(sum(buffer_gets)/greatest(sum(executions),1)) buffer_gets_per_exec,
      sum(disk_reads) disk_reads,
      ROUND(sum(disk_reads)/greatest(sum(executions),1)) disk_reads_per_exec,
      sum(rows_processed) rows_processed,
      ROUND(sum(rows_processed)/greatest(sum(executions),1)) rows_processed_per_exec,
      round(sum(elapsed_time)/1000000, 3) elapsed_seconds,
      ROUND(sum(elapsed_time)/1000000/greatest(sum(executions),1), 3) elapsed_seconds_per_exec,
      ROUND(sum(buffer_gets)*100/&&total_buffer_gets., 1) pct_total_buffer_gets,
      ROUND(sum(disk_reads)*100/&&total_disk_reads., 1) pct_total_disk_reads,
      MIN(sql_text) min_sql_text,
      rank() over (order by sum(buffer_gets) desc nulls last) AS sql_rank
   from
      &&gv_object_prefix.sql
   where
      FORCE_MATCHING_SIGNATURE <> 0 and 
      FORCE_MATCHING_SIGNATURE <> EXACT_MATCHING_SIGNATURE 
   group by
      FORCE_MATCHING_SIGNATURE
   having
      count(*) >= 30
   order by
      buffer_gets desc
  ) v1
where
   sql_rank < 101
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Top SQL by number of duplicates';
DEF main_table = '&&gv_view_prefix.SQL';
COL total_buffer_gets NEW_V total_buffer_gets;
COL total_disk_reads NEW_V total_disk_reads;
SELECT SUM(buffer_gets) total_buffer_gets, SUM(disk_reads) total_disk_reads FROM &&gv_object_prefix.sql;
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
   FORCE_MATCHING_SIGNATURE,
   duplicate_count,
   min_sql_id,
   max_sql_id,
   executions,
   buffer_gets,
   buffer_gets_per_exec,
   disk_reads,
   disk_reads_per_exec,
   rows_processed,
   rows_processed_per_exec,
   elapsed_seconds,
   elapsed_seconds_per_exec,
   pct_total_buffer_gets,
   pct_total_disk_reads,
   min_sql_text
from
  (select
      FORCE_MATCHING_SIGNATURE,
      count(*) duplicate_count,
      min(sql_id) min_sql_id,
      max(sql_id) max_sql_id,
      sum(executions) executions,
      sum(buffer_gets) buffer_gets,
      ROUND(sum(buffer_gets)/greatest(sum(executions),1)) buffer_gets_per_exec,
      sum(disk_reads) disk_reads,
      ROUND(sum(disk_reads)/greatest(sum(executions),1)) disk_reads_per_exec,
      sum(rows_processed) rows_processed,
      ROUND(sum(rows_processed)/greatest(sum(executions),1)) rows_processed_per_exec,
      round(sum(elapsed_time)/1000000, 3) elapsed_seconds,
      ROUND(sum(elapsed_time)/1000000/greatest(sum(executions),1), 3) elapsed_seconds_per_exec,
      ROUND(sum(buffer_gets)*100/&&total_buffer_gets., 1) pct_total_buffer_gets,
      ROUND(sum(disk_reads)*100/&&total_disk_reads., 1) pct_total_disk_reads,
      MIN(sql_text) min_sql_text,
      rank() over (order by count(*) desc nulls last) AS sql_rank
   from
      &&gv_object_prefix.sql
   where
      FORCE_MATCHING_SIGNATURE <> 0 and 
      FORCE_MATCHING_SIGNATURE <> EXACT_MATCHING_SIGNATURE 
   group by
      FORCE_MATCHING_SIGNATURE
   order by
      count(*) desc
  ) v1
where
   sql_rank < 101
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Active SQL (sql_id)';
DEF main_table = '&&gv_view_prefix.SQL';
BEGIN
  :sql_text := q'[
WITH /* active_sql */ 
unique_sql AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       DISTINCT sq.sql_id,
       sq.sql_text
  FROM &&gv_object_prefix.session se,
       &&gv_object_prefix.sql sq
 WHERE se.status = 'ACTIVE'
   AND sq.inst_id = se.inst_id
   AND sq.sql_id = se.sql_id
   AND sq.child_number = se.sql_child_number
   AND sq.sql_text NOT LIKE 'WITH /* active_sql */%'
)
SELECT sql_id, sql_text
  FROM unique_sql
 ORDER BY
       sql_id
]';
END;
/
--@@edb360_9a_pre_one.sql (removed for performance)

DEF title = 'Active SQL (full text)';
DEF main_table = '&&gv_view_prefix.SQL';
BEGIN
  :sql_text := q'[
SELECT /* active_sql */ 
       sq.inst_id, sq.sql_id, sq.child_number,
       sq.sql_fulltext
  FROM &&gv_object_prefix.session se,
       &&gv_object_prefix.sql sq
 WHERE se.status = 'ACTIVE'
   AND sq.inst_id = se.inst_id
   AND sq.sql_id = se.sql_id
   AND sq.child_number = se.sql_child_number
   AND sq.sql_text NOT LIKE 'SELECT /* active_sql */%'
 ORDER BY
       sq.inst_id, sq.sql_id, sq.child_number
]';
END;
/
--@@edb360_9a_pre_one.sql (removed for performance)

DEF title = 'Active SQL (detail)';
DEF main_table = '&&gv_view_prefix.SQL';
BEGIN
  :sql_text := q'[
SELECT /* active_sql */ 
       sq.*
  FROM &&gv_object_prefix.session se,
       &&gv_object_prefix.sql sq
 WHERE se.status = 'ACTIVE'
   AND sq.inst_id = se.inst_id
   AND sq.sql_id = se.sql_id
   AND sq.child_number = se.sql_child_number
   AND sq.sql_text NOT LIKE 'SELECT /* active_sql */%'
 ORDER BY
       sq.inst_id, sq.sql_id, sq.child_number
]';
END;
/
--@@edb360_9a_pre_one.sql (removed for performance)

DEF title = 'Libraries calling DBMS_STATS';
DEF main_table = '&&dva_view_prefix.SOURCE';
BEGIN
  :sql_text := q'[
WITH
lines_with_api AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ *
  FROM &&dva_object_prefix.source
 WHERE '&&edb360_conf_incl_source.' = 'Y'
   AND REPLACE(UPPER(text), ' ') LIKE '%DBMS_STATS.%'
   AND UPPER(text) NOT LIKE '%--%DBMS_STATS%'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
),
include_nearby_lines AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ DISTINCT s.*
  FROM lines_with_api l,
       &&dva_object_prefix.source s
 WHERE '&&edb360_conf_incl_source.' = 'Y'
   AND s.owner = l.owner
   AND s.name = l.name
   AND s.type = l.type
   AND s.line BETWEEN l.line - 8 AND l.line + 8
)
SELECT a.owner,
       a.name,
       a.type,
       a.line,
       CASE WHEN REPLACE(UPPER(a.text), ' ') LIKE '%DBMS_STATS.%' AND UPPER(a.text) NOT LIKE '%--%DBMS_STATS%' THEN '*' END dbms_stats,
       REPLACE(a.text, '  ', '..') text
  FROM include_nearby_lines a
 ORDER BY 1, 2, 3, 4
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Libraries doing ALTER SESSION';
DEF main_table = '&&dva_view_prefix.SOURCE';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.source
 WHERE '&&edb360_conf_incl_source.' = 'Y'
   AND UPPER(text) LIKE '%ALTER%SESSION%'
   AND UPPER(text) NOT LIKE '%--%ALTER%SESSION%'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner, name, type, line
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Libraries calling ANALYZE';
DEF main_table = '&&dva_view_prefix.SOURCE';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.source
 WHERE (REPLACE(UPPER(text), ' ') LIKE '%''ANALYZETABLE%' OR REPLACE(UPPER(text), ' ') LIKE '%''ANALYZEINDEX%')
   AND '&&edb360_conf_incl_source.' = 'Y'
   AND UPPER(text) NOT LIKE '%--%ANALYZE %'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY owner, name, type, line
]';
END;
/
-- taking long and of little use, 
-- enable only if you suspect of ANALYZE been executed by application
-- @@edb360_9a_pre_one.sql

DEF title = 'Workload Repository Control';
DEF main_table = '&&awr_hist_prefix.WR_CONTROL';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM &&awr_object_prefix.wr_control
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'ASH Info';
DEF main_table = '&&v_view_prefix.ASH_INFO';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM &&v_object_prefix.ash_info
]';
END;
/
@@&&skip_diagnostics.&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'ASH Retention ';
DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := q'[
-- from http://jhdba.wordpress.com/tag/purge-wrh-tables/
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
 sysdate - a.sample_time ash,
sysdate - s.begin_interval_time snap,
c.RETENTION
from sys.wrm$_wr_control c,
(
select db.dbid,
min(w.sample_time) sample_time
from sys.v_$database db,
sys.Wrh$_active_session_history w
where w.dbid = db.dbid group by db.dbid
) a,
(
select db.dbid,
min(r.begin_interval_time) begin_interval_time
from sys.v_$database db,
sys.wrm$_snapshot r
where r.dbid = db.dbid
group by db.dbid
) s
where a.dbid = s.dbid
and c.dbid = a.dbid
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'WRH$ Partitions ';
DEF main_table = '&&dva_view_prefix.TAB_PARTITIONS';
BEGIN
  :sql_text := q'[
-- from http://jhdba.wordpress.com/tag/purge-wrh-tables/
select table_name, count(*)
from &&dva_object_prefix.tab_partitions
where table_name like 'WRH$%'
and table_owner = 'SYS'
group by table_name
order by 1
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Segments with Next Extent at Risk';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
with 
max_free AS (
select /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
tablespace_name, max(bytes) bytes
from &&dva_object_prefix.free_space
group by tablespace_name )
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
s.owner, s.segment_name, s.partition_name, s.tablespace_name, s.next_extent, max_free.bytes max_free_bytes 
from &&dva_object_prefix.segments s, max_free
where '&&edb360_conf_incl_segments.' = 'Y'
and s.owner NOT IN &&exclusion_list.
and s.owner NOT IN &&exclusion_list2.
and s.next_extent > max_free.bytes 
and s.tablespace_name=max_free.tablespace_name
order by 1,2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Libraries Version';
DEF main_table = '&&dva_view_prefix.SOURCE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.source
 WHERE '&&edb360_conf_incl_source.' = 'Y'
   AND line < 21
   AND text LIKE '%$Header%'
 ORDER BY
       1, 2, 3, 4
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Orphaned Synonyms';
DEF main_table = '&&dva_view_prefix.SYNONYMS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       s.owner, s.table_owner, COUNT(1)
  FROM &&dva_object_prefix.synonyms s
 WHERE NOT EXISTS
       (select NULL
          from &&dva_object_prefix.objects o
         where o.object_name = s.table_name
           and o.owner = s.table_owner)
   AND s.db_link IS NULL
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.table_owner NOT IN &&exclusion_list.
   AND s.table_owner NOT IN &&exclusion_list2.
 GROUP BY s.owner, s.table_owner
 ORDER BY s.owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Last DDL by date';
DEF main_table = 'CDB_OBJECTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner, TO_CHAR(TRUNC(last_ddl_time), 'YYYY-MM-DD') last_ddl_time, COUNT(*) objects
  FROM dba_objects
 WHERE last_ddl_time >= TRUNC(SYSDATE) - 30
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 GROUP BY  owner, TRUNC(last_ddl_time)
 ORDER BY 
       2 DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Last DDL by pdb and date';
DEF main_table = 'CDB_OBJECTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       con_id, owner, TO_CHAR(TRUNC(last_ddl_time), 'YYYY-MM-DD') last_ddl_time, COUNT(*) objects
  FROM cdb_objects
 WHERE last_ddl_time >= TRUNC(SYSDATE) - 30
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 GROUP BY con_id, owner, TRUNC(last_ddl_time)
 ORDER BY 
       1, 3 DESC
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
