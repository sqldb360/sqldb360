@@&&edb360_0g.tkprof.sql
DEF section_id = '3c';
DEF section_name = 'Cost-based Optimizer (CBO) Statistics';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'CBO System Statistics';
DEF main_table = 'SYS.AUX_STATS$';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM sys.aux_stats$
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'CBO System Statistics History';
DEF main_table = 'SYS.WRI$_OPTSTAT_AUX_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM sys.wri$_optstat_aux_history
 ORDER BY 1 DESC, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Stats History Availability';
DEF main_table = 'DBMS_STATS';
BEGIN
  :sql_text := q'[
SELECT DBMS_STATS.get_stats_history_availability availability,
       DBMS_STATS.get_stats_history_retention retention
  FROM dual
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Default Values for DBMS_STATS';
DEF main_table = 'SYS.OPTSTAT_HIST_CONTROL$';
BEGIN
  :sql_text := q'[
SELECT * FROM sys.optstat_hist_control$
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables Summary';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       COUNT(*) tables_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(partitioned, 'YES', 1, 0)) partitioned,
       SUM(DECODE(temporary, 'Y', 1, 0)) temporary,
       SUM(DECODE(status, 'VALID', 0, 1)) not_valid,
       SUM(DECODE(logging, 'YES', 0, 1)) not_logging,
       SUM(DECODE(TRIM(cache), 'Y', 1, 0)) cache,
       &&skip_ver_le_11_1.SUM(DECODE(flash_cache, 'KEEP', 1, 0)) keep_flash_cache,
       &&skip_ver_le_11_1.SUM(DECODE(cell_flash_cache, 'KEEP', 1, 0)) keep_cell_flash_cache,
       &&skip_ver_le_11_1.SUM(DECODE(result_cache, 'FORCE', 1, 0)) result_cache_force,
       SUM(DECODE(dependencies, 'ENABLED', 1, 0)) dependencies,
       SUM(DECODE(compression, 'ENABLED', 1, 0)) compression,
       &&skip_ver_le_10.SUM(DECODE(compress_for, 'BASIC', 1, 0)) compress_for_basic,
       &&skip_ver_le_10.SUM(DECODE(compress_for, 'OLTP', 1, 0)) compress_for_oltp,
       &&skip_ver_le_10.SUM(CASE WHEN compress_for IN 
       &&skip_ver_le_10.('ARCHIVE HIGH', 'ARCHIVE LOW', 'QUERY HIGH', 'QUERY LOW') 
       &&skip_ver_le_10.THEN 1 ELSE 0 END) compress_for_hcc,
       SUM(DECODE(dropped, 'YES', 1, 0)) dropped,
       &&skip_ver_le_11_1.SUM(DECODE(read_only, 'YES', 1, 0)) read_only,
       SUM(num_rows) sum_num_rows,
       MAX(num_rows) max_num_rows,
       SUM(blocks) sum_blocks,
       MAX(blocks) max_blocks,
       MIN(last_analyzed) min_last_analyzed,
       MAX(last_analyzed) max_last_analyzed,
       MEDIAN(last_analyzed) median_last_analyzed,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_75_percentile,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_90_percentile,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_95_percentile,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_99_percentile
  FROM &&cdb_object_prefix.tables t
 WHERE table_name NOT LIKE 'BIN$%' -- bug 9930151 reported by brad peek
   AND NOT EXISTS (
SELECT /*+ &&top_level_hints. */ NULL
  FROM &&cdb_object_prefix.external_tables e
 WHERE e.owner = t.owner
   &&skip_noncdb.AND e.con_id = t.con_id
   AND e.table_name = t.table_name)
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

rem dmk 14.11.2018 better title to help distinguish reports in section
col TYPE_COUNT heading 'Type|Count'
col NOT_ANALYZED heading 'Not|Analyzed'
col STATS_LOCKED heading 'Stats|Locked'
col STALE_STATS	heading 'Stale|Stats'
col SUM_NUM_ROWS heading 'Sum|NUM_ROWS'
col MAX_NUM_ROWS heading 'Max|NUM_ROWS'
col SUM_BLOCKS heading 'Sum|Blocks'
col MAX_BLOCKS heading 'Max|Blocks'
col MIN_LAST_ANALYZED 'Min Last|Analyzed'
col MAX_LAST_ANALYZED 'Max Last|Analyzed'
col MEDIAN_LAST_ANALYZE	'Median|Last|Analyzed'
col LAST_ANALYZED_75_PE	'Last Analyzed|75th Percentile'
col LAST_ANALYZED_90_PE	'Last Analyzed|90th Percentile'	
col LAST_ANALYZED_95_PE	'Last Analyzed|95th Percentile'
col LAST_ANALYZED_99_PE	'Last Analyzed|99th Percentile'

DEF title = 'Table Statistics Summary';
DEF main_table = '&&cdb_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       object_type,
       COUNT(*) type_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(stattype_locked, NULL, 0, 1)) stats_locked,
       SUM(DECODE(stale_stats, 'YES', 1, 0)) stale_stats,
       SUM(num_rows) sum_num_rows,
       MAX(num_rows) max_num_rows,
       SUM(blocks) sum_blocks,
       MAX(blocks) max_blocks,
       MIN(last_analyzed) min_last_analyzed,
       MAX(last_analyzed) max_last_analyzed,
       MEDIAN(last_analyzed) median_last_analyzed,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_75_percentile,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_90_percentile,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_95_percentile,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_99_percentile
  FROM &&cdb_object_prefix.tab_statistics s
 WHERE table_name NOT LIKE 'BIN$%' -- bug 9930151 reported by brad peek
   AND NOT EXISTS (
SELECT /*+ &&top_level_hints. */ NULL
  FROM &&cdb_object_prefix.external_tables e
 WHERE e.owner = s.owner
   &&skip_noncdb.AND e.con_id = s.con_id
   AND e.table_name = s.table_name)
GROUP BY
       &&skip_noncdb.con_id,
       owner, object_type
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       owner, object_type
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Table Columns Summary';
DEF main_table = '&&cdb_view_prefix.TAB_COLS';
BEGIN
  :sql_text := q'[
WITH x aS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       COUNT(DISTINCT table_name) tables_count,
       COUNT(*) columns_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(hidden_column, 'YES', 1, 0)) hidden_column,
       SUM(DECODE(virtual_column, 'YES', 1, 0)) virtual_column,
       SUM(DECODE(histogram, 'NONE', 0, 1)) histogram,
       MIN(last_analyzed) min_last_analyzed,
       MAX(last_analyzed) max_last_analyzed,
       MEDIAN(last_analyzed) median_last_analyzed,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_75_percentile,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_90_percentile,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_95_percentile,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_99_percentile
  FROM &&cdb_object_prefix.tab_cols c
 WHERE table_name NOT LIKE 'BIN$%' -- bug 9930151 reported by brad peek
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND NOT EXISTS (
SELECT /*+ &&top_level_hints. */ NULL
  FROM &&cdb_object_prefix.external_tables e
 WHERE e.owner = c.owner
   &&skip_noncdb.AND e.con_id = c.con_id
   AND e.table_name = c.table_name)
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
       owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Indexes Summary';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       COUNT(DISTINCT table_name) tables_count,
       COUNT(*) indexes_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(partitioned, 'YES', 1, 0)) partitioned,
       SUM(DECODE(temporary, 'Y', 1, 0)) temporary,
       SUM(DECODE(status, 'UNUSABLE', 1, 0)) unusable,
       &&skip_ver_le_10.SUM(DECODE(visibility, 'INVISIBLE', 1, 0)) invisible,
       SUM(DECODE(logging, 'YES', 0, 1)) not_logging,
       &&skip_ver_le_11_1.SUM(DECODE(flash_cache, 'KEEP', 1, 0)) keep_flash_cache,
       &&skip_ver_le_11_1.SUM(DECODE(cell_flash_cache, 'KEEP', 1, 0)) keep_cell_flash_cache,
       SUM(DECODE(compression, 'ENABLED', 1, 0)) compression,
       SUM(DECODE(dropped, 'YES', 1, 0)) dropped,
       SUM(leaf_blocks) sum_leaf_blocks,
       MAX(leaf_blocks) max_leaf_blocks,
       MAX(blevel) max_blevel,
       MIN(last_analyzed) min_last_analyzed,
       MAX(last_analyzed) max_last_analyzed,
       MEDIAN(last_analyzed) median_last_analyzed,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_75_percentile,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_90_percentile,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_95_percentile,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_99_percentile
  FROM &&cdb_object_prefix.indexes
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
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

DEF title = 'Ind Summary';
DEF main_table = '&&cdb_view_prefix.IND_STATISTICS';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       object_type,
       COUNT(*) type_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(stattype_locked, NULL, 0, 1)) stats_locked,
       SUM(DECODE(stale_stats, 'YES', 1, 0)) stale_stats,
       SUM(leaf_blocks) sum_leaf_blocks,
       MAX(leaf_blocks) max_leaf_blocks,
       MAX(blevel) max_blevel,
       MIN(last_analyzed) min_last_analyzed,
       MAX(last_analyzed) max_last_analyzed,
       MEDIAN(last_analyzed) median_last_analyzed,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_75_percentile,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_90_percentile,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_95_percentile,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_99_percentile
  FROM &&cdb_object_prefix.ind_statistics
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.con_id,
	   owner, object_type
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner, x.object_type
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Table Partitions Summary';
DEF main_table = '&&cdb_view_prefix.TAB_PARTITIONS';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       table_owner,
       COUNT(DISTINCT table_name) tables_count,
       COUNT(*) partitions_count,
       SUM(DECODE(composite, 'YES', 1, 0)) subpartitioned,
       SUM(subpartition_count) subpartition_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(logging, 'YES', 0, 1)) not_logging,
       &&skip_ver_le_11_1.SUM(DECODE(flash_cache, 'KEEP', 1, 0)) keep_flash_cache,
       &&skip_ver_le_11_1.SUM(DECODE(cell_flash_cache, 'KEEP', 1, 0)) keep_cell_flash_cache,
       SUM(DECODE(compression, 'ENABLED', 1, 0)) compression,
       &&skip_ver_le_10.SUM(DECODE(compress_for, 'BASIC', 1, 0)) compress_for_basic,
       &&skip_ver_le_10.SUM(DECODE(compress_for, 'OLTP', 1, 0)) compress_for_oltp,
       &&skip_ver_le_10.SUM(CASE WHEN compress_for IN 
       &&skip_ver_le_10.('ARCHIVE HIGH', 'ARCHIVE LOW', 'QUERY HIGH', 'QUERY LOW') 
       &&skip_ver_le_10.THEN 1 ELSE 0 END) compress_for_hcc,
       SUM(num_rows) sum_num_rows,
       MAX(num_rows) max_num_rows,
       SUM(blocks) sum_blocks,
       MAX(blocks) max_blocks,
       MIN(last_analyzed) min_last_analyzed,
       MAX(last_analyzed) max_last_analyzed,
       MEDIAN(last_analyzed) median_last_analyzed,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_75_percentile,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_90_percentile,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_95_percentile,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_99_percentile
  FROM &&cdb_object_prefix.tab_partitions
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.con_id,
	   table_owner
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.table_owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Index Partitions Summary';
DEF main_table = '&&cdb_view_prefix.IND_PARTITIONS';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       index_owner,
       COUNT(DISTINCT index_name) indexes_count,
       COUNT(*) partitions_count,
       SUM(DECODE(composite, 'YES', 1, 0)) subpartitioned,
       SUM(subpartition_count) subpartition_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(status, 'UNUSABLE', 1, 0)) unusable,
       SUM(DECODE(logging, 'YES', 0, 1)) not_logging,
       &&skip_ver_le_11_1.SUM(DECODE(flash_cache, 'KEEP', 1, 0)) keep_flash_cache,
       &&skip_ver_le_11_1.SUM(DECODE(cell_flash_cache, 'KEEP', 1, 0)) keep_cell_flash_cache,
       SUM(DECODE(compression, 'ENABLED', 1, 0)) compression,
       SUM(leaf_blocks) sum_leaf_blocks,
       MAX(leaf_blocks) max_leaf_blocks,
       MAX(blevel) max_blevel,
       MIN(last_analyzed) min_last_analyzed,
       MAX(last_analyzed) max_last_analyzed,
       MEDIAN(last_analyzed) median_last_analyzed,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_75_percentile,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_90_percentile,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_95_percentile,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY last_analyzed) last_analyzed_99_percentile
  FROM &&cdb_object_prefix.ind_partitions
 WHERE index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.con_id,
	   index_owner
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.index_owner
]';
END;
/
@@edb360_9a_pre_one.sql

REM dmk 14.11.2018 - report of partitioned tables, partitioning type and size
col owner heading 'Table|Owner'
col table_name heading 'Table|Name'
col autolist heading 'Auto|List' 
col autolist_Subpartition heading 'Auto|List|Subpart' 
col interval_Subpartition heading 'Interval|Subpart' 
col partitioning_type heading 'Part|Type'
col Subpartitioning_type heading 'Subpart|Type'
col part_column_list heading 'Partition|Column|List' 
col Subp_column_list heading 'Subpart|Column|List' 
col part_num_rows heading 'Part''n|Rows'
col Subp_num_rows heading 'Subpart|Rows'
col part_blocks heading 'Part''n|Blocks'
col Subp_blocks heading 'Subpart|Blocks'
col part_tablespaces heading 'Distinct|Part''n|Tablespaces'
col Subp_tablespaces heading 'Distinct|Subpart|Tablespaces'
col part_segments_created heading 'Part''n|Segments|Created'
col Subp_segments_created heading 'Subpart|Segments|Created'
col part_compression_enabled heading 'Compress|Enabled|Parts' 
col Subp_compression_enabled heading 'Compress|Enabled|Subparts' 
col part_compressfor_basic heading 'Simple|Compress|Parts' 
col Subp_compressfor_basic heading 'Simple|Compress|Subparts' 
col part_compressfor_queryhigh   heading 'HCC|Query|High|Parts' 
col Subp_compressfor_queryhigh   heading 'HCC|Query|High|Subparts' 
col part_compressfor_querylow    heading 'HCC|Query|Low|Parts' 
col Subp_compressfor_querylow    heading 'HCC|Query|Low|Subparts' 
col part_compressfor_archivehigh heading 'HCC|Archive|High|Parts' 
col Subp_compressfor_archivehigh heading 'HCC|Archive|High|Subparts' 
col part_compressfor_archivelow  heading 'HCC|Archive|Low|Parts' 
col Subp_compressfor_archivelow  heading 'HCC|Archive|Low|Subparts' 
col part_intervals heading 'Part''n|Intervals'
col Subp_intervals heading 'Subpart|Intervals'
col part_count heading 'Number of|Parts'
col Subp_count heading 'Number of|Subparts'
DEF title = 'Table Partitioning';
DEF main_table = '&&cdb_view_prefix.PART_TABLES';
BEGIN
  :sql_text := q'[
WITH pc AS (
SELECT &&skip_noncdb.con_id,
       owner, name table_name
,      LISTAGG(column_name,', ') WITHIN GROUP (ORDER BY column_position) part_column_list
FROM   &&cdb_object_prefix.part_key_columns
WHERE  object_type = 'TABLE'
GROUP BY 
       &&skip_noncdb.con_id,
       owner, name
), sc as (
SELECT &&skip_noncdb.con_id,
       owner, name table_name
,      LISTAGG(column_name,', ') WITHIN GROUP (ORDER BY column_position) subp_column_list
FROM   &&cdb_object_prefix.subpart_key_columns
WHERE  object_type = 'TABLE'
GROUP BY 
       &&skip_noncdb.con_id,
       owner, name
), tp as (
SELECT &&skip_noncdb.con_id,
       table_owner owner, table_name
,      COUNT(*) part_count
,      COUNT(distinct tablespace_name) part_tablespaces
,      SUM(DECODE(compression,'ENABLE',1)) part_compression_enabled
,      SUM(CASE WHEN compress_for like 'BASIC'         THEN 1 END) part_compressfor_basic
,      SUM(CASE WHEN compress_for like 'QUERY HIGH%'   THEN 1 END) part_compressfor_queryhigh
,      SUM(CASE WHEN compress_for like 'QUERY LOW%'    THEN 1 END) part_compressfor_querylow
,      SUM(CASE WHEN compress_for like 'ARCHIVE HIGH%' THEN 1 END) part_compressfor_archivehigh
,      SUM(CASE WHEN compress_for like 'ARCHIVE LOW%'  THEN 1 END) part_compressfor_archivelow
,      SUM(num_rows) part_num_rows
,      SUM(blocks) part_blocks
&&skip_ver_le_11_1.,      SUM(DECODE(interval,'YES',1)) part_intervals
&&skip_ver_le_11_1.,      SUM(DECODE(segment_created,'YES',1)) part_segments_created
FROM   &&cdb_object_prefix.tab_partitions
GROUP BY 
       &&skip_noncdb.con_id,
	   table_owner, table_name
), sp as (
SELECT &&skip_noncdb.con_id,
       table_owner owner, table_name
,      COUNT(*) subp_count
,      COUNT(distinct tablespace_name) subp_tablespaces
,      SUM(DECODE(compression,'ENABLE',1)) subp_compression_enabled
,      SUM(CASE WHEN compress_for like 'BASIC'         THEN 1 END) subp_compressfor_basic
,      SUM(CASE WHEN compress_for like 'QUERY HIGH%'   THEN 1 END) subp_compressfor_queryhigh
,      SUM(CASE WHEN compress_for like 'QUERY LOW%'    THEN 1 END) subp_compressfor_querylow
,      SUM(CASE WHEN compress_for like 'ARCHIVE HIGH%' THEN 1 END) subp_compressfor_archivehigh
,      SUM(CASE WHEN compress_for like 'ARCHIVE LOW%'  THEN 1 END) subp_compressfor_archivelow
,      SUM(num_rows) subp_num_rows
,      SUM(blocks) subp_blocks
&&skip_ver_le_11_1.,      SUM(DECODE(interval,'YES',1)) subp_intervals
&&skip_ver_le_11_1.,      SUM(DECODE(segment_created,'YES',1)) subp_segments_created
FROM   &&cdb_object_prefix.tab_subpartitions
GROUP BY 
       &&skip_noncdb.con_id,
       table_owner, table_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
  &&skip_noncdb.p.con_id,
  p.owner, p.table_name
, p.partitioning_type
, pc.part_column_list
&&skip_ver_le_10., NULLIF(p.interval,'NO') interval
&&skip_ver_le_12., NULLIF(p.autolist,'NO') autolist
,tp.part_count
&&skip_ver_le_11.,tp.part_intervals
,tp.part_num_rows, tp.part_blocks
&&skip_ver_le_11.,tp.part_segments_created
,tp.part_tablespaces
,tp.part_compression_enabled
,tp.part_compressfor_basic
,tp.part_compressfor_queryhigh
,tp.part_compressfor_querylow
,tp.part_compressfor_archivehigh
,tp.part_compressfor_archivelow
, NULLIF(p.subpartitioning_type,'NONE') subpartitioning_type
--,DEF_SUBPARTITION_COUNT
,sc.subp_column_list
&&skip_ver_le_12.,NULLIF(p.interval_subpartition,'NO') interval_subpartition
&&skip_ver_le_12.,NULLIF(p.autolist_subpartition,'NO') autolist_subpartition
,sp.subp_count
&&skip_ver_le_11.,sp.subp_intervals
,sp.subp_num_rows, sp.subp_blocks
&&skip_ver_le_11.,sp.subp_segments_created
,sp.subp_tablespaces
,sp.subp_compression_enabled
,sp.subp_compressfor_basic
,sp.subp_compressfor_queryhigh
,sp.subp_compressfor_querylow
,sp.subp_compressfor_archivehigh
,sp.subp_compressfor_archivelow
--,STATUS
--,DEF_COMPRESSION
--,DEF_COMPRESS_FOR
--,IS_NESTED
&&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.part_Tables p
       LEFT OUTER JOIN pc ON pc.owner = p.owner AND pc.table_name = p.table_name &&skip_noncdb.AND pc.con_id = p.con_id
       LEFT OUTER JOIN sc ON sc.owner = p.owner AND sc.table_name = p.table_name &&skip_noncdb.AND sc.con_id = p.con_id
       LEFT OUTER JOIN tp ON tp.owner = p.owner AND tp.table_name = p.table_name &&skip_noncdb.AND tp.con_id = p.con_id
       LEFT OUTER JOIN sp ON sp.owner = p.owner AND sp.table_name = p.table_name &&skip_noncdb.AND sp.con_id = p.con_id
	   &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = p.con_id
 WHERE p.owner NOT IN &&exclusion_list.
   AND p.owner NOT IN &&exclusion_list2.
   AND p.table_name NOT LIKE 'BIN%'
 ORDER BY
       &&skip_noncdb.p.con_id,
       p.owner, p.table_name
]';
END;
/
@@edb360_9a_pre_one.sql
col owner clear
col table_name clear
col autolist clear
col autolist_Subpartition clear
col interval_Subpartition clear
col partitioning_type     clear
col Subpartitioning_type  clear
col part_column_list      clear
col Subp_column_list      clear
col part_num_rows         clear
col Subp_num_rows         clear
col part_blocks           clear
col Subp_blocks           clear
col part_tablespaces      clear
col Subp_tablespaces      clear
col part_segments_created        clear
col Subp_segments_created        clear
col part_compression_enabled     clear
col Subp_compression_enabled     clear
col part_compressfor_basic       clear
col Subp_compressfor_basic       clear
col part_compressfor_queryhigh   clear
col Subp_compressfor_queryhigh   clear
col part_compressfor_querylow    clear
col Subp_compressfor_querylow    clear
col part_compressfor_archivehigh clear
col Subp_compressfor_archivehigh clear
col part_compressfor_archivelow  clear
col Subp_compressfor_archivelow  clear
col part_intervals clear
col Subp_intervals clear
col part_count     clear
col Subp_count     clear


REM dmk 14.11.2018 - report of usage of partitioning key columns
col column_id          heading 'Column|ID'
col column_name        heading 'Column|Name'
col num_distinct       heading 'Distinct|Values'
col sample_size        heading 'Sample|Size'
col num_nulls          heading 'Number|of Nulls'
col partitioning_level heading 'Partitioning|Level'
col partitioning_type  heading 'Partitioning|Type'
col column_position    heading 'Partitioning|Key Column|Position'
col EQUALITY_PREDS     heading 'Equality|Predicates'
col EQUIJOIN_PREDS     heading 'EquiJoin|Predicates'
col NONEQUIJOIN_PREDS  heading 'NonEquiJoin|Predicates'
col RANGE_PREDS        heading 'Range|Predicates'
col LIKE_PREDS         heading 'Like|Predicates'
col NULL_PREDS         heading 'NULL|Predicates'
DEF title = 'Partitioning Keys and col Usage Statistics';
DEF main_table = 'sys.col_usage$';
BEGIN
  :sql_text := q'[
WITH k as (
SELECT &&skip_noncdb.con_id,
       owner, name, column_position, column_name
,      'Partition' partitioning_level
FROM   &&cdb_object_prefix.part_key_columns
WHERE  object_type = 'TABLE'
AND    owner NOT IN &&exclusion_list.
AND    owner NOT IN &&exclusion_list2.
UNION ALL
SELECT &&skip_noncdb.con_id,
       owner, name, column_position, column_name
,      'Subpartition'
FROM   &&cdb_object_prefix.subpart_key_columns
WHERE  object_type = 'TABLE'
AND    owner NOT IN &&exclusion_list.
AND    owner NOT IN &&exclusion_list2.
), c as (
SELECT &&skip_noncdb.p.con_id,
       p.owner, p.table_name, o.object_id
,      c.column_id, c.column_name, c.num_distinct, c.sample_size, c.num_nulls
,         p.partitioning_type
,      p.subpartitioning_type
FROM   &&cdb_object_prefix.objects o
,      &&cdb_object_prefix.part_tables p
,      &&cdb_object_prefix.tab_columns c
WHERE  p.owner = o.owner
&&skip_noncdb.AND    p.con_id = o.con_id
AND    p.table_name = o.object_name
AND    o.object_type = 'TABLE'
&&skip_noncdb.AND    c.con_id = p.con_id
AND    c.owner = p.owner
AND    c.table_name = p.table_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.c.con_id,
       c.owner, c.table_name
,      c.column_id, c.column_name
,      k.partitioning_level
,      CASE WHEN k.partitioning_level = 'Partition'    THEN    c.partitioning_type
            WHEN k.partitioning_level = 'Subpartition' THEN c.subpartitioning_type
       END as partitioning_type
,      k.column_position
,      c.num_distinct, c.sample_size, c.num_nulls
,      u.EQUALITY_PREDS
,      u.EQUIJOIN_PREDS
,      u.NONEQUIJOIN_PREDS
,      u.RANGE_PREDS
,      u.LIKE_PREDS
,      u.NULL_PREDS
,      u.TIMESTAMP
&&skip_noncdb.,c.name con_name
FROM   c
  LEFT OUTER JOIN k
    ON k.owner = c.owner
   &&skip_noncdb.AND k.con_id = c.con_id
   AND k.name = c.table_name
   AND k.column_name = c.column_name
  LEFT OUTER JOIN sys.col_usage$ u
    ON u.obj# = c.object_id
   AND u.intcol# = c.column_id
  &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = c.con_id
WHERE  (u.obj# IS NOT NULL
or     k.partitioning_level IS NOT NULL)
AND    c.owner NOT IN &&exclusion_list.
AND    c.owner NOT IN &&exclusion_list2.
ORDER BY &&skip_noncdb.c.con_id,
       c.owner, c.table_name, c.column_id, c.column_name
]';
END;
/
@@edb360_9a_pre_one.sql
col column_id          clear
col column_name        clear
col num_distinct       clear
col sample_size        clear
col num_nulls          clear
col partitioning_level clear
col partitioning_type  clear
col column_position    clear
col EQUALITY_PREDS     clear
col EQUIJOIN_PREDS     clear
col NONEQUIJOIN_PREDS  clear
col RANGE_PREDS        clear
col LIKE_PREDS         clear
col NULL_PREDS         clear



DEF title = 'Tables with Missing Stats';
DEF main_table = '&&cdb_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
	   s.owner, s.table_name, s.stale_stats, s.stattype_locked
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_statistics s,
       &&cdb_object_prefix.tables t
	   &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = t.con_id
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM &&cdb_object_prefix.external_tables e
 WHERE e.owner = s.owner
 &&skip_noncdb.AND e.con_id = s.con_id
   AND e.table_name = s.table_name 
)
 ORDER BY
       &&skip_noncdb.s.con_id,
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with Stale Stats';
DEF main_table = '&&cdb_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
	   s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stattype_locked
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_statistics s,
       &&cdb_object_prefix.tables t
	   &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = t.con_id
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.stale_stats = 'YES'
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   &&skip_noncdb.AND t.con_id = s.con_id
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM &&cdb_object_prefix.external_tables e
 WHERE e.owner = s.owner
   &&skip_noncdb.AND e.con_id = s.con_id
   AND e.table_name = s.table_name 
)
 ORDER BY
       &&skip_noncdb.s.con_id,
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with Outdated Stats';
DEF main_table = '&&cdb_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
	   s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_statistics s,
       &&cdb_object_prefix.tables t
	   &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = t.con_id
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed < SYSDATE - 31
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   &&skip_noncdb.AND t.con_id = s.con_id
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM &&cdb_object_prefix.external_tables e
 WHERE e.owner = s.owner
   &&skip_noncdb.AND e.con_id = s.con_id
   AND e.table_name = s.table_name 
)
 ORDER BY
       &&skip_noncdb.s.con_id,
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with Locked Stats';
DEF main_table = '&&cdb_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
	   s.owner, s.table_name, t.temporary, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked, e.type_name external_table_type
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_statistics s
       LEFT OUTER JOIN &&cdb_object_prefix.external_tables e ON e.owner = s.owner AND e.table_name = s.table_name &&skip_noncdb.AND e.con_id = s.con_id
	   &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
      ,&&cdb_object_prefix.tables t       
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.stattype_locked IS NOT NULL
   AND s.table_name NOT LIKE 'BIN%'
   &&skip_noncdb.AND t.con_id = s.con_id
   AND t.owner = s.owner
   AND t.table_name = s.table_name
 ORDER BY
       &&skip_noncdb.s.con_id,
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Global Temporary Tables with Stats';
DEF main_table = '&&cdb_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
	   s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_statistics s
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
      ,&&cdb_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NOT NULL
   AND s.table_name NOT LIKE 'BIN%'
   &&skip_noncdb.AND t.con_id = s.con_id
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'Y'
 ORDER BY
       &&skip_noncdb.s.con_id,
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Temp Tables with Stats';
DEF main_table = '&&cdb_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
	   s.owner, s.table_name, t.temporary, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_statistics s
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
	  ,&&cdb_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NOT NULL
   /*AND s.stale_stats = 'YES'*/
   AND (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND s.table_name NOT LIKE 'BIN%'
   &&skip_noncdb.AND t.con_id = s.con_id
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND NOT EXISTS (
SELECT NULL
  FROM &&cdb_object_prefix.external_tables e
 WHERE e.owner = s.owner
   &&skip_noncdb.AND e.con_id = s.con_id
   AND e.table_name = s.table_name 
)
 ORDER BY
       &&skip_noncdb.s.con_id,
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Objects with many Stats Versions';
DEF main_table = 'WRI$_OPTSTAT_TAB_HISTORY';
BEGIN
  :sql_text := q'[
WITH
h AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       obj#,
       COUNT(*) versions,
       MIN(savtime) min_savtime,
       MAX(savtime) max_savtime,
       MEDIAN(savtime) med_savtime,
       MIN(rowcnt) min_rowcnt,
       MAX(rowcnt) max_rowcnt,
       MEDIAN(rowcnt) med_rowcnt,
       MIN(blkcnt) min_blkcnt,
       MAX(blkcnt) max_blkcnt,
       MEDIAN(blkcnt) med_blkcnt
  FROM sys.wri$_optstat_tab_history
 GROUP BY
       obj#
HAVING COUNT(*) > DBMS_STATS.GET_STATS_HISTORY_RETENTION
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       h.versions,
       o.owner,
       o.object_name,
       o.subobject_name,
       o.object_type,
       o.object_id,
       h.min_savtime,
       h.max_savtime,
       h.med_savtime,
       h.min_rowcnt,
       h.max_rowcnt,
       h.med_rowcnt,
       h.min_blkcnt,
       h.max_blkcnt,
       h.med_blkcnt
  FROM h, &&dva_object_prefix.objects o
 WHERE o.object_id = h.obj#
   AND o.owner NOT IN &&exclusion_list.
   AND o.owner NOT IN &&exclusion_list2.
 ORDER BY
       h.versions DESC,
       o.owner,
       o.object_name,
       o.subobject_name
]';
END;
/
@@edb360_9a_pre_one.sql

&&skip_ver_le_11_1.@@edb360_3c_dbms_stats.sql

DEF title = 'SYS Stats for WRH$, WRI$, WRM$ and WRR$ Tables';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       &&skip_noncdb.x.con_id,
	   x.table_name, x.blocks, x.num_rows, x.sample_size, x.last_analyzed
	   &&skip_noncdb.,c.name con_name
from   &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
where  x.owner = 'SYS'
and    x.table_name like 'WR_$%'
order by &&skip_noncdb.x.con_id,
       x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SYS Stats for WRH$, WRI$, WRM$ and WRR$ Indexes';
DEF main_table = '&&cdb_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       &&skip_noncdb.x.con_id,
	   x.table_name, x.index_name, x.blevel, x.leaf_blocks, x.distinct_keys, x.num_rows, x.sample_size, x.last_analyzed
	   &&skip_noncdb.,c.name con_name
from   &&cdb_object_prefix.indexes x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
where  x.owner = 'SYS'
and    x.table_name like 'WR_$%'
order by 
       &&skip_noncdb.x.con_id,
	   x.table_name, x.index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Table Modifications for WRH$, WRI$, WRM$ and WRR$';
DEF main_table = '&&cdb_view_prefix.TAB_MODIFICATIONS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
	   x.table_name, x.partition_name, x.inserts, x.updates, x.deletes, x.timestamp, x.truncated
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tab_modifications x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.table_owner = 'SYS'
   AND x.table_name LIKE 'WR_$%'
 ORDER BY
       x.table_name, x.partition_name
]';
END;
/
@@edb360_9a_pre_one.sql

col owner            heading 'Table|Owner'
col table_name       heading 'Table|Name'
col index_name       heading 'Index|Name'
col column_name      heading 'Column|Name'
col object_type      heading 'Object|Type'
col object_name      heading 'Index/Extension|Name'
col column_list      heading 'Column|List'
col histogram        heading 'Histogram|Type'
col distinct_keys    heading 'Distinct|Keys'
col num_distinct     heading 'Number of|Distinct|Values'
col num_buckets      heading 'Number of|Buckets'
col distinct_keys    heading 'Distinct|Keys'
col col_num_distinct heading 'Column|Number of|Distinct|Values'
col col_num_buckets  heading 'Column|Number of|Buckets'
col col_histogram    heading 'Column|Histogram|Type'
DEF title = 'Columns with Histograms in Extended Statistics';
REM dmk 29.11.2018 Columns with histograms that are part of a col group where the extended statistics do not have a histogram, 
REM or part of a composite index where there is no corresponding extended histogram prevent use of extended statistics.  Need extended histograms.
REM https://jonathanlewis.wordpress.com/2012/04/11/extended-stats/ - note Colgan comment
REM https://antognini.ch/2014/02/extension-bypassed-because-of-missing-histogram/ - note fix control
REM see also Bug 6972291 - col group selectivity is not used when there is a histogram on one col (Doc ID 6972291.8)
DEF main_table = '&&cdb_view_prefix.STAT_EXTENSIONS';
BEGIN
  :sql_text := q'[
WITH i as ( /*composite indexes*/
SELECT	&&skip_noncdb.i.con_id,
        i.table_owner, i.table_name, i.owner index_owner, i.index_name, i.distinct_keys
,	    '('||(LISTAGG('"'||c.column_name||'"',',') WITHIN GROUP (order by c.column_position))||')' column_list
FROM	&&cdb_object_prefix.indexes i
,	    &&cdb_object_prefix.ind_columns c
WHERE   i.table_owner = c.table_owner
AND     i.table_name = c.table_name
&&skip_noncdb.AND     i.con_id = c.con_id
AND     i.owner = c.index_owner
AND     i.index_name = c.index_name
GROUP BY &&skip_noncdb.i.con_id,
         i.table_owner, i.table_name, i.owner, i.index_name, i.distinct_keys
HAVING COUNT(*) > 1
), e as ( /*extended stats*/
SELECT 	&&skip_noncdb.e.con_id,
        e.owner, e.table_name, e.extension_name
,       CAST(e.extension AS VARCHAR(1000)) extension
,       se.histogram, se.num_buckets, se.num_distinct
FROM	&&cdb_object_prefix.stat_extensions e
,       &&cdb_object_prefix.tab_col_statistics se
WHERE	e.creator = 'USER'
&&skip_noncdb.AND     se.con_id = e.con_id
AND     se.owner = e.owner
AND     se.table_name = e.table_name
AND     se.column_name = e.extension_name
AND     e.table_name NOT LIKE 'BIN$%' 
AND     e.owner NOT IN &&exclusion_list.
AND     e.owner NOT IN &&exclusion_list2.
), x as (
SELECT	&&skip_noncdb.e.con_id,
        e.owner, e.table_name
, 	    'Extension' object_type
,       e.extension_name object_name, e.num_distinct, e.num_buckets, e.extension
,       sc.column_name
,       sc.num_distinct col_num_distinct
,       sc.num_buckets col_num_buckets
,       sc.histogram col_histogram
FROM	e
,       &&cdb_object_prefix.tab_col_statistics sc
WHERE	e.histogram = 'NONE'
AND     e.extension LIKE '%"'||sc.column_name||'"%'
&&skip_noncdb.AND     sc.con_id = e.con_id
AND     sc.owner = e.owner
AND     sc.table_name = e.table_name
AND     sc.histogram != 'NONE'
AND     sc.num_buckets > 1
AND     e.num_buckets = 1
UNION ALL
SELECT	/*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
        &&skip_noncdb.i.con_id,
		i.table_owner, i.table_name
,       'Index' object_type
,       i.index_name object_name, i.distinct_keys, TO_NUMBER(null), i.column_list
,       sc.column_name
,       sc.num_distinct col_num_distinct
,       sc.num_buckets col_num_buckets
,       sc.histogram col_histogram
from	i
,       &&cdb_object_prefix.ind_columns ic
,       &&cdb_object_prefix.tab_col_statistics sc
WHERE 	ic.table_owner = i.table_owner
AND     ic.table_name = i.table_name
AND     ic.index_owner = i.index_owner
AND 	ic.index_name = i.index_name
&&skip_noncdb.AND     ic.con_id = i.con_id
&&skip_noncdb.AND     sc.con_id = ic.con_id
AND     sc.owner = ic.table_owner
AND     sc.table_name = ic.table_name
AND     sc.column_name = ic.column_name
AND     sc.histogram != 'NONE'
AND     sc.num_buckets > 1
AND NOT EXISTS( /*report index if no extension*/
        SELECT 'x'
        FROM    e
        WHERE   e.owner = i.table_owner
        AND     e.table_name = i.table_name
        AND     e.extension = i.column_list      
        &&skip_noncdb.AND     e.con_id = i.con_id
        )
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id    
ORDER BY &&skip_noncdb.x.con_id,
       x.owner, x.table_name, x.object_type, x.num_distinct
]';
END;
/
@@edb360_9a_pre_one.sql
col owner            heading clear
col table_name       heading clear
col index_name       heading clear
col column_name      heading clear
col object_type      heading clear
col object_name      heading clear
col column_list      heading clear
col histogram        heading clear
col distinct_keys    heading clear
col num_distinct     heading clear
col num_buckets      heading clear
col distinct_keys    heading clear
col col_num_distinct heading clear
col col_num_buckets  heading clear
col col_histogram    heading clear

col TYPE_COUNT	        clear
col NOT_ANALYZED	    clear
col STATS_LOCKED	    clear
col STALE_STATS	        clear
col SUM_NUM_ROWS	    clear
col MAX_NUM_ROWS	    clear
col SUM_BLOCKS	        clear
col MAX_BLOCKS	        clear
col MIN_LAST_ANALYZED	clear
col MAX_LAST_ANALYZED	clear
col MEDIAN_LAST_ANALYZE	clear
col LAST_ANALYZED_75_PE	clear
col LAST_ANALYZED_90_PE	clear
col LAST_ANALYZED_95_PE	clear
col LAST_ANALYZED_99_PE	clear

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
