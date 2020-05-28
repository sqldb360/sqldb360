@@&&edb360_0g.tkprof.sql
DEF section_id = '4g';
DEF section_name = 'AAS Histogram for Top 24 Wait Events';
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
       (wait_time_milli - wait_time_milli/4)  /* middle of the bucket */ 
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
       ROUND(wait_time_milli_total / 1000 / 3600, 1) hours_waited,
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
       (wait_time_milli - wait_time_milli/4)  /* middle of the bucket */ 
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
       ROUND(wait_time_milli_total / 1000 / 3600, 1) hours_waited,
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

/* Till 12.1 the lowest bucket resolution stored in DBA_HIST_EVENT_HISTOGRAM was 1ms.
So  the bucket "1ms" means less or equals to 1ms.
In 12.2 this changed. Now there can be buckets smaller than 1ms...
*/
COL one_ms_comp NEW_V one_ms_comp;
Select case when substr('&&db_version',1,4) <= '12.1' then '<=' else '<' end one_ms_comp from dual;

COL two_ms_comp NEW_V two_ms_comp;
Select case when substr('&&db_version',1,4) <= '12.1' then '>' else'>=' end two_ms_comp from dual;


DEF main_table = '&&awr_hist_prefix.EVENT_HISTOGRAM';
DEF vbaseline = '';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: ''true'',';

DEF 

DEF tit_01 = '< 1ms';
DEF tit_02 = '< 2ms';
DEF tit_03 = '< 4ms';
DEF tit_04 = '< 8ms';
DEF tit_05 = '< 16ms';
DEF tit_06 = '< 32ms';
DEF tit_07 = '< 64ms';
DEF tit_08 = '< 128ms';
DEF tit_09 = '< 256ms';
DEF tit_10 = '< 512ms';
DEF tit_11 = '< 1.024s';
DEF tit_12 = '< 2.048s';
DEF tit_13 = '< 4.096s';
DEF tit_14 = '< 8.192s';
DEF tit_15 = '>= 8.192s';

COL less_1_ms HEADING '<|1ms'
COL less_2_ms HEADING '<|2ms'
COL less_4_ms HEADING '<|4ms'
COL less_8_ms HEADING '<|8ms'
COL less_16_ms HEADING '<|16ms'
COL less_32_ms HEADING '<|32ms'
COL less_64_ms HEADING '<|64ms'
COL less_128_ms HEADING '<|128ms'
COL less_256_ms HEADING '<|256ms'
COL less_512_ms HEADING '<|512ms'
COL less_1024_ms HEADING '<|1.024s'
COL less_2048_ms HEADING '<|2.048s'
COL less_4096_ms HEADING '<|4.192s'
COL less_8192_ms HEADING '<|8.192s'
COL more_8192_ms HEADING '>=|8.192s'

BEGIN
  :sql_text_backup := q'[
WITH
histogram AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       wait_time_milli,
       (wait_count - LAG(wait_count) OVER (PARTITION BY dbid, instance_number, event_id, wait_class_id, wait_time_milli ORDER BY snap_id)) * /* wait_count_this_snap */
       (wait_time_milli - wait_time_milli/4)  /* middle of the bucket */ 
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
       wait_time_milli,
       SUM(wait_time_milli_total) wait_time_milli_total
  FROM histogram
 WHERE wait_time_milli_total >= 0
 GROUP BY
       snap_id,
       dbid,
       instance_number,
       wait_time_milli
),
per_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       s.begin_interval_time,
       s.end_interval_time,
       h.wait_time_milli,
       h.wait_time_milli_total,
       (cast(s.end_interval_time as date)-cast(s.begin_interval_time as date)) time_range 
  FROM history           h,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id         = h.snap_id
   AND s.dbid            = h.dbid
   AND s.instance_number = h.instance_number
),
gendata AS (
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli &&one_ms_comp  POWER(2,00)                                   THEN wait_time_milli_total ELSE 0 END),2) less_1_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli &&two_ms_comp  POWER(2,00) AND wait_time_milli < POWER(2,01) THEN wait_time_milli_total ELSE 0 END),2) less_2_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,01) AND wait_time_milli < POWER(2,02) THEN wait_time_milli_total ELSE 0 END),2) less_4_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,02) AND wait_time_milli < POWER(2,03) THEN wait_time_milli_total ELSE 0 END),2) less_8_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,03) AND wait_time_milli < POWER(2,04) THEN wait_time_milli_total ELSE 0 END),2) less_16_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,04) AND wait_time_milli < POWER(2,05) THEN wait_time_milli_total ELSE 0 END),2) less_32_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,05) AND wait_time_milli < POWER(2,06) THEN wait_time_milli_total ELSE 0 END),2) less_64_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,06) AND wait_time_milli < POWER(2,07) THEN wait_time_milli_total ELSE 0 END),2) less_128_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,07) AND wait_time_milli < POWER(2,08) THEN wait_time_milli_total ELSE 0 END),2) less_256_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,08) AND wait_time_milli < POWER(2,09) THEN wait_time_milli_total ELSE 0 END),2) less_512_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,09) AND wait_time_milli < POWER(2,10) THEN wait_time_milli_total ELSE 0 END),2) less_1024_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,10) AND wait_time_milli < POWER(2,11) THEN wait_time_milli_total ELSE 0 END),2) less_2048_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,11) AND wait_time_milli < POWER(2,12) THEN wait_time_milli_total ELSE 0 END),2) less_4096_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,12) AND wait_time_milli < POWER(2,13) THEN wait_time_milli_total ELSE 0 END),2) less_8192_ms,
       ROUND((1/(24*60*60*1000*MIN(time_range)))*SUM(CASE WHEN wait_time_milli             >= POWER(2,13) THEN wait_time_milli_total ELSE 0 END),2) more_8192_ms
       FROM per_snap
       GROUP BY
              snap_id
)
SELECT *
  FROM gendata
ORDER by snap_id
]';
END;
/

/* By Abel :
time_range returns fractions of day ,  
time_range could be as 1/(24*3600*1000*time_range) in gendata but I prefer to deferred because
that way the multiplication is done at the very end saving some cpu,  uses less memory to add the values and less precision is lost.
It is not a problem to have the operation repeated because of constant folding at parse time.
*/ 

DEF skip_lch = '';
DEF title = '&&wait_class_01. "&&event_name_01." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_01. "&&event_name_01." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_01.'') AND event_name = TRIM(''&&event_name_01.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_02. "&&event_name_02." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_02. "&&event_name_02." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_02.'') AND event_name = TRIM(''&&event_name_02.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_03. "&&event_name_03." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_03. "&&event_name_03." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_03.'') AND event_name = TRIM(''&&event_name_03.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_04. "&&event_name_04." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_04. "&&event_name_04." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_04.'') AND event_name = TRIM(''&&event_name_04.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_05. "&&event_name_05." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_05. "&&event_name_05." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_05.'') AND event_name = TRIM(''&&event_name_05.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_06. "&&event_name_06." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_06. "&&event_name_06." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_06.'') AND event_name = TRIM(''&&event_name_06.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_07. "&&event_name_07." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_07. "&&event_name_07." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_07.'') AND event_name = TRIM(''&&event_name_07.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_08. "&&event_name_08." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_08. "&&event_name_08." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_08.'') AND event_name = TRIM(''&&event_name_08.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_09. "&&event_name_09." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_09. "&&event_name_09." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_09.'') AND event_name = TRIM(''&&event_name_09.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_10. "&&event_name_10." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_10. "&&event_name_10." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_10.'') AND event_name = TRIM(''&&event_name_10.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_11. "&&event_name_11." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_11. "&&event_name_11." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_11.'') AND event_name = TRIM(''&&event_name_11.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_12. "&&event_name_12." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_12. "&&event_name_12." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_12.'') AND event_name = TRIM(''&&event_name_12.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_13. "&&event_name_13." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_13. "&&event_name_13." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_13.'') AND event_name = TRIM(''&&event_name_13.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_14. "&&event_name_14." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_14. "&&event_name_14." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_14.'') AND event_name = TRIM(''&&event_name_14.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_15. "&&event_name_15." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_15. "&&event_name_15." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_15.'') AND event_name = TRIM(''&&event_name_15.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_16. "&&event_name_16." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_16. "&&event_name_16." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_16.'') AND event_name = TRIM(''&&event_name_16.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_17. "&&event_name_17." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_17. "&&event_name_17." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_17.'') AND event_name = TRIM(''&&event_name_17.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_18. "&&event_name_18." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_18. "&&event_name_18." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_18.'') AND event_name = TRIM(''&&event_name_18.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_19. "&&event_name_19." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_19. "&&event_name_19." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_19.'') AND event_name = TRIM(''&&event_name_19.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_20. "&&event_name_20." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_20. "&&event_name_20." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_20.'') AND event_name = TRIM(''&&event_name_20.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_21. "&&event_name_21." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_21. "&&event_name_21." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_21.'') AND event_name = TRIM(''&&event_name_21.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_22. "&&event_name_22." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_22. "&&event_name_22." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_22.'') AND event_name = TRIM(''&&event_name_22.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_23. "&&event_name_23." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_23. "&&event_name_23." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_23.'') AND event_name = TRIM(''&&event_name_23.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '&&wait_class_24. "&&event_name_24." Average Active Session Histogram';
DEF abstract = 'AAS of &&wait_class_24. "&&event_name_24." Waits, taking less (or more) than N milliseconds.<br />'
DEF vaxis = 'Histogram of AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_24.'') AND event_name = TRIM(''&&event_name_24.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
