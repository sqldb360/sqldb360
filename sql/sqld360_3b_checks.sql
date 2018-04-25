DEF section_id = '3b';
DEF section_name = 'Statistics Checks';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Table Statistics checks';
DEF main_table = 'DBA_TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       owner, table_name, partition_name, subpartition_name,
       CASE WHEN stale_stats = 'YES' THEN 'YES' END stale_stats,
       stattype_locked locked_stats, 
       CASE WHEN empty_blocks > blocks THEN 'YES' END emptyblocks_gt_blocks,
       CASE WHEN num_rows = 0 THEN 'YES' END num_rows_0,
       CASE WHEN num_rows IS NULL THEN 'YES' END no_stats,
       CASE WHEN sample_size < num_rows THEN 'YES' END no_andv_used
  FROM dba_tab_statistics
 WHERE (owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
   AND (stale_stats = 'YES' 
     OR stattype_locked IS NOT NULL 
     OR empty_blocks > blocks
     OR num_rows = 0
     OR num_rows IS NULL
     OR sample_size < num_rows)
 ORDER BY owner, table_name, partition_position, subpartition_position
]';
END;
/
@@sqld360_9a_pre_one.sql

-- the checks are done at the global level only
-- if people will like will add partition level too but SQL may take longer
DEF title = 'Index Statistics checks';
DEF main_table = 'DBA_TAB_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       ixs.table_owner, ixs.table_name, ixs.index_name, ixs.partition_name, ixs.subpartition_name,
       CASE WHEN ixs.num_rows IS NULL THEN 'YES' END no_stats,
       CASE WHEN ixs.num_rows > ts.num_rows THEN 'YES' END more_rows_in_ind_than_tab,
       CASE WHEN ixs.clustering_factor > ts.num_rows THEN 'YES' END cluf_larger_than_tab,
       CASE WHEN ts.last_analyzed - ixs.last_analyzed > 1 THEN 'YES' END tab_ind_stats_not_sync
  FROM dba_ind_statistics ixs,
       dba_tab_statistics ts
 WHERE (ixs.table_owner, ixs.table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
   AND ts.owner = ixs.table_owner
   AND ts.table_name = ixs.table_name
   AND ts.partition_name IS NULL
   AND ts.subpartition_name IS NULL
   AND ixs.partition_name IS NULL
   AND ixs.subpartition_name IS NULL
   AND (ixs.num_rows IS NULL
     OR ixs.num_rows > ts.num_rows
     OR ixs.clustering_factor > ts.num_rows	
     OR ts.last_analyzed - ixs.last_analyzed > 1)
 ORDER BY ixs.owner, ixs.table_name, ixs.index_name, ixs.partition_position, ixs.subpartition_position
]';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;