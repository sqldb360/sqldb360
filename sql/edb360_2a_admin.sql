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
      latch#, name, addr, inst_id,
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
DEF main_table = '&&cdb_view_prefix.OBJECTS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.objects x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.status = 'INVALID'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.object_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Disabled Constraints';
DEF main_table = '&&cdb_view_prefix.CONSTRAINTS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.constraints x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.status = 'DISABLED'
   AND NOT (x.owner = 'SYSTEM' AND x.constraint_name LIKE 'LOGMNR%')
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.constraint_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Enabled and not Validated Constraints';
DEF main_table = '&&cdb_view_prefix.CONSTRAINTS';
DEF main_table = '&&cdb_view_prefix.CONSTRAINTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.constraints x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.status = 'ENABLED'
   AND x.validated = 'NOT VALIDATED'
   AND x.constraint_type != 'O'
   AND NOT (x.owner = 'SYSTEM' AND x.constraint_name LIKE 'LOGMNR%')
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.constraint_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Non-indexed FK Constraints';
DEF main_table = '&&cdb_view_prefix.CONSTRAINTS';
COL constraint_columns FOR A200;
BEGIN
  :sql_text := q'[
-- based on "Oracle Database Transactions and Locking Revealed" book by Thomas Kyte
WITH
ref_int_constraints AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.col.con_id,
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
  FROM &&cdb_object_prefix.constraints  con,
       &&cdb_object_prefix.cons_columns col,
       &&cdb_object_prefix.constraints  par
 WHERE con.constraint_type = 'R'
   AND con.owner NOT IN &&exclusion_list.
   AND con.owner NOT IN &&exclusion_list2.
   &&skip_noncdb.AND col.con_id = con.con_id
   AND col.owner = con.owner
   AND col.constraint_name = con.constraint_name
   AND col.table_name = con.table_name
   &&skip_noncdb.AND par.con_id(+) = con.con_id
   AND par.owner(+) = con.r_owner
   AND par.constraint_name(+) = con.r_constraint_name
 GROUP BY
       &&skip_noncdb.col.con_id,
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
       &&skip_noncdb.r.con_id,
       r.owner,
       r.constraint_name,
       c.table_owner,
       c.table_name,
       c.index_owner,
       c.index_name,
       r.col_cnt
  FROM ref_int_constraints r,
       &&cdb_object_prefix.ind_columns c,
       &&cdb_object_prefix.indexes i
 WHERE c.table_owner = r.owner
   AND c.table_name = r.table_name
   &&skip_noncdb.AND c.con_id = r.con_id
   AND c.column_position <= r.col_cnt
   AND c.column_name IN (r.col_01, r.col_02, r.col_03, r.col_04, r.col_05, r.col_06, r.col_07, r.col_08,
                         r.col_09, r.col_10, r.col_11, r.col_12, r.col_13, r.col_14, r.col_15, r.col_16)
   &&skip_noncdb.AND i.con_id = c.con_id
   AND i.owner = c.index_owner
   AND i.index_name = c.index_name
   AND i.table_owner = c.table_owner
   AND i.table_name = c.table_name
   AND i.index_type != 'BITMAP'
 GROUP BY
       &&skip_noncdb.r.con_id,
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
       x.*
       &&skip_noncdb.,c.name con_name
  FROM ref_int_constraints x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE NOT EXISTS (
SELECT NULL
  FROM ref_int_indexes i
 WHERE i.owner = x.owner
   &&skip_noncdb.AND i.con_id = x.con_id
   AND i.constraint_name = x.constraint_name)
 ORDER BY
       1, 2, 3
       &&skip_noncdb., x.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unusable Indexes';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin) Expanded by Abel Macias
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       index_owner,index_name, 'SUBPARTITIONED' INDEX_TYPE ,partition_name,subpartition_name
  FROM &&cdb_object_prefix.ind_subpartitions
 WHERE status = 'UNUSABLE'
   AND index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
UNION ALL
SELECT &&skip_noncdb.con_id,
       index_owner,index_name,'PARTITIONED',partition_name,null
  FROM &&cdb_object_prefix.ind_partitions
 WHERE status = 'UNUSABLE'
   AND index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
UNION ALL
SELECT &&skip_noncdb.con_id,
       owner,index_name,index_type,null,null
  FROM &&cdb_object_prefix.indexes
 WHERE status = 'UNUSABLE'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 )
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.index_owner, x.index_name, x.partition_name nulls first, x.subpartition_name nulls first
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Invisible Indexes';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.indexes x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.visibility = 'INVISIBLE'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.index_name
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Function-based Indexes';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.indexes x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.index_type LIKE 'FUNCTION-BASED%'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Bitmap Indexes';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.indexes x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.index_type LIKE '%BITMAP'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Reversed Indexes';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.indexes x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.index_type LIKE '%REV'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Fat Indexes';
DEF main_table = '&&cdb_view_prefix.IND_COLUMNS';
BEGIN
  :sql_text := q'[
WITH
indexes_list AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       index_owner owner, /*index_name,*/ COUNT(*) columns
  FROM &&cdb_object_prefix.ind_columns
 WHERE index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.con_id,
       index_owner, index_name
), x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
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
       &&skip_noncdb.con_id,
       owner
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Columns with Histogram on Long String';
DEF main_table = '&&cdb_view_prefix.TAB_COLS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_cols x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.num_buckets BETWEEN 2 AND 253
   AND x.data_type LIKE '%CHAR%'
   AND x.char_length > 32
   AND x.avg_col_len > 6
   AND x.data_length > 32
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.table_name, x.column_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Hidden Columns';
DEF main_table = '&&cdb_view_prefix.TAB_COLS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_cols x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.hidden_column = 'YES'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name,
       x.column_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Virtual Columns';
DEF main_table = '&&cdb_view_prefix.TAB_COLS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_cols x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.virtual_column = 'YES'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name,
       x.column_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables not recently used';
DEF main_table = '&&cdb_view_prefix.TABLES';
DEF abstract = 'Be aware of false positives. List of tables not referenced in &&history_days. days.<br />';
BEGIN
  :sql_text := q'[
WITH
obj AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       object_name,
       object_id,
       last_ddl_time
  FROM &&cdb_object_prefix.objects
 WHERE object_type LIKE 'TABLE%'
   AND last_ddl_time IS NOT NULL
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
),
ash AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_noncdb.h.con_id,
       h.current_obj#,
       MAX(CAST(h.sample_time AS DATE)) sample_date
  FROM &&cdb_awr_object_prefix.active_sess_history h
 WHERE h.current_obj# > 0
   AND h.sql_plan_operation LIKE '%TABLE%'
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
 GROUP BY
       &&skip_noncdb.h.con_id,
       h.current_obj#
),
sta1 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       table_name,
       MAX(last_analyzed) last_analyzed
  FROM &&cdb_object_prefix.tab_statistics
 WHERE last_analyzed IS NOT NULL
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.con_id,
       owner,
       table_name
),
sta2 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       table_name,
       last_analyzed
  FROM &&cdb_object_prefix.tables
 WHERE last_analyzed IS NOT NULL
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
),
sta3 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       table_owner owner,
       table_name,
       MAX(timestamp) last_date
  FROM &&cdb_object_prefix.tab_modifications
 WHERE timestamp IS NOT NULL
   AND table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.con_id,
       table_owner,
       table_name
),
grp AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       object_name table_name,
       MAX(last_ddl_time) last_date
  FROM obj
 GROUP BY
       &&skip_noncdb.con_id,
       owner,
       object_name
 UNION
SELECT &&skip_noncdb.obj.con_id,
       obj.owner,
       obj.object_name table_name,
       MAX(sample_date) last_date
  FROM ash, obj
 WHERE obj.object_id = ash.current_obj#
 GROUP BY
       &&skip_noncdb.obj.con_id,
       obj.owner,
       obj.object_name
 UNION
SELECT &&skip_noncdb.con_id,
       owner,
       table_name,
       last_analyzed last_date
  FROM sta1
 UNION
SELECT &&skip_noncdb.con_id,
       owner,
       table_name,
       last_analyzed last_date
  FROM sta2
 UNION
SELECT &&skip_noncdb.con_id,
       owner,
       table_name,
       last_date
  FROM sta3
), x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       MAX(last_date) last_date,
       &&skip_noncdb.con_id,
       owner,
       table_name
  FROM grp
 GROUP BY
       &&skip_noncdb.con_id,
       owner,
       table_name
HAVING MAX(last_date) < SYSDATE - &&history_days.
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.last_date,
       &&skip_noncdb.x.con_id,
       x.owner, x.table_name
]';
END;
/
@@&&skip_ver_le_10.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Indexes not recently used';
DEF main_table = '&&cdb_view_prefix.INDEXES';
DEF abstract = 'Be aware of false positives. If using version < 12.2 turn index monitoring on for further analysis. <br /> Versions >= 12.2 use index usage tracking functionality. <br />';
BEGIN
IF '&&is_ver_ge_12_2' = 'Y' THEN
  :sql_text := q'[
    SELECT /* &&section_id..&&report_sequence. */
        di.owner,
        di.index_name,
        di.index_type,
        di.table_name,
        SUM(tm.inserts + tm.updates + tm.deletes) operations
    FROM
        &&cdb_object_prefix.indexes           di,
        &&cdb_object_prefix.tab_modifications tm
    WHERE
            di.owner in (select username from dba_users where oracle_maintained = 'N')
        AND di.table_owner NOT IN &&exclusion_list.
        AND di.table_owner NOT IN &&exclusion_list2.
        AND di.owner = tm.table_owner
        AND di.table_name = tm.table_name
        AND uniqueness = 'NONUNIQUE'
        AND NOT EXISTS (
            SELECT
                1
            FROM
                &&cdb_object_prefix.index_usage iu
            WHERE
                    iu.owner = di.owner
                AND iu.name = di.index_name
        )
    GROUP BY
        di.owner,
        di.index_name,
        di.index_type,
        di.table_name
    ORDER BY
        SUM(tm.inserts + tm.updates + tm.deletes) DESC,
        di.owner,
        di.table_name,
        di.index_name
]';
ELSE
  :sql_text := q'[
    WITH
    objects AS (
    SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
           &&skip_noncdb.con_id,
           object_id,
           owner,
           object_name
      FROM &&cdb_object_prefix.objects
     WHERE object_type LIKE 'INDEX%'
       AND owner NOT IN &&exclusion_list.
       AND owner NOT IN &&exclusion_list2.
    ),
    /*
    ash_mem AS (
    SELECT /*+ &&sq_fact_hints. * /
           DISTINCT &&skip_noncdb.con_id,
           current_obj#
      FROM &&gv_object_prefix.active_session_history
     WHERE sql_plan_operation = 'INDEX'
       AND current_obj# > 0
    ),
    */
    ash_awr AS (
    SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
           /* &&section_id..&&report_sequence. */
           DISTINCT &&skip_noncdb.h.con_id,
           h.current_obj#
      FROM &&cdb_awr_object_prefix.active_sess_history h
     WHERE h.sql_plan_operation = 'INDEX'
       AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
       AND h.dbid = &&edb360_dbid.
       AND h.current_obj# > 0
    ),
    /*
    sql_mem AS (
    SELECT /*+ &&sq_fact_hints. &&ds_hint. * /
           DISTINCT &&skip_noncdb.con_id,
           object_owner, object_name
      FROM &&gv_object_prefix.sql_plan
    WHERE operation = 'INDEX'
    ),
    */
    sql_awr AS (
    SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
           DISTINCT &&skip_noncdb.con_id,
           object_owner, object_name
      FROM &&cdb_awr_object_prefix.sql_plan
     WHERE operation = 'INDEX' AND dbid = &&edb360_dbid.
    )
    SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
           &&skip_noncdb.i.con_id,
           i.table_owner,
           i.table_name,
           i.index_name
           &&skip_noncdb.,c.name con_name
      FROM &&cdb_object_prefix.indexes i
           &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = i.con_id
     WHERE (i.index_type LIKE 'NORMAL%' OR i.index_type = 'BITMAP' OR i.index_type LIKE 'FUNCTION%')
       AND i.table_owner NOT IN &&exclusion_list.
       AND i.table_owner NOT IN &&exclusion_list2.
       --AND (i.owner, i.index_name) NOT IN ( SELECT o.owner, o.object_name FROM ash_mem a, objects o WHERE o.object_id = a.current_obj# )
       AND (&&skip_noncdb.i.con_id,
            i.owner, i.index_name) NOT IN ( SELECT &&skip_noncdb.o.con_id,
    	                                           o.owner, o.object_name
    							            FROM ash_awr a, objects o
    										WHERE o.object_id = a.current_obj#
    										&&skip_noncdb. AND o.con_id = a.con_id
    										)
       --AND (i.owner, i.index_name) NOT IN ( SELECT object_owner, object_name FROM sql_mem)
       AND (&&skip_noncdb.i.con_id,
            i.owner, i.index_name) NOT IN ( SELECT &&skip_noncdb.con_id,
    	                                           object_owner, object_name FROM sql_awr)
     ORDER BY
           &&skip_noncdb.i.con_id,
           i.table_owner,
           i.table_name,
           i.index_name
]';
END IF;
END;
/
@@&&skip_ver_le_10.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Redundant Indexes(1)';
DEF main_table = '&&cdb_view_prefix.INDEXES';
COL redundant_index FOR A200;
COL superset_index FOR A200;
BEGIN
  :sql_text := q'[
WITH i0 AS (
SELECT /*+ QB_NAME(i0) &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ *
  FROM &&cdb_object_prefix.indexes
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
   AND index_type like '%NORMAL'
),c0 AS (
SELECT /*+ QB_NAME(c0) MATERIALIZE NO_MERGE */ /* &&section_id..&&report_sequence. */ *
  FROM &&cdb_object_prefix.ind_columns 
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
 ), 
indexed_columns AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.col.con_id,
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
  FROM c0 col,
       i0 idx
 WHERE idx.table_owner = col.table_owner
   AND idx.owner = col.index_owner
   AND idx.index_name = col.index_name
   &&skip_noncdb.AND idx.con_id = col.con_id
 GROUP BY
       &&skip_noncdb.col.con_id,
       col.index_owner,
       col.index_name,
       col.table_owner,
       col.table_name,
       idx.index_type,
       idx.uniqueness
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.r.con_id,
       r.table_owner,
       r.table_name,
       r.index_type,
       r.index_name||' ('||r.indexed_columns||')' redundant_index,
       i.index_name||' ('||i.indexed_columns||')' superset_index
       &&skip_noncdb.,c.name con_name
  FROM indexed_columns r,
       indexed_columns i
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = i.con_id
 WHERE i.table_owner = r.table_owner
   &&skip_noncdb.AND i.con_id = r.con_id
   AND i.table_name = r.table_name
   AND i.index_type = r.index_type
   AND i.index_name != r.index_name
   AND i.indexed_columns LIKE r.indexed_columns||':%'
   AND r.uniqueness = 'NONUNIQUE'
 ORDER BY
       &&skip_noncdb.r.con_id,
       r.table_owner,
       r.table_name,
       r.index_name,
       i.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Redundant Indexes(2)';
DEF main_table = '&&cdb_view_prefix.INDEXES';
DEF abstract = 'Considers descending indexes (function-based), visibility of redundant indexes, and whether there are extended statistics.<br />';
BEGIN
  :sql_text := q'[
-- requested by David Kurtz
WITH i0 AS (
SELECT /*+ QB_NAME(i0) &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ *
  FROM &&cdb_object_prefix.indexes
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
   AND index_type like '%NORMAL'
), c0 AS (
SELECT /*+ QB_NAME(c0) &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ *
  FROM &&cdb_object_prefix.ind_columns 
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
 ),f AS ( /*function expressions*/
SELECT /*+ QB_NAME(f) &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner, table_name, extension, extension_name
  FROM &&cdb_object_prefix.stat_extensions
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND creator = 'SYSTEM' /*exclude extended stats*/
), ic AS ( /*list indexed columns getting expressions FROM stat_extensions*/
SELECT /*+ QB_NAME(ic) LEADING(i c) USE_HASH(i c f) &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.i.con_id,
       i.table_owner, i.table_name,
       i.owner index_owner, i.index_name,
       i.index_type, i.uniqueness, i.visibility,
       c.column_position,
       CASE WHEN f.extension IS NULL THEN c.column_name
            ELSE CAST(SUBSTR(REPLACE(SUBSTR(f.extension,2,LENGTH(f.extension)-2),'"',''),1,256) AS VARCHAR2(256))
       END column_name
  FROM i0 i
     , c0 c
       LEFT OUTER JOIN f
       ON f.owner = c.table_owner
       AND f.table_name = c.table_name
       AND f.extension_name = c.column_name
	   &&skip_noncdb.AND f.con_id = c.con_id
 WHERE i.table_owner = c.table_owner
   AND i.table_name = c.table_name
   &&skip_noncdb.AND i.con_id = c.con_id
   AND i.owner = c.index_owner
   AND i.index_name = c.index_name
), i AS ( /*construct column list*/
SELECT /*+ QB_NAME(i) &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.ic.con_id,
       ic.table_owner, ic.table_name,
       ic.index_owner, ic.index_name,
       ic.index_type, ic.uniqueness, ic.visibility,
       listagg(ic.column_name,',') within group (ORDER BY ic.column_position) AS column_list,
       '('||listagg('"'||ic.column_name||'"',',') within group (ORDER BY ic.column_position)||')' AS extension,
       count(*) num_columns
  FROM ic
GROUP BY
       &&skip_noncdb.ic.con_id,
       ic.table_owner, ic.table_name,
       ic.index_owner, ic.index_name,
       ic.index_type, ic.uniqueness, ic.visibility
), e AS ( /*extended stats*/
SELECT /*+ QB_NAME(e) &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner, table_name, CAST(SUBSTR(extension,1,256) AS VARCHAR2(256)) extension, extension_name
  FROM &&cdb_object_prefix.stat_extensions
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND creator = 'USER' /*extended stats not function based indexes*/
), cn0 as ( /*constraints*/
SELECT /*+ QB_NAME(cn0) &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ *
  FROM &&cdb_object_prefix.constraints
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND constraint_type IN('P','U')
)
SELECT /*+LEADING(i r)*/
       &&skip_noncdb.r.con_id,
       r.table_owner, r.table_name,
       i.index_name||' ('||i.column_list||')' superset_index,
       r.index_name||' ('||r.column_list||')' redundant_index,
       c.constraint_type, c.constraint_name,
       r.index_type, r.visibility, e.extension_name
       &&skip_noncdb.,c.name con_name
  FROM i r
       LEFT OUTER JOIN e
         ON  e.owner = r.table_owner
		 &&skip_noncdb.AND e.con_id = r.con_id
         AND e.table_name = r.table_name
         AND e.extension = r.extension
       LEFT OUTER JOIN cn0 c
         ON c.table_name = r.table_name
		 &&skip_noncdb.AND c.con_id = r.con_id
         AND c.index_owner = r.index_owner
         AND c.index_name = r.index_name
         AND c.owner = r.table_owner
     , i
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = i.con_id
 WHERE i.table_owner = r.table_owner
   &&skip_noncdb.AND i.con_id = r.con_id
   AND i.table_name = r.table_name
   AND i.index_name != r.index_name 
   AND i.column_list LIKE r.column_list||',%'
   AND i.num_columns > r.num_columns
   AND i.num_columns >=2 /*must have at least 2 columns*/
 ORDER BY &&skip_noncdb.r.con_id,
          r.table_owner, r.table_name, r.index_name, i.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with more than 5 Indexes';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       COUNT(*) indexes,
       &&skip_noncdb.con_id,
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
       &&skip_ver_le_10.SUM(CASE WHEN visibility LIKE 'VISIBLE%' THEN 1 ELSE 0 END) visible,
       &&skip_ver_le_10.SUM(CASE WHEN visibility LIKE 'INVISIBLE%' THEN 1 ELSE 0 END) invisible,
       SUM(CASE WHEN status LIKE 'UNUSABLE%' THEN 1 ELSE 0 END) unusable
  FROM &&cdb_object_prefix.indexes
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.con_id,
       table_owner,
       table_name
HAVING COUNT(*) > 5
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.indexes DESC,
       &&skip_noncdb.x.con_id,
       x.table_owner, x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables on KEEP Buffer Pool';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name,
       x.num_rows,
       x.blocks
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND x.buffer_pool = 'KEEP'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables on RECYCLE Buffer Pool';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name,
       x.num_rows,
       x.blocks
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND x.buffer_pool = 'RECYCLE'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name
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
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name,
       x.num_rows,
       x.blocks
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND TRIM(x.cache) = 'Y'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables on KEEP Flash Cache';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name,
       x.num_rows,
       x.blocks
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND x.flash_cache = 'KEEP'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name
]';
END;
/
@@&&skip_ver_le_11_1.edb360_9a_pre_one.sql

DEF title = 'Tables on KEEP Cell Flash Cache';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name,
       x.num_rows,
       x.blocks
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND x.cell_flash_cache = 'KEEP'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name
]';
END;
/
@@&&skip_ver_le_11_1.edb360_9a_pre_one.sql

DEF title = 'Tables set for Compression';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name,
       x.compress_for,
       x.num_rows,
       x.blocks
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND x.compression = 'ENABLED'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name
]';
END;
/
@@&&skip_ver_le_11_1.edb360_9a_pre_one.sql

DEF title = 'Partitions set for Compression';
DEF main_table = '&&cdb_view_prefix.TAB_PARTITIONS';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       table_owner,
       table_name,
       compress_for,
       COUNT(*),
       MIN(partition_position) min_part_pos,
       MAX(partition_position) max_part_pos
  FROM &&cdb_object_prefix.tab_partitions x
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
   AND compression = 'ENABLED'
 GROUP BY
       &&skip_noncdb.con_id,
       table_owner,
       table_name,
       compress_for
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.table_owner,
       x.table_name,
       x.compress_for
]';
END;
/
@@&&skip_ver_le_11_1.edb360_9a_pre_one.sql

REM DMK 25.6.2018
DEF title = 'Unindexed Partition Key Columns';
DEF main_table = '&&cdb_view_prefix.PART_KEY_COLUMNS';
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
WITH k as (
SELECT k.*, 'Partition' part_level
FROM   &&cdb_object_prefix.part_key_columns k
union all
SELECT k.*, 'Subpartition'
FROM   &&cdb_object_prefix.subpart_key_columns k
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.i.con_id,
       i.table_owner, i.table_name
,      i.owner index_owner
,      i.index_name
,      i.index_type
,      'Partition' part_level
,      pi.locality
,      pi.partitioning_type
,      pi.partition_count
,      k.column_position part_column_position
,      k.column_name part_column_name
,	  (SELECT LISTAGG(NVL(ie.extension,ic.column_name),',') WITHIN GROUP (ORDER BY ic.column_position)
       FROM	  &&cdb_object_prefix.ind_columns ic
       LEFT OUTER JOIN &&cdb_object_prefix.stat_extensions ie
       ON    ie.owner = ic.table_owner
       &&skip_noncdb.AND  ie.con_id = ic.con_id
       AND   ie.table_name = ic.table_name
       AND   ie.extension_name = ic.column_name
       WHERE i.owner = ic.index_owner
       &&skip_noncdb.AND   i.con_id = ic.con_id
       AND 	 i.index_name = ic.index_name
       AND	 i.table_owner = ic.table_owner
       AND	 i.table_name = ic.table_name
       ) column_list
       &&skip_noncdb.,c.name con_name
FROM   &&cdb_object_prefix.indexes i
,      &&cdb_object_prefix.part_indexes pi
,      k
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = k.con_id
WHERE  i.table_owner NOT IN &&exclusion_list.
AND    i.table_owner NOT IN &&exclusion_list2.
AND    i.index_type NOT IN('LOB')
&&skip_noncdb.AND    k.con_id = i.con_id
AND    k.owner = i.owner
AND    k.name = i.index_name
AND    k.object_type = 'INDEX'
AND    i.partitioned = 'YES'
&&skip_noncdb.AND    pi.con_id = i.con_id
AND    pi.owner = i.owner
AND    pi.index_name = i.index_name
AND    pi.table_name = i.table_name
AND    not exists (
	SELECT  'x'
	FROM 	&&cdb_object_prefix.ind_columns ic
	WHERE	ic.index_owner = i.owner
	&&skip_noncdb.AND     ic.con_id      = i.con_id
	AND 	ic.index_name  = i.index_name
	AND     ic.table_owner = i.table_owner
	AND     ic.table_name  = i.table_name
	AND     ic.column_name = k.column_name)
ORDER BY
       &&skip_noncdb.i.con_id,
       i.table_owner, i.table_name
,      i.owner
,      i.index_name
,      i.index_type
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
DEF main_table = '&&cdb_view_prefix.TAB_SUBPARTITIONS';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       table_owner,
       table_name,
       compress_for,
       COUNT(*),
       MIN(subpartition_position) min_part_pos,
       MAX(subpartition_position) max_part_pos
  FROM &&cdb_object_prefix.tab_subpartitions
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
   AND compression = 'ENABLED'
 GROUP BY
       &&skip_noncdb.con_id,
       table_owner,
       table_name,
       compress_for
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.table_owner,
       x.table_name,
       x.compress_for
]';
END;
/
@@&&skip_ver_le_11_1.edb360_9a_pre_one.sql

DEF title = 'Segments with non-default Buffer Pool';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.buffer_pool, x.owner, x.segment_name, x.partition_name, x.segment_type, x.blocks
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.segments x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND TRIM(x.buffer_pool) != 'DEFAULT'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.buffer_pool,
       x.owner,
       x.segment_name,
       x.partition_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Segments with non-default Flash Cache';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.flash_cache, x.owner, x.segment_name, x.partition_name, x.segment_type, x.blocks
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.segments x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND TRIM(x.flash_cache) != 'DEFAULT'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.flash_cache,
       x.owner,
       x.segment_name,
       x.partition_name
]';
END;
/
@@&&skip_ver_le_11_1.edb360_9a_pre_one.sql

DEF title = 'Segments with non-default Cell Flash Cache';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.cell_flash_cache, x.owner, x.segment_name, x.partition_name, x.segment_type, x.blocks
         &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.segments x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND TRIM(x.cell_flash_cache) != 'DEFAULT'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.cell_flash_cache,
       x.owner,
       x.segment_name,
       x.partition_name
]';
END;
/
@@&&skip_ver_le_11_1.edb360_9a_pre_one.sql

DEF title = 'Degree of Parallelism DOP on Tables';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
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
  FROM &&cdb_object_prefix.tables x
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
HAVING COUNT(*) > SUM(CASE WHEN TRIM(degree) IN ('0', '1') THEN 1 ELSE 0 END)
 GROUP BY
       &&skip_noncdb.con_id,
       owner
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with DOP Set';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.degree,
       x.owner,
       x.table_name,
       x.blocks,
       x.partitioned
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND TRIM(x.degree) NOT IN ('0', '1')
 ORDER BY
       LENGTH(TRIM(x.degree)) DESC,
       x.degree DESC,
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Degree of Parallelism DOP on Indexes';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
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
  FROM &&cdb_object_prefix.indexes
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND index_type != 'LOB'
 GROUP BY
       &&skip_noncdb.con_id,
       owner
HAVING COUNT(*) > SUM(CASE WHEN TRIM(degree) IN ('0', '1') THEN 1 ELSE 0 END)
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Indexes with DOP Set';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.degree,
       &&skip_noncdb.x.con_id,
       x.owner,
       x.index_name,
       x.leaf_blocks,
       x.partitioned
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.indexes x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND x.index_type != 'LOB'
   AND TRIM(x.degree) NOT IN ('0', '1')
 ORDER BY
       LENGTH(TRIM(x.degree)) DESC,
       x.degree DESC,
       &&skip_noncdb.x.con_id,
       x.owner,
       x.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unused Columns';
DEF main_table = '&&cdb_view_prefix.UNUSED_COL_TABS';
BEGIN
  :sql_text := q'[
-- requested by Mike Moehlman
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.unused_col_tabs x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Columns with multiple Data Types';
DEF main_table = '&&cdb_view_prefix.TAB_COLUMNS';
BEGIN
  :sql_text := q'[
WITH
tables AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.t.con_id,
       t.owner,
       t.table_name
  FROM &&cdb_object_prefix.tables t
 WHERE t.owner NOT IN &&exclusion_list.
   AND t.owner NOT IN &&exclusion_list2.
   AND t.table_name NOT LIKE 'BIN%'
), columns AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.c.con_id,
       c.owner,
       c.table_name,
       c.column_name,
       c.data_type
  FROM &&cdb_object_prefix.tab_columns c
 WHERE c.owner NOT IN &&exclusion_list.
   AND c.owner NOT IN &&exclusion_list2.
   AND c.data_type != 'UNDEFINED'
   AND c.table_name NOT LIKE 'BIN%'
   AND c.data_type != 'UNDEFINED'
), table_columns AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.c.con_id,
       c.column_name, COUNT(*) typ_cnt, c.data_type,
       MIN(c.owner||'.'||c.table_name) min_table_name,
       MAX(c.owner||'.'||c.table_name) max_table_name
  FROM columns c,
       tables t
 WHERE t.owner = c.owner -- this to filter out views
   &&skip_noncdb.AND t.con_id = c.con_id
   AND t.table_name = c.table_name -- this to filter out views
 GROUP BY
       &&skip_noncdb.c.con_id,
       c.column_name, c.data_type
), more_than_one_type AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       column_name, SUM(typ_cnt) col_cnt
  FROM table_columns
 GROUP BY
       &&skip_noncdb.con_id,
       column_name
HAVING COUNT(*) > 1
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       m.col_cnt, x.*
       &&skip_noncdb.,c.name con_name
  FROM table_columns x,
       more_than_one_type m
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = m.con_id
 WHERE m.column_name = x.column_name
       &&skip_noncdb.AND m.con_id = x.con_id
 ORDER BY
       m.col_cnt DESC,
       &&skip_noncdb.m.con_id,
       x.column_name,
       x.typ_cnt DESC,
       x.data_type
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Jobs';
DEF main_table = '&&cdb_view_prefix.JOBS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.jobs x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.job
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Jobs Running';
DEF main_table = '&&cdb_view_prefix.JOBS_RUNNING';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.jobs_running x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.job
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Jobs';
DEF main_table = '&&cdb_view_prefix.SCHEDULER_JOBS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.scheduler_jobs x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.job_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Job Log for past 7 days';
DEF main_table = '&&cdb_view_prefix.SCHEDULER_JOB_LOG';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.scheduler_job_log x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.log_date > SYSDATE - 7
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.log_id DESC,
       x.log_date DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Windows';
DEF main_table = '&&cdb_view_prefix.SCHEDULER_WINDOWS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.scheduler_windows x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.window_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Scheduler Window Group Members';
DEF main_table = '&&cdb_view_prefix.SCHEDULER_WINGROUP_MEMBERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.scheduler_wingroup_members x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.window_group_name, x.window_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Advisor Parameters';
DEF main_table = '&&cdb_view_prefix.ADVISOR_PARAMETERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.advisor_parameters x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.task_id
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Advisor Execution Types';
DEF main_table = '&&cdb_view_prefix.ADVISOR_EXECUTION_TYPES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.advisor_execution_types x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY
       &&skip_noncdb.x.con_id,
       x.advisor_name, x.execution_type
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Advisor Tasks';
DEF main_table = '&&cdb_view_prefix.ADVISOR_TASKS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.advisor_tasks x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.task_id
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Advisor Executions';
DEF main_table = '&&cdb_view_prefix.ADVISOR_EXECUTIONS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.advisor_executions x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.task_id
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Tasks';
DEF main_table = '&&cdb_view_prefix.AUTOTASK_CLIENT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.autotask_client x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.client_name
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Task Tasks';
DEF main_table = '&&cdb_view_prefix.AUTOTASK_TASK';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.autotask_task x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.client_name
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Automated Maintenance Tasks History';
DEF main_table = '&&cdb_view_prefix.AUTOTASK_CLIENT_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.autotask_client_history x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.window_start_time DESC
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Auto Task Job History';
DEF main_table = '&&cdb_view_prefix.AUTOTASK_JOB_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.autotask_job_history x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.window_start_time DESC
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Current Blocking Activity';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       a.inst_id, a.sid, a.sql_id sql_id_a, a.state, a.blocking_session, b.sql_id sql_id_b, b.prev_sql_id,
       a.blocking_session_status, a.seconds_in_wait
	   &&skip_noncdb.,a.con_id
	   &&skip_noncdb.,c.name con_name
  FROM &&gv_object_prefix.session a
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = a.con_id
     , &&gv_object_prefix.session b
 WHERE a.blocking_session is not null
   AND a.blocking_session = b.sid
   AND a.blocking_instance = b.inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sequences';
DEF main_table = '&&cdb_view_prefix.SEQUENCES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.*,
       ROUND(100 * (s.last_number - s.min_value) / GREATEST((s.max_value - s.min_value), 1), 1) percent_used /* requested by Mike Moehlman */
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.sequences s
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
 WHERE s.sequence_owner not in &&exclusion_list.
   AND s.sequence_owner not in &&exclusion_list2.
   AND s.max_value > 0
ORDER BY
       &&skip_noncdb.s.con_id,
       s.sequence_owner, s.sequence_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sequences used over 20%';
DEF main_table = '&&cdb_view_prefix.SEQUENCES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       ROUND(100 * (s.last_number - s.min_value) / GREATEST((s.max_value - s.min_value), 1), 1) percent_used, /* requested by Mike Moehlman */
       s.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.sequences s
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
 WHERE s.sequence_owner not in &&exclusion_list.
   AND s.sequence_owner not in &&exclusion_list2.
   AND s.max_value > 0
   AND ROUND(100 * (s.last_number - s.min_value) / GREATEST((s.max_value - s.min_value), 1), 1) > 20
ORDER BY
       ROUND(100 * (s.last_number - s.min_value) / GREATEST((s.max_value - s.min_value), 1), 1) DESC, /* requested by Mike Moehlman */
       &&skip_noncdb.s.con_id,
s.sequence_owner, s.sequence_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sequences prone to contention';
DEF main_table = '&&cdb_view_prefix.SEQUENCES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       (s.last_number - CASE WHEN s.increment_by > 0 THEN s.min_value ELSE s.max_value END) / s.increment_by times_used,
       s.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.sequences s
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
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
DEF main_table = '&&cdb_view_prefix.TAB_COLUMNS';
DEF abstract = 'Tables with more than 255 Columns are subject to intra-block chained rows. Continuation pieces could be stored on other blocks, even on different storage units. See MOS 9373758 AND 18940497<br />';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       MAX(c.column_id) columns, 
       &&skip_noncdb.c.con_id,
       c.owner,
       c.table_name,
       t.avg_row_len
  FROM &&cdb_object_prefix.tab_columns c,
       &&cdb_object_prefix.tables t
 WHERE t.owner NOT IN &&exclusion_list.
   AND t.owner NOT IN &&exclusion_list2.
   AND t.table_name NOT LIKE 'BIN%'
   &&skip_noncdb.AND t.con_id = c.con_id
   AND t.owner = c.owner
   AND t.table_name = c.table_name
   AND c.column_id > 255
   AND NOT EXISTS
       (SELECT NULL
        FROM &&cdb_object_prefix.views v
        WHERE v.owner = t.owner
        &&skip_noncdb.AND   v.con_id = t.con_id
		AND   v.view_name = t.table_name)
 GROUP BY
       &&skip_noncdb.c.con_id,
       c.owner, c.table_name, t.avg_row_len
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.columns DESC,
       &&skip_noncdb.x.con_id,
       x.owner,
       x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL using Literals or many children (by COUNT)';
DEF main_table = '&&gv_view_prefix.SQL';

COL force_matching_signature FOR 99999999999999999999 HEA "Force|Matching|Signature";
COL sql_text format a100
BEGIN
  :sql_text := q'[
WITH
lit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       force_matching_signature, COUNT(*) cnt, MIN(sql_id) min_sql_id, MAX(sql_id) max_sql_id
  FROM &&gv_object_prefix.sql
 WHERE force_matching_signature > 0
   AND UPPER(sql_text) NOT LIKE '%EDB360%'
 GROUP BY
       &&skip_noncdb.con_id,
       force_matching_signature
HAVING COUNT(*) > 99
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       DISTINCT lit.cnt, s.force_matching_signature,
       &&skip_noncdb.s.con_id,
       s.parsing_schema_name owner,
       CASE WHEN o.object_name IS NOT NULL THEN o.object_name||'('||s.program_line#||')' END source,
       lit.min_sql_id,
       lit.max_sql_id,
       s.sql_text
	   &&skip_noncdb.,c.name con_name
  FROM lit
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = lit.con_id
      ,&&gv_object_prefix.sql s
       LEFT OUTER JOIN &&cdb_object_prefix.objects o
                    ON o.object_id = s.program_id
                    &&skip_noncdb.AND o.con_id = s.con_id
 WHERE s.force_matching_signature = lit.force_matching_signature
   AND s.sql_id = lit.min_sql_id
   &&skip_noncdb.AND s.con_id = lit.con_id
 ORDER BY
       lit.cnt DESC,
	   &&skip_noncdb.s.con_id,
	   s.force_matching_signature
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL using Literals or many children (by OWNER)';
DEF main_table = '&&gv_view_prefix.SQL';

BEGIN
  :sql_text := q'[
WITH
lit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       force_matching_signature, COUNT(*) cnt, MIN(sql_id) min_sql_id, MAX(sql_id) max_sql_id
  FROM &&gv_object_prefix.sql
 WHERE force_matching_signature > 0
   AND UPPER(sql_text) NOT LIKE '%EDB360%'
 GROUP BY
       &&skip_noncdb.con_id,
       force_matching_signature
HAVING COUNT(*) > 99
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       DISTINCT &&skip_noncdb.s.con_id,
       s.parsing_schema_name owner, lit.cnt, s.force_matching_signature,
       CASE WHEN o.object_name IS NOT NULL THEN o.object_name||'('||s.program_line#||')' END source,
       lit.min_sql_id,
       lit.max_sql_id,
       s.sql_text
	   &&skip_noncdb.,c.name con_name
  FROM lit,
       &&gv_object_prefix.sql s
	   &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
	   LEFT OUTER JOIN &&cdb_object_prefix.objects o
	                ON o.object_id = s.program_id
	                &&skip_noncdb.AND o.con_id = s.con_id
 WHERE s.force_matching_signature = lit.force_matching_signature
   AND s.sql_id = lit.min_sql_id
   &&skip_noncdb.AND s.con_id = lit.con_id
 ORDER BY
       &&skip_noncdb.s.con_id,
       s.parsing_schema_name, lit.cnt DESC, s.force_matching_signature
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL consuming over 10GB of TEMP space';
DEF main_table = '&&cdb_awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_noncdb.h.con_id,
       h.sql_id,
       ROUND(MAX(h.temp_space_allocated)/POWER(10,9),1) max_temp_space_gb,
       DBMS_LOB.SUBSTR(s.sql_text, 1000) sql_text
  FROM &&cdb_awr_object_prefix.active_sess_history h,
       &&cdb_awr_object_prefix.sqltext s
 WHERE h.temp_space_allocated > 10*POWER(10,9)
   AND h.sql_id IS NOT NULL
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   &&skip_noncdb.AND s.con_id(+) = h.con_id
   AND s.sql_id(+) = h.sql_id
   AND s.dbid(+) = &&edb360_dbid.
   &&skip_noncdb.AND s.con_id(+) = h.con_id
 GROUP BY
       &&skip_noncdb.h.con_id,
       h.sql_id,
       DBMS_LOB.SUBSTR(s.sql_text, 1000)
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.max_temp_space_gb DESC,
       &&skip_noncdb.x.con_id,
       x.sql_id
]';
END;
/
@@&&skip_ver_le_11_1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'SQL with over 2GB of PGA allocated memory';
DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF abstract = '&&abstract_uom.';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_noncdb.h.con_id,
       h.sql_id,
       ROUND(MAX(h.pga_allocated)/POWER(2,30),1) max_pga_gb,
       DBMS_LOB.SUBSTR(s.sql_text, 1000) sql_text
  FROM &&cdb_awr_object_prefix.active_sess_history h,
       &&cdb_awr_object_prefix.sqltext s
 WHERE h.pga_allocated > 2*POWER(2,30)
   AND h.sql_id IS NOT NULL
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.sql_id(+) = h.sql_id
   AND s.dbid(+) = &&edb360_dbid.
   &&skip_noncdb.AND s.con_id(+) = h.con_id
 GROUP BY
       &&skip_noncdb.h.con_id,
       h.sql_id,
       DBMS_LOB.SUBSTR(s.sql_text, 1000)
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.max_pga_gb DESC, x.sql_id
]';
END;
/
@@&&skip_ver_le_11_1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Opened Cursors Current - Count per Session';
DEF main_table = '&&gv_view_prefix.SESSTAT';
DEF abstract = 'Open cursors for each session<br />';
BEGIN
  :sql_text := q'[
-- from http://www.orafaq.com/node/758
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       TO_NUMBER(a.value) opened_cursors_current,
	   &&skip_noncdb.a.con_id,
	   a.inst_id,
       s.sid, s.serial#,
	   s.username, s.machine, s.program, s.module, s.action
	   &&skip_noncdb.,c.name con_name
  FROM &&gv_object_prefix.sesstat a, &&gv_object_prefix.statname b, &&gv_object_prefix.session s
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
 WHERE a.statistic# = b.statistic#
   AND a.inst_id = b.inst_id
   AND s.sid=a.sid
   AND s.inst_id = a.inst_id
   AND b.name = 'opened cursors current'
   AND TO_NUMBER(a.value) < 1.844E+19 -- bug
   AND TO_NUMBER(a.value) > 0
ORDER BY 1 desc, 2, 3, 4
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Cached Cursors Count per Session';
DEF main_table = '&&gv_view_prefix.OPEN_CURSOR';
DEF abstract = 'Cursors in the "session cursor cache" for each session<br />';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       COUNT(*) cached_cursors,
	   &&skip_noncdb.con_id,
	   inst_id, sid, user_name
  FROM &&gv_object_prefix.open_cursor
 GROUP BY
       &&skip_noncdb.con_id,
       inst_id, sid, user_name
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       1 DESC, 2, 3, 4
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Cached Cursors Count per SQL_ID';
DEF main_table = '&&gv_view_prefix.OPEN_CURSOR';
DEF abstract = 'SQL statements with more than 50 cached cursors in the "session cursor cache".<br />';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       COUNT(*) cached_cursors, COUNT(DISTINCT inst_id||'.'||sid) sessions,
	   &&skip_noncdb.con_id,
	   sql_id, hash_value, sql_text, cursor_type,
       MIN(user_name) min_user_name, MAX(user_name) max_user_name, MAX(last_sql_active_time) last_sql_active_time
  FROM &&gv_object_prefix.open_cursor
 GROUP BY
       &&skip_noncdb.con_id,
       sql_id, hash_value, sql_text, cursor_type
HAVING COUNT(*) >= 50
   AND COUNT(*) > COUNT(DISTINCT inst_id||'.'||sid)
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.sessions DESC,
	   &&skip_noncdb.x.con_id,
	   x.sql_id
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Cached Cursors List per Session';
DEF main_table = '&&gv_view_prefix.OPEN_CURSOR';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&gv_object_prefix.open_cursor x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.inst_id, x.sid, x.sql_id
       &&skip_ver_le_10., x.sql_exec_id
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

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
       &&skip_noncdb.c.con_id,
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
   &&skip_noncdb.AND p.con_id = c.con_id
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.session_cache_misses,
       x.session_cache_hits,
       x.total_parse_count,
       &&skip_noncdb.x.con_id,
       x.inst_id,
       x.sid,
       s.serial#,
       s.username,
       s.machine,
       s.program,
       s.module,
       s.action
	   &&skip_noncdb.,c.name con_name
  FROM session_cache x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
      ,&&gv_object_prefix.session s
 WHERE x.session_cache_misses > 0
   AND s.inst_id = x.inst_id
   AND s.sid = x.sid
 ORDER BY
       x.session_cache_misses DESC,
       x.session_cache_hits, x.total_parse_count
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'High Cursor Count';
DEF main_table = '&&gv_view_prefix.SQL';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.v1.con_id,
       v1.sql_id,
       COUNT(*) child_cursors,
       MIN(inst_id) min_inst_id,
       MAX(inst_id) max_inst_id,
       MIN(child_number) min_child,
       MAX(child_number) max_child,
       v1.sql_text
  FROM &&gv_object_prefix.sql v1
 GROUP BY
       &&skip_noncdb.v1.con_id,
       v1.sql_id,
       v1.sql_text
HAVING COUNT(*) > 99
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       child_cursors DESC,
       &&skip_noncdb.x.con_id,
	   x.sql_id
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
       &&skip_noncdb.con_id,
       sql_id, COUNT(*) child_cursors,
       RANK() OVER (ORDER BY COUNT(*) DESC NULLS LAST) AS sql_rank
  FROM &&gv_object_prefix.sql_shared_cursor
 GROUP BY
       &&skip_noncdb.con_id,
       sql_id
HAVING COUNT(*) > 99
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       DISTINCT
       ns.sql_rank,
       ns.child_cursors,
       ns.sql_id,
       s.sql_text
	   &&skip_noncdb.,c.name con_name
  FROM not_shared ns
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = ns.con_id
       LEFT OUTER JOIN &&gv_object_prefix.sql s ON s.sql_id = ns.sql_id
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
   &&skip_noncdb.v1.con_id,
   v1.FORCE_MATCHING_SIGNATURE,
   v1.duplicate_count cnt,
   v1.min_sql_id,
   v1.max_sql_id,
   v1.distinct_phv phv_cnt,
   v1.executions,
   v1.buffer_gets,
   v1.buffer_gets_per_exec,
   v1.disk_reads,
   v1.disk_reads_per_exec,
   v1.rows_processed,
   v1.rows_processed_per_exec,
   v1.elapsed_seconds,
   v1.elapsed_seconds_per_exec,
   v1.pct_total_buffer_gets,
   v1.pct_total_disk_reads,
   v1.min_sql_text
   &&skip_noncdb.,c.name con_name
from
  (SELECT
      &&skip_noncdb.con_id,
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
      rank() over (ORDER BY sum(buffer_gets) desc nulls last) AS sql_rank
   from
      &&gv_object_prefix.sql
   WHERE
      FORCE_MATCHING_SIGNATURE <> 0 AND
      FORCE_MATCHING_SIGNATURE <> EXACT_MATCHING_SIGNATURE
   group by
      &&skip_noncdb.con_id,
      FORCE_MATCHING_SIGNATURE
   having
      count(*) >= 30
   ORDER BY
      buffer_gets desc
  ) v1
  &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = v1.con_id
WHERE
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
   &&skip_noncdb.,c.name con_name
from
  (SELECT
      &&skip_noncdb.con_id,
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
      rank() over (ORDER BY count(*) desc nulls last) AS sql_rank
   from
      &&gv_object_prefix.sql
   WHERE
      FORCE_MATCHING_SIGNATURE <> 0 AND
      FORCE_MATCHING_SIGNATURE <> EXACT_MATCHING_SIGNATURE
   group by
      &&skip_noncdb.con_id,
	  FORCE_MATCHING_SIGNATURE
   ORDER BY
      count(*) desc
  ) v1
  &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = v1.con_id
WHERE
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
       DISTINCT &&skip_noncdb.sql.con_id,
	   sq.sql_id,
       sq.sql_text
  FROM &&gv_object_prefix.session se,
       &&gv_object_prefix.sql sq
 WHERE se.status = 'ACTIVE'
   AND sq.inst_id = se.inst_id
   AND sq.sql_id = se.sql_id
   AND sq.child_number = se.sql_child_number
   AND sq.sql_text NOT LIKE 'WITH /* active_sql */%'
)
SELECT &&skip_noncdb.con_id,
       x.sql_id, x.sql_text
	   &&skip_noncdb.,c.name con_name
  FROM unique_sql x
 ORDER BY
       &&skip_noncdb.con_id,
	   x.sql_id
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
DEF main_table = '&&cdb_view_prefix.SOURCE';
BEGIN
  :sql_text := q'[
WITH
lines_with_api AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ *
  FROM &&cdb_object_prefix.source
 WHERE '&&edb360_conf_incl_source.' = 'Y'
   AND REPLACE(UPPER(text), ' ') LIKE '%DBMS_STATS.%'
   AND UPPER(text) NOT LIKE '%--%DBMS_STATS%'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
),
include_nearby_lines AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ DISTINCT s.*
  FROM lines_with_api l,
       &&cdb_object_prefix.source s
 WHERE '&&edb360_conf_incl_source.' = 'Y'
   &&skip_noncdb.AND s.con_id = l.con_id
   AND s.owner = l.owner
   AND s.name = l.name
   AND s.type = l.type
   AND s.line BETWEEN l.line - 8 AND l.line + 8
)
SELECT
       &&skip_noncdb.a.con_id,
       a.owner,
       a.name,
       a.type,
       a.line,
       CASE WHEN REPLACE(UPPER(a.text), ' ') LIKE '%DBMS_STATS.%' AND UPPER(a.text) NOT LIKE '%--%DBMS_STATS%' THEN '*' END dbms_stats,
       REPLACE(a.text, '  ', '..') text
       &&skip_noncdb.,c.name con_name
  FROM include_nearby_lines a
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = a.con_id
 ORDER BY
       &&skip_noncdb.a.con_id,
       a.owner,
       a.name,
       a.type,
       a.line
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Libraries doing ALTER SESSION';
DEF main_table = '&&cdb_view_prefix.SOURCE';
BEGIN
  :sql_text := q'[
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.source x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE '&&edb360_conf_incl_source.' = 'Y'
   AND UPPER(x.text) LIKE '%ALTER%SESSION%'
   AND UPPER(x.text) NOT LIKE '%--%ALTER%SESSION%'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.name, x.type, x.line
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Libraries calling ANALYZE';
DEF main_table = '&&cdb_view_prefix.SOURCE';
BEGIN
  :sql_text := q'[
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.source x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE (REPLACE(UPPER(x.text), ' ') LIKE '%''ANALYZETABLE%' OR REPLACE(UPPER(x.text), ' ') LIKE '%''ANALYZEINDEX%')
   AND '&&edb360_conf_incl_source.' = 'Y'
   AND UPPER(x.text) NOT LIKE '%--%ANALYZE %'
   AND x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.name, x.type, x.line
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
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&awr_object_prefix.wr_control x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
&&skip_noncdb.ORDER BY x.con_id
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'ASH Info';
DEF main_table = '&&gv_view_prefix.ASH_INFO';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.ash_info
]';
END;
/
@@&&skip_ver_le_10.&&skip_diagnostics.edb360_9a_pre_one.sql

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
SELECT db.dbid,
min(w.sample_time) sample_time
from sys.v_$database db,
sys.Wrh$_active_session_history w
WHERE w.dbid = db.dbid group by db.dbid
) a,
(
SELECT db.dbid,
min(r.begin_interval_time) begin_interval_time
from sys.v_$database db,
sys.wrm$_snapshot r
WHERE r.dbid = db.dbid
group by db.dbid
) s
WHERE a.dbid = s.dbid
AND c.dbid = a.dbid
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'WRH$ Partitions ';
DEF main_table = '&&cdb_view_prefix.TAB_PARTITIONS';
BEGIN
  :sql_text := q'[
-- from http://jhdba.wordpress.com/tag/purge-wrh-tables/
WITH x AS (
SELECT &&skip_noncdb.con_id,
       table_name, count(*)
  FROM &&cdb_object_prefix.tab_partitions
 WHERE table_name like 'WRH$%'
   AND table_owner = 'SYS'
group by
       &&skip_noncdb.con_id,
       table_name
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Segments with Next Extent at Risk';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
with
max_free AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       tablespace_name, max(bytes) bytes
  FROM &&cdb_object_prefix.free_space
group by
       &&skip_noncdb.con_id,
       tablespace_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
       s.owner, s.segment_name, s.partition_name, s.tablespace_name, s.next_extent, max_free.bytes max_free_bytes
  FROM &&cdb_object_prefix.segments s
     , max_free
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.next_extent > max_free.bytes
   &&skip_noncdb.AND s.con_id = max_free.con_id
   AND s.tablespace_name=max_free.tablespace_name
ORDER BY
       &&skip_noncdb.s.con_id,
       s.owner, s.segment_name, s.partition_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Libraries Version';
DEF main_table = '&&cdb_view_prefix.SOURCE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.source x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE '&&edb360_conf_incl_source.' = 'Y'
   AND x.line < 21
   AND x.text LIKE '%$Header%'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.name, x.type, x.line
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Orphaned Synonyms';
DEF main_table = '&&cdb_view_prefix.SYNONYMS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
       s.owner, s.table_owner, COUNT(1) counter
  FROM &&cdb_object_prefix.synonyms s
 WHERE NOT EXISTS
       (SELECT NULL
          FROM &&cdb_object_prefix.objects o
         WHERE o.object_name = s.table_name
	       &&skip_noncdb.AND o.con_id = s.con_id
           AND o.owner = s.table_owner)
   AND s.db_link IS NULL
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.table_owner NOT IN &&exclusion_list.
   AND s.table_owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.s.con_id,
       s.owner, s.table_owner
)
 SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY
       x.counter DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Last DDL by date';
DEF main_table = '&&cdb_view_prefix.OBJECTS';
BEGIN
  :sql_text := q'[
WITH x aS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner, TO_CHAR(TRUNC(last_ddl_time), 'YYYY-MM-DD') last_ddl_time, COUNT(*) objects
  FROM &&cdb_object_prefix.objects
 WHERE last_ddl_time >= TRUNC(SYSDATE) - 30
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.con_id,
       owner, TRUNC(last_ddl_time)
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       last_ddl_time DESC
       &&skip_noncdb.,x.con_id
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
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
COL force_matching_signature clear
COL sql_text clear
