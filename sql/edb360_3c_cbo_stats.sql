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
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       COUNT(*) tables_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(partitioned, 'YES', 1, 0)) partitioned,
       SUM(DECODE(temporary, 'Y', 1, 0)) temporary,
       SUM(DECODE(status, 'VALID', 0, 1)) not_valid,
       SUM(DECODE(logging, 'YES', 0, 1)) not_logging,
       SUM(DECODE(TRIM(cache), 'Y', 1, 0)) cache,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(flash_cache, 'KEEP', 1, 0)) keep_flash_cache,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(cell_flash_cache, 'KEEP', 1, 0)) keep_cell_flash_cache,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(result_cache, 'FORCE', 1, 0)) result_cache_force,
       SUM(DECODE(dependencies, 'ENABLED', 1, 0)) dependencies,
       SUM(DECODE(compression, 'ENABLED', 1, 0)) compression,
       &&skip_10g_column.SUM(DECODE(compress_for, 'BASIC', 1, 0)) compress_for_basic,
       &&skip_10g_column.SUM(DECODE(compress_for, 'OLTP', 1, 0)) compress_for_oltp,
       &&skip_10g_column.SUM(CASE WHEN compress_for IN 
       &&skip_10g_column.('ARCHIVE HIGH', 'ARCHIVE LOW', 'QUERY HIGH', 'QUERY LOW') 
       &&skip_10g_column.THEN 1 ELSE 0 END) compress_for_hcc,
       SUM(DECODE(dropped, 'YES', 1, 0)) dropped,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(read_only, 'YES', 1, 0)) read_only,
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
  FROM &&dva_object_prefix.tables t
 WHERE table_name NOT LIKE 'BIN$%' -- bug 9930151 reported by brad peek
   AND NOT EXISTS (
SELECT /*+ &&top_level_hints. */ NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = t.owner
   AND e.table_name = t.table_name 
)
 GROUP BY
       owner
 ORDER BY
       owner
]';
END;
/
@@edb360_9a_pre_one.sql

rem dmk 14.11.2018 better title to help distinguish reports in section
DEF title = 'Table Statistics Summary';
DEF main_table = '&&dva_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
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
  FROM &&dva_object_prefix.tab_statistics s
 WHERE table_name NOT LIKE 'BIN$%' -- bug 9930151 reported by brad peek
   AND NOT EXISTS (
SELECT /*+ &&top_level_hints. */ NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 GROUP BY
       owner, object_type
 ORDER BY
       owner, object_type
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Table Columns Summary';
DEF main_table = '&&dva_view_prefix.TAB_COLS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
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
  FROM &&dva_object_prefix.tab_cols c
 WHERE table_name NOT LIKE 'BIN$%' -- bug 9930151 reported by brad peek
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
   AND NOT EXISTS (
SELECT /*+ &&top_level_hints. */ NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = c.owner
   AND e.table_name = c.table_name 
)
 GROUP BY
       owner
 ORDER BY
       owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Indexes Summary';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       COUNT(DISTINCT table_name) tables_count,
       COUNT(*) indexes_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(partitioned, 'YES', 1, 0)) partitioned,
       SUM(DECODE(temporary, 'Y', 1, 0)) temporary,
       SUM(DECODE(status, 'UNUSABLE', 1, 0)) unusable,
       &&skip_10g_column.SUM(DECODE(visibility, 'INVISIBLE', 1, 0)) invisible,
       SUM(DECODE(logging, 'YES', 0, 1)) not_logging,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(flash_cache, 'KEEP', 1, 0)) keep_flash_cache,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(cell_flash_cache, 'KEEP', 1, 0)) keep_cell_flash_cache,
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
  FROM &&dva_object_prefix.indexes
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 GROUP BY
       owner
 ORDER BY
       owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Ind Summary';
DEF main_table = '&&dva_view_prefix.IND_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
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
  FROM &&dva_object_prefix.ind_statistics
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 GROUP BY
       owner, object_type
 ORDER BY
       owner, object_type
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Table Partitions Summary';
DEF main_table = '&&dva_view_prefix.TAB_PARTITIONS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       table_owner,
       COUNT(DISTINCT table_name) tables_count,
       COUNT(*) partitions_count,
       SUM(DECODE(composite, 'YES', 1, 0)) subpartitioned,
       SUM(subpartition_count) subpartition_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(logging, 'YES', 0, 1)) not_logging,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(flash_cache, 'KEEP', 1, 0)) keep_flash_cache,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(cell_flash_cache, 'KEEP', 1, 0)) keep_cell_flash_cache,
       SUM(DECODE(compression, 'ENABLED', 1, 0)) compression,
       &&skip_10g_column.SUM(DECODE(compress_for, 'BASIC', 1, 0)) compress_for_basic,
       &&skip_10g_column.SUM(DECODE(compress_for, 'OLTP', 1, 0)) compress_for_oltp,
       &&skip_10g_column.SUM(CASE WHEN compress_for IN 
       &&skip_10g_column.('ARCHIVE HIGH', 'ARCHIVE LOW', 'QUERY HIGH', 'QUERY LOW') 
       &&skip_10g_column.THEN 1 ELSE 0 END) compress_for_hcc,
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
  FROM &&dva_object_prefix.tab_partitions
 WHERE table_owner NOT IN &&exclusion_list.
   AND table_owner NOT IN &&exclusion_list2.
 GROUP BY
       table_owner
 ORDER BY
       table_owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Index Partitions Summary';
DEF main_table = '&&dva_view_prefix.IND_PARTITIONS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       index_owner,
       COUNT(DISTINCT index_name) indexes_count,
       COUNT(*) partitions_count,
       SUM(DECODE(composite, 'YES', 1, 0)) subpartitioned,
       SUM(subpartition_count) subpartition_count,
       SUM(DECODE(last_analyzed, NULL, 1, 0)) not_analyzed,
       SUM(DECODE(status, 'UNUSABLE', 1, 0)) unusable,
       SUM(DECODE(logging, 'YES', 0, 1)) not_logging,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(flash_cache, 'KEEP', 1, 0)) keep_flash_cache,
       &&skip_10g_column.&&skip_11r1_column.SUM(DECODE(cell_flash_cache, 'KEEP', 1, 0)) keep_cell_flash_cache,
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
  FROM &&dva_object_prefix.ind_partitions
 WHERE index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
 GROUP BY
       index_owner
 ORDER BY
       index_owner
]';
END;
/
@@edb360_9a_pre_one.sql

REM dmk 14.11.2018 - report of partitioned tables, partitioning type and size
column owner heading 'Table|Owner'
column table_name heading 'Table|Name'
column autolist heading 'Auto|List' 
column autolist_Subpartition heading 'Auto|List|Subpart' 
column interval_Subpartition heading 'Interval|Subpart' 
column partitioning_type heading 'Part|Type'
column Subpartitioning_type heading 'Subpart|Type'
column part_column_list heading 'Partition|Column|List' 
column Subp_column_list heading 'Subpart|Column|List' 
column part_num_rows heading 'Part''n|Rows'
column Subp_num_rows heading 'Subpart|Rows'
column part_blocks heading 'Part''n|Blocks'
column Subp_blocks heading 'Subpart|Blocks'
column part_tablespaces heading 'Distinct|Part''n|Tablespaces'
column Subp_tablespaces heading 'Distinct|Subpart|Tablespaces'
column part_segments_created heading 'Part''n|Segments|Created'
column Subp_segments_created heading 'Subpart|Segments|Created'
column part_compression_enabled heading 'Compress|Enabled|Parts' 
column Subp_compression_enabled heading 'Compress|Enabled|Subparts' 
column part_compressfor_basic heading 'Simple|Compress|Parts' 
column Subp_compressfor_basic heading 'Simple|Compress|Subparts' 
column part_compressfor_queryhigh   heading 'HCC|Query|High|Parts' 
column Subp_compressfor_queryhigh   heading 'HCC|Query|High|Subparts' 
column part_compressfor_querylow    heading 'HCC|Query|Low|Parts' 
column Subp_compressfor_querylow    heading 'HCC|Query|Low|Subparts' 
column part_compressfor_archivehigh heading 'HCC|Archive|High|Parts' 
column Subp_compressfor_archivehigh heading 'HCC|Archive|High|Subparts' 
column part_compressfor_archivelow  heading 'HCC|Archive|Low|Parts' 
column Subp_compressfor_archivelow  heading 'HCC|Archive|Low|Subparts' 
column part_intervals heading 'Part''n|Intervals'
column Subp_intervals heading 'Subpart|Intervals'
column part_count heading 'Number of|Parts'
column Subp_count heading 'Number of|Subparts'
DEF title = 'Table Partitioning';
DEF main_table = '&&dva_view_prefix.PART_TABLES';
BEGIN
  :sql_text := q'[
WITH pc AS (
SELECT owner, name table_name
,      LISTAGG(column_name,', ') WITHIN GROUP (ORDER BY column_position) part_column_list
FROM   &&dva_object_prefix.part_key_columns
WHERE  object_type = 'TABLE'
GROUP BY owner, name
), sc as (
SELECT owner, name table_name
,      LISTAGG(column_name,', ') WITHIN GROUP (ORDER BY column_position) subp_column_list
FROM   &&dva_object_prefix.subpart_key_columns
WHERE  object_type = 'TABLE'
GROUP BY owner, name
), tp as (
SELECT table_owner owner, table_name
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
,      SUM(DECODE(interval,'YES',1)) part_intervals
,      SUM(DECODE(segment_created,'YES',1)) part_segments_created
FROM   &&dva_object_prefix.tab_partitions
GROUP BY table_owner, table_name
), sp as (
SELECT table_owner owner, table_name
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
,      SUM(DECODE(interval,'YES',1)) subp_intervals
,      SUM(DECODE(segment_created,'YES',1)) subp_segments_created
FROM   &&dva_object_prefix.tab_subpartitions
GROUP BY table_owner, table_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
  p.owner, p.table_name
, p.partitioning_type
, pc.part_column_list]';

  FOR i IN (
    SELECT column_name 
    FROM   &&dva_object_prefix.tab_columns 
    WHERE  table_name = '&&dva_object_prefix.PART_TABLES'
    AND    column_name IN('INTERVAL','AUTOLIST')
    ORDER BY column_id
  ) LOOP
    :sql_text := :sql_text || ',NULLIF('||i.column_name||',''NO'') '||lower(i.column_name);
  END LOOP;

  :sql_text := :sql_text || 
q'[,tp.part_count, tp.part_intervals
,tp.part_num_rows, tp.part_blocks, tp.part_segments_created
,tp.part_tablespaces
,tp.part_compression_enabled
,tp.part_compressfor_basic
,tp.part_compressfor_queryhigh
,tp.part_compressfor_querylow
,tp.part_compressfor_archivehigh
,tp.part_compressfor_archivelow
, NULLIF(p.subpartitioning_type,'NONE') subpartitioning_type
--,DEF_SUBPARTITION_COUNT
, sc.subp_column_list]';

  FOR i IN (
    SELECT column_name 
    FROM   &&dva_object_prefix.tab_columns 
    WHERE  table_name = '&&dva_object_prefix.PART_TABLES'
    AND    column_name IN('INTERVAL_SUBPARTITION','AUTOLIST_SUBPARTITION')
    ORDER BY column_id
  ) LOOP
    :sql_text := :sql_text || ',NULLIF('||i.column_name||',''NO'') '||lower(i.column_name);
  END LOOP;

  :sql_text := :sql_text || 
q'[,sp.subp_count, sp.subp_intervals
,sp.subp_num_rows, sp.subp_blocks, sp.subp_segments_created
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
  FROM &&dva_object_prefix.part_Tables p
       LEFT OUTER JOIN pc ON pc.owner = p.owner AND pc.table_name = p.table_name
       LEFT OUTER JOIN sc ON sc.owner = p.owner AND sc.table_name = p.table_name
       LEFT OUTER JOIN tp ON tp.owner = p.owner AND tp.table_name = p.table_name
       LEFT OUTER JOIN sp ON sp.owner = p.owner AND sp.table_name = p.table_name
 WHERE p.owner NOT IN &&exclusion_list.
   AND p.owner NOT IN &&exclusion_list2.
   AND p.table_name NOT LIKE 'BIN%'
 ORDER BY
       p.owner, p.table_name
]';
END;
/
@@edb360_9a_pre_one.sql
column owner clear
column table_name clear
column autolist clear
column autolist_Subpartition clear
column interval_Subpartition clear
column partitioning_type     clear
column Subpartitioning_type  clear
column part_column_list      clear
column Subp_column_list      clear
column part_num_rows         clear
column Subp_num_rows         clear
column part_blocks           clear
column Subp_blocks           clear
column part_tablespaces      clear
column Subp_tablespaces      clear
column part_segments_created        clear
column Subp_segments_created        clear
column part_compression_enabled     clear
column Subp_compression_enabled     clear
column part_compressfor_basic       clear
column Subp_compressfor_basic       clear
column part_compressfor_queryhigh   clear
column Subp_compressfor_queryhigh   clear
column part_compressfor_querylow    clear
column Subp_compressfor_querylow    clear
column part_compressfor_archivehigh clear
column Subp_compressfor_archivehigh clear
column part_compressfor_archivelow  clear
column Subp_compressfor_archivelow  clear
column part_intervals clear
column Subp_intervals clear
column part_count     clear
column Subp_count     clear



REM dmk 14.11.2018 - report of usage of partitioning key columns
column column_id          heading 'Column|ID'
column column_name        heading 'Column|Name'
column num_distinct       heading 'Distinct|Values'
column sample_size        heading 'Sample|Size'
column num_nulls          heading 'Number|of Nulls'
column partitioning_level heading 'Partitioning|Level'
column partitioning_type  heading 'Partitioning|Type'
column column_position    heading 'Partitioning|Key Column|Position'
column EQUALITY_PREDS     heading 'Equality|Predicates'
column EQUIJOIN_PREDS     heading 'EquiJoin|Predicates'
column NONEQUIJOIN_PREDS  heading 'NonEquiJoin|Predicates'
column RANGE_PREDS        heading 'Range|Predicates'
column LIKE_PREDS         heading 'Like|Predicates'
column NULL_PREDS         heading 'NULL|Predicates'
DEF title = 'Partitioning Keys and Column Usage Statistics';
DEF main_table = 'sys.col_usage$';
BEGIN
  :sql_text := q'[
WITH k as (
SELECT owner, name, column_position, column_name
,      'Partition' partitioning_level
FROM   &&dva_object_prefix.part_key_columns
WHERE  object_type = 'TABLE'
AND    owner NOT IN &&exclusion_list.
AND    owner NOT IN &&exclusion_list2.
UNION ALL
SELECT owner, name, column_position, column_name
,      'Subpartition'
FROM   &&dva_object_prefix.subpart_key_columns
WHERE  object_type = 'TABLE'
AND    owner NOT IN &&exclusion_list.
AND    owner NOT IN &&exclusion_list2.
), c as (
SELECT p.owner, p.table_name, o.object_id
,      c.column_id, c.column_name, c.num_distinct, c.sample_size, c.num_nulls
,         p.partitioning_type
,      p.subpartitioning_type
FROM   &&dva_object_prefix.objects o
,      &&dva_object_prefix.part_tables p
,      &&dva_object_prefix.tab_columns c
WHERE  p.owner = o.owner
AND    p.table_name = o.object_name
AND    o.object_type = 'TABLE'
AND    c.owner = p.owner
AND    c.table_name = p.table_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
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
FROM   c
  LEFT OUTER JOIN k
    ON k.owner = c.owner
   AND k.name = c.table_name
   AND k.column_name = c.column_name
  LEFT OUTER JOIN sys.col_usage$ u
    ON u.obj# = c.object_id
   AND u.intcol# = c.column_id
WHERE  (u.obj# IS NOT NULL
or     k.partitioning_level IS NOT NULL)
AND    c.owner NOT IN &&exclusion_list.
AND    c.owner NOT IN &&exclusion_list2.
ORDER BY c.owner, c.table_name, c.column_id, c.column_name
]';
END;
/
@@edb360_9a_pre_one.sql
column column_id          clear
column column_name        clear
column num_distinct       clear
column sample_size        clear
column num_nulls          clear
column partitioning_level clear
column partitioning_type  clear
column column_position    clear
column EQUALITY_PREDS     clear
column EQUIJOIN_PREDS     clear
column NONEQUIJOIN_PREDS  clear
column RANGE_PREDS        clear
column LIKE_PREDS         clear
column NULL_PREDS         clear



DEF title = 'Tables with Missing Stats';
DEF main_table = '&&dva_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, s.stale_stats, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
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
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 ORDER BY
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with Stale Stats';
DEF main_table = '&&dva_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.stale_stats = 'YES'
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 ORDER BY
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with Outdated Stats';
DEF main_table = '&&dva_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed < SYSDATE - 31
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 ORDER BY
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with Locked Stats';
DEF main_table = '&&dva_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, t.temporary, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked, e.type_name external_table_type
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t,
       &&dva_object_prefix.external_tables e
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.stattype_locked IS NOT NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND e.owner(+) = s.owner
   AND e.table_name(+) = s.table_name 
 ORDER BY
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Global Temporary Tables with Stats';
DEF main_table = '&&dva_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NOT NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'Y'
 ORDER BY
       s.owner, s.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Temp Tables with Stats';
DEF main_table = '&&dva_view_prefix.TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, t.temporary, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NOT NULL
   /*AND s.stale_stats = 'YES'*/
   AND (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND NOT EXISTS (
SELECT NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 ORDER BY
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

@@&&skip_10g_script.&&skip_11r1_script.edb360_3c_dbms_stats.sql

DEF title = 'SYS Stats for WRH$, WRI$, WRM$ and WRR$ Tables';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
table_name, blocks, num_rows, sample_size, last_analyzed
from &&dva_object_prefix.tables 
where owner = 'SYS'
and table_name like 'WR_$%'
order by table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SYS Stats for WRH$, WRI$, WRM$ and WRR$ Indexes';
DEF main_table = '&&dva_view_prefix.INDEXES';
BEGIN
  :sql_text := q'[
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
table_name, index_name, blevel, leaf_blocks, distinct_keys, num_rows, sample_size, last_analyzed
from &&dva_object_prefix.indexes 
where owner = 'SYS'
and table_name like 'WR_$%'
order by table_name, index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Table Modifications for WRH$, WRI$, WRM$ and WRR$';
DEF main_table = '&&dva_view_prefix.TAB_MODIFICATIONS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       table_name, partition_name, inserts, updates, deletes, timestamp, truncated
  FROM &&dva_object_prefix.tab_modifications
 WHERE table_owner = 'SYS'
   AND table_name LIKE 'WR_$%'
 ORDER BY
       table_name, partition_name
]';
END;
/
@@edb360_9a_pre_one.sql

column owner format  heading 'Table|Owner'
column table_owner   heading 'Table|Owner'
column table_name    heading 'Table|Name'
column index_name    heading 'Index|Name'
column column_name   heading 'Column|Name'
column object_type   heading 'Object|Type'
column object_name   heading 'Index/Extension|Name'
column column_list   heading 'Column|List'
column histogram     heading 'Histogram|Type'
column distinct_keys heading 'Distinct|Keys'
column num_distinct  heading 'Number of|Distinct|Values'
column num_buckets   heading 'Number of|Buckets'
column distinct_keys heading 'Distinct|Keys'
DEF title = 'Columns with Histograms in Extended Statistics';
REM dmk 29.11.2018 Columns with histograms that are part of a column group where the extended statistics do not have a histogram, 
REM or part of a composite index where there is no corresponding extended histogram prevent use of extended statistics.  Need extended histograms.
DEF main_table = '&&dva_view_prefix.STAT_EXTENSIONS';
BEGIN
  :sql_text := q'[
WITH i as ( /*composite indexes*/
SELECT	i.table_owner, i.table_name, i.owner index_owner, i.index_name, i.distinct_keys
,	    '('||(LISTAGG('"'||c.column_name||'"',',') WITHIN GROUP (order by c.column_position))||')' column_list
FROM	&&dva_object_prefix.indexes i
,	    &&dva_object_prefix.ind_columns c
WHERE   i.table_owner = c.table_owner
AND     i.table_name = c.table_name
AND     i.owner = c.index_owner
AND     i.index_name = c.index_name
GROUP BY i.table_owner, i.table_name, i.owner, i.index_name, i.distinct_keys
HAVING COUNT(*) > 1
), e as ( /*extended stats*/
SELECT 	e.owner, e.table_name, e.extension_name
,       CAST(e.extension AS VARCHAR(1000)) extension
,       se.histogram, se.num_buckets, se.num_distinct
FROM	&&dva_object_prefix.stat_extensions e
,       &&dva_object_prefix.tab_col_statistics se
WHERE	e.creator = 'USER'
AND     se.owner = e.owner
AND     se.table_name = e.table_name
AND     se.column_name = e.extension_name
)
SELECT	/*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
        i.table_owner, i.table_name
,       'Index' object_type
,       i.index_name object_name, i.distinct_keys, i.column_list
,       sc.column_name, sc.num_distinct, sc.num_buckets, sc.histogram
from	i
,       &&dva_object_prefix.ind_columns ic
,       &&dva_object_prefix.tab_col_statistics sc
WHERE 	ic.table_owner = i.table_owner
AND     ic.table_name = i.table_name
AND     ic.index_owner = i.index_owner
AND 	ic.index_name = i.index_name
AND     sc.owner = i.table_owner
AND     sc.table_name = ic.table_name
AND     sc.column_name = ic.column_name
AND     sc.histogram != 'NONE'
AND NOT EXISTS( /*report index if no extension*/
        SELECT 'x'
        FROM    e
        WHERE   e.owner = i.table_owner
        AND     e.table_name = i.table_name
        AND     e.extension = i.column_list      
        )
AND     i.table_name NOT LIKE 'BIN$%' 
AND     i.table_owner NOT IN &&exclusion_list.
AND     i.table_owner NOT IN &&exclusion_list2.
UNION ALL
SELECT	e.owner, e.table_name
, 	    'Extension' object_type
,       e.extension_name object_name, e.num_distinct, e.extension
,       sc.column_name, sc.num_distinct, sc.num_buckets, sc.histogram
FROM	e
,       &&dva_object_prefix.tab_col_statistics sc
WHERE	e.histogram = 'NONE'
AND     e.extension LIKE '%"'||sc.column_name||'"%'
AND     sc.owner = e.owner
AND     sc.table_name = e.table_name
AND     sc.histogram != 'NONE'
AND     e.table_name NOT LIKE 'BIN$%' 
AND     e.owner NOT IN &&exclusion_list.
AND     e.owner NOT IN &&exclusion_list2.
ORDER BY 1,2,3,5
]';
END;
/
@@edb360_9a_pre_one.sql
column owner format  heading clear
column table_owner   heading clear
column table_name    heading clear
column index_name    heading clear
column column_name   heading clear
column object_type   heading clear
column object_name   heading clear
column column_list   heading clear
column histogram     heading clear
column distinct_keys heading clear
column num_distinct  heading clear
column num_buckets   heading clear
column distinct_keys heading clear
SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
