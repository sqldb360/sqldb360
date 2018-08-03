@@&&edb360_0g.tkprof.sql
DEF section_id = '5d';
DEF section_name = 'System Statistics per Snap Interval';
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
DEF title = 'Cell Blocks';
DEF vaxis = 'Cell Blocks';
DEF tit_01 = 'cell blocks helped by commit cache';
DEF tit_02 = 'cell blocks helped by minscn optimization';
DEF tit_03 = 'cell blocks processed by cache layer';
DEF tit_04 = 'cell blocks processed by data layer';
DEF tit_05 = 'cell blocks processed by index layer';
DEF tit_06 = 'cell blocks processed by txn layer';
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
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',13,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Cell Commit Cache';
DEF vaxis = 'Counts';
DEF tit_01 = 'cell commit cache queries';
DEF tit_02 = 'cell transactions found in commit cache';
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

DEF skip_lch = '';
DEF title = 'Cell Compression Units';
DEF vaxis = 'Cell Compression Units';
DEF tit_01 = 'cell CUs processed for compressed';
DEF tit_02 = 'cell CUs processed for uncompressed';
DEF tit_03 = 'cell CUs sent compressed';
DEF tit_04 = 'cell CUs sent head piece';
DEF tit_05 = 'cell CUs sent uncompressed';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_05@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',10,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Cell Flash Cache Read Hits';
DEF vaxis = 'Read Hits';
DEF tit_01 = 'cell flash cache read hits';
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
DEF title = 'Cell I/O Bytes';
DEF vaxis = 'Bytes';
DEF tit_01 = 'cell IO uncompressed bytes';
DEF tit_02 = 'cell physical IO bytes eligible for predicate offload';
DEF tit_03 = 'cell physical IO bytes saved by storage index';
DEF tit_04 = 'cell physical IO bytes saved during optimized file creation';
DEF tit_05 = 'cell physical IO bytes saved during optimized RMAN file restore';
DEF tit_06 = 'cell physical IO bytes sent directly to DB node to balance CPU';
DEF tit_07 = 'cell physical IO interconnect bytes';
DEF tit_08 = 'cell physical IO interconnect bytes returned by smart scan';
DEF tit_09 = 'cell simulated physical IO bytes eligible for predicate offload';
DEF tit_10 = 'cell simulated physical IO bytes returned by predicate offload';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_10@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',24,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',24,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',24,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',24,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',24,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',18,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',18,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',28,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_10', '"'||SUBSTR('&&tit_10.',28,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Cell Scans';
DEF vaxis = 'Scans';
DEF tit_01 = 'cell scans';
DEF tit_02 = 'cell index scans';
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

DEF skip_lch = '';
DEF title = 'Cell Smart Scan Sessions';
DEF vaxis = 'Sessions';
DEF tit_01 = 'cell num fast response sessions';
DEF tit_02 = 'cell num fast response sessions continuing to smart scan';
DEF tit_03 = 'cell num smart file creation sessions using rdbms block IO mode';
DEF tit_04 = 'cell num smart IO sessions in rdbms block IO due to big payload';
DEF tit_05 = 'cell num smart IO sessions in rdbms block IO due to no cell mem';
DEF tit_06 = 'cell num smart IO sessions in rdbms block IO due to user';
DEF tit_07 = 'cell num smart IO sessions using passthru mode due to cellsrv';
DEF tit_08 = 'cell num smart IO sessions using passthru mode due to timezone';
DEF tit_09 = 'cell num smart IO sessions using passthru mode due to user';
DEF tit_10 = 'cell smart IO session cache hard misses';
DEF tit_11 = 'cell smart IO session cache hits';
DEF tit_12 = 'cell smart IO session cache hwm';
DEF tit_13 = 'cell smart IO session cache lookups';
DEF tit_14 = 'cell smart IO session cache soft misses';
DEF tit_15 = '';
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name_01@', '&&tit_01.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_02@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_05@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_06@', '&&tit_06.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_10@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_11@', '&&tit_11.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_12@', '&&tit_12.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_13@', '&&tit_13.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_14@', '&&tit_14.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',37,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',37,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',37,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',34,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',34,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',34,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_10', '"'||SUBSTR('&&tit_10.',23,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_11', '"'||SUBSTR('&&tit_11.',23,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_12', '"'||SUBSTR('&&tit_12.',23,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_13', '"'||SUBSTR('&&tit_13.',23,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_14', '"'||SUBSTR('&&tit_14.',23,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Chained or Migrated Rows';
DEF vaxis = 'Rows';
DEF tit_01 = 'table fetch continued row';
DEF tit_02 = 'chained rows processed by cell';
DEF tit_03 = 'chained rows rejected by cell';
DEF tit_04 = 'chained rows skipped by cell';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Checkpoints';
DEF vaxis = 'Checkpoints';
DEF tit_01 = 'background checkpoints completed';
DEF tit_02 = 'background checkpoints started';
DEF tit_03 = 'DBWR checkpoints';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Commits and Rollbacks';
DEF vaxis = 'Commits and Rollbacks';
DEF tit_01 = 'user commits';
DEF tit_02 = 'user rollbacks';
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

DEF skip_lch = '';
DEF title = 'Current and Consistent Blocks';
DEF vaxis = 'Counts';
DEF tit_01 = 'consistent changes';
DEF tit_02 = 'consistent gets';
DEF tit_03 = 'consistent gets direct';
DEF tit_04 = 'consistent gets from cache';
DEF tit_05 = 'CR blocks created';
DEF tit_06 = 'current blocks converted for CR';
DEF tit_07 = 'data blocks consistent reads - undo records applied';
DEF tit_08 = 'db block changes';
DEF tit_09 = 'db block gets';
DEF tit_10 = 'db block gets direct';
DEF tit_11 = 'db block gets from cache';
DEF tit_12 = 'switch current to new buffer';
DEF tit_13 = 'write clones created in background';
DEF tit_14 = 'write clones created in foreground';
DEF tit_15 = '';
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name_01@', '&&tit_01.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_02@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_05@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_06@', '&&tit_06.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_10@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_11@', '&&tit_11.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_12@', '&&tit_12.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_13@', '&&tit_13.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_14@', '&&tit_14.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_10', '"'||SUBSTR('&&tit_10.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_11', '"'||SUBSTR('&&tit_11.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_12', '"'||SUBSTR('&&tit_12.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_13', '"'||SUBSTR('&&tit_13.',14,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_14', '"'||SUBSTR('&&tit_14.',14,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF abstract = 'Number of times a consistent read was requested for a block.<br />';
DEF title = 'Consistent Gets (direct and from cache)';
DEF vaxis = 'Counts';
DEF tit_01 = 'consistent gets';
DEF tit_02 = 'consistent gets direct';
DEF tit_03 = 'consistent gets from cache';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Cursor and SQL Area evicted';
DEF vaxis = 'Count';
DEF tit_01 = 'CCursor + sql area evicted';
DEF tit_02 = 'sql area evicted';
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

DEF skip_lch = '';
DEF title = 'En(De)cryption';
DEF vaxis = 'Blocks or Bytes';
DEF tit_01 = 'blocks decrypted';
DEF tit_02 = 'blocks encrypted';
DEF tit_03 = 'securefile bytes encrypted';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'EHCC Compression Units (De)Compressed';
DEF vaxis = 'Compression Units';
DEF tit_01 = 'EHCC Analyze CUs Decompressed';
DEF tit_02 = 'EHCC Archive CUs Compressed';
DEF tit_03 = 'EHCC Archive CUs Decompressed';
DEF tit_04 = 'EHCC Check CUs Decompressed';
DEF tit_05 = 'EHCC CUs Compressed';
DEF tit_06 = 'EHCC CUs Decompressed';
DEF tit_07 = 'EHCC DML CUs Decompressed';
DEF tit_08 = 'EHCC Dump CUs Decompressed';
DEF tit_09 = 'EHCC Normal Scan CUs Decompressed';
DEF tit_10 = 'EHCC Query High CUs Compressed';
DEF tit_11 = 'EHCC Query High CUs Decompressed';
DEF tit_12 = 'EHCC Query Low CUs Compressed';
DEF tit_13 = 'EHCC Query Low CUs Decompressed';
DEF tit_14 = 'EHCC Rowid CUs Decompressed';
DEF tit_15 = 'EHCC Turbo Scan CUs Decompressed';
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name_01@', '&&tit_01.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_02@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_05@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_06@', '&&tit_06.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_10@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_11@', '&&tit_11.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_12@', '&&tit_12.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_13@', '&&tit_13.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_14@', '&&tit_14.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_15@', '&&tit_15.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_10', '"'||SUBSTR('&&tit_10.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_11', '"'||SUBSTR('&&tit_11.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_12', '"'||SUBSTR('&&tit_12.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_13', '"'||SUBSTR('&&tit_13.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_14', '"'||SUBSTR('&&tit_14.',6,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_15', '"'||SUBSTR('&&tit_15.',6,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Enqueues';
DEF vaxis = 'Enqueues';
DEF tit_01 = 'enqueue conversions';
DEF tit_02 = 'enqueue deadlocks';
DEF tit_03 = 'enqueue releases';
DEF tit_04 = 'enqueue requests';
DEF tit_05 = 'enqueue timeouts';
DEF tit_06 = 'enqueue waits';
DEF tit_07 = 'global enqueue gets async';
DEF tit_08 = 'global enqueue gets sync';
DEF tit_09 = 'global enqueue releases';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Flash Cache Inserts and Evictions';
DEF vaxis = 'Counts';
DEF tit_01 = 'flash cache eviction: aged out';
DEF tit_02 = 'flash cache eviction: buffer pinned';
DEF tit_03 = 'flash cache eviction: invalidated';
DEF tit_04 = 'flash cache insert skip: corrupt';
DEF tit_05 = 'flash cache insert skip: DBWR overloaded';
DEF tit_06 = 'flash cache insert skip: exists';
DEF tit_07 = 'flash cache insert skip: modification';
DEF tit_08 = 'flash cache insert skip: not current';
DEF tit_09 = 'flash cache insert skip: not useful';
DEF tit_10 = 'flash cache inserts';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_10@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',13,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_10', '"'||SUBSTR('&&tit_10.',13,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Global Blocks and Reads';
DEF vaxis = 'Counts';
DEF tit_01 = 'gc blocks compressed';
DEF tit_02 = 'gc blocks corrupt';
DEF tit_03 = 'gc blocks lost';
DEF tit_04 = 'gc claim blocks lost';
DEF tit_05 = 'gc cr blocks received';
DEF tit_06 = 'gc cr blocks served';
DEF tit_07 = 'gc current blocks received';
DEF tit_08 = 'gc current blocks served';
DEF tit_09 = 'gc kbytes saved';
DEF tit_10 = 'gc kbytes sent';
DEF tit_11 = 'gc read wait failures';
DEF tit_12 = 'gc read wait timeouts';
DEF tit_13 = 'gc read waits';
DEF tit_14 = '';
DEF tit_15 = '';
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name_01@', '&&tit_01.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_02@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_05@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_06@', '&&tit_06.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_10@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_11@', '&&tit_11.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_12@', '&&tit_12.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_13@', '&&tit_13.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_10', '"'||SUBSTR('&&tit_10.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_11', '"'||SUBSTR('&&tit_11.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_12', '"'||SUBSTR('&&tit_12.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_13', '"'||SUBSTR('&&tit_13.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Logons';
DEF vaxis = 'Logons';
DEF tit_01 = 'logons cumulative';
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
DEF title = 'Node Splits';
DEF vaxis = 'Node Splits';
DEF tit_01 = 'branch node splits';
DEF tit_02 = 'leaf node 90-10 splits';
DEF tit_03 = 'leaf node splits';
DEF tit_04 = 'root node splits';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Parse Counts';
DEF vaxis = 'Parse Counts';
DEF tit_01 = 'parse count (describe)';
DEF tit_02 = 'parse count (failures)';
DEF tit_03 = 'parse count (hard)';
DEF tit_04 = 'parse count (total)';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Physical Reads Blocks';
DEF vaxis = 'Blocks';
DEF tit_01 = 'physical read flash cache hits';
DEF tit_02 = 'physical reads';
DEF tit_03 = 'physical reads cache';
DEF tit_04 = 'physical reads cache prefetch';
DEF tit_05 = 'physical reads direct';
DEF tit_06 = 'physical reads direct (lob)';
DEF tit_07 = 'physical reads direct temporary tablespace';
DEF tit_08 = 'physical reads for flashback new';
DEF tit_09 = 'physical reads prefetch warmup';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',10,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF abstract = 'Total number of data blocks read from disk. "physical reads" value can be greater than the value of "physical reads direct" plus "physical reads cache" as reads into process private buffers also included in this statistic.<br />';
DEF title = 'Physical Reads Blocks (direct and cache)';
DEF vaxis = 'Blocks';
DEF tit_01 = 'physical reads';
DEF tit_02 = 'physical reads cache';
DEF tit_03 = 'physical reads direct';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',10,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Physical Reads Bytes';
DEF vaxis = 'Bytes';
DEF tit_01 = 'physical read bytes';
DEF tit_02 = 'physical read total bytes';
DEF tit_03 = 'physical read total bytes optimized';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',10,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Physical Reads Requests';
DEF vaxis = 'Requests';
DEF tit_01 = 'physical read IO requests';
DEF tit_02 = 'physical read requests optimized';
DEF tit_03 = 'physical read total IO requests';
DEF tit_04 = 'physical read total multi block requests';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',10,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF abstract = 'The difference between "physical read total IO requests" and "physical read total multi block requests" gives the total number of single block read requests<br />';
DEF title = 'Physical Reads Total IO Requests';
DEF vaxis = 'Requests';
DEF tit_01 = 'physical read total IO requests';
DEF tit_02 = 'physical read total multi block requests';
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
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Physical Writes Blocks';
DEF vaxis = 'Blocks';
DEF tit_01 = 'physical writes';
DEF tit_02 = 'physical writes direct';
DEF tit_03 = 'physical writes direct (lob)';
DEF tit_04 = 'physical writes direct temporary tablespace';
DEF tit_05 = 'physical writes from cache';
DEF tit_06 = 'physical writes non checkpoint';
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
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',10,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Physical Writes Bytes';
DEF vaxis = 'Bytes';
DEF tit_01 = 'physical write bytes';
DEF tit_02 = 'physical write total bytes';
DEF tit_03 = 'redo size';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Physical Writes Requests';
DEF vaxis = 'Requests';
DEF tit_01 = 'physical write IO requests';
DEF tit_02 = 'physical write total IO requests';
DEF tit_03 = 'physical write total multi block requests';
DEF tit_04 = 'redo writes';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',10,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'PX messages';
DEF vaxis = 'Messages';
DEF tit_01 = 'PX local messages recv`d';
DEF tit_02 = 'PX local messages sent';
DEF tit_03 = 'PX remote messages recv`d';
DEF tit_04 = 'PX remote messages sent';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '`', '''''');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',4,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',4,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',4,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',4,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Redo and Undo Bytes';
DEF vaxis = 'Bytes';
DEF tit_01 = 'redo size';
DEF tit_02 = 'redo size for direct writes';
DEF tit_03 = 'redo size for lost write detection';
DEF tit_04 = 'redo wastage';
DEF tit_05 = 'undo change vector size';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_05@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Rollback Activity';
DEF vaxis = 'Counts';
DEF tit_01 = 'rollback changes - undo records applied';
DEF tit_02 = 'rollbacks only - consistent read gets';
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

DEF skip_lch = '';
DEF title = 'Sorts';
DEF vaxis = 'Sorts';
DEF tit_01 = 'sorts (disk)';
DEF tit_02 = 'sorts (memory)';
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

DEF skip_lch = '';
DEF title = 'SQL*Net Bytes';
DEF vaxis = 'Bytes';
DEF tit_01 = 'bytes received via SQL*Net from client';
DEF tit_02 = 'bytes received via SQL*Net from dblink';
DEF tit_03 = 'bytes sent via SQL*Net to client';
DEF tit_04 = 'bytes sent via SQL*Net to dblink';
DEF tit_05 = 'bytes via SQL*Net vector from client';
DEF tit_06 = 'bytes via SQL*Net vector from dblink';
DEF tit_07 = 'bytes via SQL*Net vector to client';
DEF tit_08 = 'bytes via SQL*Net vector to dblink';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',7,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',7,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',7,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',7,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',7,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',7,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',7,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',7,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'SQL*Net Roundtrips';
DEF vaxis = 'Roundtrips';
DEF tit_01 = 'SQL*Net roundtrips to/from client';
DEF tit_02 = 'SQL*Net roundtrips to/from dblink';
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
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',20,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',20,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Table Scans';
DEF vaxis = 'Table Scans';
DEF tit_01 = 'table scans (cache partitions)';
DEF tit_02 = 'table scans (direct read)';
DEF tit_03 = 'table scans (long tables)';
DEF tit_04 = 'table scans (rowid ranges)';
DEF tit_05 = 'table scans (short tables)';
DEF tit_06 = 'cell scans';
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
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Wait Time';
DEF vaxis = 'Microseconds';
DEF tit_01 = 'application wait time';
DEF tit_02 = 'cluster wait time';
DEF tit_03 = 'concurrency wait time';
DEF tit_04 = 'file io wait time';
DEF tit_05 = 'non-idle wait time';
DEF tit_06 = 'OS CPU Qt wait time';
DEF tit_07 = 'scheduler wait time';
DEF tit_08 = 'transaction lock foreground wait time';
DEF tit_09 = 'user I/O wait time';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Workarea Executions';
DEF vaxis = 'Executions';
DEF tit_01 = 'workarea executions - multipass';
DEF tit_02 = 'workarea executions - onepass';
DEF tit_03 = 'workarea executions - optimal';
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
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Parsing Counts and Session Cursor Cache Hits';
DEF vaxis = 'Parsing and Session Cursor Cache Counts';
DEF tit_01 = 'parse count (total)';
DEF tit_02 = 'parse count (hard)';
DEF tit_03 = 'parse count (failures)';
DEF tit_04 = 'parse count (describe)';
DEF tit_05 = 'session cursor cache count';
DEF tit_06 = 'session cursor cache hits';
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
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',1,30)||'"');
@@edb360_9a_pre_one.sql

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

DEF skip_lch = 'Y';

/*****************************************************************************************/

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
