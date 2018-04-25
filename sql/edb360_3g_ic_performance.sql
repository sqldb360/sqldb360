@@&&edb360_0g.tkprof.sql
DEF section_id = '3g';
DEF section_name = 'Interconnect Performance';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';

BEGIN
  :sql_text_backup := q'[
WITH ic_client_stats AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.dbid,
       h.instance_number,
       h.name,
       s.begin_interval_time,
       s.end_interval_time,
       s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.name ORDER BY h.snap_id) startup_time_interval,
       h.bytes_sent - LAG(h.bytes_sent) OVER (PARTITION BY h.dbid, h.instance_number, h.name ORDER BY h.snap_id) bytes_sent,
       h.bytes_received - LAG(h.bytes_received) OVER (PARTITION BY h.dbid, h.instance_number, h.name ORDER BY h.snap_id) bytes_received
  FROM &&awr_object_prefix.ic_client_stats h,
       &&awr_object_prefix.snapshot s
 WHERE h.instance_number = @instance_number@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
per_instance AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       begin_interval_time,
       end_interval_time,
       instance_number,
       ROUND(SUM(bytes_received) / POWER(10,6) / ROUND((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 24 * 60 * 60), 2) mbps_received,
       ROUND(SUM(bytes_sent) / POWER(10,6) / ROUND((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 24 * 60 * 60), 2) mbps_sent
  FROM ic_client_stats
  WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
    AND bytes_received >= 0
    AND bytes_sent >= 0
 GROUP BY
       snap_id,
       begin_interval_time,
       end_interval_time,
       instance_number
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(mbps_sent) + SUM(mbps_received) mbps_total,
       SUM(mbps_sent) mbps_sent,
       SUM(mbps_received) mbps_received,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM per_instance
 GROUP BY       
       snap_id
 ORDER BY       
       snap_id
]';
END;
/
DEF main_table = '&&awr_hist_prefix.IC_CLIENT_STATS';
DEF vaxis = 'IC Client Statistics (MBPS)';
DEF tit_01 = 'MBPS Total';
DEF tit_02 = 'MBPS Sent';
DEF tit_03 = 'MBPS Received';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF skip_lch = '';
DEF title = 'Interconnect Client Statistics for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'h.instance_number');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'Interconnect Client Statistics for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'Interconnect Client Statistics for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'Interconnect Client Statistics for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'Interconnect Client Statistics for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'Interconnect Client Statistics for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'Interconnect Client Statistics for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'Interconnect Client Statistics for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'Interconnect Client Statistics for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

/****************************************************************************************/

BEGIN
  :sql_text_backup := q'[
WITH 
ic_device_stats AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.dbid,
       h.instance_number,
       h.if_name,
       s.begin_interval_time,
       s.end_interval_time,
       s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) startup_time_interval,
       h.bytes_received - LAG(h.bytes_received) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) bytes_received,
       h.packets_received - LAG(h.packets_received) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) packets_received,
       h.receive_errors - LAG(h.receive_errors) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) receive_errors,
       h.receive_dropped - LAG(h.receive_dropped) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) receive_dropped,
       h.receive_buf_or - LAG(h.receive_buf_or) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) receive_buf_or,
       h.receive_frame_err - LAG(h.receive_frame_err) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) receive_frame_err,
       h.bytes_sent - LAG(h.bytes_sent) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) bytes_sent,
       h.packets_sent - LAG(h.packets_sent) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) packets_sent,
       h.send_errors - LAG(h.send_errors) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) send_errors,
       h.sends_dropped - LAG(h.sends_dropped) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) sends_dropped,
       h.send_buf_or - LAG(h.send_buf_or) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) send_buf_or,
       h.send_carrier_lost - LAG(h.send_carrier_lost) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) send_carrier_lost
  FROM &&awr_object_prefix.ic_device_stats h,
       &&awr_object_prefix.snapshot s
 WHERE h.instance_number = @instance_number@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
per_instance AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       begin_interval_time,
       end_interval_time,
       instance_number,
       if_name,
       SUM(bytes_received) bytes_received,
       SUM(packets_received) packets_received,
       SUM(receive_errors) receive_errors,
       SUM(receive_dropped) receive_dropped,
       SUM(receive_buf_or) receive_buf_or,
       SUM(receive_frame_err) receive_frame_err,
       SUM(bytes_sent) bytes_sent,
       SUM(packets_sent) packets_sent,
       SUM(send_errors) send_errors,
       SUM(sends_dropped) sends_dropped,
       SUM(send_buf_or) send_buf_or,
       SUM(send_carrier_lost) send_carrier_lost
  FROM ic_device_stats
  WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
    AND bytes_received >= 0
    AND packets_received >= 0
    AND receive_errors >= 0
    AND receive_dropped >= 0
    AND receive_buf_or >= 0
    AND receive_frame_err >= 0
    AND bytes_sent >= 0
    AND packets_sent >= 0
    AND send_errors >= 0
    AND sends_dropped >= 0
    AND send_buf_or >= 0
    AND send_carrier_lost >= 0
 GROUP BY
       snap_id,
       begin_interval_time,
       end_interval_time,
       instance_number,
       if_name
),
per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       begin_interval_time,
       end_interval_time,
       SUM(bytes_received) bytes_received,
       SUM(packets_received) packets_received,
       SUM(receive_errors) receive_errors,
       SUM(receive_dropped) receive_dropped,
       SUM(receive_buf_or) receive_buf_or,
       SUM(receive_frame_err) receive_frame_err,
       SUM(bytes_sent) bytes_sent,
       SUM(packets_sent) packets_sent,
       SUM(send_errors) send_errors,
       SUM(sends_dropped) sends_dropped,
       SUM(send_buf_or) send_buf_or,
       SUM(send_carrier_lost) send_carrier_lost
  FROM per_instance
 GROUP BY
       snap_id,
       begin_interval_time,
       end_interval_time
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id
       ,TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time
       ,TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time
       #column01#
       #column02#
       #column03#
       #column04#
       #column05#
       #column06#
       #column07#
       #column08#
       #column09#
       #column10#
       ,0 dummy_11
       ,0 dummy_12
       ,0 dummy_13
       ,0 dummy_14
       ,0 dummy_15
  FROM per_cluster
 ORDER BY       
       snap_id
]';
END;
/
DEF main_table = '&&awr_hist_prefix.IC_DEVICE_STATS';
DEF vaxis = 'IC Device Statistics';
DEF tit_01 = 'Packets Received';
DEF tit_02 = 'Packets Sent';
DEF tit_03 = 'Receive Errors';
DEF tit_04 = 'Receive Dropped';
DEF tit_05 = 'Receive Buffer Overruns';
DEF tit_06 = 'Receive Frame Error';
DEF tit_07 = 'Send Errors';
DEF tit_08 = 'Sends Dropped';
DEF tit_09 = 'Send Buffer Overruns';
DEF tit_10 = 'Send Carrier Lost';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', ', packets_received');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', ', packets_sent');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', ', receive_errors');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', ', receive_dropped');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', ', receive_buf_or');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', ', receive_frame_err');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', ', send_errors');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', ', sends_dropped');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', ', send_buf_or');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', ', send_carrier_lost');

DEF skip_lch = '';
DEF title = 'IC Device Statistics summary for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'h.instance_number');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'IC Device Statistics summary for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'IC Device Statistics summary for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'IC Device Statistics summary for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'IC Device Statistics summary for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'IC Device Statistics summary for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'IC Device Statistics summary for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'IC Device Statistics summary for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'IC Device Statistics summary for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = 'Y';

/****************************************************************************************/

BEGIN
  :sql_text_backup := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI:SS') end_time,
       h.if_name,
       h.bytes_received - LAG(h.bytes_received) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) bytes_received,
       h.packets_received - LAG(h.packets_received) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) packets_received,
       h.receive_errors - LAG(h.receive_errors) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) receive_errors,
       h.receive_dropped - LAG(h.receive_dropped) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) receive_dropped,
       h.receive_buf_or - LAG(h.receive_buf_or) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) receive_buf_or,
       h.receive_frame_err - LAG(h.receive_frame_err) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) receive_frame_err,
       h.bytes_sent - LAG(h.bytes_sent) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) bytes_sent,
       h.packets_sent - LAG(h.packets_sent) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) packets_sent,
       h.send_errors - LAG(h.send_errors) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) send_errors,
       h.sends_dropped - LAG(h.sends_dropped) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) sends_dropped,
       h.send_buf_or - LAG(h.send_buf_or) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) send_buf_or,
       h.send_carrier_lost - LAG(h.send_carrier_lost) OVER (PARTITION BY h.dbid, h.instance_number, h.if_name ORDER BY h.snap_id) send_carrier_lost
  FROM &&awr_object_prefix.ic_device_stats h,
       &&awr_object_prefix.snapshot s
 WHERE h.instance_number = @instance_number@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
 ORDER BY
       s.snap_id DESC,
       h.if_name
]';
END;
/
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'IC Device Statistics details for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'IC Device Statistics details for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'IC Device Statistics details for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'IC Device Statistics details for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'IC Device Statistics details for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'IC Device Statistics details for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'IC Device Statistics details for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'IC Device Statistics details for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
