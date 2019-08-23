@@&&edb360_0g.tkprof.sql
DEF section_id = '4c';
DEF section_name = 'Reads to Buffer Cache';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&awr_hist_prefix.sysstat';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
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
BEGIN
  :sql_text_backup2 := q'[
WITH
sysstat_io AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = 'physical read flash cache hits' THEN value ELSE 0 END) r_flash_cache_hits,
       SUM(CASE WHEN stat_name = 'physical reads cache' THEN value ELSE 0 END) r_cache,
       SUM(CASE WHEN stat_name = 'physical reads cache prefetch' THEN value ELSE 0 END) r_cache_prefetch,
       SUM(CASE WHEN stat_name = 'physical reads prefetch warmup' THEN value ELSE 0 END) r_prefetch_warmup
  FROM &&awr_object_prefix.sysstat 
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND stat_name IN (
   'physical read flash cache hits',
   'physical reads cache',
   'physical reads cache prefetch',
   'physical reads prefetch warmup')
 GROUP BY
       instance_number,
       snap_id
),
io_per_inst_and_snap_id AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       s1.snap_id,
       h1.instance_number,
       s1.begin_interval_time,
       s1.end_interval_time,
       (h1.r_flash_cache_hits - h0.r_flash_cache_hits) r_flash_cache_hits,
       (h1.r_cache - h0.r_cache) r_cache,
       (h1.r_cache_prefetch - h0.r_cache_prefetch) r_cache_prefetch,
       (h1.r_prefetch_warmup - h0.r_prefetch_warmup) r_prefetch_warmup,
       --(h1.reads - h0.reads) - (h1.r_direct - h0.r_direct) - (h1.r_cache - h0.r_cache) r_buffered_multi_block_req,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_io h0,
       &&awr_object_prefix.snapshot s0,
       sysstat_io h1,
       &&awr_object_prefix.snapshot s1
 WHERE s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 > 60 -- ignore snaps too close
),
io_per_inst_and_hr AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       ROUND(MAX(r_flash_cache_hits )) r_flash_cache_hits_bl,
       ROUND(MAX(r_cache )) r_cache_bl,
       ROUND(MAX(r_cache_prefetch )) r_cache_prefetch_bl,
       ROUND(MAX(r_prefetch_warmup )) r_prefetch_warmup_bl,
       ROUND(MAX(r_cache) * &&database_block_size. / POWER(2,20)) r_cache_mb,
       ROUND(MAX(r_flash_cache_hits) * &&database_block_size. / POWER(2,20)) r_flash_cache_hits_mb,
       ROUND(MAX(r_cache_prefetch) * &&database_block_size. / POWER(2,20)) r_cache_prefetch_mb,
       ROUND(MAX(r_prefetch_warmup) * &&database_block_size. / POWER(2,20))r_prefetch_warmup_mb,       
       ROUND(MAX(r_flash_cache_hits / elapsed_sec),3) r_flash_cache_hits_ps,
       ROUND(MAX(r_cache / elapsed_sec),3) r_cache_ps,
       ROUND(MAX(r_cache_prefetch / elapsed_sec),3) r_cache_prefetch_ps,
       ROUND(MAX(r_prefetch_warmup / elapsed_sec),3) r_prefetch_warmup_ps
       --ROUND(MAX(r_buffered_multi_block_req / elapsed_sec)) r_buffered_multi_block_iops,
  FROM io_per_inst_and_snap_id
 GROUP BY
       snap_id,
       instance_number
),
bufch AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       ROUND(SUM(bytes) / POWER(2,20), 3) buffer_cache_mb,
       ROUND(SUM(bytes) / &&database_block_size.) buffer_cache_bl
  FROM &&awr_object_prefix.sgastat 
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND name = 'buffer_cache'
 GROUP BY 
       snap_id,
       instance_number)
SELECT i.snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       #column1#,
       #column2#,
       #column3#,
       #column4#,
       #column5#,
       0 dummy_6,
       0 dummy_7,
       0 dummy_8,
       0 dummy_9,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM io_per_inst_and_hr i ,bufch b
 WHERE i.snap_id=b.snap_id
   AND i.instance_number = b.instance_number
 GROUP BY
       i.snap_id
 ORDER BY
       i.snap_id
]';
END;
/

DEF tit_01 = 'Buffer Cache MB';
DEF tit_02 = 'MB from Disk';
DEF tit_03 = 'MB from Flash';
DEF tit_04 = 'MB using Prefetch';
DEF tit_05 = 'MB during Warmup';
DEF vaxis = 'Megabytes';

EXEC :sql_text_backup:=REPLACE(:sql_text_backup2,'#column1#','SUM(buffer_cache_mb) buffer_cache_mb');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column2#','SUM(r_cache_mb) r_cache_mb');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column3#','SUM(r_flash_cache_hits_mb) r_flash_cache_hits_mb');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column4#','SUM(r_cache_prefetch_mb) r_cache_prefetch_mb');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column5#','SUM(r_prefetch_warmup_mb) r_prefetch_warmup_mb');

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Cluster';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Instance 1';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Instance 2';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Instance 3';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Instance 4';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Instance 5';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Instance 6';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Instance 7';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in MB for Instance 8';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'Buffer Cache blocks';
DEF tit_02 = 'Blocks from Disk';
DEF tit_03 = 'Blocks from Flash';
DEF tit_04 = 'Blocks using Prefetch';
DEF tit_05 = 'Blocks during Warmup';
DEF vaxis = 'Blocks';

EXEC :sql_text_backup:=REPLACE(:sql_text_backup2,'#column1#','SUM(buffer_cache_bl) buffer_cache_bl');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column2#','SUM(r_cache_bl) r_cache_bl');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column3#','SUM(r_flash_cache_hits_bl) r_flash_cache_hits_bl');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column4#','SUM(r_cache_prefetch_bl) r_cache_prefetch_bl');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column5#','SUM(r_prefetch_warmup_bl) r_prefetch_warmup_bl');

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Cluster';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Instance 1';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Instance 2';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Instance 3';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Instance 4';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Instance 5';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Instance 6';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Instance 7';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks for Instance 8';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'Blocks from Disk per second';
DEF tit_02 = 'Blocks from Flash per second';
DEF tit_03 = 'Blocks using Prefetch per sec';
DEF tit_04 = 'Blocks during Warmup per sec';
DEF vaxis = 'Blocks per Second';

EXEC :sql_text_backup:=REPLACE(:sql_text_backup2,'#column1#','ROUND(SUM(r_cache_ps)) r_cache_ps');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column2#','ROUND(SUM(r_flash_cache_hits_ps)) r_flash_cache_hits_ps');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column3#','ROUND(SUM(r_cache_prefetch_ps)) r_cache_prefetch_ps');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column4#','ROUND(SUM(r_prefetch_warmup_ps)) r_prefetch_warmup_ps');
EXEC :sql_text_backup:=REPLACE(:sql_text_backup ,'#column5#','0 dummy_5');

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Cluster';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Instance 1';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Instance 2';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Instance 3';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Instance 4';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Instance 5';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Instance 6';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Instance 7';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Buffer Cache Statistics in Blocks per second for Instance 8';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
