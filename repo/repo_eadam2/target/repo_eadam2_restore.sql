HOS rm repo_eadam2_logs.zip

SPO repo_eadam2_restore_log1.txt;
EXEC DBMS_APPLICATION_INFO.SET_MODULE('EADAM2','RESTORE');
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

-- parameters
HOS ls -lat repo_eadam2_*.zip

PRO
ACC tool_source_db_name  PROMPT 'source database name: '

COL tool_repo_db_name NEW_V tool_repo_db_name;
SELECT LOWER(TRIM('&&tool_source_db_name.')) tool_repo_db_name FROM DUAL;

HOS unzip -l repo_eadam2_&&tool_repo_db_name.

PRO
ACC tool_repo_user PROMPT 'tool repository user (i.e. eadam2): '

BEGIN
  IF UPPER(TRIM('&&tool_repo_user.')) = 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20000, 'SYS cannot be used as repository!');
  END IF;
END;
/

-- constants
DEF tool_repo_days = '31';
-- prefix for eadam2 tables
DEF tool_prefix_0 = 'eadam2#';
DEF tool_prefix_0e = 'eadam2e';
-- prefix for AWR "dba_hist_" views
DEF tool_prefix_1 = 'dba_hist#';
DEF tool_prefix_1e = 'dba_histe';
-- prefix for data dictionary "dba_" views
DEF tool_prefix_2 = 'dba#';
DEF tool_prefix_2e = 'dbae';
-- prefix for dynamic "gv$" views
DEF tool_prefix_3 = 'gv#';
DEF tool_prefix_3e = 'gve';
-- prefix for dynamic "v$" views
DEF tool_prefix_4 = 'v#';
DEF tool_prefix_4e = 've';
-- eadam2 directory
DEF eadam2_dir = 'EADAM2_DIR';

-- columns delimiter: "}]><[{" = "7D5D3E3C5B7B"
DEF columns_delimiter = '7D5D3E3C5B7B';
-- records delimiter: "}]><[{" + "$" + NULL + LF
DEF records_delimiter = '&&columns_delimiter.240A';

-- this grant is needed so CREATE VIEW would work, else we get "ORA-06564: object EADAM2_DIR does not exist"
GRANT READ,WRITE ON DIRECTORY &&eadam2_dir. TO &&tool_repo_user.;

-- get directory path
COL eadam2_directory_path NEW_V eadam2_directory_path;
SELECT directory_path eadam2_directory_path FROM dba_directories WHERE directory_name = UPPER('&&eadam2_dir.');

-- list files on directory path
HOS echo 'dummy' >> repo_eadam2_restore_log2.txt
HOS rm repo_eadam2_restore_log2.txt
HOS echo '*************** directory content - begin ****************' >> repo_eadam2_restore_log2.txt
HOS ls -lat &&eadam2_directory_path. >> repo_eadam2_restore_log2.txt

-- additional variables used by repo_eadam2_restore_one
COL repo_external_table_name NEW_V repo_external_table_name;
COL repo_heap_table_name NEW_V repo_heap_table_name;
COL source_view_name NEW_V source_view_name;
COL contains_long_column NEW_V contains_long_column;
COL contains_xmltype_column NEW_V contains_xmltype_column;
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
-- some NLS settings
ALTER SESSION SET NLS_TERRITORY = 'AMERICA';
ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';
ALTER SESSION SET NLS_LENGTH_SEMANTICS = 'CHAR';
-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
-- nls
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = '&&tool_date_mask.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&tool_timestamp_mask.';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = '&&tool_timestamp_tz_mask.';
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
-- Parallel Execution
------------------------------------------------------------------------------------------

--ALTER SESSION ENABLE PARALLEL QUERY;
--ALTER SESSION ENABLE PARALLEL DML;
--DEF select_hints = 'PARALLEL(4)';
--DEF insert_hints = 'APPEND PARALLEL(4)';
DEF select_hints = '';
DEF insert_hints = 'APPEND';

------------------------------------------------------------------------------------------
-- Control
------------------------------------------------------------------------------------------

--WHENEVER SQLERROR CONTINUE;
DROP TABLE &&tool_repo_user..&&tool_prefix_0e.control;
--WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE TABLE &&tool_repo_user..&&tool_prefix_0e.control
( eadam2_date    VARCHAR2(4000)
, db_id          VARCHAR2(4000)
, db_name        VARCHAR2(4000)
, platform_name  VARCHAR2(4000)
, version        VARCHAR2(4000)
, instances      VARCHAR2(4000)
, min_host_name  VARCHAR2(4000)
, max_host_name  VARCHAR2(4000)
, eadam2_version VARCHAR2(4000)
)
ORGANIZATION EXTERNAL
( TYPE ORACLE_LOADER
  DEFAULT DIRECTORY &&eadam2_dir.
  ACCESS PARAMETERS
  ( RECORDS DELIMITED BY 0x'&&records_delimiter.'
    BADFILE '&&tool_prefix_0e.control_bad.txt'
    LOGFILE '&&tool_prefix_0e.control_log.txt'
    FIELDS TERMINATED BY 0x'&&columns_delimiter.'
    LRTRIM
    MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
  )
  LOCATION ('&&tool_prefix_0.control.txt')
)
REJECT LIMIT UNLIMITED;

--WHENEVER SQLERROR CONTINUE;
DROP TABLE &&tool_repo_user..&&tool_prefix_0.control;
--WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE TABLE &&tool_repo_user..&&tool_prefix_0.control
( eadam2_date    DATE
, db_id          NUMBER
, db_name        VARCHAR2(9)
, platform_name  VARCHAR2(101)
, version        VARCHAR2(17)
, instances      NUMBER
, min_host_name  VARCHAR2(64)
, max_host_name  VARCHAR2(64)
, eadam2_version VARCHAR2(5)
);

HOS unzip -o repo_eadam2_&&tool_repo_db_name. &&tool_prefix_0.control.txt >> repo_eadam2_restore_log2.txt

INSERT INTO &&tool_repo_user..&&tool_prefix_0.control
SELECT * FROM &&tool_repo_user..&&tool_prefix_0e.control;

DROP TABLE &&tool_repo_user..&&tool_prefix_0e.control;

EXEC DBMS_STATS.GATHER_TABLE_STATS('&&tool_repo_user.', '&&tool_prefix_0.control');

HOS rm &&tool_prefix_0.control.txt >> repo_eadam2_restore_log2.txt
HOS zip -m repo_eadam2_logs &&tool_prefix_0e.control_bad.txt &&tool_prefix_0e.control_log.txt >> repo_eadam2_restore_log2.txt
HOS zip repo_eadam2_logs repo_eadam2_restore_log1.txt >> repo_eadam2_restore_log2.txt
HOS zip repo_eadam2_logs repo_eadam2_restore_log2.txt

------------------------------------------------------------------------------------------
-- Tables and Columns
------------------------------------------------------------------------------------------

--WHENEVER SQLERROR CONTINUE;
DROP TABLE &&tool_repo_user..&&tool_prefix_0e.tab_columns;
--WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE TABLE &&tool_repo_user..&&tool_prefix_0e.tab_columns
( view_name      VARCHAR2(4000)
, table_name     VARCHAR2(4000)
, column_name    VARCHAR2(4000)
, data_type      VARCHAR2(4000)
, data_length    VARCHAR2(4000)
, data_precision VARCHAR2(4000)
, data_scale     VARCHAR2(4000)
, nullable       VARCHAR2(4000)
, column_id      VARCHAR2(4000)
, char_length    VARCHAR2(4000)
, char_used      VARCHAR2(4000)
)
ORGANIZATION EXTERNAL
( TYPE ORACLE_LOADER
  DEFAULT DIRECTORY &&eadam2_dir.
  ACCESS PARAMETERS
  ( RECORDS DELIMITED BY 0x'&&records_delimiter.'
    BADFILE '&&tool_prefix_0e.tab_columns_bad.txt'
    LOGFILE '&&tool_prefix_0e.tab_columns_log.txt'
    FIELDS TERMINATED BY 0x'&&columns_delimiter.'
    LRTRIM
    MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
  )
  LOCATION ('&&tool_prefix_0.tab_columns.txt')
)
REJECT LIMIT UNLIMITED;

--WHENEVER SQLERROR CONTINUE;
DROP TABLE &&tool_repo_user..&&tool_prefix_0.tab_columns;
--WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE TABLE &&tool_repo_user..&&tool_prefix_0.tab_columns
( view_name      VARCHAR2(128)
, table_name     VARCHAR2(30)
, column_name    VARCHAR2(128)
, data_type      VARCHAR2(128)
, data_length    NUMBER
, data_precision NUMBER
, data_scale     NUMBER
, nullable       VARCHAR2(1)
, column_id      NUMBER
, char_length    NUMBER
, char_used      VARCHAR2(1)
) COMPRESS;

HOS unzip -o repo_eadam2_&&tool_repo_db_name. &&tool_prefix_0.tab_columns.txt >> repo_eadam2_restore_log2.txt

INSERT /*+ APPEND */ INTO &&tool_repo_user..&&tool_prefix_0.tab_columns
SELECT * FROM &&tool_repo_user..&&tool_prefix_0e.tab_columns;

DROP TABLE &&tool_repo_user..&&tool_prefix_0e.tab_columns;

EXEC DBMS_STATS.GATHER_TABLE_STATS('&&tool_repo_user.', '&&tool_prefix_0.tab_columns');

HOS rm &&tool_prefix_0.tab_columns.txt >> repo_eadam2_restore_log2.txt
HOS zip -m repo_eadam2_logs &&tool_prefix_0e.tab_columns_bad.txt &&tool_prefix_0e.tab_columns_log.txt >> repo_eadam2_restore_log2.txt
HOS zip repo_eadam2_logs repo_eadam2_restore_log1.txt >> repo_eadam2_restore_log2.txt
HOS zip repo_eadam2_logs repo_eadam2_restore_log2.txt

------------------------------------------------------------------------------------------
-- template used on each table
------------------------------------------------------------------------------------------

VAR script_template CLOB;
VAR script_one CLOB;

BEGIN
:script_template := q'[
--WHENEVER SQLERROR CONTINUE;
DROP TABLE &&tool_repo_user..<EXTERNAL_TABLE_NAME>;
--WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE TABLE &&tool_repo_user..<EXTERNAL_TABLE_NAME>
(<EXTERNAL_TABLE_COLUMN_LIST>
)
ORGANIZATION EXTERNAL
( TYPE ORACLE_LOADER
  DEFAULT DIRECTORY &&eadam2_dir.
  ACCESS PARAMETERS
  ( RECORDS DELIMITED BY 0x'&&records_delimiter.'
    BADFILE '<EXTERNAL_TABLE_NAME>_bad.txt'
    LOGFILE '<EXTERNAL_TABLE_NAME>_log.txt'
    FIELDS TERMINATED BY 0x'&&columns_delimiter.'
    LRTRIM
    MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
  )
  LOCATION ('<HEAP_TABLE_NAME>.txt')
)
REJECT LIMIT UNLIMITED;

--WHENEVER SQLERROR CONTINUE;
DROP TABLE &&tool_repo_user..<HEAP_TABLE_NAME>;
--WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE TABLE &&tool_repo_user..<HEAP_TABLE_NAME>
(<HEAP_TABLE_COLUMN_LIST>
) COMPRESS;

HOS unzip -o repo_eadam2_&&tool_repo_db_name. <HEAP_TABLE_NAME>.txt >> repo_eadam2_restore_log2.txt

INSERT /*+ &&insert_hints. */ INTO &&tool_repo_user..<HEAP_TABLE_NAME> <INSERT_COLUMN_LIST>
SELECT /*+ &&select_hints. */ <SELECT_COLUMN_LIST> FROM &&tool_repo_user..<EXTERNAL_TABLE_NAME>;

DROP TABLE &&tool_repo_user..<EXTERNAL_TABLE_NAME>;

EXEC DBMS_STATS.GATHER_TABLE_STATS('&&tool_repo_user.', '<HEAP_TABLE_NAME>');

HOS rm <HEAP_TABLE_NAME>.txt >> repo_eadam2_restore_log2.txt
HOS zip -m repo_eadam2_logs <EXTERNAL_TABLE_NAME>_bad.txt <EXTERNAL_TABLE_NAME>_log.txt >> repo_eadam2_restore_log2.txt
HOS zip repo_eadam2_logs repo_eadam2_restore_log1.txt >> repo_eadam2_restore_log2.txt
HOS zip repo_eadam2_logs repo_eadam2_restore_log2.txt
]';
END;
/

PRINT script_template;

------------------------------------------------------------------------------------------
-- create tool repository. it overrides existing tables.
------------------------------------------------------------------------------------------

SPO OFF;

@@repo_eadam2_restore_one.sql dba_2pc_neighbors
@@repo_eadam2_restore_one.sql dba_2pc_pending
@@repo_eadam2_restore_one.sql dba_all_tables
@@repo_eadam2_restore_one.sql dba_audit_mgmt_config_params
@@repo_eadam2_restore_one.sql dba_autotask_client
@@repo_eadam2_restore_one.sql dba_autotask_client_history
@@repo_eadam2_restore_one.sql dba_cons_columns
@@repo_eadam2_restore_one.sql dba_constraints
@@repo_eadam2_restore_one.sql dba_data_files
@@repo_eadam2_restore_one.sql dba_db_links
@@repo_eadam2_restore_one.sql dba_extents
@@repo_eadam2_restore_one.sql dba_external_tables
@@repo_eadam2_restore_one.sql dba_feature_usage_statistics
@@repo_eadam2_restore_one.sql dba_free_space
@@repo_eadam2_restore_one.sql dba_high_water_mark_statistics
@@repo_eadam2_restore_one.sql dba_hist_active_sess_history
@@repo_eadam2_restore_one.sql dba_hist_database_instance
@@repo_eadam2_restore_one.sql dba_hist_event_histogram
@@repo_eadam2_restore_one.sql dba_hist_ic_client_stats
@@repo_eadam2_restore_one.sql dba_hist_ic_device_stats
@@repo_eadam2_restore_one.sql dba_hist_interconnect_pings
@@repo_eadam2_restore_one.sql dba_hist_memory_resize_ops
@@repo_eadam2_restore_one.sql dba_hist_memory_target_advice
@@repo_eadam2_restore_one.sql dba_hist_osstat
@@repo_eadam2_restore_one.sql dba_hist_parameter
@@repo_eadam2_restore_one.sql dba_hist_pgastat
@@repo_eadam2_restore_one.sql dba_hist_resource_limit
@@repo_eadam2_restore_one.sql dba_hist_seg_stat
@@repo_eadam2_restore_one.sql dba_hist_service_name
@@repo_eadam2_restore_one.sql dba_hist_sga
@@repo_eadam2_restore_one.sql dba_hist_sgastat
@@repo_eadam2_restore_one.sql dba_hist_snapshot
@@repo_eadam2_restore_one.sql dba_hist_sql_plan
@@repo_eadam2_restore_one.sql dba_hist_sqlstat
@@repo_eadam2_restore_one.sql dba_hist_sqltext
@@repo_eadam2_restore_one.sql dba_hist_sys_time_model
@@repo_eadam2_restore_one.sql dba_hist_sysmetric_history
@@repo_eadam2_restore_one.sql dba_hist_sysmetric_summary
@@repo_eadam2_restore_one.sql dba_hist_sysstat
@@repo_eadam2_restore_one.sql dba_hist_system_event
@@repo_eadam2_restore_one.sql dba_hist_tbspc_space_usage
@@repo_eadam2_restore_one.sql dba_hist_wr_control
@@repo_eadam2_restore_one.sql dba_ind_columns
@@repo_eadam2_restore_one.sql dba_ind_partitions
@@repo_eadam2_restore_one.sql dba_ind_statistics
@@repo_eadam2_restore_one.sql dba_ind_subpartitions
@@repo_eadam2_restore_one.sql dba_indexes
@@repo_eadam2_restore_one.sql dba_jobs
@@repo_eadam2_restore_one.sql dba_jobs_running
@@repo_eadam2_restore_one.sql dba_lob_partitions
@@repo_eadam2_restore_one.sql dba_lob_subpartitions
@@repo_eadam2_restore_one.sql dba_lobs
@@repo_eadam2_restore_one.sql dba_obj_audit_opts
@@repo_eadam2_restore_one.sql dba_objects
@@repo_eadam2_restore_one.sql dba_pdbs
@@repo_eadam2_restore_one.sql dba_priv_audit_opts
@@repo_eadam2_restore_one.sql dba_procedures
@@repo_eadam2_restore_one.sql dba_profiles
@@repo_eadam2_restore_one.sql dba_recyclebin
@@repo_eadam2_restore_one.sql dba_registry
@@repo_eadam2_restore_one.sql dba_registry_hierarchy
@@repo_eadam2_restore_one.sql dba_registry_history
@@repo_eadam2_restore_one.sql dba_registry_sqlpatch
@@repo_eadam2_restore_one.sql dba_role_privs
@@repo_eadam2_restore_one.sql dba_roles
@@repo_eadam2_restore_one.sql dba_rsrc_consumer_group_privs
@@repo_eadam2_restore_one.sql dba_rsrc_consumer_groups
@@repo_eadam2_restore_one.sql dba_rsrc_group_mappings
@@repo_eadam2_restore_one.sql dba_rsrc_io_calibrate
@@repo_eadam2_restore_one.sql dba_rsrc_mapping_priority
@@repo_eadam2_restore_one.sql dba_rsrc_plan_directives
@@repo_eadam2_restore_one.sql dba_rsrc_plans
@@repo_eadam2_restore_one.sql dba_scheduler_job_log
@@repo_eadam2_restore_one.sql dba_scheduler_jobs
@@repo_eadam2_restore_one.sql dba_scheduler_windows
@@repo_eadam2_restore_one.sql dba_scheduler_wingroup_members
@@repo_eadam2_restore_one.sql dba_segments
@@repo_eadam2_restore_one.sql dba_sequences
@@repo_eadam2_restore_one.sql dba_source
@@repo_eadam2_restore_one.sql dba_sql_patches
@@repo_eadam2_restore_one.sql dba_sql_plan_baselines
@@repo_eadam2_restore_one.sql dba_sql_plan_dir_objects
@@repo_eadam2_restore_one.sql dba_sql_plan_directives
@@repo_eadam2_restore_one.sql dba_sql_profiles
@@repo_eadam2_restore_one.sql dba_stat_extensions
@@repo_eadam2_restore_one.sql dba_stmt_audit_opts
@@repo_eadam2_restore_one.sql dba_synonyms
@@repo_eadam2_restore_one.sql dba_sys_privs
@@repo_eadam2_restore_one.sql dba_tab_cols
@@repo_eadam2_restore_one.sql dba_tab_columns
@@repo_eadam2_restore_one.sql dba_tab_modifications
@@repo_eadam2_restore_one.sql dba_tab_partitions
@@repo_eadam2_restore_one.sql dba_tab_privs
@@repo_eadam2_restore_one.sql dba_tab_statistics
@@repo_eadam2_restore_one.sql dba_tab_subpartitions
@@repo_eadam2_restore_one.sql dba_tables
@@repo_eadam2_restore_one.sql dba_tablespace_groups
@@repo_eadam2_restore_one.sql dba_tablespaces
@@repo_eadam2_restore_one.sql dba_temp_files
@@repo_eadam2_restore_one.sql dba_triggers
@@repo_eadam2_restore_one.sql dba_ts_quotas
@@repo_eadam2_restore_one.sql dba_unused_col_tabs
@@repo_eadam2_restore_one.sql dba_users
@@repo_eadam2_restore_one.sql dba_views
@@repo_eadam2_restore_one.sql gv$active_session_history
@@repo_eadam2_restore_one.sql gv$archive_dest
@@repo_eadam2_restore_one.sql gv$archived_log
@@repo_eadam2_restore_one.sql gv$asm_disk_iostat
@@repo_eadam2_restore_one.sql gv$database
@@repo_eadam2_restore_one.sql gv$dataguard_status
@@repo_eadam2_restore_one.sql gv$event_name
@@repo_eadam2_restore_one.sql gv$eventmetric
@@repo_eadam2_restore_one.sql gv$instance
@@repo_eadam2_restore_one.sql gv$instance_recovery
@@repo_eadam2_restore_one.sql gv$latch
@@repo_eadam2_restore_one.sql gv$license
@@repo_eadam2_restore_one.sql gv$managed_standby
@@repo_eadam2_restore_one.sql gv$memory_current_resize_ops
@@repo_eadam2_restore_one.sql gv$memory_dynamic_components
@@repo_eadam2_restore_one.sql gv$memory_resize_ops
@@repo_eadam2_restore_one.sql gv$memory_target_advice
@@repo_eadam2_restore_one.sql gv$open_cursor
@@repo_eadam2_restore_one.sql gv$osstat
@@repo_eadam2_restore_one.sql gv$parameter
@@repo_eadam2_restore_one.sql gv$pga_target_advice
@@repo_eadam2_restore_one.sql gv$pgastat
@@repo_eadam2_restore_one.sql gv$pq_slave
@@repo_eadam2_restore_one.sql gv$pq_sysstat
@@repo_eadam2_restore_one.sql gv$process
@@repo_eadam2_restore_one.sql gv$process_memory
@@repo_eadam2_restore_one.sql gv$px_buffer_advice
@@repo_eadam2_restore_one.sql gv$px_process
@@repo_eadam2_restore_one.sql gv$px_process_sysstat
@@repo_eadam2_restore_one.sql gv$px_session
@@repo_eadam2_restore_one.sql gv$px_sesstat
@@repo_eadam2_restore_one.sql gv$resource_limit
@@repo_eadam2_restore_one.sql gv$result_cache_memory
@@repo_eadam2_restore_one.sql gv$result_cache_statistics
@@repo_eadam2_restore_one.sql gv$rsrc_cons_group_history
@@repo_eadam2_restore_one.sql gv$rsrc_consumer_group
@@repo_eadam2_restore_one.sql gv$rsrc_plan
@@repo_eadam2_restore_one.sql gv$rsrc_plan_history
@@repo_eadam2_restore_one.sql gv$rsrc_session_info
@@repo_eadam2_restore_one.sql gv$rsrcmgrmetric
@@repo_eadam2_restore_one.sql gv$rsrcmgrmetric_history
@@repo_eadam2_restore_one.sql gv$segstat
@@repo_eadam2_restore_one.sql gv$services
@@repo_eadam2_restore_one.sql gv$session
@@repo_eadam2_restore_one.sql gv$session_blockers
@@repo_eadam2_restore_one.sql gv$session_wait
@@repo_eadam2_restore_one.sql gv$sga
@@repo_eadam2_restore_one.sql gv$sga_target_advice
@@repo_eadam2_restore_one.sql gv$sgainfo
@@repo_eadam2_restore_one.sql gv$sgastat
@@repo_eadam2_restore_one.sql gv$sql
@@repo_eadam2_restore_one.sql gv$sql_monitor
@@repo_eadam2_restore_one.sql gv$sql_plan
@@repo_eadam2_restore_one.sql gv$sql_shared_cursor
@@repo_eadam2_restore_one.sql gv$sql_workarea_histogram
@@repo_eadam2_restore_one.sql gv$sysmetric
@@repo_eadam2_restore_one.sql gv$sysmetric_summary
@@repo_eadam2_restore_one.sql gv$sysstat
@@repo_eadam2_restore_one.sql gv$system_parameter2
@@repo_eadam2_restore_one.sql gv$system_wait_class
@@repo_eadam2_restore_one.sql gv$temp_extent_pool
@@repo_eadam2_restore_one.sql gv$undostat
@@repo_eadam2_restore_one.sql gv$waitclassmetric
@@repo_eadam2_restore_one.sql gv$waitstat
@@repo_eadam2_restore_one.sql v$archive_dest_status
@@repo_eadam2_restore_one.sql v$archived_log
@@repo_eadam2_restore_one.sql v$ash_info
@@repo_eadam2_restore_one.sql v$asm_attribute
@@repo_eadam2_restore_one.sql v$asm_client
@@repo_eadam2_restore_one.sql v$asm_disk
@@repo_eadam2_restore_one.sql v$asm_disk_stat
@@repo_eadam2_restore_one.sql v$asm_diskgroup
@@repo_eadam2_restore_one.sql v$asm_diskgroup_stat
@@repo_eadam2_restore_one.sql v$asm_file
@@repo_eadam2_restore_one.sql v$asm_template
@@repo_eadam2_restore_one.sql v$backup
@@repo_eadam2_restore_one.sql v$backup_set_details
@@repo_eadam2_restore_one.sql v$block_change_tracking
@@repo_eadam2_restore_one.sql v$cell_config
@@repo_eadam2_restore_one.sql v$cell_state
@@repo_eadam2_restore_one.sql v$controlfile
@@repo_eadam2_restore_one.sql v$database
@@repo_eadam2_restore_one.sql v$database_block_corruption
@@repo_eadam2_restore_one.sql v$datafile
@@repo_eadam2_restore_one.sql v$flashback_database_log
@@repo_eadam2_restore_one.sql v$flashback_database_stat
@@repo_eadam2_restore_one.sql v$instance
@@repo_eadam2_restore_one.sql v$io_outlier
@@repo_eadam2_restore_one.sql v$iostat_file
@@repo_eadam2_restore_one.sql v$kernel_io_outlier
@@repo_eadam2_restore_one.sql v$lgwrio_outlier
@@repo_eadam2_restore_one.sql v$log
@@repo_eadam2_restore_one.sql v$log_history
@@repo_eadam2_restore_one.sql v$logfile
@@repo_eadam2_restore_one.sql v$mystat
@@repo_eadam2_restore_one.sql v$nonlogged_block
@@repo_eadam2_restore_one.sql v$option
@@repo_eadam2_restore_one.sql v$parallel_degree_limit_mth
@@repo_eadam2_restore_one.sql v$parameter
@@repo_eadam2_restore_one.sql v$pdbs
@@repo_eadam2_restore_one.sql v$recovery_area_usage
@@repo_eadam2_restore_one.sql v$recovery_file_dest
@@repo_eadam2_restore_one.sql v$restore_point
@@repo_eadam2_restore_one.sql v$rman_backup_job_details
@@repo_eadam2_restore_one.sql v$rman_output
@@repo_eadam2_restore_one.sql v$segstat
@@repo_eadam2_restore_one.sql v$spparameter
@@repo_eadam2_restore_one.sql v$standby_log
@@repo_eadam2_restore_one.sql v$sys_time_model
@@repo_eadam2_restore_one.sql v$sysaux_occupants
@@repo_eadam2_restore_one.sql v$system_parameter2
@@repo_eadam2_restore_one.sql v$tablespace
@@repo_eadam2_restore_one.sql v$tempfile
@@repo_eadam2_restore_one.sql v$thread
@@repo_eadam2_restore_one.sql v$version

SPO repo_eadam2_restore_log1.txt APP;

------------------------------------------------------------------------------------------
-- repository summary
------------------------------------------------------------------------------------------

-- control
SELECT * FROM &&tool_repo_user..&&tool_prefix_0.control;

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

------------------------------------------------------------------------------------------
-- wrap-up
------------------------------------------------------------------------------------------

-- zip execution logs
HOS zip -m repo_eadam2_logs repo_eadam2_restore_log1.txt >> repo_eadam2_restore_log2.txt
HOS zip -mq repo_eadam2_logs repo_eadam2_restore_log2.txt

-- list file created on current directory
HOS ls -lat repo_eadam2_logs.zip

--WHENEVER SQLERROR CONTINUE;
EXEC DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);

UNDEF 1;