HOS rm repo_edb360_create_log1.txt

SPO repo_edb360_create_log.txt;
EXEC DBMS_APPLICATION_INFO.SET_MODULE('EDB360','CREATE');
--WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO ON;
SET HEA ON;
SET LIN 1000;
SET LONG 32000000;
SET LONGC 2000;
SET PAGES 1000;
SET SERVEROUT ON;
SET TERM ON;
SET TIM ON;
SET TIMI ON;
SET TRIMS ON;
SET VER ON;
CL COL;

-- parameter
PRO
ACC tool_repo_user PROMPT 'tool repository user (i.e. edb360): '

BEGIN
  IF UPPER(TRIM('&&tool_repo_user.')) = 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20000, 'SYS cannot be used as repository!');
  END IF;
END;
/

-- constants
DEF tool_repo_days = '31';
-- prefix for AWR "dba_hist_" views
DEF tool_prefix_1 = 'dba_hist#';
-- prefix for data dictionary "dba_" views
DEF tool_prefix_2 = 'dba#';
-- prefix for dynamic "gv$" views
DEF tool_prefix_3 = 'gv#';
-- prefix for dynamic "v$" views
DEF tool_prefix_4 = 'v#';
-- compression clause
DEF compression_clause = 'COMPRESS';

-- get dbid
COL tool_repo_dbid NEW_V tool_repo_dbid;
SELECT TO_CHAR(dbid) tool_repo_dbid FROM v$database;

-- get min_snap_id
COL tool_repo_min_snap_id NEW_V tool_repo_min_snap_id;
SELECT TO_CHAR(MIN(snap_id)) tool_repo_min_snap_id FROM dba_hist_snapshot WHERE dbid = &&tool_repo_dbid. AND CAST(begin_interval_time AS DATE) > TRUNC(SYSDATE) - &&tool_repo_days.;

-- get max_snap_id
COL tool_repo_max_snap_id NEW_V tool_repo_max_snap_id;
SELECT TO_CHAR(MAX(snap_id)) tool_repo_max_snap_id FROM dba_hist_snapshot WHERE dbid = &&tool_repo_dbid.;

-- additional variables used by repo_edb360_create_one
COL repo_table_name NEW_V repo_table_name;
COL query_predicate NEW_V query_predicate;
COL contains_long_column NEW_V contains_long_column;
COL view_exists NEW_V view_exists;

------------------------------------------------------------------------------------------
-- session configuration as per edb360 experiences.
------------------------------------------------------------------------------------------

-- dates format
DEF tool_date_mask = 'YYYY-MM-DD"T"HH24:MI:SS';
DEF tool_timestamp_mask = 'YYYY-MM-DD"T"HH24:MI:SS.FF6';
DEF tool_timestamp_tz_mask = 'YYYY-MM-DD"T"HH24:MI:SS.FF6 TZH:TZM';
-- exadata
ALTER SESSION SET "_serial_direct_read" = ALWAYS;
ALTER SESSION SET "_small_table_threshold" = 1001;
-- nls
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = '&&tool_date_mask.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&tool_timestamp_mask.';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = '&&tool_timestamp_tz_mask.';
-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
-- workaround fairpoint
COL db_vers_ofe NEW_V db_vers_ofe;
SELECT TRIM('.' FROM TRIM('0' FROM version)) db_vers_ofe FROM v$instance;
ALTER SESSION SET optimizer_features_enable = '&&db_vers_ofe.';
-- to work around bug 12672969
ALTER SESSION SET "_optimizer_order_by_elimination_enabled"=false; 
-- workaround Siebel
ALTER SESSION SET optimizer_index_cost_adj = 100;
ALTER SESSION SET "_always_semi_join" = CHOOSE;
ALTER SESSION SET "_and_pruning_enabled" = TRUE;
ALTER SESSION SET "_subquery_pruning_enabled" = TRUE;
-- workaround bug 19567916
ALTER SESSION SET "_optimizer_aggr_groupby_elim" = FALSE;
-- workaround nigeria
ALTER SESSION SET "_gby_hash_aggregation_enabled" = TRUE;
ALTER SESSION SET "_hash_join_enabled" = TRUE;
ALTER SESSION SET "_optim_peek_user_binds" = TRUE;
ALTER SESSION SET "_optimizer_skip_scan_enabled" = TRUE;
ALTER SESSION SET "_optimizer_sortmerge_join_enabled" = TRUE;
ALTER SESSION SET cursor_sharing = EXACT;
ALTER SESSION SET db_file_multiblock_read_count = 128;
ALTER SESSION SET optimizer_index_caching = 0;
ALTER SESSION SET optimizer_index_cost_adj = 100;
-- workaround 21150273 and 20465582
ALTER SESSION SET optimizer_dynamic_sampling = 0;
ALTER SESSION SET "_optimizer_dsdir_usage_control"=0;
ALTER SESSION SET "_sql_plan_directive_mgmt_control" = 0;

------------------------------------------------------------------------------------------
-- create tool repository. it overrides existing tables.
------------------------------------------------------------------------------------------

@@repo_edb360_create_one.sql dba_2pc_neighbors
@@repo_edb360_create_one.sql dba_2pc_pending
@@repo_edb360_create_one.sql dba_all_tables
@@repo_edb360_create_one.sql dba_audit_mgmt_config_params
@@repo_edb360_create_one.sql dba_autotask_client
@@repo_edb360_create_one.sql dba_autotask_client_history
@@repo_edb360_create_one.sql dba_cons_columns
@@repo_edb360_create_one.sql dba_constraints
@@repo_edb360_create_one.sql dba_data_files
@@repo_edb360_create_one.sql dba_db_links
@@repo_edb360_create_one.sql dba_extents
@@repo_edb360_create_one.sql dba_external_tables
@@repo_edb360_create_one.sql dba_feature_usage_statistics
@@repo_edb360_create_one.sql dba_free_space
@@repo_edb360_create_one.sql dba_high_water_mark_statistics
@@repo_edb360_create_one.sql dba_hist_active_sess_history
@@repo_edb360_create_one.sql dba_hist_database_instance
@@repo_edb360_create_one.sql dba_hist_event_histogram
@@repo_edb360_create_one.sql dba_hist_ic_client_stats
@@repo_edb360_create_one.sql dba_hist_ic_device_stats
@@repo_edb360_create_one.sql dba_hist_interconnect_pings
@@repo_edb360_create_one.sql dba_hist_memory_resize_ops
@@repo_edb360_create_one.sql dba_hist_memory_target_advice
@@repo_edb360_create_one.sql dba_hist_osstat
@@repo_edb360_create_one.sql dba_hist_parameter
@@repo_edb360_create_one.sql dba_hist_pgastat
@@repo_edb360_create_one.sql dba_hist_resource_limit
@@repo_edb360_create_one.sql dba_hist_seg_stat
@@repo_edb360_create_one.sql dba_hist_service_name
@@repo_edb360_create_one.sql dba_hist_sga
@@repo_edb360_create_one.sql dba_hist_sgastat
@@repo_edb360_create_one.sql dba_hist_snapshot
@@repo_edb360_create_one.sql dba_hist_sql_plan
@@repo_edb360_create_one.sql dba_hist_sqlstat
@@repo_edb360_create_one.sql dba_hist_sqltext
@@repo_edb360_create_one.sql dba_hist_sys_time_model
@@repo_edb360_create_one.sql dba_hist_sysmetric_history
@@repo_edb360_create_one.sql dba_hist_sysmetric_summary
@@repo_edb360_create_one.sql dba_hist_sysstat
@@repo_edb360_create_one.sql dba_hist_system_event
@@repo_edb360_create_one.sql dba_hist_tbspc_space_usage
@@repo_edb360_create_one.sql dba_hist_wr_control
@@repo_edb360_create_one.sql dba_ind_columns
@@repo_edb360_create_one.sql dba_ind_partitions
@@repo_edb360_create_one.sql dba_ind_statistics
@@repo_edb360_create_one.sql dba_ind_subpartitions
@@repo_edb360_create_one.sql dba_indexes
@@repo_edb360_create_one.sql dba_jobs
@@repo_edb360_create_one.sql dba_jobs_running
@@repo_edb360_create_one.sql dba_lob_partitions
@@repo_edb360_create_one.sql dba_lob_subpartitions
@@repo_edb360_create_one.sql dba_lobs
@@repo_edb360_create_one.sql dba_obj_audit_opts
@@repo_edb360_create_one.sql dba_objects
@@repo_edb360_create_one.sql dba_pdbs
@@repo_edb360_create_one.sql dba_priv_audit_opts
@@repo_edb360_create_one.sql dba_procedures
@@repo_edb360_create_one.sql dba_profiles
@@repo_edb360_create_one.sql dba_recyclebin
@@repo_edb360_create_one.sql dba_registry
@@repo_edb360_create_one.sql dba_registry_hierarchy
@@repo_edb360_create_one.sql dba_registry_history
@@repo_edb360_create_one.sql dba_registry_sqlpatch
@@repo_edb360_create_one.sql dba_role_privs
@@repo_edb360_create_one.sql dba_roles
@@repo_edb360_create_one.sql dba_rsrc_consumer_group_privs
@@repo_edb360_create_one.sql dba_rsrc_consumer_groups
@@repo_edb360_create_one.sql dba_rsrc_group_mappings
@@repo_edb360_create_one.sql dba_rsrc_io_calibrate
@@repo_edb360_create_one.sql dba_rsrc_mapping_priority
@@repo_edb360_create_one.sql dba_rsrc_plan_directives
@@repo_edb360_create_one.sql dba_rsrc_plans
@@repo_edb360_create_one.sql dba_scheduler_job_log
@@repo_edb360_create_one.sql dba_scheduler_jobs
@@repo_edb360_create_one.sql dba_scheduler_windows
@@repo_edb360_create_one.sql dba_scheduler_wingroup_members
@@repo_edb360_create_one.sql dba_segments
@@repo_edb360_create_one.sql dba_sequences
@@repo_edb360_create_one.sql dba_source
@@repo_edb360_create_one.sql dba_sql_patches
@@repo_edb360_create_one.sql dba_sql_plan_baselines
@@repo_edb360_create_one.sql dba_sql_plan_dir_objects
@@repo_edb360_create_one.sql dba_sql_plan_directives
@@repo_edb360_create_one.sql dba_sql_profiles
@@repo_edb360_create_one.sql dba_stat_extensions
@@repo_edb360_create_one.sql dba_stmt_audit_opts
@@repo_edb360_create_one.sql dba_synonyms
@@repo_edb360_create_one.sql dba_sys_privs
@@repo_edb360_create_one.sql dba_tab_cols
@@repo_edb360_create_one.sql dba_tab_columns
@@repo_edb360_create_one.sql dba_tab_modifications
@@repo_edb360_create_one.sql dba_tab_partitions
@@repo_edb360_create_one.sql dba_tab_privs
@@repo_edb360_create_one.sql dba_tab_statistics
@@repo_edb360_create_one.sql dba_tab_subpartitions
@@repo_edb360_create_one.sql dba_tables
@@repo_edb360_create_one.sql dba_tablespace_groups
@@repo_edb360_create_one.sql dba_tablespaces
@@repo_edb360_create_one.sql dba_temp_files
@@repo_edb360_create_one.sql dba_triggers
@@repo_edb360_create_one.sql dba_ts_quotas
@@repo_edb360_create_one.sql dba_unused_col_tabs
@@repo_edb360_create_one.sql dba_users
@@repo_edb360_create_one.sql dba_views
@@repo_edb360_create_one.sql gv$active_session_history
@@repo_edb360_create_one.sql gv$archive_dest
@@repo_edb360_create_one.sql gv$archived_log
@@repo_edb360_create_one.sql gv$asm_disk_iostat
@@repo_edb360_create_one.sql gv$database
@@repo_edb360_create_one.sql gv$dataguard_status
@@repo_edb360_create_one.sql gv$event_name
@@repo_edb360_create_one.sql gv$eventmetric
@@repo_edb360_create_one.sql gv$instance
@@repo_edb360_create_one.sql gv$instance_recovery
@@repo_edb360_create_one.sql gv$latch
@@repo_edb360_create_one.sql gv$license
@@repo_edb360_create_one.sql gv$managed_standby
@@repo_edb360_create_one.sql gv$memory_current_resize_ops
@@repo_edb360_create_one.sql gv$memory_dynamic_components
@@repo_edb360_create_one.sql gv$memory_resize_ops
@@repo_edb360_create_one.sql gv$memory_target_advice
@@repo_edb360_create_one.sql gv$open_cursor
@@repo_edb360_create_one.sql gv$osstat
@@repo_edb360_create_one.sql gv$parameter
@@repo_edb360_create_one.sql gv$pga_target_advice
@@repo_edb360_create_one.sql gv$pgastat
@@repo_edb360_create_one.sql gv$pq_slave
@@repo_edb360_create_one.sql gv$pq_sysstat
@@repo_edb360_create_one.sql gv$process
@@repo_edb360_create_one.sql gv$process_memory
@@repo_edb360_create_one.sql gv$px_buffer_advice
@@repo_edb360_create_one.sql gv$px_process
@@repo_edb360_create_one.sql gv$px_process_sysstat
@@repo_edb360_create_one.sql gv$px_session
@@repo_edb360_create_one.sql gv$px_sesstat
@@repo_edb360_create_one.sql gv$resource_limit
@@repo_edb360_create_one.sql gv$result_cache_memory
@@repo_edb360_create_one.sql gv$result_cache_statistics
@@repo_edb360_create_one.sql gv$rsrc_cons_group_history
@@repo_edb360_create_one.sql gv$rsrc_consumer_group
@@repo_edb360_create_one.sql gv$rsrc_plan
@@repo_edb360_create_one.sql gv$rsrc_plan_history
@@repo_edb360_create_one.sql gv$rsrc_session_info
@@repo_edb360_create_one.sql gv$rsrcmgrmetric
@@repo_edb360_create_one.sql gv$rsrcmgrmetric_history
@@repo_edb360_create_one.sql gv$segstat
@@repo_edb360_create_one.sql gv$services
@@repo_edb360_create_one.sql gv$session
@@repo_edb360_create_one.sql gv$session_blockers
@@repo_edb360_create_one.sql gv$session_wait
@@repo_edb360_create_one.sql gv$sga
@@repo_edb360_create_one.sql gv$sga_target_advice
@@repo_edb360_create_one.sql gv$sgainfo
@@repo_edb360_create_one.sql gv$sgastat
@@repo_edb360_create_one.sql gv$sql
@@repo_edb360_create_one.sql gv$sql_monitor
@@repo_edb360_create_one.sql gv$sql_plan
@@repo_edb360_create_one.sql gv$sql_shared_cursor
@@repo_edb360_create_one.sql gv$sql_workarea_histogram
@@repo_edb360_create_one.sql gv$sysmetric
@@repo_edb360_create_one.sql gv$sysmetric_summary
@@repo_edb360_create_one.sql gv$sysstat
@@repo_edb360_create_one.sql gv$system_parameter2
@@repo_edb360_create_one.sql gv$system_wait_class
@@repo_edb360_create_one.sql gv$temp_extent_pool
@@repo_edb360_create_one.sql gv$undostat
@@repo_edb360_create_one.sql gv$waitclassmetric
@@repo_edb360_create_one.sql gv$waitstat
@@repo_edb360_create_one.sql v$archive_dest_status
@@repo_edb360_create_one.sql v$archived_log
@@repo_edb360_create_one.sql v$ash_info
@@repo_edb360_create_one.sql v$asm_attribute
@@repo_edb360_create_one.sql v$asm_client
@@repo_edb360_create_one.sql v$asm_disk
@@repo_edb360_create_one.sql v$asm_disk_stat
@@repo_edb360_create_one.sql v$asm_diskgroup
@@repo_edb360_create_one.sql v$asm_diskgroup_stat
@@repo_edb360_create_one.sql v$asm_file
@@repo_edb360_create_one.sql v$asm_template
@@repo_edb360_create_one.sql v$backup
@@repo_edb360_create_one.sql v$backup_set_details
@@repo_edb360_create_one.sql v$block_change_tracking
@@repo_edb360_create_one.sql v$cell_config
@@repo_edb360_create_one.sql v$cell_state
@@repo_edb360_create_one.sql v$controlfile
@@repo_edb360_create_one.sql v$database
@@repo_edb360_create_one.sql v$database_block_corruption
@@repo_edb360_create_one.sql v$datafile
@@repo_edb360_create_one.sql v$flashback_database_log
@@repo_edb360_create_one.sql v$flashback_database_stat
@@repo_edb360_create_one.sql v$instance
@@repo_edb360_create_one.sql v$io_outlier
@@repo_edb360_create_one.sql v$iostat_file
@@repo_edb360_create_one.sql v$kernel_io_outlier
@@repo_edb360_create_one.sql v$lgwrio_outlier
@@repo_edb360_create_one.sql v$log
@@repo_edb360_create_one.sql v$log_history
@@repo_edb360_create_one.sql v$logfile
@@repo_edb360_create_one.sql v$mystat
@@repo_edb360_create_one.sql v$nonlogged_block
@@repo_edb360_create_one.sql v$option
@@repo_edb360_create_one.sql v$parallel_degree_limit_mth
@@repo_edb360_create_one.sql v$parameter
@@repo_edb360_create_one.sql v$pdbs
@@repo_edb360_create_one.sql v$recovery_area_usage
@@repo_edb360_create_one.sql v$recovery_file_dest
@@repo_edb360_create_one.sql v$restore_point
@@repo_edb360_create_one.sql v$rman_backup_job_details
@@repo_edb360_create_one.sql v$rman_output
@@repo_edb360_create_one.sql v$segstat
@@repo_edb360_create_one.sql v$spparameter
@@repo_edb360_create_one.sql v$standby_log
@@repo_edb360_create_one.sql v$sys_time_model
@@repo_edb360_create_one.sql v$sysaux_occupants
@@repo_edb360_create_one.sql v$system_parameter2
@@repo_edb360_create_one.sql v$tablespace
@@repo_edb360_create_one.sql v$tempfile
@@repo_edb360_create_one.sql v$thread
@@repo_edb360_create_one.sql v$version

------------------------------------------------------------------------------------------
-- repository summary
------------------------------------------------------------------------------------------

-- list of repository tables with num_rows and blocks
SELECT table_name, num_rows, blocks FROM dba_tables WHERE owner = UPPER('&&tool_repo_user.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'))
ORDER BY table_name;

-- table count and total rows and blocks
SELECT COUNT(*) tables, SUM(num_rows), SUM(blocks) FROM dba_tables WHERE owner = UPPER('&&tool_repo_user.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'));

-- approximate repository size in GBs
SELECT ROUND(MIN(TO_NUMBER(p.value)) * SUM(blocks) / POWER(10,9), 3) approx_repo_size_gb FROM v$parameter p, dba_tables t WHERE p.name = 'db_block_size' AND t.owner = UPPER('&&tool_repo_user.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'));

SPO OFF;

-- list files created on current directory
HOS ls -lat repo_edb360_create_log1.txt

--WHENEVER SQLERROR CONTINUE;
EXEC DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);

UNDEF 1;