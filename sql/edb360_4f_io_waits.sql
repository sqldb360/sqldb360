@@&&edb360_0g.tkprof.sql
DEF section_id = '4f';
DEF section_name = 'Wait Times and Latency per Class';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Average Latency per Wait Class';
DEF main_table = '&&gv_view_prefix.WAITCLASSMETRIC';
BEGIN
  :sql_text := q'[
-- inspired by http://www.oraclerealworld.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       c.wait_class,
       m.inst_id,
       ROUND(10 * m.time_waited / m.wait_count, 3) avg_ms,
       m.wait_count,
       m.time_waited,
       ROUND(m.time_waited / 100) seconds_waited
  FROM &&gv_object_prefix.waitclassmetric m,
       &&gv_object_prefix.system_wait_class c
 WHERE m.wait_count > 0
   AND c.inst_id = m.inst_id
   AND c.wait_class# = m.wait_class#
   AND c.wait_class <> 'Idle'
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Average Latency per Wait Event';
DEF main_table = '&&gv_view_prefix.EVENTMETRIC';
BEGIN
  :sql_text := q'[
-- inspired by http://www.oraclerealworld.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       e.wait_class,
       e.name event,
       m.inst_id,
       ROUND(10 * m.time_waited / m.wait_count, 3) avg_ms,
       m.wait_count,
       m.time_waited,
       ROUND(m.time_waited / 100) seconds_waited
  FROM &&gv_object_prefix.eventmetric m,
       &&gv_object_prefix.event_name e
 WHERE m.wait_count > 0
   AND e.inst_id = m.inst_id
   AND e.event_id = m.event_id
   AND e.wait_class <> 'Idle'
 ORDER BY
       1,2,3
]';
END;
/
@@edb360_9a_pre_one.sql

@&&chart_setup_driver.;

DEF main_table = '&&awr_hist_prefix.EVENT_HISTOGRAM';
DEF vaxis = 'Wait Minutes (stacked)';
DEF vbaseline = '';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';

BEGIN
  :sql_text_backup := q'[
WITH 
histogram AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       wait_count - LAG(wait_count) OVER (PARTITION BY dbid, instance_number, event_id, wait_class_id, wait_time_milli ORDER BY snap_id) wait_count_this_snap,
       (wait_count - LAG(wait_count) OVER (PARTITION BY dbid, instance_number, event_id, wait_class_id, wait_time_milli ORDER BY snap_id)) * /* wait_count_this_snap */ 
       (wait_time_milli - LAG(wait_time_milli) OVER (PARTITION BY snap_id, dbid, instance_number, event_id, wait_class_id  ORDER BY wait_time_milli)) / 2 /* average wait_time_milli */
       wait_time_milli_total
  FROM &&awr_object_prefix.event_histogram
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND @filter_predicate@
),
history AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(wait_time_milli_total) wait_time_milli_total
  FROM histogram
 WHERE wait_count_this_snap >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       s.begin_interval_time,
       s.end_interval_time,
       h.instance_number,
       (h.wait_time_milli_total / 1000 / 60) wait_minutes
  FROM history           h,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = h.snap_id
   AND s.dbid            = h.dbid
   AND s.instance_number = h.instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(CASE instance_number WHEN 1 THEN wait_minutes ELSE 0 END), 1) inst_01,
       ROUND(SUM(CASE instance_number WHEN 2 THEN wait_minutes ELSE 0 END), 1) inst_02,
       ROUND(SUM(CASE instance_number WHEN 3 THEN wait_minutes ELSE 0 END), 1) inst_03,
       ROUND(SUM(CASE instance_number WHEN 4 THEN wait_minutes ELSE 0 END), 1) inst_04,
       ROUND(SUM(CASE instance_number WHEN 5 THEN wait_minutes ELSE 0 END), 1) inst_05,
       ROUND(SUM(CASE instance_number WHEN 6 THEN wait_minutes ELSE 0 END), 1) inst_06,
       ROUND(SUM(CASE instance_number WHEN 7 THEN wait_minutes ELSE 0 END), 1) inst_07,
       ROUND(SUM(CASE instance_number WHEN 8 THEN wait_minutes ELSE 0 END), 1) inst_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM per_inst
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'User I/O Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''User I/O''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'System I/O Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''System I/O''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Cluster Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Cluster''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Commit Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Commit''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Concurrency Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Concurrency''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Application Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Application''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Administrative Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Administrative''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Configuration Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Configuration''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Network Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Network''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Queueing Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Queueing''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Scheduler Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Scheduler''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Other Wait Time per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF main_table = '&&awr_hist_prefix.EVENT_HISTOGRAM';
COL less_1_perc FOR 999990.0 HEADING'% <||1ms';
COL less_2_perc FOR 999990.0 HEADING'% <||2ms';
COL less_4_perc FOR 999990.0 HEADING'% <||4ms';
COL less_8_perc FOR 999990.0 HEADING'% <||8ms';
COL less_16_perc FOR 999990.0 HEADING'% <||16ms';
COL less_32_perc FOR 999990.0 HEADING'% <||32ms';
COL less_64_perc FOR 999990.0 HEADING'% <||64ms';
COL less_128_perc FOR 999990.0 HEADING'% <||128ms';
COL less_256_perc FOR 999990.0 HEADING'% <||256ms';
COL less_512_perc FOR 999990.0 HEADING'% <||512ms';
COL less_1024_perc FOR 999990.0 HEADING'% <||1.024s';
COL less_2048_perc FOR 999990.0 HEADING'% <||2.048s';
COL less_4096_perc FOR 999990.0 HEADING'% <||4.096s';
COL less_8192_perc FOR 999990.0 HEADING'% <||8.192s';
COL more_8192_perc FOR 999990.0 HEADING'% >=||8.192s';

DEF tit_01 = '% < 1ms';
DEF tit_02 = '% < 2ms';
DEF tit_03 = '% < 4ms';
DEF tit_04 = '% < 8ms';
DEF tit_05 = '% < 16ms';
DEF tit_06 = '% < 32ms';
DEF tit_07 = '% < 64ms';
DEF tit_08 = '% < 128ms';
DEF tit_09 = '% < 256ms';
DEF tit_10 = '% < 512ms';
DEF tit_11 = '% < 1.024s';
DEF tit_12 = '% < 2.048s';
DEF tit_13 = '% < 4.096s';
DEF tit_14 = '% < 8.192s';
DEF tit_15 = '% > 8.192s';

BEGIN
  :sql_text_backup := q'[
WITH 
histogram AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       wait_time_milli,
       wait_count - LAG(wait_count) OVER (PARTITION BY dbid, instance_number, event_id, wait_class_id, wait_time_milli ORDER BY snap_id) wait_count_this_snap
  FROM &&awr_object_prefix.event_histogram
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND @filter_predicate@
),
history AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       wait_time_milli,
       SUM(wait_count_this_snap) wait_count_this_snap
  FROM histogram
 WHERE wait_count_this_snap >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number,
       wait_time_milli
),
per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       s.begin_interval_time,
       s.end_interval_time,
       h.wait_time_milli,
       h.wait_count_this_snap
  FROM history           h,
       &&cdb_awr_object_prefix.snapshot s
 WHERE s.snap_id         = h.snap_id
   AND s.dbid            = h.dbid
   AND s.instance_number = h.instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,00) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_1_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,01) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_2_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,02) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_4_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,03) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_8_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,04) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_16_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,05) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_32_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,06) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_64_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,07) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_128_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,08) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_256_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,09) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_512_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,10) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_1024_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,11) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_2048_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,12) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_4096_ms,
       ROUND(100 * SUM(CASE wait_time_milli WHEN POWER(2,13) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) less_8192_ms,
       ROUND(100 * SUM(CASE WHEN wait_time_milli > POWER(2,13) THEN wait_count_this_snap ELSE 0 END) / SUM(wait_count_this_snap), 1) more_8192_ms
  FROM per_inst
 GROUP BY
       snap_id
HAVING SUM(wait_count_this_snap) > 0
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'User I/O Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''User I/O''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'System I/O Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''System I/O''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Cluster Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Cluster''');
@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Commit Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Commit''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Concurrency Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Concurrency''');
@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Application Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Application''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Administrative Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Administrative''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Configuration Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Configuration''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Network Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Network''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Queueing Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Queueing''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Scheduler Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Scheduler''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Other Wait Latency Histogram';
DEF abstract = 'Percentage of Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram as Percent of Waits (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql


SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
