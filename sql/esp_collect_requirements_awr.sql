----------------------------------------------------------------------------------------
--
-- File name:   esp_collect_requirements_awr.sql (2016-09-01)
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
--  Notes:      Developed and tested on 12.1.0.2, 11.2.0.3, 10.2.0.4, 9.2.0.1
--
---------------------------------------------------------------------------------------
--
DEF MAX_DAYS = '365';
DEF INCLUDE_IC = 'Y';
DEF INCLUDE_NETW = 'Y';
SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;

-- get host name (up to 30, stop before first '.', no special characters)
DEF esp_host_name_short = '';
COL esp_host_name_short NEW_V esp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) esp_host_name_short FROM DUAL;
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

-- get collection days
DEF collection_days = '&&MAX_DAYS.';
COL collection_days NEW_V collection_days;
SELECT NVL(TO_CHAR(LEAST(EXTRACT(DAY FROM retention), TO_NUMBER('&&MAX_DAYS.'))), '&&MAX_DAYS.') collection_days FROM dba_hist_wr_control;

DEF skip_on_10g = '';
COL skip_on_10g NEW_V skip_on_10g;
SELECT '--' skip_on_10g FROM v$instance WHERE version LIKE '10%';

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';

DEF ecr_sq_fact_hints = 'MATERIALIZE NO_MERGE';
DEF ecr_date_format = 'YYYY-MM-DD/HH24:MI:SS';

CL COL;
COL ecr_collection_key NEW_V ecr_collection_key;
SELECT 'get_collection_key', SUBSTR(name||ora_hash(dbid||name||instance_name||host_name||systimestamp), 1, 13) ecr_collection_key FROM v$instance, v$database
/
COL ecr_dbid NEW_V ecr_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) ecr_dbid FROM v$database
/
COL ecr_instance_number NEW_V ecr_instance_number;
SELECT 'get_instance_number', TO_CHAR(instance_number) ecr_instance_number FROM v$instance
/
COL ecr_min_snap_id NEW_V ecr_min_snap_id;
SELECT 'get_min_snap_id', TO_CHAR(MIN(snap_id)) ecr_min_snap_id FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid. AND CAST(begin_interval_time AS DATE) > SYSDATE - &&collection_days.
/
COL ecr_collection_host NEW_V ecr_collection_host;
SELECT 'get_collection_host', LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', 1, INSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', '.') - 1)) ecr_collection_host FROM DUAL
/

DEF;
SELECT 'get_current_time', TO_CHAR(SYSDATE, '&&ecr_date_format.') current_time FROM DUAL
/

SPO esp_requirements_awr_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..csv;

-- header
SELECT 'collection_host,collection_key,category,data_element,source,instance_number,inst_id,value' FROM DUAL
/

-- id
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'collector_version', 'v1601', 0, 0, '2016-01-05' FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'collection_date', 'sysdate', 0, 0, TO_CHAR(SYSDATE, '&&ecr_date_format.') FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'awr_retention_days', 'dba_hist_snapshot', 0, 0,  ROUND(CAST(MAX(end_interval_time) AS DATE) - CAST(MIN(begin_interval_time) AS DATE), 1) FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid. AND CAST(begin_interval_time AS DATE) > SYSDATE - &&collection_days.
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'awr_retention_days', 'dba_hist_snapshot', instance_number, 0, ROUND(CAST(MAX(end_interval_time) AS DATE) - CAST(MIN(begin_interval_time) AS DATE), 1) FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid. AND CAST(begin_interval_time AS DATE) > SYSDATE - &&collection_days. GROUP BY instance_number ORDER BY instance_number
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'collection_days', 'dba_hist_wr_control', 0, 0, '&&collection_days.' FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'user', 'user', 0, 0, USER FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'host', 'sys_context', 0, 0, LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'HOST')||'.', 1, INSTR(SYS_CONTEXT('USERENV', 'HOST')||'.', '.') - 1)) FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'server_host', 'sys_context', 0, 0, LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', 1, INSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', '.') - 1)) FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'dbid', 'v$database', 0, 0, '&&ecr_dbid.' FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'db_name', 'sys_context', 0, 0, SYS_CONTEXT('USERENV', 'DB_NAME') FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'db_unique_name', 'sys_context', 0, 0, SYS_CONTEXT('USERENV', 'DB_UNIQUE_NAME') FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'platform_name', 'v$database', 0, 0, platform_name FROM v$database
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'host_name', 'gv$instance', instance_number, inst_id, LOWER(SUBSTR(host_name||'.', 1, INSTR(host_name||'.', '.') - 1)) FROM gv$instance ORDER BY inst_id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'version', 'gv$instance', instance_number, inst_id, version FROM gv$instance ORDER BY inst_id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'instance_name', 'gv$instance', instance_number, inst_id, instance_name FROM gv$instance ORDER BY inst_id
/
SELECT DISTINCT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'instance_name', 'dba_hist_database_instance', instance_number, 0, instance_name FROM dba_hist_database_instance WHERE dbid = &&ecr_dbid. AND CAST(startup_time AS DATE) > SYSDATE - &&collection_days. ORDER BY instance_number
/

-- cpu
WITH
cpu_per_inst_and_sample AS (
SELECT /*+ &&ecr_sq_fact_hints.
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       h.instance_number,
       h.snap_id,
       h.sample_id,
       COUNT(*) aas_on_cpu_and_resmgr,
       SUM(CASE h.session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE h.event WHEN 'resmgr:cpu quantum' THEN 1 ELSE 0 END) aas_resmgr_cpu_quantum
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id,
       h.sample_id
),
cpu_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       instance_number,
       MAX(aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_peak,
       MAX(aas_on_cpu) aas_on_cpu_peak,
       MAX(aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_peak,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_9999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_999,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_99,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_97,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_95,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_90,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_75,
       MEDIAN(aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_median,
       MEDIAN(aas_on_cpu) aas_on_cpu_median,
       MEDIAN(aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_median,
       ROUND(AVG(aas_on_cpu_and_resmgr), 1) aas_on_cpu_and_resmgr_avg,
       ROUND(AVG(aas_on_cpu), 1) aas_on_cpu_avg,
       ROUND(AVG(aas_resmgr_cpu_quantum), 1) aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       instance_number
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_peak', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_peak FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_peak', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_peak FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_peak', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_peak FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_peak', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_peak) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_peak', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_peak) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_peak', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_peak) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_9999', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_9999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_9999', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_9999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_9999', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_9999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_9999', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_9999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_9999', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_9999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_9999', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_9999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_999', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_999', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_999', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_999', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_999', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_999', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_99', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_99 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_99', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_99 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_99', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_99 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_99', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_99) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_99', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_99) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_99', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_99) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_97', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_97 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_97', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_97 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_97', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_97 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_97', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_97) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_97', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_97) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_97', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_97) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_95', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_95 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_95', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_95 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_95', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_95 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_95', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_95) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_95', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_95) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_95', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_95) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_90', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_90 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_90', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_90 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_90', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_90 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_90', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_90) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_90', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_90) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_90', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_90) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_75', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_75 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_75', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_75 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_75', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_75 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_75', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_75) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_75', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_75) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_75', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_75) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_median', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_median FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_median', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_median FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_median', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_median FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_median', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_median) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_median', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_median) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_median', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_median) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_avg', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_and_resmgr_avg FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_avg', 'dba_hist_active_sess_history', instance_number, 0, aas_on_cpu_avg FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_avg', 'dba_hist_active_sess_history', instance_number, 0, aas_resmgr_cpu_quantum_avg FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_avg', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_and_resmgr_avg) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_avg', 'dba_hist_active_sess_history', -1, -1, SUM(aas_on_cpu_avg) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_avg', 'dba_hist_active_sess_history', -1, -1, SUM(aas_resmgr_cpu_quantum_avg) FROM cpu_per_inst
/
WITH
cpu_per_inst_and_sample AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       inst_id,
       sample_id,
       COUNT(*) aas_on_cpu_and_resmgr,
       SUM(CASE session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE event WHEN 'resmgr:cpu quantum' THEN 1 ELSE 0 END) aas_resmgr_cpu_quantum
  FROM gv$active_session_history
 WHERE (session_state = 'ON CPU' OR event = 'resmgr:cpu quantum')
   AND CAST(sample_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       inst_id,
       sample_id
),
cpu_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       inst_id,
       MAX(aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_peak,
       MAX(aas_on_cpu) aas_on_cpu_peak,
       MAX(aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_peak,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_9999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_999,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_99,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_97,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_95,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_90,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_on_cpu) aas_on_cpu_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_75,
       MEDIAN(aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_median,
       MEDIAN(aas_on_cpu) aas_on_cpu_median,
       MEDIAN(aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_median,
       ROUND(AVG(aas_on_cpu_and_resmgr), 1) aas_on_cpu_and_resmgr_avg,
       ROUND(AVG(aas_on_cpu), 1) aas_on_cpu_avg,
       ROUND(AVG(aas_resmgr_cpu_quantum), 1) aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       inst_id
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_peak', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_peak FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_peak', 'gv$active_session_history', 0, inst_id, aas_on_cpu_peak FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_peak', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_peak FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_peak', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_peak) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_peak', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_peak) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_peak', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_peak) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_9999', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_9999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_9999', 'gv$active_session_history', 0, inst_id, aas_on_cpu_9999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_9999', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_9999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_9999', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_9999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_9999', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_9999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_9999', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_9999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_999', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_999', 'gv$active_session_history', 0, inst_id, aas_on_cpu_999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_999', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_999 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_999', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_999', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_999', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_999) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_99', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_99 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_99', 'gv$active_session_history', 0, inst_id, aas_on_cpu_99 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_99', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_99 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_99', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_99) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_99', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_99) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_99', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_99) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_97', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_97 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_97', 'gv$active_session_history', 0, inst_id, aas_on_cpu_97 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_97', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_97 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_97', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_97) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_97', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_97) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_97', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_97) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_95', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_95 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_95', 'gv$active_session_history', 0, inst_id, aas_on_cpu_95 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_95', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_95 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_95', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_95) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_95', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_95) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_95', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_95) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_90', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_90 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_90', 'gv$active_session_history', 0, inst_id, aas_on_cpu_90 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_90', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_90 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_90', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_90) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_90', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_90) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_90', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_90) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_75', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_75 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_75', 'gv$active_session_history', 0, inst_id, aas_on_cpu_75 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_75', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_75 FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_75', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_75) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_75', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_75) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_75', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_75) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_median', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_median FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_median', 'gv$active_session_history', 0, inst_id, aas_on_cpu_median FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_median', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_median FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_median', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_median) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_median', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_median) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_median', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_median) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_avg', 'gv$active_session_history', 0, inst_id, aas_on_cpu_and_resmgr_avg FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_avg', 'gv$active_session_history', 0, inst_id, aas_on_cpu_avg FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_avg', 'gv$active_session_history', 0, inst_id, aas_resmgr_cpu_quantum_avg FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_and_resmgr_avg', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_and_resmgr_avg) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_on_cpu_avg', 'gv$active_session_history', -1, -1, SUM(aas_on_cpu_avg) FROM cpu_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu', 'aas_resmgr_cpu_quantum_avg', 'gv$active_session_history', -1, -1, SUM(aas_resmgr_cpu_quantum_avg) FROM cpu_per_inst
/

-- mem
WITH
sga_per_inst_and_snap AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       h.snap_id,
       SUM(h.value) sga_alloc
  FROM dba_hist_sga h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id
),
sga_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints. */
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
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', 'sga_alloc', 'gv$sgainfo', 0, inst_id, bytes FROM gv$sgainfo WHERE name = 'Maximum SGA Size' ORDER BY inst_id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', 'sga_alloc', 'gv$sgainfo', -1, -1, SUM(bytes) FROM gv$sgainfo WHERE name = 'Maximum SGA Size'
/
WITH
pga_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       MAX(h.value) pga_alloc
  FROM dba_hist_pgastat h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND h.name = 'maximum PGA allocated'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number
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
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       h.parameter_name,
       MAX(TO_NUMBER(h.value)) value
  FROM dba_hist_parameter h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND h.parameter_name IN ('memory_target', 'memory_max_target', 'sga_target', 'sga_max_size', 'pga_aggregate_target', 'cpu_count')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.parameter_name
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', parameter_name, 'dba_hist_parameter', instance_number, 0, value FROM par_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem', parameter_name, 'dba_hist_parameter', -1, -1, SUM(value) FROM par_per_inst GROUP BY parameter_name
 ORDER BY 3, 6 NULLS FIRST, 5
/
WITH
par_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints. */
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
WITH
sizes AS (
SELECT /*+ &&ecr_sq_fact_hints. */
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
 UNION ALL
SELECT 'controlfile' file_type,
       'v$controlfile' source,
       SUM(block_size * file_size_blks) bytes
  FROM v$controlfile
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'db_size', file_type, source, -1, -1, bytes FROM sizes
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'db_size', 'total', 'v$', -1, -1, SUM(bytes) FROM sizes
/

-- disk_perf
WITH
sysstat_io AS (
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
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       USE_HASH(h s)
       LEADING(h.INT$DBA_HIST_SYSSTAT.nm h.INT$DBA_HIST_SYSSTAT.s h.INT$DBA_HIST_SYSSTAT.sn s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       LEADING(h.nm h.s h.sn s.WRM$_SNAPSHOT)
       */
       h.instance_number,
       h.snap_id,
       SUM(CASE WHEN h.stat_name = 'physical read total IO requests'                    THEN h.value ELSE 0 END) r_reqs,
       SUM(CASE WHEN h.stat_name IN ('physical write total IO requests', 'redo writes') THEN h.value ELSE 0 END) w_reqs,
       SUM(CASE WHEN h.stat_name = 'physical read total bytes'                          THEN h.value ELSE 0 END) r_bytes,
       SUM(CASE WHEN h.stat_name IN ('physical write total bytes', 'redo size')         THEN h.value ELSE 0 END) w_bytes
  FROM dba_hist_sysstat h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND h.stat_name IN ('physical read total IO requests', 'physical write total IO requests', 'redo writes', 'physical read total bytes', 'physical write total bytes', 'redo size')
   AND s.snap_id(+) = h.snap_id
   AND s.dbid(+) = h.dbid
   AND s.instance_number(+) = h.instance_number
   AND CAST(s.begin_interval_time(+) AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id
),
io_per_inst_and_snap_id AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s0.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s0.WRM$_SNAPSHOT)
       FULL(s1.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s1.WRM$_SNAPSHOT)
       USE_HASH(h0 s0 h1 s1)
       */
       h1.instance_number,
       h1.snap_id,
       (h1.r_reqs - h0.r_reqs) r_reqs,
       (h1.w_reqs - h0.w_reqs) w_reqs,
       (h1.r_bytes - h0.r_bytes) r_bytes,
       (h1.w_bytes - h0.w_bytes) w_bytes,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_io h0,
       dba_hist_snapshot s0,
       sysstat_io h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s0.dbid = &&ecr_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s1.dbid = &&ecr_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
),
io_per_snap_id AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       snap_id,
       SUM(r_reqs) r_reqs,
       SUM(w_reqs) w_reqs,
       SUM(r_bytes) r_bytes,
       SUM(w_bytes) w_bytes,
       AVG(elapsed_sec) elapsed_sec
  FROM io_per_inst_and_snap_id
 GROUP BY
       snap_id
),
io_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       instance_number,
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_75,
       ROUND(MEDIAN((r_reqs + w_reqs) / elapsed_sec)) rw_iops_median,
       ROUND(MEDIAN(r_reqs / elapsed_sec)) r_iops_median,
       ROUND(MEDIAN(w_reqs / elapsed_sec)) w_iops_median,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_75,
       ROUND(MEDIAN((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_median,
       ROUND(MEDIAN(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_median,
       ROUND(MEDIAN(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_median,
       ROUND(AVG((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_avg
  FROM io_per_inst_and_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       instance_number
),
io_per_cluster AS ( -- combined
SELECT /*+ &&ecr_sq_fact_hints. */
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_75,
       ROUND(MEDIAN((r_reqs + w_reqs) / elapsed_sec)) rw_iops_median,
       ROUND(MEDIAN(r_reqs / elapsed_sec)) r_iops_median,
       ROUND(MEDIAN(w_reqs / elapsed_sec)) w_iops_median,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_75,
       ROUND(MEDIAN((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_median,
       ROUND(MEDIAN(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_median,
       ROUND(MEDIAN(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_median,
       ROUND(AVG((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_avg
  FROM io_per_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
)
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
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_999', 'dba_hist_sysstat', instance_number, 0, r_iops_999 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_999', 'dba_hist_sysstat', instance_number, 0, w_iops_999 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_99', 'dba_hist_sysstat', instance_number, 0, rw_iops_99 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_99', 'dba_hist_sysstat', instance_number, 0, r_iops_99 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_99', 'dba_hist_sysstat', instance_number, 0, w_iops_99 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_97', 'dba_hist_sysstat', instance_number, 0, rw_iops_97 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_97', 'dba_hist_sysstat', instance_number, 0, r_iops_97 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_97', 'dba_hist_sysstat', instance_number, 0, w_iops_97 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_95', 'dba_hist_sysstat', instance_number, 0, rw_iops_95 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_95', 'dba_hist_sysstat', instance_number, 0, r_iops_95 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_95', 'dba_hist_sysstat', instance_number, 0, w_iops_95 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_90', 'dba_hist_sysstat', instance_number, 0, rw_iops_90 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_90', 'dba_hist_sysstat', instance_number, 0, r_iops_90 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_90', 'dba_hist_sysstat', instance_number, 0, w_iops_90 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_75', 'dba_hist_sysstat', instance_number, 0, rw_iops_75 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_75', 'dba_hist_sysstat', instance_number, 0, r_iops_75 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_75', 'dba_hist_sysstat', instance_number, 0, w_iops_75 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_median', 'dba_hist_sysstat', instance_number, 0, rw_iops_median FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_median', 'dba_hist_sysstat', instance_number, 0, r_iops_median FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_median', 'dba_hist_sysstat', instance_number, 0, w_iops_median FROM io_per_inst
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
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_999', 'dba_hist_sysstat', instance_number, 0, r_mbps_999 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_999', 'dba_hist_sysstat', instance_number, 0, w_mbps_999 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_99', 'dba_hist_sysstat', instance_number, 0, rw_mbps_99 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_99', 'dba_hist_sysstat', instance_number, 0, r_mbps_99 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_99', 'dba_hist_sysstat', instance_number, 0, w_mbps_99 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_97', 'dba_hist_sysstat', instance_number, 0, rw_mbps_97 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_97', 'dba_hist_sysstat', instance_number, 0, r_mbps_97 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_97', 'dba_hist_sysstat', instance_number, 0, w_mbps_97 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_95', 'dba_hist_sysstat', instance_number, 0, rw_mbps_95 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_95', 'dba_hist_sysstat', instance_number, 0, r_mbps_95 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_95', 'dba_hist_sysstat', instance_number, 0, w_mbps_95 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_90', 'dba_hist_sysstat', instance_number, 0, rw_mbps_90 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_90', 'dba_hist_sysstat', instance_number, 0, r_mbps_90 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_90', 'dba_hist_sysstat', instance_number, 0, w_mbps_90 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_75', 'dba_hist_sysstat', instance_number, 0, rw_mbps_75 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_75', 'dba_hist_sysstat', instance_number, 0, r_mbps_75 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_75', 'dba_hist_sysstat', instance_number, 0, w_mbps_75 FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_median', 'dba_hist_sysstat', instance_number, 0, rw_mbps_median FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_median', 'dba_hist_sysstat', instance_number, 0, r_mbps_median FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_median', 'dba_hist_sysstat', instance_number, 0, w_mbps_median FROM io_per_inst
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
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_999', 'dba_hist_sysstat', -1, -1, SUM(r_iops_999) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_999', 'dba_hist_sysstat', -1, -1, SUM(w_iops_999) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_99', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_99) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_99', 'dba_hist_sysstat', -1, -1, SUM(r_iops_99) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_99', 'dba_hist_sysstat', -1, -1, SUM(w_iops_99) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_97', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_97) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_97', 'dba_hist_sysstat', -1, -1, SUM(r_iops_97) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_97', 'dba_hist_sysstat', -1, -1, SUM(w_iops_97) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_95', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_95) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_95', 'dba_hist_sysstat', -1, -1, SUM(r_iops_95) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_95', 'dba_hist_sysstat', -1, -1, SUM(w_iops_95) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_90', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_90) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_90', 'dba_hist_sysstat', -1, -1, SUM(r_iops_90) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_90', 'dba_hist_sysstat', -1, -1, SUM(w_iops_90) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_75', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_75) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_75', 'dba_hist_sysstat', -1, -1, SUM(r_iops_75) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_75', 'dba_hist_sysstat', -1, -1, SUM(w_iops_75) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_median', 'dba_hist_sysstat', -1, -1, SUM(rw_iops_median) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_median', 'dba_hist_sysstat', -1, -1, SUM(r_iops_median) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_median', 'dba_hist_sysstat', -1, -1, SUM(w_iops_median) FROM io_per_inst
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
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_999', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_999) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_999', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_999) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_99', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_99) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_99', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_99) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_99', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_99) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_97', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_97) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_97', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_97) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_97', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_97) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_95', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_95) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_95', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_95) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_95', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_95) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_90', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_90) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_90', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_90) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_90', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_90) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_75', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_75) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_75', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_75) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_75', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_75) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_median', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_median) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_median', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_median) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_median', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_median) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_avg', 'dba_hist_sysstat', -1, -1, SUM(rw_mbps_avg) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_avg', 'dba_hist_sysstat', -1, -1, SUM(r_mbps_avg) FROM io_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_avg', 'dba_hist_sysstat', -1, -1, SUM(w_mbps_avg) FROM io_per_inst
UNION ALL
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
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_999', 'dba_hist_sysstat', -2, -2, r_iops_999 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_999', 'dba_hist_sysstat', -2, -2, w_iops_999 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_99', 'dba_hist_sysstat', -2, -2, rw_iops_99 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_99', 'dba_hist_sysstat', -2, -2, r_iops_99 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_99', 'dba_hist_sysstat', -2, -2, w_iops_99 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_97', 'dba_hist_sysstat', -2, -2, rw_iops_97 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_97', 'dba_hist_sysstat', -2, -2, r_iops_97 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_97', 'dba_hist_sysstat', -2, -2, w_iops_97 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_95', 'dba_hist_sysstat', -2, -2, rw_iops_95 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_95', 'dba_hist_sysstat', -2, -2, r_iops_95 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_95', 'dba_hist_sysstat', -2, -2, w_iops_95 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_90', 'dba_hist_sysstat', -2, -2, rw_iops_90 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_90', 'dba_hist_sysstat', -2, -2, r_iops_90 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_90', 'dba_hist_sysstat', -2, -2, w_iops_90 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_75', 'dba_hist_sysstat', -2, -2, rw_iops_75 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_75', 'dba_hist_sysstat', -2, -2, r_iops_75 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_75', 'dba_hist_sysstat', -2, -2, w_iops_75 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_iops_median', 'dba_hist_sysstat', -2, -2, rw_iops_median FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_iops_median', 'dba_hist_sysstat', -2, -2, r_iops_median FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_iops_median', 'dba_hist_sysstat', -2, -2, w_iops_median FROM io_per_cluster
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
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_999', 'dba_hist_sysstat', -2, -2, r_mbps_999 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_999', 'dba_hist_sysstat', -2, -2, w_mbps_999 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_99', 'dba_hist_sysstat', -2, -2, rw_mbps_99 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_99', 'dba_hist_sysstat', -2, -2, r_mbps_99 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_99', 'dba_hist_sysstat', -2, -2, w_mbps_99 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_97', 'dba_hist_sysstat', -2, -2, rw_mbps_97 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_97', 'dba_hist_sysstat', -2, -2, r_mbps_97 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_97', 'dba_hist_sysstat', -2, -2, w_mbps_97 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_95', 'dba_hist_sysstat', -2, -2, rw_mbps_95 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_95', 'dba_hist_sysstat', -2, -2, r_mbps_95 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_95', 'dba_hist_sysstat', -2, -2, w_mbps_95 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_90', 'dba_hist_sysstat', -2, -2, rw_mbps_90 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_90', 'dba_hist_sysstat', -2, -2, r_mbps_90 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_90', 'dba_hist_sysstat', -2, -2, w_mbps_90 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_75', 'dba_hist_sysstat', -2, -2, rw_mbps_75 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_75', 'dba_hist_sysstat', -2, -2, r_mbps_75 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_75', 'dba_hist_sysstat', -2, -2, w_mbps_75 FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_median', 'dba_hist_sysstat', -2, -2, rw_mbps_median FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_median', 'dba_hist_sysstat', -2, -2, r_mbps_median FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_median', 'dba_hist_sysstat', -2, -2, w_mbps_median FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'rw_mbps_avg', 'dba_hist_sysstat', -2, -2, rw_mbps_avg FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'r_mbps_avg', 'dba_hist_sysstat', -2, -2, r_mbps_avg FROM io_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'disk_perf', 'w_mbps_avg', 'dba_hist_sysstat', -2, -2, w_mbps_avg FROM io_per_cluster
/

-- rman
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'rman', status, TO_CHAR(end_time, '&&ecr_date_format.'), 0, 0, ROUND(output_bytes / POWER(10,9), 3) value FROM v$rman_backup_job_details WHERE '&&skip_on_10g.' IS NULL ORDER BY end_time
/

-- os stats
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'osstat', stat_name, 'gv$osstat', 0, inst_id, value FROM gv$osstat ORDER BY inst_id, stat_name
/

-- cpu time series
WITH
cpu_per_inst_and_sample AS (
SELECT /*+ &&ecr_sq_fact_hints.
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       h.instance_number,
       h.snap_id,
       h.sample_id,
       MIN(h.sample_time) sample_time,
       CASE h.session_state WHEN 'ON CPU' THEN 'ON CPU' ELSE 'resmgr:cpu quantum' END session_state,
       COUNT(*) active_sessions
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id,
       h.sample_id,
       h.session_state,
       h.event
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       session_state,
       instance_number,
       TO_CHAR(TRUNC(CAST(sample_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       MAX(active_sessions) active_sessions_max, -- 100% percentile or max or peak
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY active_sessions) active_sessions_99p, -- 99% percentile
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY active_sessions) active_sessions_97p, -- 97% percentile
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY active_sessions) active_sessions_95p, -- 95% percentile
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY active_sessions) active_sessions_90p, -- 90% percentile
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY active_sessions) active_sessions_75p, -- 75% percentile
       ROUND(MEDIAN(active_sessions), 1) active_sessions_med, -- 50% percentile or median
       ROUND(AVG(active_sessions), 1) active_sessions_avg -- average
  FROM cpu_per_inst_and_sample
 GROUP BY
       session_state,
       instance_number,
       TRUNC(CAST(sample_time AS DATE), 'HH')
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts', session_state, end_time, instance_number, 0 inst_id, active_sessions_max value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_99p', session_state, end_time, instance_number, 0 inst_id, active_sessions_99p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_97p', session_state, end_time, instance_number, 0 inst_id, active_sessions_97p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_95p', session_state, end_time, instance_number, 0 inst_id, active_sessions_95p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_90p', session_state, end_time, instance_number, 0 inst_id, active_sessions_90p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_75p', session_state, end_time, instance_number, 0 inst_id, active_sessions_75p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_med', session_state, end_time, instance_number, 0 inst_id, active_sessions_med value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_avg', session_state, end_time, instance_number, 0 inst_id, active_sessions_avg value FROM cpu_per_inst_and_hour
 ORDER BY
       3, 4, 6, 5
/

-- mem time series
WITH
sga AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       h.snap_id,
       TO_CHAR(TRUNC(CAST(s.end_interval_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       SUM(h.value) bytes
  FROM dba_hist_sga h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id,
       s.end_interval_time
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem_ts', 'sga', end_time, instance_number, 0 inst_id, ROUND(MAX(bytes) / POWER(2,30), 3) value
  FROM sga
 GROUP BY
       instance_number,
       end_time
 ORDER BY
       3, 4, 6, 5
/
WITH
pga AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       h.snap_id,
       TO_CHAR(TRUNC(CAST(s.end_interval_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       SUM(h.value) bytes
  FROM dba_hist_pgastat h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   --AND h.name = 'maximum PGA allocated'
   AND h.name = 'total PGA allocated'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id,
       s.end_interval_time
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'mem_ts', 'pga', end_time, instance_number, 0 inst_id, ROUND(MAX(bytes) / POWER(2,30), 3) value
  FROM pga
 GROUP BY
       instance_number,
       end_time
 ORDER BY
       3, 4, 6, 5
/

-- disk_perf time series
WITH
sysstat_io AS (
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
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       USE_HASH(h s)
       LEADING(h.INT$DBA_HIST_SYSSTAT.nm h.INT$DBA_HIST_SYSSTAT.s h.INT$DBA_HIST_SYSSTAT.sn s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       LEADING(h.nm h.s h.sn s.WRM$_SNAPSHOT)
       */
       h.instance_number,
       h.snap_id,
       SUM(CASE WHEN h.stat_name = 'physical read total IO requests'                    THEN h.value ELSE 0 END) r_reqs,
       SUM(CASE WHEN h.stat_name IN ('physical write total IO requests', 'redo writes') THEN h.value ELSE 0 END) w_reqs,
       SUM(CASE WHEN h.stat_name = 'physical read total bytes'                          THEN h.value ELSE 0 END) r_bytes,
       SUM(CASE WHEN h.stat_name IN ('physical write total bytes', 'redo size')         THEN h.value ELSE 0 END) w_bytes
  FROM dba_hist_sysstat h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND h.stat_name IN ('physical read total IO requests', 'physical write total IO requests', 'redo writes', 'physical read total bytes', 'physical write total bytes', 'redo size')
   AND s.snap_id(+) = h.snap_id
   AND s.dbid(+) = h.dbid
   AND s.instance_number(+) = h.instance_number
   AND CAST(s.begin_interval_time(+) AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id
),
io_per_inst_and_snap_id AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s0.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s0.WRM$_SNAPSHOT)
       FULL(s1.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s1.WRM$_SNAPSHOT)
       USE_HASH(h0 s0 h1 s1)
       */
       h1.instance_number,
       TO_CHAR(TRUNC(CAST(s1.end_interval_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       (h1.r_reqs - h0.r_reqs) r_reqs,
       (h1.w_reqs - h0.w_reqs) w_reqs,
       (h1.r_bytes - h0.r_bytes) r_bytes,
       (h1.w_bytes - h0.w_bytes) w_bytes,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_io h0,
       dba_hist_snapshot s0,
       sysstat_io h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s0.dbid = &&ecr_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s1.dbid = &&ecr_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 > 60 -- ignore snaps too close
)
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

-- db_size time series
WITH
ts_per_snap_id AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       us.snap_id,
       TO_CHAR(TRUNC(CAST(sn.end_interval_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       SUM(us.tablespace_size * ts.block_size) all_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'PERMANENT' THEN us.tablespace_size * ts.block_size ELSE 0 END) perm_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'UNDO'      THEN us.tablespace_size * ts.block_size ELSE 0 END) undo_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'TEMPORARY' THEN us.tablespace_size * ts.block_size ELSE 0 END) temp_tablespaces_bytes
  FROM dba_hist_tbspc_space_usage us,
       dba_hist_snapshot sn,
       v$tablespace vt,
       dba_tablespaces ts
 WHERE us.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND us.dbid = &&ecr_dbid.
   AND sn.snap_id = us.snap_id
   AND sn.dbid = us.dbid
   AND sn.instance_number = &&ecr_instance_number.
   AND CAST(sn.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
   AND vt.ts# = us.tablespace_id
   AND ts.tablespace_name = vt.name
 GROUP BY
       us.snap_id,
       sn.end_interval_time
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'db_size_ts', 'perm', end_time, &&ecr_instance_number., 0 inst_id, ROUND(MAX(perm_tablespaces_bytes) / POWER(10,9), 3) value
  FROM ts_per_snap_id
 GROUP BY
       end_time
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'db_size_ts', 'undo', end_time, &&ecr_instance_number., 0 inst_id, ROUND(MAX(undo_tablespaces_bytes) / POWER(10,9), 3) value
  FROM ts_per_snap_id
 GROUP BY
       end_time
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'db_size_ts', 'temp', end_time, &&ecr_instance_number., 0 inst_id, ROUND(MAX(temp_tablespaces_bytes) / POWER(10,9), 3) value
  FROM ts_per_snap_id
 GROUP BY
       end_time
 ORDER BY
       3, 4, 6, 5
/

-- os time series: load, num_cpus, num_cpu_cores and physical memory
WITH
osstat_denorm AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.snap_id,
       h.instance_number,
       SUM(CASE h.stat_name WHEN 'LOAD'                  THEN h.value ELSE 0 END) load,
       SUM(CASE h.stat_name WHEN 'NUM_CPUS'              THEN h.value ELSE 0 END) num_cpus,
       SUM(CASE h.stat_name WHEN 'NUM_CPU_CORES'         THEN h.value ELSE 0 END) num_cpu_cores,
       SUM(CASE h.stat_name WHEN 'NUM_CPU_SOCKETS'       THEN h.value ELSE 0 END) num_cpu_sockets,
       SUM(CASE h.stat_name WHEN 'PHYSICAL_MEMORY_BYTES' THEN h.value ELSE 0 END) physical_memory_bytes
  FROM dba_hist_osstat h,
       dba_hist_snapshot s
 WHERE h.stat_name IN ('LOAD', 'NUM_CPUS', 'NUM_CPU_CORES', 'NUM_CPU_SOCKETS', 'PHYSICAL_MEMORY_BYTES')
   AND h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.snap_id,
       h.instance_number
),
osstat_denorm_2 AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       TO_CHAR(TRUNC(CAST(s.end_interval_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       ROUND(MAX(load), 2) load,
       MAX(num_cpus) num_cpus,
       MAX(num_cpu_cores) num_cpu_cores,
       MAX(num_cpu_sockets) num_cpu_sockets,
       MAX(physical_memory_bytes) physical_memory_bytes
  FROM osstat_denorm h,
       dba_hist_snapshot s
 WHERE s.dbid = &&ecr_dbid.
   AND s.snap_id = h.snap_id
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
   AND (CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 86400 > 60 -- ignore snaps too close
 GROUP BY
       h.instance_number,
       TRUNC(CAST(s.end_interval_time AS DATE), 'HH')
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'os_ts', 'load', end_time, instance_number, 0 inst_id, load value
  FROM osstat_denorm_2
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'os_ts', 'num_cpus', end_time, instance_number, 0 inst_id, num_cpus value
  FROM osstat_denorm_2
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'os_ts', 'num_cpu_cores', end_time, instance_number, 0 inst_id, num_cpu_cores value
  FROM osstat_denorm_2
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'os_ts', 'num_cpu_sockets', end_time, instance_number, 0 inst_id, num_cpu_sockets value
  FROM osstat_denorm_2
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'os_ts', 'physical_memory_gb', end_time, instance_number, 0 inst_id, ROUND(physical_memory_bytes / POWER(2,30), 3) value
  FROM osstat_denorm_2
 ORDER BY
       3, 4, 6, 5
/
-- nw_perf
WITH
sysstat_nwtraf AS (
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
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       USE_HASH(h s)
       LEADING(h.INT$DBA_HIST_SYSSTAT.nm h.INT$DBA_HIST_SYSSTAT.s h.INT$DBA_HIST_SYSSTAT.sn s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       LEADING(h.nm h.s h.sn s.WRM$_SNAPSHOT)
       */
       h.instance_number,
       h.snap_id,
       SUM(CASE WHEN h.stat_name = 'bytes sent via SQL*Net to client'                   THEN h.value ELSE 0 END) tx_cl,
       SUM(CASE WHEN h.stat_name = 'bytes received via SQL*Net from client'             THEN h.value ELSE 0 END) rx_cl,
       SUM(CASE WHEN h.stat_name = 'bytes sent via SQL*Net to dblink'                   THEN h.value ELSE 0 END) tx_dl,
       SUM(CASE WHEN h.stat_name = 'bytes received via SQL*Net from dblink'             THEN h.value ELSE 0 END) rx_dl
  FROM dba_hist_sysstat h,
       dba_hist_snapshot s
 WHERE '&&INCLUDE_NETW.' = 'Y'
   AND h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND h.stat_name IN ('bytes sent via SQL*Net to client','bytes received via SQL*Net from client','bytes sent via SQL*Net to dblink','bytes received via SQL*Net from dblink')
   AND s.snap_id(+) = h.snap_id
   AND s.dbid(+) = h.dbid
   AND s.instance_number(+) = h.instance_number
   AND CAST(s.begin_interval_time(+) AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id
),
nwtraf_per_inst_and_snap_id AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s0.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s0.WRM$_SNAPSHOT)
       FULL(s1.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s1.WRM$_SNAPSHOT)
       USE_HASH(h0 s0 h1 s1)
       */
       h1.instance_number,
       h1.snap_id,
       (h1.tx_cl - h0.tx_cl) tx_cl,
       (h1.rx_cl - h0.rx_cl) rx_cl,
       (h1.tx_dl - h0.tx_dl) tx_dl,
       (h1.rx_dl - h0.rx_dl) rx_dl,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_nwtraf h0,
       dba_hist_snapshot s0,
       sysstat_nwtraf h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s0.dbid = &&ecr_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s1.dbid = &&ecr_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
),
nwtraf_per_snap_id AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       snap_id,
       SUM(tx_cl) tx_cl,
       SUM(rx_cl) rx_cl,
       SUM(tx_dl) tx_dl,
       SUM(rx_dl) rx_dl,
       AVG(elapsed_sec) elapsed_sec
  FROM nwtraf_per_inst_and_snap_id
 GROUP BY
       snap_id
),
nw_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       instance_number,
       ROUND(100 * (SUM(tx_cl) + SUM(tx_dl)) / (SUM(tx_cl) + SUM(rx_cl) + SUM(tx_dl) + SUM(rx_dl)), 1) nw_tx_perc,
       ROUND(100 * (SUM(rx_cl) + SUM(rx_dl)) / (SUM(tx_cl) + SUM(rx_cl) + SUM(tx_dl) + SUM(rx_dl)), 1) nw_rx_perc,
       ROUND(100 * (SUM(rx_cl) + SUM(tx_cl)) / (SUM(tx_cl) + SUM(rx_cl) + SUM(tx_dl) + SUM(rx_dl)), 1) nw_cl_perc,
       ROUND(100 * (SUM(rx_dl) + SUM(tx_dl)) / (SUM(tx_cl) + SUM(rx_cl) + SUM(tx_dl) + SUM(rx_dl)), 1) nw_dl_perc,
       ROUND(MAX((tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_peak_bytes,
       ROUND(MAX((tx_cl + tx_dl) / elapsed_sec)) nw_tx_peak_bytes,
       ROUND(MAX((rx_cl + rx_dl) / elapsed_sec)) nw_rx_peak_bytes,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_999_bytes,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_999_bytes,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_999_bytes,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_99_bytes,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_99_bytes,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_99_bytes,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_97_bytes,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_97_bytes,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_97_bytes,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_95_bytes,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_95_bytes,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_95_bytes,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_90_bytes,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_90_bytes,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_90_bytes,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_75_bytes,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_75_bytes,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_75_bytes,
       ROUND(MEDIAN((tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_median_bytes,
       ROUND(MEDIAN((tx_cl + tx_dl) / elapsed_sec)) nw_tx_median_bytes,
       ROUND(MEDIAN((rx_cl + rx_dl) / elapsed_sec)) nw_rx_median_bytes,
       ROUND(AVG((tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_avg_bytes,
       ROUND(AVG((tx_cl + tx_dl) / elapsed_sec)) nw_tx_avg_bytes,
       ROUND(AVG((rx_cl + rx_dl) / elapsed_sec)) nw_rx_avg_bytes
  FROM nwtraf_per_inst_and_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       instance_number
),
nw_per_cluster AS ( -- combined
SELECT /*+ &&ecr_sq_fact_hints. */
       ROUND(100 * (SUM(tx_cl) + SUM(tx_dl)) / (SUM(tx_cl) + SUM(rx_cl) + SUM(tx_dl) + SUM(rx_dl)), 1) nw_tx_perc,
       ROUND(100 * (SUM(rx_cl) + SUM(rx_dl)) / (SUM(tx_cl) + SUM(rx_cl) + SUM(tx_dl) + SUM(rx_dl)), 1) nw_rx_perc,
       ROUND(100 * (SUM(rx_cl) + SUM(tx_cl)) / (SUM(tx_cl) + SUM(rx_cl) + SUM(tx_dl) + SUM(rx_dl)), 1) nw_cl_perc,
       ROUND(100 * (SUM(rx_dl) + SUM(tx_dl)) / (SUM(tx_cl) + SUM(rx_cl) + SUM(tx_dl) + SUM(rx_dl)), 1) nw_dl_perc,
       ROUND(MAX((tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_peak_bytes,
       ROUND(MAX((tx_cl + tx_dl) / elapsed_sec)) nw_tx_peak_bytes,
       ROUND(MAX((rx_cl + rx_dl) / elapsed_sec)) nw_rx_peak_bytes,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_999_bytes,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_999_bytes,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_999_bytes,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_99_bytes,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_99_bytes,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_99_bytes,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_97_bytes,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_97_bytes,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_97_bytes,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_95_bytes,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_95_bytes,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_95_bytes,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_90_bytes,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_90_bytes,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_90_bytes,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_75_bytes,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (tx_cl + tx_dl) / elapsed_sec)) nw_tx_75_bytes,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (rx_cl + rx_dl) / elapsed_sec)) nw_rx_75_bytes,
       ROUND(MEDIAN((tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_median_bytes,
       ROUND(MEDIAN((tx_cl + tx_dl) / elapsed_sec)) nw_tx_median_bytes,
       ROUND(MEDIAN((rx_cl + rx_dl) / elapsed_sec)) nw_rx_median_bytes,
       ROUND(AVG((tx_cl + rx_cl + tx_dl + rx_dl) / elapsed_sec)) nw_avg_bytes,
       ROUND(AVG((tx_cl + tx_dl) / elapsed_sec)) nw_tx_avg_bytes,
       ROUND(AVG((rx_cl + rx_dl) / elapsed_sec)) nw_rx_avg_bytes
  FROM nwtraf_per_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_perc', 'dba_hist_sysstat', instance_number, 0, nw_tx_perc FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_perc', 'dba_hist_sysstat', instance_number, 0, nw_rx_perc FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_cl_perc', 'dba_hist_sysstat', instance_number, 0, nw_cl_perc FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_dl_perc', 'dba_hist_sysstat', instance_number, 0, nw_dl_perc FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_peak_bytes', 'dba_hist_sysstat', instance_number, 0, nw_peak_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_peak_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_peak_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_peak_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_peak_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_999_bytes', 'dba_hist_sysstat', instance_number, 0, nw_999_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_99_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_99_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_99_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_99_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_99_bytes', 'dba_hist_sysstat', instance_number, 0, nw_99_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_99_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_99_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_99_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_99_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_97_bytes', 'dba_hist_sysstat', instance_number, 0, nw_97_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_97_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_97_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_97_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_97_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_95_bytes', 'dba_hist_sysstat', instance_number, 0, nw_95_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_95_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_95_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_95_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_95_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_90_bytes', 'dba_hist_sysstat', instance_number, 0, nw_90_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_90_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_90_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_90_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_90_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_75_bytes', 'dba_hist_sysstat', instance_number, 0, nw_75_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_75_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_75_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_75_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_75_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_median_bytes', 'dba_hist_sysstat', instance_number, 0, nw_median_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_median_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_median_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_median_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_median_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_avg_bytes', 'dba_hist_sysstat', instance_number, 0, nw_avg_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_avg_bytes', 'dba_hist_sysstat', instance_number, 0, nw_tx_avg_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_avg_bytes', 'dba_hist_sysstat', instance_number, 0, nw_rx_avg_bytes FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_perc', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_perc) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_perc', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_perc) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_cl_perc', 'dba_hist_sysstat', -1, -1, SUM(nw_cl_perc) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_dl_perc', 'dba_hist_sysstat', -1, -1, SUM(nw_dl_perc) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_peak_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_peak_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_peak_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_peak_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_peak_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_peak_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_999_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_999_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_99_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_99_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_99_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_99_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_99_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_99_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_99_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_99_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_99_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_99_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_97_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_97_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_97_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_97_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_97_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_97_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_95_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_95_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_95_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_95_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_95_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_95_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_90_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_90_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_90_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_90_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_90_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_90_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_75_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_75_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_75_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_75_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_75_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_75_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_median_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_median_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_median_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_median_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_median_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_median_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_avg_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_avg_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_avg_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_tx_avg_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_avg_bytes', 'dba_hist_sysstat', -1, -1, SUM(nw_rx_avg_bytes) FROM nw_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_perc', 'dba_hist_sysstat', -2,-2, nw_tx_perc FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_perc', 'dba_hist_sysstat', -2,-2, nw_rx_perc FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_cl_perc', 'dba_hist_sysstat', -2,-2, nw_cl_perc FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_dl_perc', 'dba_hist_sysstat', -2,-2, nw_dl_perc FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_peak_bytes', 'dba_hist_sysstat', -2,-2, nw_peak_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_peak_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_peak_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_peak_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_peak_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_999_bytes', 'dba_hist_sysstat', -2,-2, nw_999_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_99_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_99_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_99_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_99_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_99_bytes', 'dba_hist_sysstat', -2,-2, nw_99_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_99_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_99_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_99_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_99_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_97_bytes', 'dba_hist_sysstat', -2,-2, nw_97_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_97_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_97_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_97_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_97_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_95_bytes', 'dba_hist_sysstat', -2,-2, nw_95_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_95_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_95_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_95_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_95_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_90_bytes', 'dba_hist_sysstat', -2,-2, nw_90_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_90_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_90_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_90_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_90_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_75_bytes', 'dba_hist_sysstat', -2,-2, nw_75_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_75_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_75_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_75_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_75_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_median_bytes', 'dba_hist_sysstat', -2,-2, nw_median_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_median_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_median_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_median_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_median_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_avg_bytes', 'dba_hist_sysstat', -2,-2, nw_avg_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_tx_avg_bytes', 'dba_hist_sysstat', -2,-2, nw_tx_avg_bytes FROM nw_per_cluster
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf', 'nw_rx_avg_bytes', 'dba_hist_sysstat', -2,-2, nw_rx_avg_bytes FROM nw_per_cluster
/
-- nw_perf time series
WITH
sysstat_nwtraf AS (
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
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       USE_HASH(h s)
       LEADING(h.INT$DBA_HIST_SYSSTAT.nm h.INT$DBA_HIST_SYSSTAT.s h.INT$DBA_HIST_SYSSTAT.sn s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       LEADING(h.nm h.s h.sn s.WRM$_SNAPSHOT)
       */
       h.instance_number,
       h.snap_id,
       SUM(CASE WHEN h.stat_name = 'bytes sent via SQL*Net to client'                   THEN h.value ELSE 0 END) tx_cl,
       SUM(CASE WHEN h.stat_name = 'bytes received via SQL*Net from client'             THEN h.value ELSE 0 END) rx_cl,
       SUM(CASE WHEN h.stat_name = 'bytes sent via SQL*Net to dblink'                   THEN h.value ELSE 0 END) tx_dl,
       SUM(CASE WHEN h.stat_name = 'bytes received via SQL*Net from dblink'             THEN h.value ELSE 0 END) rx_dl
  FROM dba_hist_sysstat h,
       dba_hist_snapshot s
 WHERE '&&INCLUDE_NETW.' = 'Y'
   AND h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND h.stat_name IN ('bytes sent via SQL*Net to client','bytes received via SQL*Net from client','bytes sent via SQL*Net to dblink','bytes received via SQL*Net from dblink')
   AND s.snap_id(+) = h.snap_id
   AND s.dbid(+) = h.dbid
   AND s.instance_number(+) = h.instance_number
   AND CAST(s.begin_interval_time(+) AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id
),
nwtraf_per_inst_and_snap_id AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s0.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s0.WRM$_SNAPSHOT)
       FULL(s1.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s1.WRM$_SNAPSHOT)
       USE_HASH(h0 s0 h1 s1)
       */
       h1.instance_number,
       TO_CHAR(TRUNC(CAST(s1.end_interval_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       (h1.tx_cl - h0.tx_cl) tx_cl,
       (h1.rx_cl - h0.rx_cl) rx_cl,
       (h1.tx_dl - h0.tx_dl) tx_dl,
       (h1.rx_dl - h0.rx_dl) rx_dl,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_nwtraf h0,
       dba_hist_snapshot s0,
       sysstat_nwtraf h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s0.dbid = &&ecr_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s1.dbid = &&ecr_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 > 60 -- ignore snaps too close
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf_ts', 'nw_tx_bytes', end_time, instance_number, 0 inst_id, ROUND(MAX((tx_cl + tx_dl) / elapsed_sec)) value
  FROM nwtraf_per_inst_and_snap_id
 GROUP BY
       instance_number,
       end_time
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf_ts', 'nw_rx_bytes', end_time, instance_number, 0 inst_id, ROUND(MAX((rx_cl + rx_dl) / elapsed_sec)) value
  FROM nwtraf_per_inst_and_snap_id
 GROUP BY
       instance_number,
       end_time
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf_ts', 'nw_cl_bytes', end_time, instance_number, 0 inst_id, ROUND(MAX((tx_cl + rx_cl) / elapsed_sec)) value
  FROM nwtraf_per_inst_and_snap_id
 GROUP BY
       instance_number,
       end_time
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'nw_perf_ts', 'nw_dl_bytes', end_time, instance_number, 0 inst_id, ROUND(MAX((tx_dl + rx_dl) / elapsed_sec)) value
  FROM nwtraf_per_inst_and_snap_id
 GROUP BY
       instance_number,
       end_time
 ORDER BY
       3, 4, 6, 5
/

-- ic_perf
WITH
hist_ictraf AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       h.snap_id,
       SUM(CASE WHEN h.stat_name = 'gc cr blocks received' 		                THEN h.value ELSE 0 END) gc_cr_bl_rx,
       SUM(CASE WHEN h.stat_name = 'gc current blocks received'				THEN h.value ELSE 0 END) gc_cur_bl_rx,
       SUM(CASE WHEN h.stat_name = 'gc cr blocks served'				THEN h.value ELSE 0 END) gc_cr_bl_serv,
       SUM(CASE WHEN h.stat_name = 'gc current blocks served'				THEN h.value ELSE 0 END) gc_cur_bl_serv, 
       SUM(CASE WHEN h.stat_name = 'gcs messages sent'   				THEN h.value ELSE 0 END) gcs_msg_sent, 
       SUM(CASE WHEN h.stat_name = 'ges messages sent'   				THEN h.value ELSE 0 END) ges_msg_sent, 
       SUM(CASE WHEN d.name      = 'gcs msgs received'   				THEN d.value ELSE 0 END) gcs_msg_rcv, 
       SUM(CASE WHEN d.name      = 'ges msgs received'   				THEN d.value ELSE 0 END) ges_msg_rcv, 
       SUM(CASE WHEN p.parameter_name = 'db_block_size'	 				THEN to_number(p.value) ELSE 0 END) block_size 
  FROM dba_hist_sysstat h,
       dba_hist_dlm_misc d,
       dba_hist_snapshot s,
       dba_hist_parameter p
 WHERE '&&INCLUDE_IC.' = 'Y'
   AND h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND h.stat_name IN ('gc cr blocks received','gc current blocks received','gc cr blocks served','gc current blocks served','gcs messages sent','ges messages sent')
   AND d.name IN ('gcs msgs received','ges msgs received')
   AND p.parameter_name = 'db_block_size'
   AND s.snap_id = h.snap_id
   AND d.snap_id = h.snap_id
   AND p.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND d.dbid = h.dbid
   AND p.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND d.instance_number = h.instance_number
   AND p.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id
),
ictraf_per_inst_and_snap_id AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h1.instance_number,
       h1.snap_id,
       (h1.gc_cr_bl_rx - h0.gc_cr_bl_rx) gc_cr_bl_rx,
       (h1.gc_cur_bl_rx - h0.gc_cur_bl_rx) gc_cur_bl_rx,
       (h1.gc_cr_bl_serv - h0.gc_cr_bl_serv) gc_cr_bl_serv,
       (h1.gc_cur_bl_serv - h0.gc_cur_bl_serv) gc_cur_bl_serv,
       (h1.gcs_msg_sent - h0.gcs_msg_sent) gcs_msg_sent,
       (h1.ges_msg_sent - h0.ges_msg_sent) ges_msg_sent,
       (h1.gcs_msg_rcv - h0.gcs_msg_rcv) gcs_msg_rcv,
       (h1.ges_msg_rcv - h0.ges_msg_rcv) ges_msg_rcv,
	h1.block_size,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM hist_ictraf h0,
       dba_hist_snapshot s0,
       hist_ictraf h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s0.dbid = &&ecr_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s1.dbid = &&ecr_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
),
ictraf_per_snap_id AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       snap_id,
       SUM(gc_cr_bl_rx) gc_cr_bl_rx,
       SUM(gc_cur_bl_rx) gc_cur_bl_rx,
       SUM(gc_cr_bl_serv) gc_cr_bl_serv,
       SUM(gc_cur_bl_serv) gc_cur_bl_serv,
       SUM(gcs_msg_sent) gcs_msg_sent,
       SUM(ges_msg_sent) ges_msg_sent,
       SUM(gcs_msg_rcv) gcs_msg_rcv,
       SUM(ges_msg_rcv) ges_msg_rcv,
       block_size, 
       AVG(elapsed_sec) elapsed_sec
  FROM ictraf_per_inst_and_snap_id
 GROUP BY
       snap_id
),
ic_per_inst AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       instance_number,
       ROUND(MAX(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_peak_bytes,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP ( ORDER BY( ((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec) ) ) ic_999_bytes,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP ( ORDER BY( ((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec) ) ) ic_99_bytes,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP ( ORDER BY(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec) ) ) ic_97_bytes,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP ( ORDER BY(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec) ) ) ic_95_bytes,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP ( ORDER BY(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec) ) ) ic_90_bytes,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP ( ORDER BY(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec) ) ) ic_75_bytes,
       ROUND(MEDIAN((((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec))) ic_median_bytes,
       ROUND(AVG((((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec))) ic_avg_bytes
  FROM ictraf_per_inst_and_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       instance_number
),
ic_per_cluster AS ( -- combined
SELECT /*+ &&ecr_sq_fact_hints. */
       ROUND(MAX(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_peak_bytes,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP ( ORDER BY((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_999_bytes,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP ( ORDER BY((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_99_bytes,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP ( ORDER BY((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_97_bytes,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP ( ORDER BY((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_95_bytes,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP ( ORDER BY((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_90_bytes,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP ( ORDER BY((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_75_bytes,
       ROUND(MEDIAN(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_median_bytes,
       ROUND(AVG(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) ic_avg_bytes
  FROM ictraf_per_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_peak_bytes', 'dba_hist_sysstat|dlm_misc', instance_number, 0, ic_peak_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_999_bytes', 'dba_hist_sysstat|dlm_misc', instance_number, 0, ic_999_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_99_bytes', 'dba_hist_sysstat|dlm_misc', instance_number, 0, ic_99_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_97_bytes', 'dba_hist_sysstat|dlm_misc', instance_number, 0, ic_97_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_95_bytes', 'dba_hist_sysstat|dlm_misc', instance_number, 0, ic_95_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_90_bytes', 'dba_hist_sysstat|dlm_misc', instance_number, 0, ic_90_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_75_bytes', 'dba_hist_sysstat|dlm_misc', instance_number, 0, ic_75_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_median_bytes', 'dba_hist_sysstat|dlm_misc', instance_number, 0, ic_median_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_peak_bytes', 'dba_hist_sysstat|dlm_misc', -1, -1, SUM(ic_peak_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_999_bytes', 'dba_hist_sysstat|dlm_misc', -1, -1, SUM(ic_999_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_99_bytes', 'dba_hist_sysstat|dlm_misc', -1, -1, SUM(ic_99_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_97_bytes', 'dba_hist_sysstat|dlm_misc', -1, -1, SUM(ic_97_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_95_bytes', 'dba_hist_sysstat|dlm_misc', -1, -1, SUM(ic_95_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_90_bytes', 'dba_hist_sysstat|dlm_misc', -1, -1, SUM(ic_90_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_75_bytes', 'dba_hist_sysstat|dlm_misc', -1, -1, SUM(ic_75_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_median_bytes', 'dba_hist_sysstat|dlm_misc', -1, -1, SUM(ic_median_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_avg_bytes', 'dba_hist_sysstat|dlm_misc', -1, 01, SUM(ic_avg_bytes) FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_peak_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_peak_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_999_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_999_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_99_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_99_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_97_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_97_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_95_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_95_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_90_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_90_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_75_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_75_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_median_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_median_bytes FROM ic_per_inst
UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf', 'ic_avg_bytes', 'dba_hist_sysstat|dlm_misc', -2, -2, ic_avg_bytes FROM ic_per_inst
/
-- ic_perf time series
WITH
hist_ictraf AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       h.snap_id,
       SUM(CASE WHEN h.stat_name = 'gc cr blocks received'                              THEN h.value ELSE 0 END) gc_cr_bl_rx,
       SUM(CASE WHEN h.stat_name = 'gc current blocks received'                         THEN h.value ELSE 0 END) gc_cur_bl_rx,
       SUM(CASE WHEN h.stat_name = 'gc cr blocks served'                                THEN h.value ELSE 0 END) gc_cr_bl_serv,
       SUM(CASE WHEN h.stat_name = 'gc current blocks served'                           THEN h.value ELSE 0 END) gc_cur_bl_serv,
       SUM(CASE WHEN h.stat_name = 'gcs messages sent'                                  THEN h.value ELSE 0 END) gcs_msg_sent,
       SUM(CASE WHEN h.stat_name = 'ges messages sent'                                  THEN h.value ELSE 0 END) ges_msg_sent,
       SUM(CASE WHEN d.name      = 'gcs msgs received'                                  THEN d.value ELSE 0 END) gcs_msg_rcv,
       SUM(CASE WHEN d.name      = 'ges msgs received'                                  THEN d.value ELSE 0 END) ges_msg_rcv,
       SUM(CASE WHEN p.parameter_name = 'db_block_size'                                 THEN to_number(p.value) ELSE 0 END) block_size
  FROM dba_hist_sysstat h,
       dba_hist_dlm_misc d,
       dba_hist_snapshot s,
       dba_hist_parameter p
 WHERE '&&INCLUDE_IC.' = 'Y'
   AND h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND h.stat_name IN ('gc cr blocks received','gc current blocks received','gc cr blocks served','gc current blocks served','gcs messages sent','ges messages sent')
   AND d.name IN ('gcs msgs received','ges msgs received')
   AND p.parameter_name = 'db_block_size'
   AND s.snap_id = h.snap_id
   AND d.snap_id = h.snap_id
   AND p.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND d.dbid = h.dbid
   AND p.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND d.instance_number = h.instance_number
   AND p.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.instance_number,
       h.snap_id
),
ictraf_per_inst_and_snap_id AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h1.instance_number,
       TO_CHAR(TRUNC(CAST(s1.end_interval_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       (h1.gc_cr_bl_rx - h0.gc_cr_bl_rx) gc_cr_bl_rx,
       (h1.gc_cur_bl_rx - h0.gc_cur_bl_rx) gc_cur_bl_rx,
       (h1.gc_cr_bl_serv - h0.gc_cr_bl_serv) gc_cr_bl_serv,
       (h1.gc_cur_bl_serv - h0.gc_cur_bl_serv) gc_cur_bl_serv,
       (h1.gcs_msg_sent - h0.gcs_msg_sent) gcs_msg_sent,
       (h1.ges_msg_sent - h0.ges_msg_sent) ges_msg_sent,
       (h1.gcs_msg_rcv - h0.gcs_msg_rcv) gcs_msg_rcv,
       (h1.ges_msg_rcv - h0.ges_msg_rcv) ges_msg_rcv,
        h1.block_size,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM hist_ictraf h0,
       dba_hist_snapshot s0,
       hist_ictraf h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s0.dbid = &&ecr_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND s1.dbid = &&ecr_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'ic_perf_ts', 'interconnect_bytes', end_time, instance_number, 0 inst_id, ROUND(MAX(((gc_cr_bl_rx + gc_cur_bl_rx + gc_cr_bl_serv + gc_cur_bl_serv)*block_size)+((gcs_msg_sent + ges_msg_sent + gcs_msg_rcv + ges_msg_rcv)*200) / elapsed_sec)) value
  FROM ictraf_per_inst_and_snap_id
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
