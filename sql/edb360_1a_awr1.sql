DEF ash_validation = '--skip--';

SPO 00000_readme_first_&&my_sid..txt
PRO
PRO Open and read 00001_edb360_<dbname>_index.html
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO initial log:
PRO
DEF
@@edb360_00_config.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- links
DEF edb360_conf_tool_page = '<a href="http://carlos-sierra.net/edb360-an-oracle-database-360-degree-view/" target="_blank">';
DEF edb360_conf_all_pages_icon = '<a href="http://carlos-sierra.net/edb360-an-oracle-database-360-degree-view/" target="_blank"><img src="edb360_img.jpg" alt="eDB360" height="33" width="52" /></a>';
DEF edb360_conf_all_pages_logo = '';
DEF edb360_conf_google_charts = '<script type="text/javascript" src="https://www.google.com/jsapi"></script>';
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO config log:
PRO
DEF
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO setup log:
PRO
@@edb360_0b_pre.sql
DEF section_id = '0a';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
DEF max_col_number = '1';
DEF column_number = '0';
SPO &&edb360_main_report..html APP;
PRO <table><tr class="main">
PRO <td class="c">1/&&max_col_number.</td>
PRO </tr><tr class="main"><td>
PRO &&edb360_conf_tool_page.<img src="edb360_img.jpg" alt="eDB360" height="201" width="313" /></a>
PRO <br />
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '1';

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@@&&edb360_0g.tkprof.sql
DEF section_id = '1a';
DEF section_name = 'AWR Pieces';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

COL order_by NOPRI;
COL metric FOR A16 HEA "Metric";
COL instance_number FOR 9999 HEA "Inst|Num";
COL on_cpu FOR 999990.0 HEA "Active|Sessions|ON CPU";
COL on_cpu_and_resmgr FOR 9999990.0 HEA "Active|Sessions|ON CPU|or RESMGR";
COL resmgr_cpu_quantum FOR 999999990.0 HEA "Active|Sessions|ON RESMGR|CPU quantum";
COL begin_interval_time FOR A18 HEA "Begin Interval";
COL end_interval_time FOR A18 HEA "End Interval";
COL snap_shots FOR 99999 HEA "Snap|Shots";
COL days FOR 990.0 HEA "Days|Hist";
COL avg_snaps_per_day FOR 990.0 HEA "Avg|Snaps|per|Day";
COL min_sample_time FOR A18 HEA "Begin Interval";
COL max_sample_time FOR A18 HEA "End Interval";
COL samples FOR 9999999999 HEA "Samples";
COL hours FOR 9990.0 HEA "Hours|Hist";

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions on CPU or RESMGR';
DEF tit_01 = 'ON CPU + resmgr:cpu quantum';
DEF tit_02 = 'ON CPU';
DEF tit_03 = 'resmgr:cpu quantum';
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
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       MIN(sample_time) sample_time,
       SUM(CASE session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) on_cpu,
       SUM(CASE event WHEN 'resmgr:cpu quantum' THEN 1 ELSE 0 END) resmgr,
       COUNT(*) on_cpu_and_resmgr
  FROM &&awr_object_prefix.active_sess_history h
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND (session_state = 'ON CPU' OR event = 'resmgr:cpu quantum')
 GROUP BY
       snap_id,
       instance_number,
       sample_id
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number, 
       MIN(sample_time) min_sample_time, 
       MAX(sample_time) max_sample_time, 
       MAX(on_cpu) on_cpu,
       MAX(resmgr) resmgr,
       MAX(on_cpu_and_resmgr) on_cpu_and_resmgr
  FROM cpu_per_inst_and_sample
 GROUP BY
       snap_id,
       instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(min_sample_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MAX(max_sample_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(on_cpu_and_resmgr) on_cpu_and_resmgr,
       SUM(on_cpu) on_cpu,
       SUM(resmgr) resmgr,
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
  FROM cpu_per_inst_and_hour
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

--DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 
DEF vbaseline = ''; 

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'CPU Demand Series (Peak) for Cluster';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = 'Y';

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF main_table = '&&awr_hist_prefix.SYSMETRIC_SUMMARY';
DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF tit_01 = 'Max Value';
DEF tit_02 = '';
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
per_instance AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       begin_time, 
       end_time, 
       maxval
  FROM &&awr_object_prefix.sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = 2 /* 1 minute intervals */
   AND metric_name = '@metric_name@'
   AND maxval >= 0
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(maxval), 1) "Max Value",
       0 dummy_02,
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
  FROM per_instance
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'User Commits Per Sec';
DEF vaxis = 'Commits Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = 'Y';

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- from 5a
SET SERVEROUT ON;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SPO &&edb360_output_directory.99840_&&common_edb360_prefix._chart_setup_driver2.sql;
DECLARE
  l_count NUMBER;
BEGIN
  FOR i IN 1 .. 15
  LOOP
    SELECT COUNT(*) INTO l_count FROM &&gv_object_prefix.instance WHERE instance_number = i;
    IF l_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' NOPRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = '';');
    ELSE
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' HEA 'Inst '||i||'' FOR 999990.000 PRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = 'Inst '||i||'';');
    END IF;
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
@&&edb360_output_directory.99840_&&common_edb360_prefix._chart_setup_driver2.sql;
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.99840_&&common_edb360_prefix._chart_setup_driver2.sql >> &&edb360_log3..txt

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
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC, h.wait_class, event) wrank
  FROM &&awr_object_prefix.active_sess_history h
 WHERE '&&diagnostics_pack.' = 'Y'
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.session_state = 'WAITING'
   AND (h.session_state = 'ON CPU' OR h.event IN ('log file sync', 'log file parallel write'))
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
   AND (session_state = 'ON CPU' OR event IN ('log file sync', 'log file parallel write'))
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
   &&skip_11g_column.&&skip_10g_column.AND s.con_id(+) = h.con_id
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
DEF title = 'AAS on CPU per Instance';
DEF abstract = 'Average Active Sessions (AAS) on CPU<br />'
DEF vaxis = 'Average Active Sessions (AAS) on CPU (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'session_state = ''ON CPU''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS on CPU per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'session_state = ''ON CPU''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_01. "&&event_name_01." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_01. "&&event_name_01."<br />'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_01. "&&event_name_01." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_01.'' AND event = ''&&event_name_01.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_01. "&&event_name_01." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_01.'' AND event = ''&&event_name_01.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_02. "&&event_name_02." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_02. "&&event_name_02."<br />'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_02. "&&event_name_02." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''&&wait_class_02.'' AND event = ''&&event_name_02.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_02. "&&event_name_02." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'wait_class = ''&&wait_class_02.'' AND event = ''&&event_name_02.''');
@@edb360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- log footer
SPO &&edb360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
DEF;
PRO Parameters
COL sid FOR A40;
COL name FOR A40;
COL value FOR A50;
COL display_value FOR A50;
COL update_comment NOPRI;
SELECT *
  FROM &&v_object_prefix.spparameter
 WHERE isspecified = 'TRUE'
 ORDER BY
       name,
       sid,
       ordinal;
COL sid CLE;
COL name CLE;
COL value CLE;
COL display_value CLE;
COL update_comment CLE;
SHOW PARAMETERS;
PRO
SELECT ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3) elapsed_hours FROM DUAL;
PRO
PRO end log
SPO OFF;

-- main footer
SPO &&edb360_main_report..html APP;
PRO
PRO </td></tr></table>
SPO OFF;
@@edb360_0c_post.sql
EXEC DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);

-- list of generated files
--HOS unzip -l &&edb360_zip_filename. >> &&edb360_log3..txt

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

HOS unzip -l &&edb360_zip_filename.
PRO "End edb360. Output: &&edb360_zip_filename..zip"

