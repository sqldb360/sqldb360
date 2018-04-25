@@&&edb360_0g.tkprof.sql
DEF section_id = '4c';
DEF section_name = 'Memory Statistics History';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&awr_hist_prefix.OSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Memory Statistics in GB';
DEF vbaseline = '';
DEF tit_01 = 'SGA + PGA';
DEF tit_02 = 'SGA';
DEF tit_03 = 'PGA';
DEF tit_04 = 'VM IN';
DEF tit_05 = 'VM OUT';
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
vm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(CASE WHEN h1.stat_name = 'VM_IN_BYTES'  AND h1.value > h0.value THEN h1.value - h0.value ELSE 0 END) in_bytes,
       SUM(CASE WHEN h1.stat_name = 'VM_OUT_BYTES' AND h1.value > h0.value THEN h1.value - h0.value ELSE 0 END) out_bytes
  FROM &&awr_object_prefix.osstat h0,
       &&awr_object_prefix.osstat h1
 WHERE h1.stat_name IN ('VM_IN_BYTES', 'VM_OUT_BYTES')
   AND h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&edb360_dbid.
   AND h1.instance_number = @instance_number@
   AND h0.snap_id = h1.snap_id - 1
   AND h0.dbid = h1.dbid
   AND h0.instance_number = h1.instance_number
   AND h0.stat_name = h1.stat_name
   AND h0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h0.dbid = &&edb360_dbid.
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
sga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(h1.value) bytes
  FROM &&awr_object_prefix.sga h1
 WHERE h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&edb360_dbid.
   AND h1.instance_number = @instance_number@
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(h1.value) bytes
  FROM &&awr_object_prefix.pgastat h1
 WHERE h1.name = 'total PGA allocated'
   AND h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&edb360_dbid.
   AND h1.instance_number = @instance_number@
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
mem AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snp.snap_id,
       snp.dbid,
       snp.instance_number,
       snp.begin_interval_time,
       snp.end_interval_time,
       ROUND((CAST(snp.end_interval_time AS DATE) - CAST(snp.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       NVL(vm.in_bytes, 0) vm_in_bytes,
       NVL(vm.out_bytes, 0) vm_out_bytes,
       NVL(sga.bytes, 0) sga_bytes,
       NVL(pga.bytes, 0) pga_bytes,
       NVL(sga.bytes, 0) + NVL(pga.bytes, 0) mem_bytes
  FROM &&awr_object_prefix.snapshot snp,
       vm, sga, pga
 WHERE snp.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND snp.dbid = &&edb360_dbid.
   AND snp.end_interval_time > (snp.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
   AND vm.snap_id(+) = snp.snap_id
   AND vm.dbid(+) = snp.dbid
   AND vm.instance_number(+) = snp.instance_number
   AND sga.snap_id(+) = snp.snap_id
   AND sga.dbid(+) = snp.dbid
   AND sga.instance_number(+) = snp.instance_number
   AND pga.snap_id(+) = snp.snap_id
   AND pga.dbid(+) = snp.dbid
   AND pga.instance_number(+) = snp.instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(mem_bytes)/POWER(2,30),3) mem_gb,
       ROUND(SUM(sga_bytes)/POWER(2,30),3) sga_gb,
       ROUND(SUM(pga_bytes)/POWER(2,30),3) pga_gb,
       ROUND(SUM(vm_in_bytes)/POWER(2,30),3) vm_in_gb,
       ROUND(SUM(vm_out_bytes)/POWER(2,30),3) vm_out_gb,
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
  FROM mem
 WHERE mem_bytes > 0
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Memory Statistics for Cluster';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'h1.instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'Memory Statistics for Instance 1';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'Memory Statistics for Instance 2';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'Memory Statistics for Instance 3';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'Memory Statistics for Instance 4';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'Memory Statistics for Instance 5';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'Memory Statistics for Instance 6';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'Memory Statistics for Instance 7';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'Memory Statistics for Instance 8';
DEF abstract = '&&abstract_uom.';
DEF foot = 'Includes Free SGA Memory Available.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
