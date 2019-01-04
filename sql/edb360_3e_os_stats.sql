@@&&edb360_0g.tkprof.sql
DEF section_id = '3e';
DEF section_name = 'Operating System (OS) Statistics History';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Operating System (OS) Statistics';
DEF main_table = '&&gv_view_prefix.OSSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.osstat
]';
END;
/
@@edb360_9a_pre_one.sql

DEF main_table = '&&awr_hist_prefix.OSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'OS Load and CPU Cores';
DEF vbaseline = '';
DEF abstract = '';

DEF tit_01 = 'OS Load';
DEF tit_02 = 'CPU Cores';
DEF tit_03 = '';
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

COL load FOR 999990.00;

BEGIN
  :sql_text_backup := q'[
WITH
seed AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       stat_name,
       value
  FROM &&awr_object_prefix.osstat
 WHERE stat_name IN ('LOAD', 'NUM_CPU_CORES')
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
),
manual_pivot AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE stat_name WHEN 'LOAD'            THEN value ELSE 0 END) load,
       SUM(CASE stat_name WHEN 'NUM_CPU_CORES'   THEN value ELSE 0 END) num_cpu_cores
  FROM seed
 WHERE value >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number
)
SELECT u.snap_id,
       TO_CHAR(MIN(s.begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(s.end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(u.load), 2) load,
       SUM(u.num_cpu_cores) num_cpu_cores,
       0 dummy_03,
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
  FROM manual_pivot u,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = u.snap_id
   AND s.dbid            = u.dbid
   AND s.instance_number = u.instance_number
   AND (CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 > 1 -- ignore snaps closer than 1m appart
 GROUP BY
       u.snap_id
 ORDER BY
       u.snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_inst = '&&is_single_instance.';
DEF title = 'OS Load and CPU Cores for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Cores for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Cores for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Cores for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Cores for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Cores for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Cores for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Cores for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Cores for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF main_table = '&&awr_hist_prefix.OSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'OS Load and CPU Subscription Threshold';
DEF vbaseline = '';
DEF abstract = '';

DEF tit_01 = 'OS Load';
DEF tit_02 = 'CPU Subscription';
DEF tit_03 = '';
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

COL load FOR 999990.00;

BEGIN
  :sql_text_backup := q'[
WITH
seed AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       stat_name,
       value
  FROM &&awr_object_prefix.osstat
 WHERE stat_name IN ('LOAD', 'NUM_CPU_CORES')
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
),
manual_pivot AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE stat_name WHEN 'LOAD'            THEN value ELSE 0 END) load,
       SUM(CASE stat_name WHEN 'NUM_CPU_CORES'   THEN value ELSE 0 END) num_cpu_cores
  FROM seed
 WHERE value >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number
)
SELECT u.snap_id,
       TO_CHAR(MIN(s.begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(s.end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(u.load), 2) load,
       --SUM(u.num_cpu_cores) num_cpu_cores,
       &&cpu_load_threshold. cpu_load_threshold,
       0 dummy_03,
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
  FROM manual_pivot u,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = u.snap_id
   AND s.dbid            = u.dbid
   AND s.instance_number = u.instance_number
   AND (CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 > 1 -- ignore snaps closer than 1m appart
 GROUP BY
       u.snap_id
 ORDER BY
       u.snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_inst = '&&is_single_instance.';
DEF title = 'OS Load and CPU Subscription Threshold for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_inst.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Subscription Threshold for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Subscription Threshold for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Subscription Threshold for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Subscription Threshold for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Subscription Threshold for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Subscription Threshold for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Subscription Threshold for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS Load and CPU Subscription Threshold for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF main_table = '&&awr_hist_prefix.OSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Percent over (Busy + Idle)';
--DEF vbaseline = 'baseline: 100,';
DEF vbaseline = '';
DEF abstract = '';

DEF tit_01 = 'Busy Time %';
DEF tit_02 = 'User Time %';
DEF tit_03 = 'Sys Time %';
DEF tit_04 = 'Nice Time %';
DEF tit_05 = 'Idle Time %';
DEF tit_06 = 'IO Wait Time %';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

COL busy_time_perc   FOR 90.0;
COL user_time_perc   FOR 90.0;
COL sys_time_perc    FOR 90.0;
COL nice_time_perc   FOR 90.0;
COL idle_time_perc   FOR 90.0;
COL iowait_time_perc FOR 90.0;

BEGIN
  :sql_text_backup := q'[
WITH
seed AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       stat_name,
       value - LAG(value) OVER (PARTITION BY dbid, instance_number, stat_id ORDER BY snap_id) value
  FROM &&awr_object_prefix.osstat
 WHERE stat_name IN ('IDLE_TIME', 'BUSY_TIME', 'USER_TIME', 'SYS_TIME', 'IOWAIT_TIME', 'NICE_TIME')
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
),
manual_pivot AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE stat_name WHEN 'IDLE_TIME'   THEN value ELSE 0 END) idle_time,
       SUM(CASE stat_name WHEN 'BUSY_TIME'   THEN value ELSE 0 END) busy_time,
       SUM(CASE stat_name WHEN 'USER_TIME'   THEN value ELSE 0 END) user_time,
       SUM(CASE stat_name WHEN 'SYS_TIME'    THEN value ELSE 0 END) sys_time,
       SUM(CASE stat_name WHEN 'IOWAIT_TIME' THEN value ELSE 0 END) iowait_time,
       SUM(CASE stat_name WHEN 'NICE_TIME'   THEN value ELSE 0 END) nice_time
  FROM seed
 WHERE value >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number
)
SELECT u.snap_id,
       TO_CHAR(MIN(s.begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(s.end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(100 * SUM(u.busy_time)   / (SUM(u.busy_time) + SUM(u.idle_time)), 2) busy_time_perc,
       ROUND(100 * SUM(u.user_time)   / (SUM(u.busy_time) + SUM(u.idle_time)), 2) user_time_perc,
       ROUND(100 * SUM(u.sys_time)    / (SUM(u.busy_time) + SUM(u.idle_time)), 2) sys_time_perc,
       ROUND(100 * SUM(u.nice_time)   / (SUM(u.busy_time) + SUM(u.idle_time)), 2) nice_time_perc,
       ROUND(100 * SUM(u.idle_time)   / (SUM(u.busy_time) + SUM(u.idle_time)), 2) idle_time_perc,
       ROUND(100 * SUM(u.iowait_time) / (SUM(u.busy_time) + SUM(u.idle_time)), 2) iowait_time_perc,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM manual_pivot u,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = u.snap_id
   AND s.dbid            = u.dbid
   AND s.instance_number = u.instance_number
   AND (CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 > 1 -- ignore snaps closer than 1m appart
   AND u.busy_time + u.idle_time > 0
 GROUP BY
       u.snap_id
 ORDER BY
       u.snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_inst = '&&is_single_instance.';
DEF title = 'CPU Time Percent for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_inst.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Time Percent for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Time Percent for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Time Percent for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Time Percent for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Time Percent for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Time Percent for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Time Percent for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Time Percent for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF tit_01 = 'Busy Time %';
DEF tit_02 = 'Idle Time %';
DEF tit_03 = '';
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

BEGIN
  :sql_text_backup := q'[
WITH
seed AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       stat_name,
       value - LAG(value) OVER (PARTITION BY dbid, instance_number, stat_id ORDER BY snap_id) value
  FROM &&awr_object_prefix.osstat
 WHERE stat_name IN ('IDLE_TIME', 'BUSY_TIME')
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
),
manual_pivot AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE stat_name WHEN 'IDLE_TIME'   THEN value ELSE 0 END) idle_time,
       SUM(CASE stat_name WHEN 'BUSY_TIME'   THEN value ELSE 0 END) busy_time
  FROM seed
 WHERE value >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number
)
SELECT u.snap_id,
       TO_CHAR(MIN(s.begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(s.end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(100 * SUM(u.busy_time) / (SUM(u.busy_time) + SUM(u.idle_time)), 2) busy_time_perc,
       ROUND(100 * SUM(u.idle_time) / (SUM(u.busy_time) + SUM(u.idle_time)), 2) idle_time_perc,
       0 dummy_03,
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
  FROM manual_pivot u,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = u.snap_id
   AND s.dbid            = u.dbid
   AND s.instance_number = u.instance_number
   AND (CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 > 1 -- ignore snaps closer than 1m appart
 GROUP BY
       u.snap_id
 ORDER BY
       u.snap_id
]';
END;
/

DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Percent over (Busy + Idle)';
COL cores_over_threads NEW_V cores_over_threads;
DEF abstract = '';

DEF skip_lch = '';
DEF skip_inst = '&&is_single_instance.';
DEF title = 'CPU Busy and Idle Times Percent for Cluster';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&gv_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS');
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_inst.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Busy and Idle Times Percent for Instance 1';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&awr_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS') AND instance_number = 1 AND snap_id = &&maximum_snap_id.;
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Busy and Idle Times Percent for Instance 2';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&awr_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS') AND instance_number = 2 AND snap_id = &&maximum_snap_id.;
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Busy and Idle Times Percent for Instance 3';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&awr_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS') AND instance_number = 3 AND snap_id = &&maximum_snap_id.;
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Busy and Idle Times Percent for Instance 4';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&awr_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS') AND instance_number = 4 AND snap_id = &&maximum_snap_id.;
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Busy and Idle Times Percent for Instance 5';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&awr_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS') AND instance_number = 5 AND snap_id = &&maximum_snap_id.;
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Busy and Idle Times Percent for Instance 6';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&awr_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS') AND instance_number = 6 AND snap_id = &&maximum_snap_id.;
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Busy and Idle Times Percent for Instance 7';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&awr_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS') AND instance_number = 7 AND snap_id = &&maximum_snap_id.;
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Busy and Idle Times Percent for Instance 8';
SELECT TO_CHAR(ROUND(100 * SUM(CASE stat_name WHEN 'NUM_CPU_CORES' THEN value ELSE 0 END)/SUM(CASE stat_name WHEN 'NUM_CPUS' THEN value ELSE 0 END))) cores_over_threads FROM &&awr_object_prefix.osstat WHERE stat_name IN ('NUM_CPU_CORES', 'NUM_CPUS') AND instance_number = 8 AND snap_id = &&maximum_snap_id.;
DEF abstract = 'CPU Cores threshold is at &&cores_over_threads.% mark.<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF tit_01 = 'User Time %';
DEF tit_02 = 'Sys Time %';
DEF tit_03 = '';
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

BEGIN
  :sql_text_backup := q'[
WITH
seed AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       stat_name,
       value - LAG(value) OVER (PARTITION BY dbid, instance_number, stat_id ORDER BY snap_id) value
  FROM &&awr_object_prefix.osstat
 WHERE stat_name IN ('USER_TIME', 'SYS_TIME')
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
),
manual_pivot AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE stat_name WHEN 'USER_TIME'   THEN value ELSE 0 END) user_time,
       SUM(CASE stat_name WHEN 'SYS_TIME'   THEN value ELSE 0 END) sys_time
  FROM seed
 WHERE value >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number
)
SELECT u.snap_id,
       TO_CHAR(MIN(s.begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(s.end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(100 * SUM(u.user_time) / (SUM(u.user_time) + SUM(u.sys_time)), 2) user_time_perc,
       ROUND(100 * SUM(u.sys_time) / (SUM(u.user_time) + SUM(u.sys_time)), 2) sys_time_perc,
       0 dummy_03,
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
  FROM manual_pivot u,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = u.snap_id
   AND s.dbid            = u.dbid
   AND s.instance_number = u.instance_number
   AND (CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 > 1 -- ignore snaps closer than 1m appart
 GROUP BY
       u.snap_id
 ORDER BY
       u.snap_id
]';
END;
/

DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Percent over (User + Sys)';
DEF abstract = '';

DEF skip_lch = '';
DEF skip_inst = '&&is_single_instance.';
DEF title = 'CPU User and Sys Times Percent for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_inst.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User and Sys Times Percent for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User and Sys Times Percent for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User and Sys Times Percent for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User and Sys Times Percent for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User and Sys Times Percent for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User and Sys Times Percent for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User and Sys Times Percent for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User and Sys Times Percent for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF main_table = '&&awr_hist_prefix.OSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Virtual Memory IN and OUT (GBs)';
DEF vbaseline = '';

DEF tit_01 = 'VM IN';
DEF tit_02 = 'VM OUT';
DEF tit_03 = '';
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

BEGIN
  :sql_text_backup := q'[
WITH
seed AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       stat_name,
       value - LAG(value) OVER (PARTITION BY dbid, instance_number, stat_id ORDER BY snap_id) value
  FROM &&awr_object_prefix.osstat
 WHERE stat_name IN ('VM_IN_BYTES', 'VM_OUT_BYTES')
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
),
manual_pivot AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE stat_name WHEN 'VM_IN_BYTES'  THEN value ELSE 0 END) vm_in_bytes,
       SUM(CASE stat_name WHEN 'VM_OUT_BYTES' THEN value ELSE 0 END) vm_out_bytes
  FROM seed
 WHERE value >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number
)
SELECT u.snap_id,
       TO_CHAR(MIN(s.begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(s.end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(u.vm_in_bytes) / POWER(2,30), 3) vm_in_gb,
       ROUND(SUM(u.vm_out_bytes) / POWER(2,30), 3) vm_out_gb,
       0 dummy_03,
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
  FROM manual_pivot u,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = u.snap_id
   AND s.dbid            = u.dbid
   AND s.instance_number = u.instance_number
   AND (CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 > 1 -- ignore snaps closer than 1m appart
 GROUP BY
       u.snap_id
 ORDER BY
       u.snap_id
]';
END;
/

DEF abstract = '';

DEF skip_lch = '';
DEF skip_inst = '&&is_single_instance.';
DEF title = 'Virtual Memory (VM) for Cluster';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_inst.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) for Instance 1';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) for Instance 2';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) for Instance 3';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) for Instance 4';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) for Instance 5';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) for Instance 6';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) for Instance 7';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) for Instance 8';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql


@&&chart_setup_driver;

DEF main_table = '&&awr_hist_prefix.OSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';

BEGIN
  :sql_text_backup := q'[
WITH
seed AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       o.snap_id,
       o.instance_number,
       o.value - LAG(o.value) OVER (PARTITION BY o.dbid, o.instance_number, o.stat_id ORDER BY o.snap_id) value,
       s.begin_interval_time,
       s.end_interval_time
  FROM &&awr_object_prefix.osstat o,
       &&awr_object_prefix.snapshot s
 WHERE o.stat_name = '@stat_name@'
   AND o.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND o.dbid = &&edb360_dbid.
   AND s.snap_id         = o.snap_id
   AND s.dbid            = o.dbid
   AND s.instance_number = o.instance_number
   AND (CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 > 1 -- ignore snaps closer than 1m appart
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE instance_number WHEN 1 THEN value ELSE 0 END) inst_01,
       SUM(CASE instance_number WHEN 2 THEN value ELSE 0 END) inst_02,
       SUM(CASE instance_number WHEN 3 THEN value ELSE 0 END) inst_03,
       SUM(CASE instance_number WHEN 4 THEN value ELSE 0 END) inst_04,
       SUM(CASE instance_number WHEN 5 THEN value ELSE 0 END) inst_05,
       SUM(CASE instance_number WHEN 6 THEN value ELSE 0 END) inst_06,
       SUM(CASE instance_number WHEN 7 THEN value ELSE 0 END) inst_07,
       SUM(CASE instance_number WHEN 8 THEN value ELSE 0 END) inst_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM seed
 WHERE value >= 0
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF vaxis = 'Time (centi-secs)';
DEF abstract = '';

DEF skip_lch = '';
DEF title = 'CPU Busy Time per Instance';
DEF foot = 'for CPU Threads equivalence divide CS value by 100 (to get seconds), then divide result by number of seconds on interval.'; 
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'BUSY_TIME');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU User Time per Instance';
DEF foot = 'for CPU Threads equivalence divide CS value by 100 (to get seconds), then divide result by number of seconds on interval.'; 
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'USER_TIME');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Sys Time per Instance';
DEF foot = 'for CPU Threads equivalence divide CS value by 100 (to get seconds), then divide result by number of seconds on interval.'; 
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'SYS_TIME');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Nice Time per Instance';
DEF foot = 'for CPU Threads equivalence divide CS value by 100 (to get seconds), then divide result by number of seconds on interval.'; 
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'NICE_TIME');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU Idle Time per Instance';
DEF foot = 'for CPU Threads equivalence divide CS value by 100 (to get seconds), then divide result by number of seconds on interval.'; 
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'IDLE_TIME');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU IO Wait Time per Instance';
DEF foot = 'for CPU Threads equivalence divide CS value by 100 (to get seconds), then divide result by number of seconds on interval.'; 
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'IOWAIT_TIME');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'CPU RSRC MGR Wait Time per Instance';
DEF foot = 'for CPU Threads equivalence divide CS value by 100 (to get seconds), then divide result by number of seconds on interval.'; 
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'RSRC_MGR_CPU_WAIT_TIME');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'OS CPU Wait Time per Instance';
DEF foot = 'for CPU Threads equivalence divide CS value by 100 (to get seconds), then divide result by number of seconds on interval.'; 
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'OS_CPU_WAIT_TIME');
@@&&skip_diagnostics.edb360_9a_pre_one.sql


DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) IN-Bytes per Instance';
DEF vaxis = 'Bytes paged IN';
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'VM_IN_BYTES');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Virtual Memory (VM) OUT-Bytes per Instance';
DEF vaxis = 'Bytes paged OUT';
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name@', 'VM_OUT_BYTES');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
DEF foot = '';
DEF abstract = '';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
