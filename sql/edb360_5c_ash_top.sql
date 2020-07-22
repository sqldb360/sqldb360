@@&&edb360_0g.tkprof.sql
DEF section_id = '5c';
DEF section_name = 'Active Session History (ASH) on CPU and Top 24 Wait Events';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

@&&chart_setup_driver.;

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
DEF vbaseline = '';

BEGIN
  :sql_text_backup := q'[
SELECT /*+ &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       snap_id,
       --TO_CHAR(LAG(MAX(sample_time)) OVER (ORDER BY snap_id), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(CASE instance_number WHEN 1 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_01,
       ROUND(SUM(CASE instance_number WHEN 2 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_02,
       ROUND(SUM(CASE instance_number WHEN 3 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_03,
       ROUND(SUM(CASE instance_number WHEN 4 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_04,
       ROUND(SUM(CASE instance_number WHEN 5 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_05,
       ROUND(SUM(CASE instance_number WHEN 6 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_06,
       ROUND(SUM(CASE instance_number WHEN 7 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_07,
       ROUND(SUM(CASE instance_number WHEN 8 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM &&awr_object_prefix.active_sess_history h
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND @filter_predicate@
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/
-- end from 5a

DEF title = 'Top 24 Wait Events';
DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := q'[
WITH
ranked AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       h.wait_class,
       event event_name,
       COUNT(*) samples,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) wrank
  FROM &&awr_object_prefix.active_sess_history h
 WHERE '&&diagnostics_pack.' = 'Y'
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.session_state = 'WAITING'
 GROUP BY
       h.wait_class,
       event
)
SELECT ROUND(samples * 10 / 3600, 1) hours_waited,
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
ranked AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       h.wait_class,
       event event_name,
       COUNT(*) samples,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) wrank
  FROM &&awr_object_prefix.active_sess_history h
 WHERE '&&diagnostics_pack.' = 'Y'
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.session_state = 'WAITING'
 GROUP BY
       h.wait_class,
       event
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

BEGIN
  :sql_text_backup2 := q'[
WITH
hist AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       sql_id,
       dbid,
       program,
       module,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
       COUNT(*) samples
  FROM &&awr_object_prefix.active_sess_history h
 WHERE sql_id||program||module IS NOT NULL
   AND @filter_predicate@
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       sql_id,
       dbid,
       program,
       module
),
total AS (
SELECT SUM(samples) samples FROM hist
)
SELECT SUBSTR(TRIM(h.sql_id||' '||h.program||' '||
       CASE h.module WHEN h.program THEN NULL ELSE h.module END), 1, 128) source,
       h.samples,
       ROUND(100 * h.samples / t.samples, 1) percent,
       DBMS_LOB.SUBSTR(s.sql_text, 1000) sql_text
  FROM hist h,
       total t,
       &&awr_object_prefix.sqltext s
 WHERE h.samples >= t.samples / 1000 AND rn <= 14
   AND s.sql_id(+) = h.sql_id AND s.dbid(+) = h.dbid
 UNION ALL
SELECT 'Others' source,
       NVL(SUM(h.samples), 0) samples,
       NVL(ROUND(100 * SUM(h.samples) / AVG(t.samples), 1), 0) percent,
       NULL sql_text
  FROM hist h,
       total t
 WHERE h.samples < t.samples / 1000 OR rn > 14
 ORDER BY 2 DESC NULLS LAST
]';
END;
/

DEF skip_lch = '';
DEF title = 'ASH CPU per Instance';
DEF abstract = 'Average Active Sessions (AAS) on CPU<br />'
DEF vaxis = 'Average Active Sessions (AAS) on CPU (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'session_state = ''ON CPU''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH CPU per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'session_state = ''ON CPU''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_01. "&&event_name_01." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_01. "&&event_name_01."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_01.'' AND event = ''&&event_name_01.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_01. "&&event_name_01." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_01.'' AND event = ''&&event_name_01.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_02. "&&event_name_02." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_02. "&&event_name_02."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_02.'' AND event = ''&&event_name_02.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_02. "&&event_name_02." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_02.'' AND event = ''&&event_name_02.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_03. "&&event_name_03." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_03. "&&event_name_03."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_03.'' AND event = ''&&event_name_03.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_03. "&&event_name_03." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_03.'' AND event = ''&&event_name_03.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_04. "&&event_name_04." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_04. "&&event_name_04."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_04.'' AND event = ''&&event_name_04.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_04. "&&event_name_04." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_04.'' AND event = ''&&event_name_04.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_05. "&&event_name_05." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_05. "&&event_name_05."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_05.'' AND event = ''&&event_name_05.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_05. "&&event_name_05." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_05.'' AND event = ''&&event_name_05.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_06. "&&event_name_06." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_06. "&&event_name_06."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_06.'' AND event = ''&&event_name_06.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_06. "&&event_name_06." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_06.'' AND event = ''&&event_name_06.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_07. "&&event_name_07." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_07. "&&event_name_07."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_07.'' AND event = ''&&event_name_07.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_07. "&&event_name_07." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_07.'' AND event = ''&&event_name_07.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_08. "&&event_name_08." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_08. "&&event_name_08."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_08.'' AND event = ''&&event_name_08.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_08. "&&event_name_08." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_08.'' AND event = ''&&event_name_08.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_09. "&&event_name_09." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_09. "&&event_name_09."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_09.'' AND event = ''&&event_name_09.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_09. "&&event_name_09." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_09.'' AND event = ''&&event_name_09.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_10. "&&event_name_10." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_10. "&&event_name_10."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_10.'' AND event = ''&&event_name_10.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_10. "&&event_name_10." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_10.'' AND event = ''&&event_name_10.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_11. "&&event_name_11." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_11. "&&event_name_11."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_11.'' AND event = ''&&event_name_11.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_11. "&&event_name_11." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_11.'' AND event = ''&&event_name_11.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_12. "&&event_name_12." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_12. "&&event_name_12."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_12.'' AND event = ''&&event_name_12.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_12. "&&event_name_12." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_12.'' AND event = ''&&event_name_12.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_13. "&&event_name_13." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_13. "&&event_name_13."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_13.'' AND event = ''&&event_name_13.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_13. "&&event_name_13." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_13.'' AND event = ''&&event_name_13.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_14. "&&event_name_14." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_14. "&&event_name_14."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_14.'' AND event = ''&&event_name_14.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_14. "&&event_name_14." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_14.'' AND event = ''&&event_name_14.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_15. "&&event_name_15." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_15. "&&event_name_15."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_15.'' AND event = ''&&event_name_15.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_15. "&&event_name_15." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_15.'' AND event = ''&&event_name_15.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_16. "&&event_name_16." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_16. "&&event_name_16."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_16.'' AND event = ''&&event_name_16.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_16. "&&event_name_16." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_16.'' AND event = ''&&event_name_16.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_17. "&&event_name_17." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_17. "&&event_name_17."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_17.'' AND event = ''&&event_name_17.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_17. "&&event_name_17." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_17.'' AND event = ''&&event_name_17.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_18. "&&event_name_18." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_18. "&&event_name_18."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_18.'' AND event = ''&&event_name_18.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_18. "&&event_name_18." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_18.'' AND event = ''&&event_name_18.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_19. "&&event_name_19." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_19. "&&event_name_19."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_19.'' AND event = ''&&event_name_19.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_19. "&&event_name_19." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_19.'' AND event = ''&&event_name_19.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_20. "&&event_name_20." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_20. "&&event_name_20."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_20.'' AND event = ''&&event_name_20.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_20. "&&event_name_20." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_20.'' AND event = ''&&event_name_20.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_21. "&&event_name_21." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_21. "&&event_name_21."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_21.'' AND event = ''&&event_name_21.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_21. "&&event_name_21." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_21.'' AND event = ''&&event_name_21.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_22. "&&event_name_22." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_22. "&&event_name_22."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_22.'' AND event = ''&&event_name_22.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_22. "&&event_name_22." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_22.'' AND event = ''&&event_name_22.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_23. "&&event_name_23." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_23. "&&event_name_23."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_23.'' AND event = ''&&event_name_23.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_23. "&&event_name_23." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_23.'' AND event = ''&&event_name_23.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'ASH &&wait_class_24. "&&event_name_24." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_24. "&&event_name_24."<br />'
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_24.'' AND event = ''&&event_name_24.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH &&wait_class_24. "&&event_name_24." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_24.'' AND event = ''&&event_name_24.''');
@@edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
