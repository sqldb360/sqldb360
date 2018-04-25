@@&&edb360_0g.tkprof.sql
DEF section_id = '4a';
DEF section_name = 'System Global Area (SGA) Statistics History';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'SGA Allocation';
DEF main_table = 'X$KSMSSINFO';
BEGIN
  :sql_text := q'[
select * from x$ksmssinfo  
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF main_table = '&&awr_hist_prefix.SGASTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'SGA Statistics in GBs';
DEF vbaseline = '';
DEF tit_01 = 'Total SGA allocated';
DEF tit_02 = 'Fixed SGA';
DEF tit_03 = 'Buffer Cache';
DEF tit_04 = 'Log Buffer';
DEF tit_05 = 'Shared IO Pool';
DEF tit_06 = 'Shared Pool';
DEF tit_07 = 'Large Pool';
DEF tit_08 = 'Java Pool';
DEF tit_09 = 'Streams Pool';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
BEGIN
  :sql_text_backup := q'[
WITH 
sgastat_denorm_1 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(bytes) sga_total,
       SUM(CASE WHEN pool IS NULL AND name = 'fixed_sga' THEN bytes ELSE 0 END) fixed_sga,
       SUM(CASE WHEN pool IS NULL AND name = 'buffer_cache' THEN bytes ELSE 0 END) buffer_cache,
       SUM(CASE WHEN pool IS NULL AND name = 'log_buffer' THEN bytes ELSE 0 END) log_buffer,
       SUM(CASE WHEN pool IS NULL AND name = 'shared_io_pool' THEN bytes ELSE 0 END) shared_io_pool,
       SUM(CASE pool WHEN 'shared pool' THEN bytes ELSE 0 END) shared_pool,
       SUM(CASE pool WHEN 'large pool' THEN bytes ELSE 0 END) large_pool,
       SUM(CASE pool WHEN 'java pool' THEN bytes ELSE 0 END) java_pool,
       SUM(CASE pool WHEN 'streams pool' THEN bytes ELSE 0 END) streams_pool       
  FROM &&awr_object_prefix.sgastat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
sgastat_denorm_2 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       s1.begin_interval_time,
       s1.end_interval_time,
       ROUND((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       h1.sga_total,
       h1.fixed_sga,
       h1.buffer_cache,
       h1.log_buffer,
       h1.shared_io_pool,
       h1.shared_pool,
       h1.large_pool,
       h1.java_pool,
       h1.streams_pool
  FROM sgastat_denorm_1 h0,
       sgastat_denorm_1 h1,
       &&awr_object_prefix.snapshot s0,
       &&awr_object_prefix.snapshot s1
 WHERE h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.begin_interval_time > (s0.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(sga_total) / POWER(2,30), 3) sga_total,
       ROUND(SUM(fixed_sga) / POWER(2,30), 3) fixed_sga,
       ROUND(SUM(buffer_cache) / POWER(2,30), 3) buffer_cache,
       ROUND(SUM(log_buffer) / POWER(2,30), 3) log_buffer,
       ROUND(SUM(shared_io_pool) / POWER(2,30), 3) shared_io_pool,
       ROUND(SUM(shared_pool) / POWER(2,30), 3) shared_pool,
       ROUND(SUM(large_pool) / POWER(2,30), 3) large_pool,
       ROUND(SUM(java_pool) / POWER(2,30), 3) java_pool,
       ROUND(SUM(streams_pool) / POWER(2,30), 3) streams_pool,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM sgastat_denorm_2
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'SGA Statistics for Cluster';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'SGA Statistics for Instance 1';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'SGA Statistics for Instance 2';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'SGA Statistics for Instance 3';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'SGA Statistics for Instance 4';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'SGA Statistics for Instance 5';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'SGA Statistics for Instance 6';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'SGA Statistics for Instance 7';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'SGA Statistics for Instance 8';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Does not include Free SGA Memory Available. For memory pools resize review Memory Statistics reports instead.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
