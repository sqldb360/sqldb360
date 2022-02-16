----------------------------------------------------------------------------------------
--
-- File name:   esp_collect_requirements_statspack.sql (2016-09-01)
--
-- Purpose:     Collect Database Requirements (CPU, Memory, Disk and IO Perf)
--
-- Author:      Carlos Sierra, Rodrigo Righetti
--
-- Usage:       Collects Requirements from AWR and ASH views on databases with the 
--				Oracle Diagnostics Pack license, it also collect from Statspack starting
--				9i databases up to 12c. 				 
--				 
--              The output of this script can be used to feed a Sizing and Provisioning
--              application.
--
-- Example:     # cd esp_collect-master
--              # sqlplus / as sysdba
--              SQL> START sql/esp_master.sql
--
--  Notes:      Developed and tested on 12.1.0.2, 12.1.0.1, 11.2.0.4, 11.2.0.3, 
--				10.2.0.4, 9.2.0.8, 9.2.0.1
--             
---------------------------------------------------------------------------------------
--
SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;

-- get host name (up to 30, stop before first '.', no special characters)
DEF esp_host_name_short = '';
COL esp_host_name_short NEW_V esp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(host_name, 1, decode(instr(host_name,'.'),0,31,instr(host_name,'.'))-1)) esp_host_name_short FROM v$instance;
SELECT SUBSTR('&&esp_host_name_short.', 1, INSTR('&&esp_host_name_short..', '.') - 1) esp_host_name_short FROM DUAL;
SELECT TRANSLATE('&&esp_host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') esp_host_name_short FROM DUAL;

-- get database name (up to 10, stop before first '.', no special characters)
COL esp_dbname_short NEW_V esp_dbname_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) esp_dbname_short FROM DUAL;
SELECT SUBSTR('&&esp_dbname_short.', 1, INSTR('&&esp_dbname_short..', '.') - 1) esp_dbname_short FROM DUAL;
SELECT TRANSLATE('&&esp_dbname_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') esp_dbname_short FROM DUAL;

-- get collection date
DEF esp_collection_yyyymmdd_hhmi = '';
COL esp_collection_yyyymmdd_hhmi NEW_V esp_collection_yyyymmdd_hhmi FOR A13;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') esp_collection_yyyymmdd_hhmi FROM DUAL;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';

DEF ecr_sq_fact_hints_9i = '';
DEF ecr_date_format = 'YYYY-MM-DD/HH24:MI:SS';

CL COL;
COL ecr_collection_key NEW_V ecr_collection_key;
-- STATSPACK
-- removed ora_hash for Oracle 9i
SELECT 'get_collection_key', SUBSTR(name||(dbid||name||instance_name||host_name||systimestamp), 1, 13) ecr_collection_key FROM v$instance, v$database;
COL ecr_dbid NEW_V ecr_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) ecr_dbid FROM v$database;
--SELECT DISTINCT 'get_dbid', TO_CHAR(dbid) ecr_dbid FROM perfstat.STATS$SNAPSHOT;
COL ecr_instance_number NEW_V ecr_instance_number;
SELECT 'get_instance_number', TO_CHAR(instance_number) ecr_instance_number FROM v$instance;
COL ecr_min_snap_id NEW_V ecr_min_snap_id;
-- STATSPACK
SELECT 'get_min_snap_id', TO_CHAR(MIN(snap_id)) ecr_min_snap_id FROM perfstat.STATS$SNAPSHOT WHERE dbid = &&ecr_dbid.;
COL ecr_collection_host NEW_V ecr_collection_host;
-- STATSPACK
SELECT 'get_collection_host', host_name ecr_collection_host FROM v$instance
/

DEF;
SELECT 'get_current_time', TO_CHAR(SYSDATE, '&&ecr_date_format.') current_time FROM DUAL
/

-- ignore on 9i
DEF skip_on_9i = '';
COL skip_on_9i NEW_V skip_on_9i;
SELECT '--' skip_on_9i FROM v$instance WHERE version LIKE '9%';

SPO esp_requirements_stp_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..csv;

-- header
SELECT 'collection_host,collection_key,category,data_element,source,instance_number,inst_id,value' FROM DUAL
/

-- id
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'collector_version', 'v1419', 0, 0, '2014-11-28' FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'collection_date', 'sysdate', 0, 0, TO_CHAR(SYSDATE, '&&ecr_date_format.') FROM DUAL
/
-- STATSPACK
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'awr_retention_days', 'dba_hist_snapshot', 0, 0,  ROUND(MAX(snap_time) - MIN(snap_time), 1) FROM perfstat.STATS$SNAPSHOT WHERE dbid = &&ecr_dbid.
/
-- STATSPACK
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'awr_retention_days', 'dba_hist_snapshot', instance_number, 0, ROUND(MAX(snap_time) - MIN(snap_time), 1) FROM perfstat.STATS$SNAPSHOT WHERE dbid = &&ecr_dbid. GROUP BY instance_number ORDER BY instance_number
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'user', 'user', 0, 0, USER FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'host', 'sys_context', 0, 0 &&skip_on_9i., LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'HOST')||'.', 1, INSTR(SYS_CONTEXT('USERENV', 'HOST')||'.', '.') - 1)) 
FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'server_host', 'sys_context', 0, 0 &&skip_on_9i., LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', 1, INSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', '.') - 1)) 
FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'dbid', 'v$database', 0, 0, '&&ecr_dbid.' FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'db_name', 'sys_context', 0, 0, SYS_CONTEXT('USERENV', 'DB_NAME') FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'db_unique_name', 'sys_context', 0, 0, SYS_CONTEXT('USERENV', 'DB_UNIQUE_NAME') FROM DUAL
/
-- STATSPACK 9I
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'platform_name', 'v$database', 0, 0, 
    os||' '||bit platform_name
from (
SELECT 1 id, substr(banner,9,instr(banner,':')-9)  os FROM v$version  where banner like 'TNS for%') a Left outer join
(select 1 id, substr(banner,instr(banner,'bit')-2,5) bit   FROM v$version  where banner like '%bit Pro%') b 
on a.id=b.id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'host_name', 'gv$instance', instance_number, inst_id, LOWER(SUBSTR(host_name||'.', 1, INSTR(host_name||'.', '.') - 1)) FROM gv$instance ORDER BY inst_id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'version', 'gv$instance', instance_number, inst_id, version FROM gv$instance ORDER BY inst_id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'instance_name', 'gv$instance', instance_number, inst_id, instance_name FROM gv$instance ORDER BY inst_id
/
-- STASPACK
SELECT DISTINCT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'instance_name', 'dba_hist_database_instance', instance_number, 0, value instance_name FROM perfstat.STATS$PARAMETER  WHERE dbid = &&ecr_dbid. AND NAME='instance_name' ORDER BY instance_number
/


-- STATSPACK
-- cpu
WITH 
  cpu_per_inst AS
  (SELECT /*+ INLINE &&ecr_sq_fact_hints_9i. */
    instance_number,
    MAX(aas_on_cpu) aas_on_cpu_peak,
    PERCENTILE_DISC(0.9999) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_9999,
    PERCENTILE_DISC(0.999) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_999,
    PERCENTILE_DISC(0.99) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_99,
    PERCENTILE_DISC(0.97) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_97,
    PERCENTILE_DISC(0.95) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_95,
    PERCENTILE_DISC(0.90) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_90,
    PERCENTILE_DISC(0.75) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_75,
    PERCENTILE_DISC(0.50) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_median,
    ROUND(AVG(aas_on_cpu), 1) aas_on_cpu_avg
  FROM (
  SELECT /*+ &&ecr_sq_fact_hints_9i. */
    begin_time sample_time,
    end_time,
    'ON CPU' session_state ,
    snap_id,
    instance_number,
    ROUND(((end_time    -begin_time)*86400)) elap_time,
    (value              -last_value)/100 cpu_used_secs,
    DECODE(ROUND((value -last_value)/100 / ((end_time-begin_time)*86400)), 0,1, ROUND((value -last_value)/100 / ((end_time-begin_time)*86400)))aas_on_cpu
  FROM (
  SELECT /*+ &&ecr_sq_fact_hints_9i. */ 
    s.dbid,
    s.instance_number,
    s.startup_time ,
    s.snap_time end_time ,
    LAG(s.snap_time) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS begin_time ,
    e.name stat_name ,
    s.snap_id ,
    LAG(s.snap_id) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_snap_id
    ,
    e.value ,
    LAG(e.value) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_value ,
    MIN(s.snap_time) OVER ( PARTITION BY s.dbid ) min_snap_time ,
    MAX(s.snap_time) OVER ( PARTITION BY s.dbid ) max_snap_time
  FROM perfstat.STATS$SNAPSHOT s
  INNER JOIN perfstat.STATS$SYSSTAT e --v$sysstat
  ON e.snap_id          = s.snap_id
  AND e.dbid            = s.dbid
  AND e.instance_number = s.instance_number
  AND e.name            ='CPU used by this session'
  WHERE s.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND  s.dbid = &&ecr_dbid.
   )
  WHERE last_value IS NOT NULL
  )
  GROUP BY instance_number
  )
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_peak', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_peak FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_peak', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_peak) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_9999', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_9999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_9999', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_9999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_999', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_999', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_99', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_99 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_99', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_99) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_97', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_97 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_97', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_97) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_95', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_95 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_95', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_95) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_90', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_90 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_90', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_90) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_75', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_75 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_75', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_75) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_median', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_median FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_median', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_median) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_avg', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_avg FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_avg', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_avg) FROM cpu_per_inst
/


-- STATSPACK
-- mem
WITH
sga_per_inst_and_snap AS (
SELECT /*+ INLINE &&ecr_sq_fact_hints_9i. */
       instance_number,
       snap_id,
       SUM(value) sga_alloc
  FROM perfstat.STATS$SGA
 WHERE snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND dbid = &&ecr_dbid.
 GROUP BY
       instance_number,
       snap_id
),
sga_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints_9i. */
       instance_number,
       MAX(sga_alloc) sga_alloc
  FROM sga_per_inst_and_snap
 GROUP BY
       instance_number
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', 'sga_alloc', 'dba_hist_sga', instance_number, 0, sga_alloc FROM sga_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', 'sga_alloc', 'dba_hist_sga', -1, -1, SUM(sga_alloc) FROM sga_per_inst
/

-- STATSPACK
WITH 
pga_per_inst AS (
SELECT /*+ INLINE &&ecr_sq_fact_hints_9i. */
       instance_number,
       MAX(value) pga_alloc
  FROM perfstat.STATS$PGASTAT
 WHERE snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND dbid = &&ecr_dbid.
   AND name = 'maximum PGA allocated'
 GROUP BY
       instance_number
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', 'pga_alloc', 'dba_hist_pgastat', instance_number, 0, pga_alloc FROM pga_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', 'pga_alloc', 'dba_hist_pgastat', -1, -1, SUM(pga_alloc) FROM pga_per_inst
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', 'pga_alloc', 'gv$pgastat', 0, inst_id, value FROM gv$pgastat WHERE name = 'maximum PGA allocated' ORDER BY inst_id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', 'pga_alloc', 'gv$pgastat', -1, -1, SUM(value) FROM gv$pgastat WHERE name = 'maximum PGA allocated'
/


WITH
par_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints_9i. */
       inst_id,
       name parameter_name,
       MAX(TO_NUMBER(value)) value
  FROM gv$system_parameter
 WHERE name IN ('memory_target', 'memory_max_target', 'sga_target', 'sga_max_size', 'pga_aggregate_target', 'cpu_count')
 GROUP BY
       inst_id,
       name
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', parameter_name, 'gv$system_parameter', 0, inst_id, value FROM par_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', parameter_name, 'gv$system_parameter', -1, -1, SUM(value) FROM par_per_inst GROUP BY parameter_name 
 ORDER BY 3, 5 NULLS FIRST, 6
/


-- db_size 
-- STATSPACK
-- 9i commented controlfile, add where clause for 9i version
WITH 
sizes AS (
SELECT /*+ &&ecr_sq_fact_hints_9i. */
       'datafile' file_type,
       'v$datafile' source,
       SUM(bytes) bytes
  FROM v$datafile
 UNION ALL
SELECT 'tempfile' file_type,
       'v$tempfile' source,
       SUM(bytes) bytes
  FROM v$tempfile
 UNION ALL
SELECT 'redo_log' file_type,
       'v$log' source,
       SUM(bytes) * MAX(members) bytes
  FROM v$log
-- UNION ALL
--SELECT 'controlfile' file_type,
--       'v$controlfile' source,
--       SUM(block_size * file_size_blks) bytes
--  FROM v$controlfile
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'db_size', file_type, source, -1, -1, bytes FROM sizes
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'db_size', 'total', 'v$', -1, -1, SUM(bytes) FROM sizes
/


-- STATSPACK
-- disk_perf IO_PER_INST
WITH
io_per_inst AS (
SELECT /*+ INLINE &&ecr_sq_fact_hints_9i. */
        instance_number,
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_median,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_median,
       ROUND(AVG((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_avg
  FROM (
  SELECT /*+ &&ecr_sq_fact_hints_9i. */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN ('physical writes', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value*blksize ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN ('physical writes') THEN value*blksize ELSE 0 END) 
       +
       SUM(CASE WHEN stat_name IN ('redo size') THEN value ELSE 0 END) w_bytes,
       AVG((snap_time - end_time)*86400) elapsed_sec
  FROM (
SELECT /*+  &&ecr_sq_fact_hints_9i. */
    s.dbid,
    s.instance_number,
    s.startup_time ,
    s.snap_time, 
    LAG(s.snap_time) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS end_time ,
    e.name stat_name ,
    s.snap_id ,
    LAG(s.snap_id) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_snap_id
    ,
    e.value -
    LAG(e.value) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS value ,
    MIN(s.snap_time) OVER ( PARTITION BY s.dbid ) min_snap_time ,
    MAX(s.snap_time) OVER ( PARTITION BY s.dbid ) max_snap_time
  FROM perfstat.STATS$SNAPSHOT s
  INNER JOIN perfstat.STATS$SYSSTAT e --v$sysstat
  ON e.snap_id          = s.snap_id
  AND e.dbid            = s.dbid
  AND e.instance_number = s.instance_number
  AND e.name            IN ('physical reads', 'physical writes', 'redo writes', 'redo size')
  WHERE s.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
    AND s.dbid = &&ecr_dbid.
  ) sysstat_io_lag
  ,  (
        SELECT  distinct VALUE blksize
          FROM V$parameter
          WHERE name='db_block_size'
        )block_size
 WHERE LAST_SNAP_ID is not null
 GROUP BY
       instance_number,
       snap_id
  )
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       instance_number)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_reqs_perc', 'dba_hist_sysstat', instance_number, 0, r_reqs_perc FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_reqs_perc', 'dba_hist_sysstat', instance_number, 0, w_reqs_perc FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_peak', 'dba_hist_sysstat', instance_number, 0, rw_iops_peak FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_peak', 'dba_hist_sysstat', instance_number, 0, r_iops_peak FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_peak', 'dba_hist_sysstat', instance_number, 0, w_iops_peak FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_999', 'dba_hist_sysstat', instance_number, 0, rw_iops_999 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_99', 'dba_hist_sysstat', instance_number, 0, rw_iops_99 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_97', 'dba_hist_sysstat', instance_number, 0, rw_iops_97 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_95', 'dba_hist_sysstat', instance_number, 0, rw_iops_95 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_90', 'dba_hist_sysstat', instance_number, 0, rw_iops_90 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_75', 'dba_hist_sysstat', instance_number, 0, rw_iops_75 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_median', 'dba_hist_sysstat', instance_number, 0, rw_iops_median FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_avg', 'dba_hist_sysstat', instance_number, 0, rw_iops_avg FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_avg', 'dba_hist_sysstat', instance_number, 0, r_iops_avg FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_avg', 'dba_hist_sysstat', instance_number, 0, w_iops_avg FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_bytes_perc', 'dba_hist_sysstat', instance_number, 0, r_bytes_perc FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_bytes_perc', 'dba_hist_sysstat', instance_number, 0, w_bytes_perc FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_peak', 'dba_hist_sysstat', instance_number, 0, rw_mbps_peak FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_peak', 'dba_hist_sysstat', instance_number, 0, r_mbps_peak FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_peak', 'dba_hist_sysstat', instance_number, 0, w_mbps_peak FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_999', 'dba_hist_sysstat', instance_number, 0, rw_mbps_999 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_99', 'dba_hist_sysstat', instance_number, 0, rw_mbps_99 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_97', 'dba_hist_sysstat', instance_number, 0, rw_mbps_97 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_95', 'dba_hist_sysstat', instance_number, 0, rw_mbps_95 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_90', 'dba_hist_sysstat', instance_number, 0, rw_mbps_90 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_75', 'dba_hist_sysstat', instance_number, 0, rw_mbps_75 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_median', 'dba_hist_sysstat', instance_number, 0, rw_mbps_median FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_avg', 'dba_hist_sysstat', instance_number, 0, rw_mbps_avg FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_avg', 'dba_hist_sysstat', instance_number, 0, r_mbps_avg FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_avg', 'dba_hist_sysstat', instance_number, 0, w_mbps_avg FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_reqs_perc', 'dba_hist_sysstat', -1, -1, SUM(r_reqs_perc) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_reqs_perc', 'dba_hist_sysstat', -1, -1, SUM(w_reqs_perc) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_peak', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_peak) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_peak', 'dba_hist_sysstat', -1, -1, SUM(r_iops_peak) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_peak', 'dba_hist_sysstat', -1, -1, SUM(w_iops_peak) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_999', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_999) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_99', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_99) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_97', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_97) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_95', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_95) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_90', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_90) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_75', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_75) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_median', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_median) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_avg', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_avg) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_avg', 'dba_hist_sysstat', -1, -1, SUM(r_iops_avg) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_avg', 'dba_hist_sysstat', -1, -1, SUM(w_iops_avg) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_bytes_perc', 'dba_hist_sysstat', -1, -1, SUM(r_bytes_perc) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_bytes_perc', 'dba_hist_sysstat', -1, -1, SUM(w_bytes_perc) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_peak', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_peak) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_peak', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_peak) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_peak', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_peak) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_999', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_999) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_99', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_99) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_97', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_97) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_95', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_95) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_90', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_90) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_75', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_75) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_median', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_median) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_avg', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_avg) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_avg', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_avg) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_avg', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_avg) FROM io_per_inst
/


-- STATSPACK
-- disk_perf io_per_cluster
WITH
io_per_cluster AS (
SELECT /*+ INLINE &&ecr_sq_fact_hints_9i. */
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_median,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_median,
       ROUND(AVG((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_avg
  FROM (
  SELECT /*+ &&ecr_sq_fact_hints_9i. */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN ('physical writes', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value*blksize ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN ('physical writes') THEN value*blksize ELSE 0 END) 
       +
       SUM(CASE WHEN stat_name IN ('redo size') THEN value ELSE 0 END) w_bytes,
       AVG((snap_time - end_time)*86400) elapsed_sec
  FROM (
SELECT /*+  &&ecr_sq_fact_hints_9i. */
    s.dbid,
    s.instance_number,
    s.startup_time ,
    s.snap_time, 
    LAG(s.snap_time) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS end_time ,
    e.name stat_name ,
    s.snap_id ,
    LAG(s.snap_id) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_snap_id
    ,
    e.value -
    LAG(e.value) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS value ,
    MIN(s.snap_time) OVER ( PARTITION BY s.dbid ) min_snap_time ,
    MAX(s.snap_time) OVER ( PARTITION BY s.dbid ) max_snap_time
  FROM perfstat.STATS$SNAPSHOT s
  INNER JOIN perfstat.STATS$SYSSTAT e --v$sysstat
  ON e.snap_id          = s.snap_id
  AND e.dbid            = s.dbid
  AND e.instance_number = s.instance_number
  AND e.name            IN ('physical reads', 'physical writes', 'redo writes', 'redo size')
  WHERE s.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s.dbid = &&ecr_dbid.
  ) sysstat_io_lag
  ,  (
        SELECT  distinct VALUE blksize
          FROM V$parameter
          WHERE name='db_block_size'
        )block_size
 WHERE LAST_SNAP_ID is not null
 GROUP BY
       instance_number,
       snap_id
  )
 WHERE elapsed_sec > 60 -- ignore snaps too close
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_reqs_perc', 'dba_hist_sysstat', -2, -2, r_reqs_perc FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_reqs_perc', 'dba_hist_sysstat', -2, -2, w_reqs_perc FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_peak', 'dba_hist_sysstat', -2, -2, rw_iops_peak FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_peak', 'dba_hist_sysstat', -2, -2, r_iops_peak FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_peak', 'dba_hist_sysstat', -2, -2, w_iops_peak FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_999', 'dba_hist_sysstat', -2, -2, rw_iops_999 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_99', 'dba_hist_sysstat', -2, -2, rw_iops_99 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_97', 'dba_hist_sysstat', -2, -2, rw_iops_97 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_95', 'dba_hist_sysstat', -2, -2, rw_iops_95 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_90', 'dba_hist_sysstat', -2, -2, rw_iops_90 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_75', 'dba_hist_sysstat', -2, -2, rw_iops_75 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_median', 'dba_hist_sysstat', -2, -2, rw_iops_median FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_avg', 'dba_hist_sysstat', -2, -2, rw_iops_avg FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_avg', 'dba_hist_sysstat', -2, -2, r_iops_avg FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_avg', 'dba_hist_sysstat', -2, -2, w_iops_avg FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_bytes_perc', 'dba_hist_sysstat', -2, -2, r_bytes_perc FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_bytes_perc', 'dba_hist_sysstat', -2, -2, w_bytes_perc FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_peak', 'dba_hist_sysstat', -2, -2, rw_mbps_peak FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_peak', 'dba_hist_sysstat', -2, -2, r_mbps_peak FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_peak', 'dba_hist_sysstat', -2, -2, w_mbps_peak FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_999', 'dba_hist_sysstat', -2, -2, rw_mbps_999 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_99', 'dba_hist_sysstat', -2, -2, rw_mbps_99 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_97', 'dba_hist_sysstat', -2, -2, rw_mbps_97 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_95', 'dba_hist_sysstat', -2, -2, rw_mbps_95 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_90', 'dba_hist_sysstat', -2, -2, rw_mbps_90 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_75', 'dba_hist_sysstat', -2, -2, rw_mbps_75 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_median', 'dba_hist_sysstat', -2, -2, rw_mbps_median FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_avg', 'dba_hist_sysstat', -2, -2, rw_mbps_avg FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_avg', 'dba_hist_sysstat', -2, -2, r_mbps_avg FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_avg', 'dba_hist_sysstat', -2, -2, w_mbps_avg FROM io_per_cluster
/


-- STATSPACK
-- cpu time series
WITH 
 cpu_per_inst_and_daily AS (
SELECT  /*+  INLINE &&ecr_sq_fact_hints_9i. */
       session_state,
       instance_number,
       TO_CHAR(TRUNC(CAST(sample_time AS DATE), 'DD') + (1/24), '&&ecr_date_format.') end_time, -- ecr_date_format
       MAX(active_sessions) active_sessions_max, -- 100% percentile or max or peak
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY active_sessions) active_sessions_99p, -- 99% percentile
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY active_sessions) active_sessions_97p, -- 97% percentile
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY active_sessions) active_sessions_95p, -- 95% percentile
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY active_sessions) active_sessions_90p, -- 90% percentile
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY active_sessions) active_sessions_75p, -- 75% percentile
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY active_sessions) active_sessions_med, -- 75% percentile
       ROUND(AVG(active_sessions), 1) active_sessions_avg -- average
  FROM (
  SELECT /*+  &&ecr_sq_fact_hints_9i. */
  begin_time sample_time,
  end_time,
  'ON CPU' session_state ,
  snap_id,
  instance_number,
  round(((end_time-begin_time)*86400))  elap_time,
  (value        -last_value)/100 cpu_used_secs,
   decode(round((value        -last_value)/100 / ((end_time-begin_time)*86400)),
        0,1,
        round((value        -last_value)/100 / ((end_time-begin_time)*86400)))active_sessions
FROM (
SELECT /*+  &&ecr_sq_fact_hints_9i. */
    s.dbid,
    s.instance_number,
    s.startup_time ,
    s.snap_time end_time ,
    LAG(s.snap_time) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS begin_time ,
    e.name stat_name ,
    s.snap_id ,
    LAG(s.snap_id) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_snap_id
    ,
    e.value ,
    LAG(e.value) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_value ,
    MIN(s.snap_time) OVER ( PARTITION BY s.dbid ) min_snap_time ,
    MAX(s.snap_time) OVER ( PARTITION BY s.dbid ) max_snap_time
  FROM perfstat.STATS$SNAPSHOT s
  INNER JOIN perfstat.STATS$SYSSTAT e --v$sysstat
  ON e.snap_id          = s.snap_id
  AND e.dbid            = s.dbid
  AND e.instance_number = s.instance_number
  AND e.name            ='CPU used by this session'
  WHERE s.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
    AND s.dbid = &&ecr_dbid.
    )
where last_value is not null
)
 GROUP BY
       session_state,
       instance_number,
       TRUNC(CAST(sample_time AS DATE), 'DD')
       )
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts', session_state, end_time, instance_number, 0 inst_id, active_sessions_max value FROM cpu_per_inst_and_daily
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_99p', session_state, end_time, instance_number, 0 inst_id, active_sessions_99p value FROM cpu_per_inst_and_daily
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_97p', session_state, end_time, instance_number, 0 inst_id, active_sessions_97p value FROM cpu_per_inst_and_daily
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_95p', session_state, end_time, instance_number, 0 inst_id, active_sessions_95p value FROM cpu_per_inst_and_daily
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_90p', session_state, end_time, instance_number, 0 inst_id, active_sessions_90p value FROM cpu_per_inst_and_daily
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_75p', session_state, end_time, instance_number, 0 inst_id, active_sessions_75p value FROM cpu_per_inst_and_daily
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_med', session_state, end_time, instance_number, 0 inst_id, active_sessions_med value FROM cpu_per_inst_and_daily
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_avg', session_state, end_time, instance_number, 0 inst_id, active_sessions_avg value FROM cpu_per_inst_and_daily
 ORDER BY
       3, 4, 6, 5
/


-- STATSPACK
-- mem time series
WITH
sga AS (
SELECT /*+ INLINE &&ecr_sq_fact_hints_9i. */
       h.instance_number,
       h.snap_id,
       TO_CHAR(TRUNC((s.snap_time ), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       SUM(h.value) bytes
  FROM perfstat.STATS$SGA h,
       perfstat.STATS$SNAPSHOT s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 GROUP BY
       h.instance_number,
       h.snap_id,
       s.snap_time
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem_ts', 'sga', end_time, instance_number, 0 inst_id, ROUND(MAX(bytes) / POWER(2,30), 3) value
  FROM sga
 GROUP BY
       instance_number,
       end_time
 ORDER BY
       3, 4, 6, 5
/

-- STATSPACK
-- mem time series
WITH
pga AS (
SELECT /*+ INLINE &&ecr_sq_fact_hints_9i. */
       h.instance_number,
       h.snap_id,
        TO_CHAR(TRUNC((s.snap_time ), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       SUM(h.value) bytes
  FROM perfstat.STATS$PGASTAT h,
       perfstat.STATS$SNAPSHOT s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   --AND h.name = 'maximum PGA allocated'
   AND h.name = 'total PGA allocated'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 GROUP BY
       h.instance_number,
       h.snap_id,
       s.snap_time
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem_ts', 'pga', end_time, instance_number, 0 inst_id, ROUND(MAX(bytes) / POWER(2,30), 3) value
  FROM pga
 GROUP BY
       instance_number,
       end_time
 ORDER BY
       3, 4, 6, 5
/

-- STATSPACK
-- disk_perf time series
WITH
io_per_inst_and_snap_id AS (
SELECT /*+ INLINE &&ecr_sq_fact_hints_9i. */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN ('physical writes', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value*blksize ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN ('physical writes') THEN value*blksize ELSE 0 END) 
       +
       SUM(CASE WHEN stat_name IN ('redo size') THEN value ELSE 0 END) w_bytes,
       AVG((snap_time - end_time)*86400) elapsed_sec,
       MAX(END_TIME) END_TIME
  FROM (
SELECT /*+ &&ecr_sq_fact_hints_9i. */
    s.dbid,
    s.instance_number,
    s.startup_time ,
    s.snap_time, 
    LAG(s.snap_time) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS end_time ,
    e.name stat_name ,
    s.snap_id ,
    LAG(s.snap_id) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_snap_id
    --
    ,
    e.value -
    LAG(e.value) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS value ,
    MIN(s.snap_time) OVER ( PARTITION BY s.dbid ) min_snap_time ,
    MAX(s.snap_time) OVER ( PARTITION BY s.dbid ) max_snap_time
  FROM perfstat.STATS$SNAPSHOT s
  INNER JOIN perfstat.STATS$SYSSTAT e --v$sysstat
  ON e.snap_id          = s.snap_id
  AND e.dbid            = s.dbid
  AND e.instance_number = s.instance_number
  AND e.name            IN ('physical reads', 'physical writes', 'redo writes', 'redo size')
  WHERE s.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
    AND s.dbid = &&ecr_dbid.
  ) sysstat_io_lag
  ,  (
        SELECT distinct VALUE blksize
          FROM V$parameter
          WHERE name='db_block_size'
        )block_size
 WHERE LAST_SNAP_ID is not null
 GROUP BY
       instance_number,
       snap_id)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf_ts', 'r_iops', end_time, instance_number, 0 inst_id, ROUND(MAX(r_reqs / elapsed_sec)) value
  FROM io_per_inst_and_snap_id
 GROUP BY
       instance_number,
       end_time
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf_ts', 'w_iops', end_time, instance_number, 0 inst_id, ROUND(MAX(w_reqs / elapsed_sec)) value
  FROM io_per_inst_and_snap_id
 GROUP BY
       instance_number,
       end_time
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf_ts', 'r_mbps', end_time, instance_number, 0 inst_id, ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec), 3) value
  FROM io_per_inst_and_snap_id
 GROUP BY
       instance_number,
       end_time
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf_ts', 'w_mbps', end_time, instance_number, 0 inst_id, ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec), 3) value
  FROM io_per_inst_and_snap_id
 GROUP BY
       instance_number,
       end_time
 ORDER BY
       3, 4, 6, 5
/       


-- footer
SELECT 'collection_host,collection_key,category,data_element,source,instance_number,inst_id,value' FROM DUAL
/

SPO OFF;
SET TERM ON ECHO OFF FEED ON VER ON HEA ON PAGES 14 COLSEP ' ' LIN 80 TRIMS OFF TRIM ON TI OFF TIMI OFF ARRAY 15 NUM 10 SQLBL OFF BLO ON RECSEP WR;
