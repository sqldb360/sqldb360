@@&&edb360_0g.tkprof.sql
DEF section_id = '5e';
DEF section_name = 'System Statistics (Exadata) per Snap Interval';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&awr_hist_prefix.SYSSTAT';
DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';

BEGIN
  :sql_text_backup := q'[
WITH
selected_stat_name AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       (s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) startup_time_interval,
       h.stat_name,
       (h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) value
       --h.value
  FROM &&awr_object_prefix.sysstat h,
       &&awr_object_prefix.snapshot s
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN ('@stat_name_01@', '@stat_name_02@', '@stat_name_03@', '@stat_name_04@', '@stat_name_05@', '@stat_name_06@', '@stat_name_07@', '@stat_name_08@', '@stat_name_09@', '@stat_name_10@', '@stat_name_11@', '@stat_name_12@', '@stat_name_13@', '@stat_name_14@', '@stat_name_15@')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
stat_name_per_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       stat_name,
       --SUM(value) value
       ROUND(SUM(value)/1e9, 3) value
  FROM selected_stat_name
 WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
   AND value >= 0 
 GROUP BY
       snap_id,
       stat_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE stat_name WHEN '@stat_name_01@' THEN value ELSE 0 END) dummy_01,
       SUM(CASE stat_name WHEN '@stat_name_02@' THEN value ELSE 0 END) dummy_02,
       SUM(CASE stat_name WHEN '@stat_name_03@' THEN value ELSE 0 END) dummy_03,
       SUM(CASE stat_name WHEN '@stat_name_04@' THEN value ELSE 0 END) dummy_04,
       SUM(CASE stat_name WHEN '@stat_name_05@' THEN value ELSE 0 END) dummy_05,
       SUM(CASE stat_name WHEN '@stat_name_06@' THEN value ELSE 0 END) dummy_06,
       SUM(CASE stat_name WHEN '@stat_name_07@' THEN value ELSE 0 END) dummy_07,
       SUM(CASE stat_name WHEN '@stat_name_08@' THEN value ELSE 0 END) dummy_08,
       SUM(CASE stat_name WHEN '@stat_name_09@' THEN value ELSE 0 END) dummy_09,
       SUM(CASE stat_name WHEN '@stat_name_10@' THEN value ELSE 0 END) dummy_10,
       SUM(CASE stat_name WHEN '@stat_name_11@' THEN value ELSE 0 END) dummy_11,
       SUM(CASE stat_name WHEN '@stat_name_12@' THEN value ELSE 0 END) dummy_12,
       SUM(CASE stat_name WHEN '@stat_name_13@' THEN value ELSE 0 END) dummy_13,
       SUM(CASE stat_name WHEN '@stat_name_14@' THEN value ELSE 0 END) dummy_14,
       SUM(CASE stat_name WHEN '@stat_name_15@' THEN value ELSE 0 END) dummy_15
  FROM stat_name_per_snap
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'Physical I/O in GBs';
DEF vaxis = 'GBs';
DEF tit_01 = 'physical read total bytes';
DEF tit_02 = 'physical write total bytes';
DEF tit_03 = 'cell physical IO bytes eligible for predicate offload';
DEF tit_04 = 'cell physical IO interconnect bytes';
DEF tit_05 = 'cell physical IO interconnect bytes returned by smart scan';
DEF tit_06 = 'cell physical IO bytes saved by storage index';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name_01@', '&&tit_01.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_02@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_05@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_06@', '&&tit_06.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',18,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',18,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',18,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',18,30)||'"');
@@edb360_9a_pre_one.sql

/*****************************************************************************************/

BEGIN
  :sql_text := q'[
WITH
selected_stat_name AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       (s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) startup_time_interval,
       h.stat_name,
       (h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) value
       --h.value
  FROM &&awr_object_prefix.sysstat h,
       &&awr_object_prefix.snapshot s
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN ('physical read total bytes', 
                       'physical write total bytes', 
                       'physical read total IO requests',
                       'cell flash cache read hits',
                       'cell physical IO bytes eligible for predicate offload', 
                       'cell physical IO interconnect bytes', 
                       'cell physical IO interconnect bytes returned by smart scan', 
                       'cell physical IO bytes saved by storage index')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
stat_name_per_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       stat_name,
       SUM(value) value
       --ROUND(SUM(value)/1e9, 3) value
  FROM selected_stat_name
 WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
   AND value >= 0 
 GROUP BY
       snap_id,
       stat_name
),
stats_per_snap AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE stat_name WHEN 'physical read total bytes' THEN value ELSE 0 END) prtb,
       SUM(CASE stat_name WHEN 'physical write total bytes' THEN value ELSE 0 END) pwtb,
       SUM(CASE stat_name WHEN 'physical read total IO requests' THEN value ELSE 0 END) prtior,
       SUM(CASE stat_name WHEN 'cell flash cache read hits' THEN value ELSE 0 END) cfcrh,
       SUM(CASE stat_name WHEN 'cell physical IO bytes eligible for predicate offload' THEN value ELSE 0 END) eligible,
       SUM(CASE stat_name WHEN 'cell physical IO interconnect bytes' THEN value ELSE 0 END) ib,
       SUM(CASE stat_name WHEN 'cell physical IO interconnect bytes returned by smart scan' THEN value ELSE 0 END) ibrss,
       SUM(CASE stat_name WHEN 'cell physical IO bytes saved by storage index' THEN value ELSE 0 END) bssi
  FROM stat_name_per_snap
 GROUP BY
       snap_id
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       begin_time,
       end_time,
       /* "cell physical IO bytes eligible for predicate offload" / "physical read total bytes" */
       CASE WHEN prtb > 0 THEN ROUND(100 * eligible / prtb, 1) ELSE 0 END "Eligible Percent", 
       /* ("cell physical IO bytes eligible for predicate offload" - "cell physical IO interconnect bytes returned by smart scan")/ "cell physical IO bytes eligible for predicate offload" */
       --CASE WHEN eligible > ibrss THEN ROUND(100 * (eligible - ibrss) / eligible, 1) ELSE 0 END "IO Saved Percent", 
       /* "cell physical IO bytes saved by storage index" / "cell physical IO bytes eligible for predicate offload" */
       --CASE WHEN eligible > 0 THEN ROUND(100 * bssi / eligible, 1) ELSE 0 END "Storage Index effic Perc", 
       /* "cell flash cache read hits" / "physical read total IO requests" */
       --CASE WHEN prtior > 0 THEN ROUND(100 * cfcrh / prtior, 1) ELSE 0 END "Flash Cache effic Perc", 
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
  FROM stats_per_snap
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'Offloading Eligibility';
DEF vaxis = 'Percent %';
DEF tit_01 = 'Offloading Eligible';
--DEF tit_02 = 'IO Saved Percent';
--DEF tit_03 = 'Storage Index efficiency Percent';
--DEF tit_04 = 'Flash Cache efficiency Percent';
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
@@edb360_9a_pre_one.sql

/*****************************************************************************************/

BEGIN
  :sql_text := q'[
WITH
selected_stat_name AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       (s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) startup_time_interval,
       h.stat_name,
       (h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) value
       --h.value
  FROM &&awr_object_prefix.sysstat h,
       &&awr_object_prefix.snapshot s
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN ('physical read total bytes', 
                       'physical write total bytes', 
                       'physical read total IO requests',
                       'cell flash cache read hits',
                       'cell physical IO bytes eligible for predicate offload', 
                       'cell physical IO interconnect bytes', 
                       'cell physical IO interconnect bytes returned by smart scan', 
                       'cell physical IO bytes saved by storage index')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
stat_name_per_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       stat_name,
       SUM(value) value
       --ROUND(SUM(value)/1e9, 3) value
  FROM selected_stat_name
 WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
   AND value >= 0 
 GROUP BY
       snap_id,
       stat_name
),
stats_per_snap AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE stat_name WHEN 'physical read total bytes' THEN value ELSE 0 END) prtb,
       SUM(CASE stat_name WHEN 'physical write total bytes' THEN value ELSE 0 END) pwtb,
       SUM(CASE stat_name WHEN 'physical read total IO requests' THEN value ELSE 0 END) prtior,
       SUM(CASE stat_name WHEN 'cell flash cache read hits' THEN value ELSE 0 END) cfcrh,
       SUM(CASE stat_name WHEN 'cell physical IO bytes eligible for predicate offload' THEN value ELSE 0 END) eligible,
       SUM(CASE stat_name WHEN 'cell physical IO interconnect bytes' THEN value ELSE 0 END) ib,
       SUM(CASE stat_name WHEN 'cell physical IO interconnect bytes returned by smart scan' THEN value ELSE 0 END) ibrss,
       SUM(CASE stat_name WHEN 'cell physical IO bytes saved by storage index' THEN value ELSE 0 END) bssi
  FROM stat_name_per_snap
 GROUP BY
       snap_id
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       begin_time,
       end_time,
       /* "cell physical IO bytes eligible for predicate offload" / "physical read total bytes" */
       --CASE WHEN prtb > 0 THEN ROUND(100 * eligible / prtb, 1) ELSE 0 END "Eligible Percent", 
       /* ("cell physical IO bytes eligible for predicate offload" - "cell physical IO interconnect bytes returned by smart scan")/ "cell physical IO bytes eligible for predicate offload" */
       CASE WHEN eligible > ibrss THEN ROUND(100 * (eligible - ibrss) / eligible, 1) ELSE 0 END "IO Saved Percent", 
       /* "cell physical IO bytes saved by storage index" / "cell physical IO bytes eligible for predicate offload" */
       --CASE WHEN eligible > 0 THEN ROUND(100 * bssi / eligible, 1) ELSE 0 END "Storage Index effic Perc", 
       /* "cell flash cache read hits" / "physical read total IO requests" */
       --CASE WHEN prtior > 0 THEN ROUND(100 * cfcrh / prtior, 1) ELSE 0 END "Flash Cache effic Perc", 
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
  FROM stats_per_snap
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'Offloading Efficiency';
DEF vaxis = 'Percent %';
--DEF tit_01 = 'Eligible Percent';
DEF tit_01 = 'Offloaded';
--DEF tit_03 = 'Storage Index efficiency Percent';
--DEF tit_04 = 'Flash Cache efficiency Percent';
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
@@edb360_9a_pre_one.sql

/*****************************************************************************************/

BEGIN
  :sql_text := q'[
WITH
selected_stat_name AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       (s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) startup_time_interval,
       h.stat_name,
       (h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) value
       --h.value
  FROM &&awr_object_prefix.sysstat h,
       &&awr_object_prefix.snapshot s
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN ('physical read total bytes', 
                       'physical write total bytes', 
                       'physical read total IO requests',
                       'cell flash cache read hits',
                       'cell physical IO bytes eligible for predicate offload', 
                       'cell physical IO interconnect bytes', 
                       'cell physical IO interconnect bytes returned by smart scan', 
                       'cell physical IO bytes saved by storage index')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
stat_name_per_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       stat_name,
       SUM(value) value
       --ROUND(SUM(value)/1e9, 3) value
  FROM selected_stat_name
 WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
   AND value >= 0 
 GROUP BY
       snap_id,
       stat_name
),
stats_per_snap AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE stat_name WHEN 'physical read total bytes' THEN value ELSE 0 END) prtb,
       SUM(CASE stat_name WHEN 'physical write total bytes' THEN value ELSE 0 END) pwtb,
       SUM(CASE stat_name WHEN 'physical read total IO requests' THEN value ELSE 0 END) prtior,
       SUM(CASE stat_name WHEN 'cell flash cache read hits' THEN value ELSE 0 END) cfcrh,
       SUM(CASE stat_name WHEN 'cell physical IO bytes eligible for predicate offload' THEN value ELSE 0 END) eligible,
       SUM(CASE stat_name WHEN 'cell physical IO interconnect bytes' THEN value ELSE 0 END) ib,
       SUM(CASE stat_name WHEN 'cell physical IO interconnect bytes returned by smart scan' THEN value ELSE 0 END) ibrss,
       SUM(CASE stat_name WHEN 'cell physical IO bytes saved by storage index' THEN value ELSE 0 END) bssi
  FROM stat_name_per_snap
 GROUP BY
       snap_id
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       begin_time,
       end_time,
       /* "cell physical IO bytes eligible for predicate offload" / "physical read total bytes" */
       --CASE WHEN prtb > 0 THEN ROUND(100 * eligible / prtb, 1) ELSE 0 END "Eligible Percent", 
       /* ("cell physical IO bytes eligible for predicate offload" - "cell physical IO interconnect bytes returned by smart scan")/ "cell physical IO bytes eligible for predicate offload" */
       --CASE WHEN eligible > ibrss THEN ROUND(100 * (eligible - ibrss) / eligible, 1) ELSE 0 END "IO Saved Percent", 
       /* "cell physical IO bytes saved by storage index" / "cell physical IO bytes eligible for predicate offload" */
       CASE WHEN eligible > 0 THEN ROUND(100 * bssi / eligible, 1) ELSE 0 END "Storage Index effic Perc", 
       /* "cell flash cache read hits" / "physical read total IO requests" */
       --CASE WHEN prtior > 0 THEN ROUND(100 * cfcrh / prtior, 1) ELSE 0 END "Flash Cache effic Perc", 
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
  FROM stats_per_snap
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'Storage Index efficiency';
DEF vaxis = 'Percent %';
--DEF tit_01 = 'Eligible Percent';
--DEF tit_02 = 'IO Saved Percent';
DEF tit_01 = 'Storage Index';
--DEF tit_04 = 'Flash Cache efficiency Percent';
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
@@edb360_9a_pre_one.sql

/*****************************************************************************************/

BEGIN
  :sql_text := q'[
WITH
selected_stat_name AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       (s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) startup_time_interval,
       h.stat_name,
       (h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) value
       --h.value
  FROM &&awr_object_prefix.sysstat h,
       &&awr_object_prefix.snapshot s
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN ('physical read total bytes', 
                       'physical write total bytes', 
                       'physical read total IO requests',
                       'cell flash cache read hits',
                       'cell physical IO bytes eligible for predicate offload', 
                       'cell physical IO interconnect bytes', 
                       'cell physical IO interconnect bytes returned by smart scan', 
                       'cell physical IO bytes saved by storage index')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
stat_name_per_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       stat_name,
       SUM(value) value
       --ROUND(SUM(value)/1e9, 3) value
  FROM selected_stat_name
 WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
   AND value >= 0 
 GROUP BY
       snap_id,
       stat_name
),
stats_per_snap AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE stat_name WHEN 'physical read total bytes' THEN value ELSE 0 END) prtb,
       SUM(CASE stat_name WHEN 'physical write total bytes' THEN value ELSE 0 END) pwtb,
       SUM(CASE stat_name WHEN 'physical read total IO requests' THEN value ELSE 0 END) prtior,
       SUM(CASE stat_name WHEN 'cell flash cache read hits' THEN value ELSE 0 END) cfcrh,
       SUM(CASE stat_name WHEN 'cell physical IO bytes eligible for predicate offload' THEN value ELSE 0 END) eligible,
       SUM(CASE stat_name WHEN 'cell physical IO interconnect bytes' THEN value ELSE 0 END) ib,
       SUM(CASE stat_name WHEN 'cell physical IO interconnect bytes returned by smart scan' THEN value ELSE 0 END) ibrss,
       SUM(CASE stat_name WHEN 'cell physical IO bytes saved by storage index' THEN value ELSE 0 END) bssi
  FROM stat_name_per_snap
 GROUP BY
       snap_id
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       begin_time,
       end_time,
       /* "cell physical IO bytes eligible for predicate offload" / "physical read total bytes" */
       --CASE WHEN prtb > 0 THEN ROUND(100 * eligible / prtb, 1) ELSE 0 END "Eligible Percent", 
       /* ("cell physical IO bytes eligible for predicate offload" - "cell physical IO interconnect bytes returned by smart scan")/ "cell physical IO bytes eligible for predicate offload" */
       --CASE WHEN eligible > ibrss THEN ROUND(100 * (eligible - ibrss) / eligible, 1) ELSE 0 END "IO Saved Percent", 
       /* "cell physical IO bytes saved by storage index" / "cell physical IO bytes eligible for predicate offload" */
       --CASE WHEN eligible > 0 THEN ROUND(100 * bssi / eligible, 1) ELSE 0 END "Storage Index effic Perc", 
       /* "cell flash cache read hits" / "physical read total IO requests" */
       CASE WHEN prtior > 0 THEN ROUND(100 * cfcrh / prtior, 1) ELSE 0 END "Flash Cache effic Perc", 
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
  FROM stats_per_snap
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'Flash Cache efficiency';
DEF vaxis = 'Percent %';
--DEF tit_01 = 'Eligible Percent';
--DEF tit_02 = 'IO Saved Percent';
--DEF tit_03 = 'Storage Index efficiency Percent';
DEF tit_01 = 'Flash Cache';
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
@@edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF tit_01 = '';
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

/*****************************************************************************************/

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
