-- Test the data range in esp with the CPU query
SPOOL test_range.txt 
-- New Dates format
DEF escp_date_format = 'YYYY-MM-DD"T"HH24:MI:SS';
DEF escp_timestamp_format = 'YYYY-MM-DD"T"HH24:MI:SS.FF';
DEF escp_timestamp_tz_format = 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM';

DEF ESCP_MAX_DAYS = '365';

-- Get dbid
COL escp_this_dbid NEW_V escp_this_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) escp_this_dbid FROM v$database
/

-- To support Date Range
-- get collection days escp_collection_days
DEF escp_collection_days = '&&ESCP_MAX_DAYS.';
COL escp_collection_days NEW_V escp_collection_days;
SELECT NVL(TO_CHAR(LEAST(EXTRACT(DAY FROM retention), TO_NUMBER('&&ESCP_MAX_DAYS.'))), '&&ESCP_MAX_DAYS.') escp_collection_days FROM dba_hist_wr_control WHERE dbid = &&escp_this_dbid;

-- get escp_min_snap_id
DEF escp_min_snap_id = '';
COL escp_min_snap_id NEW_V escp_min_snap_id;
SELECT 'get_min_snap_id', TO_CHAR(MIN(snap_id)) escp_min_snap_id FROM dba_hist_snapshot WHERE dbid = &&escp_this_dbid. AND CAST(begin_interval_time AS DATE) > SYSDATE - &&escp_collection_days.
/
SELECT NVL('&&escp_min_snap_id.','0') escp_min_snap_id FROM DUAL
/

-- New:
-- range of dates below supersede history days when values are other than YYYY-MM-DD
-- DEF escp_conf_date_from = 'YYYY-MM-DD';
-- DEF escp_conf_date_to   = 'YYYY-MM-DD';
DEF escp_conf_date_from = '2021-04-08';
DEF escp_conf_date_to   = '2021-04-10';

COL history_days NEW_V history_days;
-- range: takes at least 31 days and at most as many as actual history, with a default of 31. parameter restricts within that range. 
SELECT TO_CHAR(LEAST(CEIL(SYSDATE - CAST(MIN(begin_interval_time) AS DATE)), TO_NUMBER('&&escp_collection_days.'))) history_days FROM dba_hist_snapshot WHERE dbid = &&escp_this_dbid.;
SELECT TO_CHAR(TO_DATE('&&escp_conf_date_to.', 'YYYY-MM-DD') - TO_DATE('&&escp_conf_date_from.', 'YYYY-MM-DD') + 1) history_days FROM DUAL WHERE '&&escp_conf_date_from.' != 'YYYY-MM-DD' AND '&&escp_conf_date_to.' != 'YYYY-MM-DD';

COL escp_date_from NEW_V escp_date_from;
COL escp_date_to   NEW_V escp_date_to;
SELECT CASE '&&escp_conf_date_from.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE - &&history_days., '&&escp_date_format.') ELSE '&&escp_conf_date_from.T00:00:00' END escp_date_from FROM DUAL;
SELECT CASE '&&escp_conf_date_to.'   WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE, '&&escp_date_format.') ELSE '&&escp_conf_date_to.T23:59:59' END escp_date_to FROM DUAL;

-- snapshot ranges
COL minimum_snap_id NEW_V minimum_snap_id;
SELECT NVL(TO_CHAR(MIN(snap_id)), '0') minimum_snap_id FROM dba_hist_snapshot WHERE dbid = &&escp_this_dbid. AND begin_interval_time > TO_DATE('&&escp_date_from.', '&&escp_date_format.');
SELECT '-1' minimum_snap_id FROM DUAL WHERE TRIM('&&minimum_snap_id.') IS NULL;
COL maximum_snap_id NEW_V maximum_snap_id;
SELECT NVL(TO_CHAR(MAX(snap_id)), '&&minimum_snap_id.') maximum_snap_id FROM dba_hist_snapshot WHERE dbid = &&escp_this_dbid. AND end_interval_time < TO_DATE('&&escp_date_to.', '&&escp_date_format.');
SELECT '-1' maximum_snap_id FROM DUAL WHERE TRIM('&&maximum_snap_id.') IS NULL;

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
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&escp_this_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
   AND h.sample_time BETWEEN TO_TIMESTAMP('&&escp_date_from.','&&escp_timestamp_format.') 
              AND TO_TIMESTAMP('&&escp_date_to.','&&escp_timestamp_format.')
 GROUP BY
       h.session_state,
       h.instance_number,
       h.sample_time
 ORDER BY
       h.session_state,
       h.instance_number,
       h.sample_time
/
SPOOL OFF 
/*
From:
h.snap_id >= &&escp_min_snap_id.
To:
snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
From:
h.sample_time >= SYSTIMESTAMP - &&escp_collection_days.
To:
h.sample_time BETWEEN TO_TIMESTAMP('&&escp_date_from.','&&escp_timestamp_format.') 
              AND TO_TIMESTAMP('&&escp_date_to.','&&escp_timestamp_format.')
*/

