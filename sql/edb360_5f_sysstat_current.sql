@@&&edb360_0g.tkprof.sql
DEF section_id = '5f';
DEF section_name = 'System Statistics (Current) per Snap Interval';
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
       --(h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) value
       h.value
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
       SUM(value) value
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
DEF title = 'Sessions (logons current)';
DEF vaxis = 'Sessions';
DEF tit_01 = 'logons current';
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
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name_01@', '&&tit_01.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Cursors (opened and pinned)';
DEF vaxis = 'Cursors';
DEF tit_01 = 'opened cursors current';
DEF tit_02 = 'pinned cursors current';
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
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name_01@', '&&tit_01.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_02@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
@@edb360_9a_pre_one.sql

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
