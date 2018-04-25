@@&&edb360_0g.tkprof.sql
DEF section_id = '4h';
DEF section_name = 'Average Latency for Top 24 Wait Events';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Top 24 Wait Events';
DEF main_table = '&&awr_hist_prefix.EVENT_HISTOGRAM';
BEGIN
  :sql_text := q'[
WITH
details AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       wait_class,
       event_name,
       (wait_count - LAG(wait_count) OVER (PARTITION BY dbid, instance_number, event_id, wait_class_id, wait_time_milli ORDER BY snap_id)) * /* wait_count_this_snap */
       (wait_time_milli - LAG(wait_time_milli) OVER (PARTITION BY snap_id, dbid, instance_number, event_id, wait_class_id  ORDER BY wait_time_milli)) / 2 /* average wait_time_milli */
       wait_time_milli_total
  FROM &&awr_object_prefix.event_histogram
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND wait_class <> 'Idle'
),
events AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       wait_class,
       event_name,
       SUM(wait_time_milli_total) wait_time_milli_total
  FROM details
 WHERE wait_time_milli_total > 0
 GROUP BY
       wait_class,
       event_name
),
ranked AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       RANK () OVER (ORDER BY wait_time_milli_total DESC) wrank,
       ROUND(wait_time_milli_total / 100 / 3600, 1) hours_waited,
       wait_class, 
       event_name
  FROM events
)
SELECT hours_waited,
       wait_class, 
       event_name
  FROM ranked
 WHERE wrank < 25
 ORDER BY
       wrank
]';
END;
/
@@edb360_9a_pre_one.sql

COL wait_class_01 NEW_V wait_class_01;
COL event_name_01 NEW_V event_name_01;

COL wait_class_02 NEW_V wait_class_02;
COL event_name_02 NEW_V event_name_02;

COL wait_class_03 NEW_V wait_class_03;
COL event_name_03 NEW_V event_name_03;

COL wait_class_04 NEW_V wait_class_04;
COL event_name_04 NEW_V event_name_04;

COL wait_class_05 NEW_V wait_class_05;
COL event_name_05 NEW_V event_name_05;

COL wait_class_06 NEW_V wait_class_06;
COL event_name_06 NEW_V event_name_06;

COL wait_class_07 NEW_V wait_class_07;
COL event_name_07 NEW_V event_name_07;

COL wait_class_08 NEW_V wait_class_08;
COL event_name_08 NEW_V event_name_08;

COL wait_class_09 NEW_V wait_class_09;
COL event_name_09 NEW_V event_name_09;

COL wait_class_10 NEW_V wait_class_10;
COL event_name_10 NEW_V event_name_10;

COL wait_class_11 NEW_V wait_class_11;
COL event_name_11 NEW_V event_name_11;

COL wait_class_12 NEW_V wait_class_12;
COL event_name_12 NEW_V event_name_12;

COL wait_class_13 NEW_V wait_class_13;
COL event_name_13 NEW_V event_name_13;

COL wait_class_14 NEW_V wait_class_14;
COL event_name_14 NEW_V event_name_14;

COL wait_class_15 NEW_V wait_class_15;
COL event_name_15 NEW_V event_name_15;

COL wait_class_16 NEW_V wait_class_16;
COL event_name_16 NEW_V event_name_16;

COL wait_class_17 NEW_V wait_class_17;
COL event_name_17 NEW_V event_name_17;

COL wait_class_18 NEW_V wait_class_18;
COL event_name_18 NEW_V event_name_18;

COL wait_class_19 NEW_V wait_class_19;
COL event_name_19 NEW_V event_name_19;

COL wait_class_20 NEW_V wait_class_20;
COL event_name_20 NEW_V event_name_20;

COL wait_class_21 NEW_V wait_class_21;
COL event_name_21 NEW_V event_name_21;

COL wait_class_22 NEW_V wait_class_22;
COL event_name_22 NEW_V event_name_22;

COL wait_class_23 NEW_V wait_class_23;
COL event_name_23 NEW_V event_name_23;

COL wait_class_24 NEW_V wait_class_24;
COL event_name_24 NEW_V event_name_24;

WITH
details AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       wait_class,
       event_name,
       (wait_count - LAG(wait_count) OVER (PARTITION BY dbid, instance_number, event_id, wait_class_id, wait_time_milli ORDER BY snap_id)) * /* wait_count_this_snap */
       (wait_time_milli - LAG(wait_time_milli) OVER (PARTITION BY snap_id, dbid, instance_number, event_id, wait_class_id  ORDER BY wait_time_milli)) / 2 /* average wait_time_milli */
       wait_time_milli_total
  FROM &&awr_object_prefix.event_histogram
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND wait_class <> 'Idle'
),
events AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       wait_class,
       event_name,
       SUM(wait_time_milli_total) wait_time_milli_total
  FROM details
 WHERE wait_time_milli_total > 0
 GROUP BY
       wait_class,
       event_name
),
ranked AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       RANK () OVER (ORDER BY wait_time_milli_total DESC) wrank,
       ROUND(wait_time_milli_total / 100 / 3600, 1) hours_waited,
       wait_class, 
       event_name
  FROM events
)
SELECT MIN(CASE wrank WHEN 01 THEN wait_class END) wait_class_01,
       MIN(CASE wrank WHEN 01 THEN event_name END) event_name_01,
       MIN(CASE wrank WHEN 02 THEN wait_class END) wait_class_02,
       MIN(CASE wrank WHEN 02 THEN event_name END) event_name_02,
       MIN(CASE wrank WHEN 03 THEN wait_class END) wait_class_03,
       MIN(CASE wrank WHEN 03 THEN event_name END) event_name_03,
       MIN(CASE wrank WHEN 04 THEN wait_class END) wait_class_04,
       MIN(CASE wrank WHEN 04 THEN event_name END) event_name_04,
       MIN(CASE wrank WHEN 05 THEN wait_class END) wait_class_05,
       MIN(CASE wrank WHEN 05 THEN event_name END) event_name_05,
       MIN(CASE wrank WHEN 06 THEN wait_class END) wait_class_06,
       MIN(CASE wrank WHEN 06 THEN event_name END) event_name_06,
       MIN(CASE wrank WHEN 07 THEN wait_class END) wait_class_07,
       MIN(CASE wrank WHEN 07 THEN event_name END) event_name_07,
       MIN(CASE wrank WHEN 08 THEN wait_class END) wait_class_08,
       MIN(CASE wrank WHEN 08 THEN event_name END) event_name_08,
       MIN(CASE wrank WHEN 09 THEN wait_class END) wait_class_09,
       MIN(CASE wrank WHEN 09 THEN event_name END) event_name_09,
       MIN(CASE wrank WHEN 10 THEN wait_class END) wait_class_10,
       MIN(CASE wrank WHEN 10 THEN event_name END) event_name_10,
       MIN(CASE wrank WHEN 11 THEN wait_class END) wait_class_11,
       MIN(CASE wrank WHEN 11 THEN event_name END) event_name_11,
       MIN(CASE wrank WHEN 12 THEN wait_class END) wait_class_12,
       MIN(CASE wrank WHEN 12 THEN event_name END) event_name_12,
       MIN(CASE wrank WHEN 13 THEN wait_class END) wait_class_13,
       MIN(CASE wrank WHEN 13 THEN event_name END) event_name_13,
       MIN(CASE wrank WHEN 14 THEN wait_class END) wait_class_14,
       MIN(CASE wrank WHEN 14 THEN event_name END) event_name_14,
       MIN(CASE wrank WHEN 15 THEN wait_class END) wait_class_15,
       MIN(CASE wrank WHEN 15 THEN event_name END) event_name_15,
       MIN(CASE wrank WHEN 16 THEN wait_class END) wait_class_16,
       MIN(CASE wrank WHEN 16 THEN event_name END) event_name_16,
       MIN(CASE wrank WHEN 17 THEN wait_class END) wait_class_17,
       MIN(CASE wrank WHEN 17 THEN event_name END) event_name_17,
       MIN(CASE wrank WHEN 18 THEN wait_class END) wait_class_18,
       MIN(CASE wrank WHEN 18 THEN event_name END) event_name_18,
       MIN(CASE wrank WHEN 19 THEN wait_class END) wait_class_19,
       MIN(CASE wrank WHEN 19 THEN event_name END) event_name_19,
       MIN(CASE wrank WHEN 20 THEN wait_class END) wait_class_20,
       MIN(CASE wrank WHEN 20 THEN event_name END) event_name_20,
       MIN(CASE wrank WHEN 21 THEN wait_class END) wait_class_21,
       MIN(CASE wrank WHEN 21 THEN event_name END) event_name_21,
       MIN(CASE wrank WHEN 22 THEN wait_class END) wait_class_22,
       MIN(CASE wrank WHEN 22 THEN event_name END) event_name_22,
       MIN(CASE wrank WHEN 23 THEN wait_class END) wait_class_23,
       MIN(CASE wrank WHEN 23 THEN event_name END) event_name_23,
       MIN(CASE wrank WHEN 24 THEN wait_class END) wait_class_24,
       MIN(CASE wrank WHEN 24 THEN event_name END) event_name_24
  FROM ranked
 WHERE wrank < 25;

COL recovery NEW_V recovery;
SELECT CHR(38)||' recovery' recovery FROM DUAL;
-- this above is to handle event "RMAN backup & recovery I/O"

DEF main_table = '&&awr_hist_prefix.EVENT_HISTOGRAM';
DEF vbaseline = '';
DEF chartype = 'LineChart';
DEF stacked = '';

DEF tit_01 = 'Average Latency';
DEF tit_02 = 'Latency Trend';
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
average AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM((CASE wait_time_milli WHEN 1 THEN 0.50 ELSE 0.75 END) * wait_time_milli * wait_count_this_snap)/SUM(wait_count_this_snap) avg_wait_time_milli
  FROM histogram
 WHERE wait_count_this_snap >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number
HAVING SUM(wait_count_this_snap) > 0
),
average_average AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       a.snap_id,
       a.dbid,
       a.instance_number,
       MIN(a.avg_wait_time_milli) avg_wait_time_milli,
       AVG(b.avg_wait_time_milli) avg_avg_wait_time_milli
  FROM average a,
       average b
 WHERE b.snap_id         <= a.snap_id
   AND b.dbid             = a.dbid
   AND b.instance_number  = a.instance_number
 GROUP BY
       a.snap_id,
       a.dbid,
       a.instance_number
),
per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       s.begin_interval_time,
       s.end_interval_time,
       h.avg_wait_time_milli,
       h.avg_avg_wait_time_milli
  FROM average_average   h,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = h.snap_id
   AND s.dbid            = h.dbid
   AND s.instance_number = h.instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(avg_wait_time_milli), 3) avg_latency_ms,
       ROUND(SUM(avg_avg_wait_time_milli), 3) latency_trend_ms,
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
  FROM per_inst
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/


DEF skip_lch = '';
DEF title = '&&wait_class_01. "&&event_name_01." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_01.'') AND event_name = TRIM(''&&event_name_01.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_02. "&&event_name_02." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_02.'') AND event_name = TRIM(''&&event_name_02.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_03. "&&event_name_03." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_03.'') AND event_name = TRIM(''&&event_name_03.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_04. "&&event_name_04." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_04.'') AND event_name = TRIM(''&&event_name_04.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_05. "&&event_name_05." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_05.'') AND event_name = TRIM(''&&event_name_05.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_06. "&&event_name_06." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_06.'') AND event_name = TRIM(''&&event_name_06.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_07. "&&event_name_07." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_07.'') AND event_name = TRIM(''&&event_name_07.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_08. "&&event_name_08." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_08.'') AND event_name = TRIM(''&&event_name_08.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_09. "&&event_name_09." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_09.'') AND event_name = TRIM(''&&event_name_09.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_10. "&&event_name_10." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_10.'') AND event_name = TRIM(''&&event_name_10.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_11. "&&event_name_11." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_11.'') AND event_name = TRIM(''&&event_name_11.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_12. "&&event_name_12." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_12.'') AND event_name = TRIM(''&&event_name_12.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_13. "&&event_name_13." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_13.'') AND event_name = TRIM(''&&event_name_13.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_14. "&&event_name_14." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_14.'') AND event_name = TRIM(''&&event_name_14.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_15. "&&event_name_15." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_15.'') AND event_name = TRIM(''&&event_name_15.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_16. "&&event_name_16." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_16.'') AND event_name = TRIM(''&&event_name_16.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_17. "&&event_name_17." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_17.'') AND event_name = TRIM(''&&event_name_17.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_18. "&&event_name_18." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_18.'') AND event_name = TRIM(''&&event_name_18.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_19. "&&event_name_19." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_19.'') AND event_name = TRIM(''&&event_name_19.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_20. "&&event_name_20." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_20.'') AND event_name = TRIM(''&&event_name_20.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_21. "&&event_name_21." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_21.'') AND event_name = TRIM(''&&event_name_21.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_22. "&&event_name_22." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_22.'') AND event_name = TRIM(''&&event_name_22.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_23. "&&event_name_23." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_23.'') AND event_name = TRIM(''&&event_name_23.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_24. "&&event_name_24." Average Latency';
DEF abstract = 'Trend is computed as average of "Average" so far. Thus "Trend" at time T[N] is average of "Average" between time T[0] and T[N] where N > 0.<br />'
DEF vaxis = 'Average Latency and Trend in milliseconds';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_24.'') AND event_name = TRIM(''&&event_name_24.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
