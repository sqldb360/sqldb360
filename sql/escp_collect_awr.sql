----------------------------------------------------------------------------------------
--
-- File name:   escp_collect_awr.sql (2016-09-01)
--
--              Enkitec Sizing and Capacity Planing eSCP
--
-- Purpose:     Collect Resources Metrics for an Oracle Database
--
-- Author:      Carlos Sierra
--
-- Usage:       Extract from AWR a subset of:
--
--                  view                         resource(s)
--                  ---------------------------- -----------------
--                  DBA_HIST_ACTIVE_SESS_HISTORY CPU
--                  DBA_HIST_SGA                 MEM
--                  DBA_HIST_PGASTAT             MEM
--                  DBA_HIST_TBSPC_SPACE_USAGE   DISK
--                  DBA_HIST_LOG                 DISK
--                  DBA_HIST_SYSSTAT             IOPS MBPS PHYR PHYW NETW IC
--                  DBA_HIST_DLM_MISC            IC
--                  DBA_HIST_OSSTAT              OS
--
--              Collections from this script are consumed by the ESCP tool.
--
-- Example:     # cd escp_collect
--              # sqlplus / as sysdba
--              SQL> START sql/escp_master.sql
--
-- Notes:       Developed and tested on 11.2.0.3, 12.1.0.2
--
-- Warning:     Requires a license for the Oracle Diagnostics Pack
--
---------------------------------------------------------------------------------------
--
DEF ESCP_MAX_DAYS = '365';
DEF ESCP_DATE_FORMAT = 'YYYY-MM-DD"T"HH24:MI:SS';

SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
ALTER SESSION SET NLS_DATE_FORMAT = '&&ESCP_DATE_FORMAT.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&ESCP_DATE_FORMAT.';

-- get host name (up to 30, stop before first '.', no special characters)
DEF escp_host_name_short = '';
COL escp_host_name_short NEW_V escp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) escp_host_name_short FROM DUAL;
SELECT SUBSTR('&&escp_host_name_short.', 1, INSTR('&&escp_host_name_short..', '.') - 1) escp_host_name_short FROM DUAL;
SELECT TRANSLATE('&&escp_host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') escp_host_name_short FROM DUAL;

-- get database name (up to 10, stop before first '.', no special characters)
COL escp_dbname_short NEW_V escp_dbname_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) escp_dbname_short FROM DUAL;
SELECT SUBSTR('&&escp_dbname_short.', 1, INSTR('&&escp_dbname_short..', '.') - 1) escp_dbname_short FROM DUAL;
SELECT TRANSLATE('&&escp_dbname_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') escp_dbname_short FROM DUAL;

-- get collection date
DEF escp_collection_yyyymmdd_hhmi = '';
COL escp_collection_yyyymmdd_hhmi NEW_V escp_collection_yyyymmdd_hhmi FOR A13;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') escp_collection_yyyymmdd_hhmi FROM DUAL;

-- Get dbid
COL escp_this_dbid NEW_V escp_this_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) escp_this_dbid FROM v$database
/

-- get collection days
DEF escp_collection_days = '&&ESCP_MAX_DAYS.';
COL escp_collection_days NEW_V escp_collection_days;
SELECT NVL(TO_CHAR(LEAST(EXTRACT(DAY FROM retention), TO_NUMBER('&&ESCP_MAX_DAYS.'))), '&&ESCP_MAX_DAYS.') escp_collection_days FROM dba_hist_wr_control WHERE dbid = &&escp_this_dbid;

COL escp_this_inst_num NEW_V escp_this_inst_num;
SELECT 'get_instance_number', TO_CHAR(instance_number) escp_this_inst_num FROM v$instance
/

DEF escp_min_snap_id = '';
COL escp_min_snap_id NEW_V escp_min_snap_id;
SELECT 'get_min_snap_id', TO_CHAR(MIN(snap_id)) escp_min_snap_id FROM dba_hist_snapshot WHERE dbid = &&escp_this_dbid. AND CAST(begin_interval_time AS DATE) > SYSDATE - &&escp_collection_days.
/
SELECT NVL('&&escp_min_snap_id.','0') escp_min_snap_id FROM DUAL
/

DEF;

---------------------------------------------------------------------------------------

SPO escp_&&escp_host_name_short._&&escp_dbname_short._&&escp_collection_yyyymmdd_hhmi..csv;

COL escp_metric_group    FOR A8;
COL escp_metric_acronym  FOR A16;
COL escp_instance_number FOR A4;
COL escp_end_date        FOR A20;
COL escp_value           FOR A128;

-- header
SELECT 'METGROUP'       escp_metric_group,
       'METRIC_ACRONYM' escp_metric_acronym,
       'INST'           escp_instance_number,
       'END_DATE'       escp_end_date,
       'VALUE'          escp_value 
  FROM DUAL
/

SELECT 'BEGIN'                    escp_metric_group,
       d.name                     escp_metric_acronym,
       TO_CHAR(i.instance_number) escp_instance_number,
       SYSDATE                    escp_end_date,
       i.host_name                escp_value 
  FROM v$instance i, 
       v$database d
/

-- collection user
SELECT 'COLLECT' escp_metric_group,
       'USER'    escp_metric_acronym,
       NULL      escp_instance_number,
       NULL      escp_end_date,
       USER      escp_value 
  FROM v$instance
/

-- collection days
SELECT 'COLLECT'                                  escp_metric_group,
       'DAYS'                                     escp_metric_acronym,
       NULL                                       escp_instance_number,
       TO_CHAR(SYSDATE - &&escp_collection_days.) escp_end_date,
       '&&escp_collection_days.'                  escp_value 
  FROM v$instance
/

---------------------------------------------------------------------------------------

-- database dbid
SELECT 'DATABASE'       escp_metric_group,
       'DBID'           escp_metric_acronym,
       NULL             escp_instance_number,
       NULL             escp_end_date,
       TO_CHAR(dbid)    escp_value 
  FROM v$database
/

-- database name
SELECT 'DATABASE'       escp_metric_group,
       'NAME'           escp_metric_acronym,
       NULL             escp_instance_number,
       NULL             escp_end_date,
       name             escp_value 
  FROM v$database
/

-- database created
SELECT 'DATABASE'       escp_metric_group,
       'CREATED'        escp_metric_acronym,
       NULL             escp_instance_number,
       NULL             escp_end_date,
       TO_CHAR(created) escp_value 
  FROM v$database
/

-- database db_unique_name
SELECT 'DATABASE'       escp_metric_group,
       'DB_UNIQUE_NAME' escp_metric_acronym,
       NULL             escp_instance_number,
       NULL             escp_end_date,
       db_unique_name   escp_value 
  FROM v$database
/

-- database instance_name_min
SELECT 'DATABASE'         escp_metric_group,
       'INST_NAME_MIN'    escp_metric_acronym,
       NULL               escp_instance_number,
       NULL               escp_end_date,
       MIN(instance_name) escp_value 
  FROM dba_hist_database_instance
 WHERE dbid = &&escp_this_dbid.
/

-- database instance_name_max
SELECT 'DATABASE'         escp_metric_group,
       'INST_NAME_MAX'    escp_metric_acronym,
       NULL               escp_instance_number,
       NULL               escp_end_date,
       MAX(instance_name) escp_value 
  FROM dba_hist_database_instance
 WHERE dbid = &&escp_this_dbid.
/

-- database host_name_min
SELECT 'DATABASE'      escp_metric_group,
       'HOST_NAME_MIN' escp_metric_acronym,
       NULL            escp_instance_number,
       NULL            escp_end_date,
       MIN(host_name)  escp_value 
  FROM dba_hist_database_instance
 WHERE dbid = &&escp_this_dbid.
/

-- database host_name_max
SELECT 'DATABASE'      escp_metric_group,
       'HOST_NAME_MAX' escp_metric_acronym,
       NULL            escp_instance_number,
       NULL            escp_end_date,
       MAX(host_name)  escp_value 
  FROM dba_hist_database_instance
 WHERE dbid = &&escp_this_dbid.
/

-- database version
SELECT 'DATABASE' escp_metric_group,
       'VERSION'  escp_metric_acronym,
       NULL       escp_instance_number,
       NULL       escp_end_date,
       version    escp_value 
  FROM v$instance
/

-- database platform_name
SELECT 'DATABASE'    escp_metric_group,
       'PLATFORM'    escp_metric_acronym,
       NULL          escp_instance_number,
       NULL          escp_end_date,
       platform_name escp_value 
  FROM v$database
/

-- database db_block_size
SELECT 'DATABASE'           escp_metric_group,
       'DB_BLOCK_SIZE'      escp_metric_acronym,
       NULL                 escp_instance_number,
       NULL                 escp_end_date,
       SUBSTR(value, 1, 10) escp_value 
  FROM v$system_parameter2
 WHERE name = 'db_block_size'
/

-- database min_instance_host_id
SELECT 'DATABASE'                    escp_metric_group,
       'MIN_INST_HOST'               escp_metric_acronym,
       TO_CHAR(MIN(instance_number)) escp_instance_number,
       NULL                          escp_end_date,
       MIN(host_name)                escp_value 
  FROM dba_hist_database_instance
 WHERE dbid = &&escp_this_dbid.
   AND instance_number IN (
SELECT MIN(instance_number) 
  FROM dba_hist_database_instance
 WHERE dbid = &&escp_this_dbid.
)
/

---------------------------------------------------------------------------------------

-- instance instance_name
WITH
all_instances AS (
SELECT instance_number, MAX(startup_time) max_startup_time
  FROM dba_hist_database_instance
 WHERE dbid = &&escp_this_dbid.
 GROUP BY 
       instance_number
)
SELECT 'INSTANCE'                 escp_metric_group,
       'INSTANCE_NAME'            escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.startup_time             escp_end_date,
       h.instance_name            escp_value
  FROM all_instances a,
       dba_hist_database_instance h
 WHERE h.dbid = &&escp_this_dbid.
   AND h.instance_number = a.instance_number
   AND h.startup_time = a.max_startup_time
 ORDER BY
       h.instance_number
/

-- instance host_name
WITH
all_instances AS (
SELECT instance_number, MAX(startup_time) max_startup_time
  FROM dba_hist_database_instance
 WHERE dbid = &&escp_this_dbid.
 GROUP BY 
       instance_number
)
SELECT 'INSTANCE'                 escp_metric_group,
       'HOST_NAME'                escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.startup_time             escp_end_date,
       h.host_name                escp_value
  FROM all_instances a,
       dba_hist_database_instance h
 WHERE h.dbid = &&escp_this_dbid.
   AND h.instance_number = a.instance_number
   AND h.startup_time = a.max_startup_time
 ORDER BY
       h.instance_number
/

---------------------------------------------------------------------------------------

-- DBA_HIST_ACTIVE_SESS_HISTORY CPU
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       'CPU'                      escp_metric_group,
       CASE h.session_state 
       WHEN 'ON CPU' THEN 'CPU' 
       ELSE 'RMCPUQ' 
       END                        escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.sample_time              escp_end_date,
       TO_CHAR(COUNT(*))          escp_value
  FROM dba_hist_active_sess_history h
 WHERE h.snap_id >= &&escp_min_snap_id.
   AND h.dbid = &&escp_this_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
   AND h.sample_time >= SYSTIMESTAMP - &&escp_collection_days.
 GROUP BY
       h.session_state,
       h.instance_number,
       h.sample_time
 ORDER BY
       h.session_state,
       h.instance_number,
       h.sample_time
/

-- DBA_HIST_SGA MEM
WITH 
dba_hist_sga_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(h.INT$DBA_HIST_SGA.sn) 
       FULL(h.INT$DBA_HIST_SGA.sga) 
       USE_HASH(h.INT$DBA_HIST_SGA.sn h.INT$DBA_HIST_SGA.sga)
       FULL(h.sn) 
       FULL(h.sga) 
       USE_HASH(h.sn h.sga)
       */
       h.snap_id,
       h.instance_number,
       SUM(h.value) value
  FROM dba_hist_sga h
 WHERE h.snap_id >= &&escp_min_snap_id.
   AND h.dbid = &&escp_this_dbid.
 GROUP BY
       h.snap_id,
       h.instance_number
),
dba_hist_snapshot_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       */
       s.snap_id,
       s.instance_number,
       s.end_interval_time
  FROM dba_hist_snapshot s
 WHERE s.snap_id >= &&escp_min_snap_id.
   AND s.dbid = &&escp_this_dbid.
   AND s.end_interval_time >= SYSTIMESTAMP - &&escp_collection_days.
)
SELECT /*+ USE_HASH(h s) */
       'MEM'                      escp_metric_group,
       'SGA'                      escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       s.end_interval_time        escp_end_date,
       TO_CHAR(h.value)           escp_value
  FROM dba_hist_sga_sqf      h,
       dba_hist_snapshot_sqf s
 WHERE s.snap_id         = h.snap_id
   AND s.instance_number = h.instance_number
 ORDER BY
       h.instance_number,
       s.end_interval_time
/

-- DBA_HIST_PGASTAT MEM
WITH 
dba_hist_pgastat_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(h.INT$DBA_HIST_PGASTAT.sn) 
       FULL(h.INT$DBA_HIST_PGASTAT.pga) 
       USE_HASH(h.INT$DBA_HIST_PGASTAT.sn h.INT$DBA_HIST_PGASTAT.pga)
       FULL(h.sn) 
       FULL(h.pga) 
       USE_HASH(h.sn h.pga)
       */
       h.snap_id,
       h.instance_number,
       h.value
  FROM dba_hist_pgastat h
 WHERE h.snap_id >= &&escp_min_snap_id.
   AND h.dbid = &&escp_this_dbid.
   AND h.name = 'total PGA allocated'
),
dba_hist_snapshot_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       */
       s.snap_id,
       s.instance_number,
       s.end_interval_time
  FROM dba_hist_snapshot s
 WHERE s.snap_id >= &&escp_min_snap_id.
   AND s.dbid = &&escp_this_dbid.
   AND s.end_interval_time >= SYSTIMESTAMP - &&escp_collection_days.
)
SELECT /*+ USE_HASH(h s) */
       'MEM'                      escp_metric_group,
       'PGA'                      escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       s.end_interval_time        escp_end_date,
       TO_CHAR(h.value)           escp_value
  FROM dba_hist_pgastat_sqf  h,
       dba_hist_snapshot_sqf s
 WHERE s.snap_id         = h.snap_id
   AND s.instance_number = h.instance_number
 ORDER BY
       h.instance_number,
       s.end_interval_time
/

-- DBA_HIST_TBSPC_SPACE_USAGE DISK
WITH 
dba_hist_tbspc_space_usage_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(h.INT$DBA_HIST_TBSPC_SPACE_USAGE.sn) 
       FULL(h.INT$DBA_HIST_TBSPC_SPACE_USAGE.tb) 
       USE_HASH(h.INT$DBA_HIST_TBSPC_SPACE_USAGE.sn h.INT$DBA_HIST_TBSPC_SPACE_USAGE.tb)
       FULL(h.sn) 
       FULL(h.tb) 
       USE_HASH(h.sn h.tb)
       */
       h.snap_id,
       h.tablespace_id,
       h.tablespace_size
  FROM dba_hist_tbspc_space_usage h
 WHERE h.snap_id >= &&escp_min_snap_id.
   AND h.dbid = &&escp_this_dbid.
),
dba_hist_snapshot_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       */
       s.snap_id,
       s.end_interval_time
  FROM dba_hist_snapshot s
 WHERE s.snap_id >= &&escp_min_snap_id.
   AND s.dbid = &&escp_this_dbid.
   AND s.instance_number = &&escp_this_inst_num.
   AND s.end_interval_time >= SYSTIMESTAMP - &&escp_collection_days.
)
SELECT /*+ USE_HASH(h s) */
       'DISK'                                         escp_metric_group,
       SUBSTR(t.contents, 1, 4)                       escp_metric_acronym,
       NULL                                           escp_instance_number,
       s.end_interval_time                            escp_end_date,
       TO_CHAR(SUM(h.tablespace_size * t.block_size)) escp_value
  FROM dba_hist_tbspc_space_usage_sqf h,
       dba_hist_snapshot_sqf          s,
       v$tablespace                   v,
       dba_tablespaces                t
 WHERE s.snap_id         = h.snap_id
   AND v.ts#             = h.tablespace_id
   AND t.tablespace_name = v.name
 GROUP BY
       t.contents,
       s.end_interval_time
 ORDER BY
       t.contents,
       s.end_interval_time
/

-- DBA_HIST_LOG DISK
WITH 
dba_hist_log_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(h.INT$DBA_HIST_LOG.sn) 
       FULL(h.INT$DBA_HIST_LOG.log) 
       USE_HASH(h.INT$DBA_HIST_LOG.sn h.INT$DBA_HIST_LOG.log)
       FULL(h.sn) 
       FULL(h.log) 
       USE_HASH(h.sn h.log)
       */
       h.snap_id,
       h.bytes,
       h.members
  FROM dba_hist_log h
 WHERE h.snap_id >= &&escp_min_snap_id.
   AND h.dbid = &&escp_this_dbid.
),
dba_hist_snapshot_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       */
       s.snap_id,
       s.end_interval_time
  FROM dba_hist_snapshot s
 WHERE s.snap_id >= &&escp_min_snap_id.
   AND s.dbid = &&escp_this_dbid.
   AND s.instance_number = &&escp_this_inst_num.
   AND s.end_interval_time >= SYSTIMESTAMP - &&escp_collection_days.
)
SELECT /*+ USE_HASH(h s) */
       'DISK'                            escp_metric_group,
       'LOG'                             escp_metric_acronym,
       NULL                              escp_instance_number,
       s.end_interval_time               escp_end_date,
       TO_CHAR(SUM(h.bytes * h.members)) escp_value
  FROM dba_hist_log_sqf      h,
       dba_hist_snapshot_sqf s
 WHERE s.snap_id = h.snap_id
 GROUP BY
       s.end_interval_time
 ORDER BY
       s.end_interval_time
/

-- DBA_HIST_SYSSTAT IOPS MBPS NETW IC
WITH
dba_hist_sysstat_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(h.INT$DBA_HIST_SYSSTAT.sn) 
       FULL(h.INT$DBA_HIST_SYSSTAT.s) 
       FULL(h.INT$DBA_HIST_SYSSTAT.nm) 
       USE_HASH(h.INT$DBA_HIST_SYSSTAT.sn h.INT$DBA_HIST_SYSSTAT.s h.INT$DBA_HIST_SYSSTAT.nm)
       FULL(h.sn) 
       FULL(h.s) 
       FULL(h.nm) 
       USE_HASH(h.sn h.s h.nm)
       */
       h.snap_id,
       h.instance_number,
       h.stat_name,
       h.value
  FROM dba_hist_sysstat h
 WHERE h.snap_id >= &&escp_min_snap_id.
   AND h.dbid = &&escp_this_dbid.
   AND h.stat_name IN (
       'physical read total IO requests',
       'physical write total IO requests',
       'redo writes',
       'physical read total bytes',
       'physical write total bytes',
       'redo size',
       'physical reads',
       'physical reads direct',
       'physical reads cache',
       'physical writes',
       'physical writes direct',
       'physical writes from cache',
       'bytes sent via SQL*Net to client',
       'bytes received via SQL*Net from client',
       'bytes sent via SQL*Net to dblink',
       'bytes received via SQL*Net from dblink',
       'gc cr blocks received',
       'gc current blocks received',
       'gc cr blocks served',
       'gc current blocks served',
       'gcs messages sent',
       'ges messages sent'
       )
),
dba_hist_snapshot_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       */
       s.snap_id,
       s.instance_number,
       s.end_interval_time
  FROM dba_hist_snapshot s
 WHERE s.snap_id >= &&escp_min_snap_id.
   AND s.dbid = &&escp_this_dbid.
   AND s.end_interval_time >= SYSTIMESTAMP - &&escp_collection_days.
)
SELECT /*+ USE_HASH(h s) */
       CASE h.stat_name
       WHEN 'physical read total IO requests'        THEN 'IOPS'
       WHEN 'physical write total IO requests'       THEN 'IOPS'
       WHEN 'redo writes'                            THEN 'IOPS'
       WHEN 'physical read total bytes'              THEN 'MBPS'
       WHEN 'physical write total bytes'             THEN 'MBPS'
       WHEN 'redo size'                              THEN 'MBPS'
       WHEN 'physical reads'                         THEN 'PHYR'
       WHEN 'physical reads direct'                  THEN 'PHYR'
       WHEN 'physical reads cache'                   THEN 'PHYR'
       WHEN 'physical writes'                        THEN 'PHYW'
       WHEN 'physical writes direct'                 THEN 'PHYW'
       WHEN 'physical writes from cache'             THEN 'PHYW'
       WHEN 'bytes sent via SQL*Net to client'       THEN 'NETW'
       WHEN 'bytes received via SQL*Net from client' THEN 'NETW'
       WHEN 'bytes sent via SQL*Net to dblink'       THEN 'NETW'
       WHEN 'bytes received via SQL*Net from dblink' THEN 'NETW'
       WHEN 'gc cr blocks received'                  THEN 'IC'
       WHEN 'gc current blocks received'             THEN 'IC'
       WHEN 'gc cr blocks served'                    THEN 'IC'
       WHEN 'gc current blocks served'               THEN 'IC'
       WHEN 'gcs messages sent'                      THEN 'IC'
       WHEN 'ges messages sent'                      THEN 'IC'
       END                                           escp_metric_group,
       CASE h.stat_name
       WHEN 'physical read total IO requests'        THEN 'RREQS'
       WHEN 'physical write total IO requests'       THEN 'WREQS'
       WHEN 'redo writes'                            THEN 'WREDO'
       WHEN 'physical read total bytes'              THEN 'RBYTES'
       WHEN 'physical write total bytes'             THEN 'WBYTES'
       WHEN 'redo size'                              THEN 'WREDOBYTES'
       WHEN 'physical reads'                         THEN 'PHYR'
       WHEN 'physical reads direct'                  THEN 'PHYRD'
       WHEN 'physical reads cache'                   THEN 'PHYRC'
       WHEN 'physical writes'                        THEN 'PHYW'
       WHEN 'physical writes direct'                 THEN 'PHYWD'
       WHEN 'physical writes from cache'             THEN 'PHYWC'
       WHEN 'bytes sent via SQL*Net to client'       THEN 'TOCLIENT'
       WHEN 'bytes received via SQL*Net from client' THEN 'FROMCLIENT'
       WHEN 'bytes sent via SQL*Net to dblink'       THEN 'TODBLINK'
       WHEN 'bytes received via SQL*Net from dblink' THEN 'FROMDBLINK'
       WHEN 'gc cr blocks received'                  THEN 'GCCRBR'
       WHEN 'gc current blocks received'             THEN 'GCCBLR'
       WHEN 'gc cr blocks served'                    THEN 'GCCRBS'
       WHEN 'gc current blocks served'               THEN 'GCCBLS'
       WHEN 'gcs messages sent'                      THEN 'GCSMS'
       WHEN 'ges messages sent'                      THEN 'GESMS'
       END                                           escp_metric_acronym,
       TO_CHAR(h.instance_number)                    escp_instance_number,
       s.end_interval_time                           escp_end_date,
       TO_CHAR(h.value)                              escp_value
  FROM dba_hist_sysstat_sqf  h,
       dba_hist_snapshot_sqf s
 WHERE s.snap_id         = h.snap_id
   AND s.instance_number = h.instance_number
 ORDER BY
       CASE h.stat_name
       WHEN 'physical read total IO requests'        THEN 1.1
       WHEN 'physical write total IO requests'       THEN 1.2
       WHEN 'redo writes'                            THEN 1.3
       WHEN 'physical read total bytes'              THEN 2.1
       WHEN 'physical write total bytes'             THEN 2.2
       WHEN 'redo size'                              THEN 2.3
       WHEN 'physical reads'                         THEN 3.1
       WHEN 'physical reads direct'                  THEN 3.2
       WHEN 'physical reads cache'                   THEN 3.3
       WHEN 'physical writes'                        THEN 4.1
       WHEN 'physical writes direct'                 THEN 4.2
       WHEN 'physical writes from cache'             THEN 4.3
       WHEN 'bytes sent via SQL*Net to client'       THEN 5.1
       WHEN 'bytes received via SQL*Net from client' THEN 5.2
       WHEN 'bytes sent via SQL*Net to dblink'       THEN 5.3
       WHEN 'bytes received via SQL*Net from dblink' THEN 5.4
       WHEN 'gc cr blocks received'                  THEN 6.1
       WHEN 'gc current blocks received'             THEN 6.2
       WHEN 'gc cr blocks served'                    THEN 6.3
       WHEN 'gc current blocks served'               THEN 6.4
       WHEN 'gcs messages sent'                      THEN 6.5
       WHEN 'ges messages sent'                      THEN 6.6
       ELSE 9.9 
       END,
       h.instance_number,
       s.end_interval_time
/

-- DBA_HIST_DLM_MISC IC
WITH 
dba_hist_dlm_misc_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(h.INT$DBA_HIST_DLM_MISC.sn) 
       FULL(h.INT$DBA_HIST_DLM_MISC.dlm) 
       USE_HASH(h.INT$DBA_HIST_DLM_MISC.sn h.INT$DBA_HIST_DLM_MISC.dlm)
       FULL(h.sn) 
       FULL(h.dlm) 
       USE_HASH(h.sn h.dlm)
       */
       h.snap_id,
       h.instance_number,
       h.name,
       h.value
  FROM dba_hist_dlm_misc h
 WHERE h.snap_id >= &&escp_min_snap_id.
   AND h.dbid = &&escp_this_dbid.
   AND h.name IN (
       'gcs msgs received',
       'ges msgs received'
       )
),
dba_hist_snapshot_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       */
       s.snap_id,
       s.instance_number,
       s.end_interval_time
  FROM dba_hist_snapshot s
 WHERE s.snap_id >= &&escp_min_snap_id.
   AND s.dbid = &&escp_this_dbid.
   AND s.end_interval_time >= SYSTIMESTAMP - &&escp_collection_days.
)
SELECT /*+ USE_HASH(h s) */
       'IC'                       escp_metric_group,
       CASE h.name
       WHEN 'gcs msgs received' THEN 'GCSMR'
       WHEN 'ges msgs received' THEN 'GESMR'
       END                        escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       s.end_interval_time        escp_end_date,
       TO_CHAR(h.value)           escp_value
  FROM dba_hist_dlm_misc_sqf h,
       dba_hist_snapshot_sqf s
 WHERE s.snap_id         = h.snap_id
   AND s.instance_number = h.instance_number
 ORDER BY
       CASE h.name
       WHEN 'gcs msgs received' THEN 1
       WHEN 'ges msgs received' THEN 2
       ELSE 9 
       END,
       h.instance_number,
       s.end_interval_time
/

-- DBA_HIST_OSSTAT OS
WITH
dba_hist_osstat_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(h.INT$DBA_HIST_OSSTAT.sn) 
       FULL(h.INT$DBA_HIST_OSSTAT.s) 
       FULL(h.INT$DBA_HIST_OSSTAT.nm) 
       USE_HASH(h.INT$DBA_HIST_OSSTAT.sn h.INT$DBA_HIST_OSSTAT.s h.INT$DBA_HIST_OSSTAT.nm)
       FULL(h.sn) 
       FULL(h.s) 
       FULL(h.nm) 
       USE_HASH(h.sn h.s h.nm)
       */
       h.snap_id,
       h.instance_number,
       h.stat_name,
       h.value
  FROM dba_hist_osstat h
 WHERE h.snap_id >= &&escp_min_snap_id.
   AND h.dbid = &&escp_this_dbid.
   AND h.stat_name IN (
       'LOAD', 
       'NUM_CPUS', 
       'NUM_CPU_CORES', 
       'PHYSICAL_MEMORY_BYTES',
       'IDLE_TIME',
       'BUSY_TIME',
       'USER_TIME',
       'SYS_TIME',
       'IOWAIT_TIME',
       'NICE_TIME', 
       'OS_CPU_WAIT_TIME', 
       'RSRC_MGR_CPU_WAIT_TIME'
       )
),
dba_hist_snapshot_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       */
       s.snap_id,
       s.instance_number,
       s.end_interval_time
  FROM dba_hist_snapshot s
 WHERE s.snap_id >= &&escp_min_snap_id.
   AND s.dbid = &&escp_this_dbid.
   AND s.end_interval_time >= SYSTIMESTAMP - &&escp_collection_days.
)
SELECT /*+ USE_HASH(h s) */
      'OS'                           escp_metric_group,
       CASE h.stat_name
       WHEN 'LOAD'                   THEN 'OSLOAD'
       WHEN 'NUM_CPUS'               THEN 'OSCPUS'
       WHEN 'NUM_CPU_CORES'          THEN 'OSCORES'
       WHEN 'PHYSICAL_MEMORY_BYTES'  THEN 'OSMEMBYTES'
       WHEN 'IDLE_TIME'              THEN 'OSIDLE'
       WHEN 'BUSY_TIME'              THEN 'OSBUSY'
       WHEN 'USER_TIME'              THEN 'OSUSER'
       WHEN 'SYS_TIME'               THEN 'OSSYS'
       WHEN 'IOWAIT_TIME'            THEN 'OSIOWAIT'
       WHEN 'NICE_TIME'              THEN 'OSNICEWAIT'
       WHEN 'OS_CPU_WAIT_TIME'       THEN 'OSCPUWAIT'
       WHEN 'RSRC_MGR_CPU_WAIT_TIME' THEN 'RMCPUWAIT'
       END                           escp_metric_acronym,
       TO_CHAR(h.instance_number)    escp_instance_number,
       s.end_interval_time           escp_end_date,
       TO_CHAR(h.value)              escp_value
  FROM dba_hist_osstat_sqf   h,
       dba_hist_snapshot_sqf s
 WHERE s.snap_id         = h.snap_id
   AND s.instance_number = h.instance_number
 ORDER BY
       CASE h.stat_name
       WHEN 'LOAD'                   THEN 01
       WHEN 'NUM_CPUS'               THEN 02
       WHEN 'NUM_CPU_CORES'          THEN 03
       WHEN 'PHYSICAL_MEMORY_BYTES'  THEN 04
       WHEN 'IDLE_TIME'              THEN 05
       WHEN 'BUSY_TIME'              THEN 06
       WHEN 'USER_TIME'              THEN 07
       WHEN 'SYS_TIME'               THEN 08
       WHEN 'IOWAIT_TIME'            THEN 09
       WHEN 'NICE_TIME'              THEN 10
       WHEN 'OS_CPU_WAIT_TIME'       THEN 11
       WHEN 'RSRC_MGR_CPU_WAIT_TIME' THEN 12
       ELSE 99 
       END,
       h.instance_number,
       s.end_interval_time
/   

---------------------------------------------------------------------------------------

-- collection end
SELECT 'END'                      escp_metric_group,
       d.name                     escp_metric_acronym,
       TO_CHAR(i.instance_number) escp_instance_number,
       SYSDATE                    escp_end_date,
       i.host_name                escp_value 
  FROM v$instance i, 
       v$database d
/

SPO OFF;
SET TERM ON ECHO OFF FEED ON VER ON HEA ON PAGES 14 COLSEP ' ' LIN 80 TRIMS OFF TRIM ON TI OFF TIMI OFF ARRAY 15 NUM 10 SQLBL OFF BLO ON RECSEP WR;
