@@&&edb360_0g.tkprof.sql
DEF section_id = '1f';
DEF section_name = 'Resources (as per Statspack)';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

REM **********************************************************
REM * STATSPACK USER: CHANGE HERE IF DIFFERENT FROM PERFSTAT *
REM **********************************************************
DEF statspack_user = 'perfstat';

-- set snapshot ranges to STATSPACK ranges !!
DEF sp_minimum_snap_id = '';
COL sp_minimum_snap_id NEW_V sp_minimum_snap_id NOPRI;
SELECT /* ignore if it fails to parse */
NVL(TO_CHAR(MIN(snap_id)), '0') sp_minimum_snap_id 
FROM &&statspack_user..stats$snapshot s
WHERE 1=1 
AND begin_interval_time > TO_DATE('&&edb360_date_from.', '&&edb360_date_format.');
SELECT '-1' sp_minimum_snap_id FROM DUAL WHERE TRIM('&&sp_minimum_snap_id.') IS NULL;

DEF sp_maximum_snap_id = '';
COL sp_maximum_snap_id NEW_V sp_maximum_snap_id NOPRI;
SELECT /* ignore if it fails to parse */
NVL(TO_CHAR(MAX(snap_id)), '&&sp_minimum_snap_id.') sp_maximum_snap_id 
FROM &&statspack_user..stats$snapshot s
WHERE 1=1
AND end_interval_time < TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') + 1;
SELECT '-1' sp_maximum_snap_id FROM DUAL WHERE TRIM('&&sp_maximum_snap_id.') IS NULL;

DEF skip_if_missing = ' echo skip ';
COL skip_if_missing NEW_V skip_if_missing;
SELECT NULL skip_if_missing FROM DUAL WHERE TO_NUMBER('&&sp_minimum_snap_id.') > -1 AND TO_NUMBER('&&sp_maximum_snap_id.') > -1;

DEF title = 'Memory Size (MEM)';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
DEF abstract = 'Consolidated view of Memory requirements.<br />'
DEF abstract2 = 'It considers AMM if setup, else ASMM if setup, else no memory management settings (individual pools size).<br />'
DEF foot = 'Consider "Giga Bytes (GB)" column for sizing.'
BEGIN
  :sql_text := q'[
WITH
par AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       d.dbid,
       d.name,
       i.inst_id,
       /* LOWER(SUBSTR(i.host_name||'.', 1, INSTR(i.host_name||'.', '.') - 1)) */ 
       LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_name,
       i.instance_number,
       i.instance_name,
       SUM(CASE p.name WHEN 'memory_target' THEN TO_NUMBER(value) END) memory_target,
       SUM(CASE p.name WHEN 'memory_max_target' THEN TO_NUMBER(value) END) memory_max_target,
       SUM(CASE p.name WHEN 'sga_target' THEN TO_NUMBER(value) END) sga_target,
       SUM(CASE p.name WHEN 'sga_max_size' THEN TO_NUMBER(value) END) sga_max_size,
       SUM(CASE p.name WHEN 'pga_aggregate_target' THEN TO_NUMBER(value) END) pga_aggregate_target
  FROM &&gv_object_prefix.instance i,
       &&gv_object_prefix.database d,
       &&gv_object_prefix.system_parameter2 p
 WHERE d.inst_id = i.inst_id
   AND p.inst_id = i.inst_id
   AND p.name IN ('memory_target', 'memory_max_target', 'sga_target', 'sga_max_size', 'pga_aggregate_target')
 GROUP BY
       d.dbid,
       d.name,
       i.inst_id,
       i.host_name,
       i.instance_number,
       i.instance_name
),
sga_max AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       bytes
  FROM &&gv_object_prefix.sgainfo
 WHERE name = 'Maximum SGA Size'
),
pga_max AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       value bytes
  FROM &&gv_object_prefix.pgastat
 WHERE name = 'maximum PGA allocated'
),
pga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.pga_aggregate_target,
       pga_max.bytes max_bytes,
       GREATEST(par.pga_aggregate_target, pga_max.bytes) bytes
  FROM par,
       pga_max
 WHERE par.inst_id = pga_max.inst_id
),
amm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.memory_target,
       par.memory_max_target,
       GREATEST(par.memory_target, par.memory_max_target) + (6 * POWER(2,20)) bytes
  FROM par
),
asmm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.sga_target,
       par.sga_max_size,
       pga.bytes pga_bytes,
       GREATEST(sga_target, sga_max_size) + pga.bytes + (6 * POWER(2,20)) bytes
  FROM par,
       pga
 WHERE par.inst_id = pga.inst_id
),
no_mm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       pga.dbid,
       pga.name,
       pga.inst_id,
       pga.host_name,
       pga.instance_number,
       pga.instance_name,
       sga_max.bytes max_sga,
       pga.bytes max_pga,
       pga.pga_aggregate_target,
       sga_max.bytes + pga.bytes + (5 * POWER(2,20)) bytes
  FROM sga_max,
       pga
 WHERE sga_max.inst_id = pga.inst_id
),
them_all AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       amm.dbid,
       amm.name,
       amm.inst_id,
       amm.host_name,
       amm.instance_number,
       amm.instance_name,
       GREATEST(amm.bytes, asmm.bytes, no_mm.bytes) bytes,
       amm.memory_target,
       amm.memory_max_target,
       asmm.sga_target,
       asmm.sga_max_size,
       no_mm.max_sga,
       no_mm.pga_aggregate_target,
       no_mm.max_pga
  FROM amm,
       asmm,
       no_mm
 WHERE asmm.inst_id = amm.inst_id
   AND no_mm.inst_id = amm.inst_id
 ORDER BY
       amm.inst_id
)
SELECT dbid,
       name,
       host_name,
       instance_number,
       instance_name,
       bytes required,
       CASE 
       WHEN bytes > POWER(2,50) THEN ROUND(bytes/POWER(2,50),3)||' P'
       WHEN bytes > POWER(2,40) THEN ROUND(bytes/POWER(2,40),3)||' T'
       WHEN bytes > POWER(2,30) THEN ROUND(bytes/POWER(2,30),3)||' G'
       WHEN bytes > POWER(2,20) THEN ROUND(bytes/POWER(2,20),3)||' M'
       WHEN bytes > POWER(2,10) THEN ROUND(bytes/POWER(2,10),3)||' K'
       WHEN bytes > 0 THEN bytes||' B' END approx1,
       memory_target,
       CASE 
       WHEN memory_target > POWER(2,50) THEN ROUND(memory_target/POWER(2,50),3)||' P'
       WHEN memory_target > POWER(2,40) THEN ROUND(memory_target/POWER(2,40),3)||' T'
       WHEN memory_target > POWER(2,30) THEN ROUND(memory_target/POWER(2,30),3)||' G'
       WHEN memory_target > POWER(2,20) THEN ROUND(memory_target/POWER(2,20),3)||' M'
       WHEN memory_target > POWER(2,10) THEN ROUND(memory_target/POWER(2,10),3)||' K'
       WHEN memory_target > 0 THEN memory_target||' B' END approx2,
       memory_max_target,
       CASE 
       WHEN memory_max_target > POWER(2,50) THEN ROUND(memory_max_target/POWER(2,50),3)||' P'
       WHEN memory_max_target > POWER(2,40) THEN ROUND(memory_max_target/POWER(2,40),3)||' T'
       WHEN memory_max_target > POWER(2,30) THEN ROUND(memory_max_target/POWER(2,30),3)||' G'
       WHEN memory_max_target > POWER(2,20) THEN ROUND(memory_max_target/POWER(2,20),3)||' M'
       WHEN memory_max_target > POWER(2,10) THEN ROUND(memory_max_target/POWER(2,10),3)||' K'
       WHEN memory_max_target > 0 THEN memory_max_target||' B' END approx3,
       sga_target,
       CASE 
       WHEN sga_target > POWER(2,50) THEN ROUND(sga_target/POWER(2,50),3)||' P'
       WHEN sga_target > POWER(2,40) THEN ROUND(sga_target/POWER(2,40),3)||' T'
       WHEN sga_target > POWER(2,30) THEN ROUND(sga_target/POWER(2,30),3)||' G'
       WHEN sga_target > POWER(2,20) THEN ROUND(sga_target/POWER(2,20),3)||' M'
       WHEN sga_target > POWER(2,10) THEN ROUND(sga_target/POWER(2,10),3)||' K'
       WHEN sga_target > 0 THEN sga_target||' B' END approx4,
       sga_max_size,
       CASE 
       WHEN sga_max_size > POWER(2,50) THEN ROUND(sga_max_size/POWER(2,50),3)||' P'
       WHEN sga_max_size > POWER(2,40) THEN ROUND(sga_max_size/POWER(2,40),3)||' T'
       WHEN sga_max_size > POWER(2,30) THEN ROUND(sga_max_size/POWER(2,30),3)||' G'
       WHEN sga_max_size > POWER(2,20) THEN ROUND(sga_max_size/POWER(2,20),3)||' M'
       WHEN sga_max_size > POWER(2,10) THEN ROUND(sga_max_size/POWER(2,10),3)||' K'
       WHEN sga_max_size > 0 THEN sga_max_size||' B' END approx5,
       max_sga,
       CASE 
       WHEN max_sga > POWER(2,50) THEN ROUND(max_sga/POWER(2,50),3)||' P'
       WHEN max_sga > POWER(2,40) THEN ROUND(max_sga/POWER(2,40),3)||' T'
       WHEN max_sga > POWER(2,30) THEN ROUND(max_sga/POWER(2,30),3)||' G'
       WHEN max_sga > POWER(2,20) THEN ROUND(max_sga/POWER(2,20),3)||' M'
       WHEN max_sga > POWER(2,10) THEN ROUND(max_sga/POWER(2,10),3)||' K'
       WHEN max_sga > 0 THEN max_sga||' B' END approx6,
       pga_aggregate_target,
       CASE 
       WHEN pga_aggregate_target > POWER(2,50) THEN ROUND(pga_aggregate_target/POWER(2,50),3)||' P'
       WHEN pga_aggregate_target > POWER(2,40) THEN ROUND(pga_aggregate_target/POWER(2,40),3)||' T'
       WHEN pga_aggregate_target > POWER(2,30) THEN ROUND(pga_aggregate_target/POWER(2,30),3)||' G'
       WHEN pga_aggregate_target > POWER(2,20) THEN ROUND(pga_aggregate_target/POWER(2,20),3)||' M'
       WHEN pga_aggregate_target > POWER(2,10) THEN ROUND(pga_aggregate_target/POWER(2,10),3)||' K'
       WHEN pga_aggregate_target > 0 THEN pga_aggregate_target||' B' END approx7,
       max_pga,
       CASE
       WHEN max_pga > POWER(2,50) THEN ROUND(max_pga/POWER(2,50),3)||' P'
       WHEN max_pga > POWER(2,40) THEN ROUND(max_pga/POWER(2,40),3)||' T'
       WHEN max_pga > POWER(2,30) THEN ROUND(max_pga/POWER(2,30),3)||' G'
       WHEN max_pga > POWER(2,20) THEN ROUND(max_pga/POWER(2,20),3)||' M'
       WHEN max_pga > POWER(2,10) THEN ROUND(max_pga/POWER(2,10),3)||' K'
       WHEN max_pga > 0 THEN max_pga||' B' END approx8
  FROM them_all
 UNION ALL
SELECT TO_NUMBER(NULL) dbid,
       NULL name,
       NULL host_name,
       TO_NUMBER(NULL) instance_number,
       NULL instance_name,
       SUM(bytes) required,      
       CASE 
       WHEN SUM(bytes) > POWER(2,50) THEN ROUND(SUM(bytes)/POWER(2,50),3)||' P'
       WHEN SUM(bytes) > POWER(2,40) THEN ROUND(SUM(bytes)/POWER(2,40),3)||' T'
       WHEN SUM(bytes) > POWER(2,30) THEN ROUND(SUM(bytes)/POWER(2,30),3)||' G'
       WHEN SUM(bytes) > POWER(2,20) THEN ROUND(SUM(bytes)/POWER(2,20),3)||' M'
       WHEN SUM(bytes) > POWER(2,10) THEN ROUND(SUM(bytes)/POWER(2,10),3)||' K'
       WHEN SUM(bytes) > 0 THEN SUM(bytes)||' B' END approx1,
       SUM(memory_target) memory_target,
       CASE 
       WHEN SUM(memory_target) > POWER(2,50) THEN ROUND(SUM(memory_target)/POWER(2,50),3)||' P'
       WHEN SUM(memory_target) > POWER(2,40) THEN ROUND(SUM(memory_target)/POWER(2,40),3)||' T'
       WHEN SUM(memory_target) > POWER(2,30) THEN ROUND(SUM(memory_target)/POWER(2,30),3)||' G'
       WHEN SUM(memory_target) > POWER(2,20) THEN ROUND(SUM(memory_target)/POWER(2,20),3)||' M'
       WHEN SUM(memory_target) > POWER(2,10) THEN ROUND(SUM(memory_target)/POWER(2,10),3)||' K'
       WHEN SUM(memory_target) > 0 THEN SUM(memory_target)||' B' END approx2,
       SUM(memory_max_target) memory_max_target,
       CASE 
       WHEN SUM(memory_max_target) > POWER(2,50) THEN ROUND(SUM(memory_max_target)/POWER(2,50),3)||' P'
       WHEN SUM(memory_max_target) > POWER(2,40) THEN ROUND(SUM(memory_max_target)/POWER(2,40),3)||' T'
       WHEN SUM(memory_max_target) > POWER(2,30) THEN ROUND(SUM(memory_max_target)/POWER(2,30),3)||' G'
       WHEN SUM(memory_max_target) > POWER(2,20) THEN ROUND(SUM(memory_max_target)/POWER(2,20),3)||' M'
       WHEN SUM(memory_max_target) > POWER(2,10) THEN ROUND(SUM(memory_max_target)/POWER(2,10),3)||' K'
       WHEN SUM(memory_max_target) > 0 THEN SUM(memory_max_target)||' B' END approx3,
       SUM(sga_target) sga_target,
       CASE 
       WHEN SUM(sga_target) > POWER(2,50) THEN ROUND(SUM(sga_target)/POWER(2,50),3)||' P'
       WHEN SUM(sga_target) > POWER(2,40) THEN ROUND(SUM(sga_target)/POWER(2,40),3)||' T'
       WHEN SUM(sga_target) > POWER(2,30) THEN ROUND(SUM(sga_target)/POWER(2,30),3)||' G'
       WHEN SUM(sga_target) > POWER(2,20) THEN ROUND(SUM(sga_target)/POWER(2,20),3)||' M'
       WHEN SUM(sga_target) > POWER(2,10) THEN ROUND(SUM(sga_target)/POWER(2,10),3)||' K'
       WHEN SUM(sga_target) > 0 THEN SUM(sga_target)||' B' END approx4,
       SUM(sga_max_size) sga_max_size,
       CASE
       WHEN SUM(sga_max_size) > POWER(2,50) THEN ROUND(SUM(sga_max_size)/POWER(2,50),3)||' P'
       WHEN SUM(sga_max_size) > POWER(2,40) THEN ROUND(SUM(sga_max_size)/POWER(2,40),3)||' T'
       WHEN SUM(sga_max_size) > POWER(2,30) THEN ROUND(SUM(sga_max_size)/POWER(2,30),3)||' G'
       WHEN SUM(sga_max_size) > POWER(2,20) THEN ROUND(SUM(sga_max_size)/POWER(2,20),3)||' M'
       WHEN SUM(sga_max_size) > POWER(2,10) THEN ROUND(SUM(sga_max_size)/POWER(2,10),3)||' K'
       WHEN SUM(sga_max_size) > 0 THEN SUM(sga_max_size)||' B' END approx5,
       SUM(max_sga) max_sga,
       CASE 
       WHEN SUM(max_sga) > POWER(2,50) THEN ROUND(SUM(max_sga)/POWER(2,50),3)||' P'
       WHEN SUM(max_sga) > POWER(2,40) THEN ROUND(SUM(max_sga)/POWER(2,40),3)||' T'
       WHEN SUM(max_sga) > POWER(2,30) THEN ROUND(SUM(max_sga)/POWER(2,30),3)||' G'
       WHEN SUM(max_sga) > POWER(2,20) THEN ROUND(SUM(max_sga)/POWER(2,20),3)||' M'
       WHEN SUM(max_sga) > POWER(2,10) THEN ROUND(SUM(max_sga)/POWER(2,10),3)||' K'
       WHEN SUM(max_sga) > 0 THEN SUM(max_sga)||' B' END approx6,
       SUM(pga_aggregate_target) pga_aggregate_target,
       CASE 
       WHEN SUM(pga_aggregate_target) > POWER(2,50) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,50),3)||' P'
       WHEN SUM(pga_aggregate_target) > POWER(2,40) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,40),3)||' T'
       WHEN SUM(pga_aggregate_target) > POWER(2,30) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,30),3)||' G'
       WHEN SUM(pga_aggregate_target) > POWER(2,20) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,20),3)||' M'
       WHEN SUM(pga_aggregate_target) > POWER(2,10) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,10),3)||' K'
       WHEN SUM(pga_aggregate_target) > 0 THEN SUM(pga_aggregate_target)||' B' END approx7,
       SUM(max_pga) max_pga,
       CASE 
       WHEN SUM(max_pga) > POWER(2,50) THEN ROUND(SUM(max_pga)/POWER(2,50),3)||' P'
       WHEN SUM(max_pga) > POWER(2,40) THEN ROUND(SUM(max_pga)/POWER(2,40),3)||' T'
       WHEN SUM(max_pga) > POWER(2,30) THEN ROUND(SUM(max_pga)/POWER(2,30),3)||' G'
       WHEN SUM(max_pga) > POWER(2,20) THEN ROUND(SUM(max_pga)/POWER(2,20),3)||' M'
       WHEN SUM(max_pga) > POWER(2,10) THEN ROUND(SUM(max_pga)/POWER(2,10),3)||' K'
       WHEN SUM(max_pga) > 0 THEN SUM(max_pga)||' B' END approx8
  FROM them_all
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Size (statspack)';
DEF main_table = 'STATS$PARAMETER';
DEF abstract = 'Consolidated view of Memory requirements.<br />'
DEF abstract2 = 'It considers AMM if setup, else ASMM if setup, else no memory management settings (individual pools size).<br />'
DEF foot = 'Consider "Giga Bytes (GB)" column for sizing.'
BEGIN
  :sql_text := q'[
WITH
max_snap AS (
SELECT /* ignore if it fails to parse */ /* &&section_id..&&report_sequence. */
       MAX(snap_id) snap_id,
       dbid,
       instance_number,
       name 
  FROM &&statspack_user..stats$parameter
 WHERE 1 = 1
   AND name IN ('memory_target', 'memory_max_target', 'sga_target', 'sga_max_size', 'pga_aggregate_target')
   AND snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
 GROUP BY
       dbid,
       instance_number,
       name
),
last_value AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       s.snap_id,
       s.dbid,
       s.instance_number,
       s.name,
       p.value
  FROM max_snap s,
       &&statspack_user..stats$parameter p
 WHERE p.snap_id = s.snap_id
   AND p.dbid = s.dbid
   AND p.instance_number = s.instance_number
   AND p.name = s.name
   AND p.snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
),
last_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       p.snap_id,
       p.dbid,
       p.instance_number,
       p.name,
       p.value,
       s.startup_time
  FROM last_value p,
       &&statspack_user..stats$snapshot s
 WHERE s.snap_id = p.snap_id
   AND s.dbid = p.dbid
   AND s.instance_number = p.instance_number
   AND s.snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
),
par AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       p.dbid,
       di.db_name,
       /* LOWER(SUBSTR(di.host_name||'.', 1, INSTR(di.host_name||'.', '.') - 1)) */ 
       LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_name,
       p.instance_number,
       di.instance_name,
       SUM(CASE p.name WHEN 'memory_target' THEN TO_NUMBER(p.value) ELSE 0 END) memory_target,
       SUM(CASE p.name WHEN 'memory_max_target' THEN TO_NUMBER(p.value) ELSE 0 END) memory_max_target,
       SUM(CASE p.name WHEN 'sga_target' THEN TO_NUMBER(p.value) ELSE 0 END) sga_target,
       SUM(CASE p.name WHEN 'sga_max_size' THEN TO_NUMBER(p.value) ELSE 0 END) sga_max_size,
       SUM(CASE p.name WHEN 'pga_aggregate_target' THEN TO_NUMBER(p.value) ELSE 0 END) pga_aggregate_target
  FROM last_snap p,
       &&statspack_user..stats$database_instance di
 WHERE di.dbid = p.dbid
   AND di.instance_number = p.instance_number
   AND di.startup_time = p.startup_time
 GROUP BY
       p.dbid,
       di.db_name,
       di.host_name,
       p.instance_number,
       di.instance_name
),
sgainfo AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(value) sga_size
  FROM &&statspack_user..stats$sga
 WHERE 1=1
   AND snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
sga_max AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       instance_number,
       MAX(sga_size) bytes
  FROM sgainfo
 GROUP BY
       dbid,
       instance_number
),
pga_max AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       instance_number,
       MAX(value) bytes
  FROM &&statspack_user..stats$pgastat
 WHERE 1=1
   AND name = 'maximum PGA allocated'
   AND snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
 GROUP BY
       dbid,
       instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.pga_aggregate_target,
       pga_max.bytes max_bytes,
       GREATEST(par.pga_aggregate_target, pga_max.bytes) bytes
  FROM pga_max,
       par
 WHERE par.dbid = pga_max.dbid
   AND par.instance_number = pga_max.instance_number
),
amm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.memory_target,
       par.memory_max_target,
       GREATEST(par.memory_target, par.memory_max_target) + (6 * POWER(2,20)) bytes
  FROM par
),
asmm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.sga_target,
       par.sga_max_size,
       pga.bytes pga_bytes,
       GREATEST(sga_target, sga_max_size) + pga.bytes + (6 * POWER(2,20)) bytes
  FROM pga,
       par
 WHERE par.dbid = pga.dbid
   AND par.instance_number = pga.instance_number
),
no_mm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       pga.dbid,
       pga.db_name,
       pga.host_name,
       pga.instance_number,
       pga.instance_name,
       sga_max.bytes max_sga,
       pga.bytes max_pga,
       pga.pga_aggregate_target,
       sga_max.bytes + pga.bytes + (5 * POWER(2,20)) bytes
  FROM pga,
       sga_max
 WHERE sga_max.dbid = pga.dbid
   AND sga_max.instance_number = pga.instance_number
),
them_all AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       amm.dbid,
       amm.db_name,
       amm.host_name,
       amm.instance_number,
       amm.instance_name,
       GREATEST(amm.bytes, asmm.bytes, no_mm.bytes) bytes,
       amm.memory_target,
       amm.memory_max_target,
       asmm.sga_target,
       asmm.sga_max_size,
       no_mm.max_sga,
       no_mm.pga_aggregate_target,
       no_mm.max_pga
  FROM amm,
       asmm,
       no_mm
 WHERE asmm.instance_number = amm.instance_number
   AND asmm.dbid = amm.dbid
   AND no_mm.instance_number = amm.instance_number
   AND no_mm.dbid = amm.dbid
 ORDER BY
       amm.dbid,
       amm.instance_number
)
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       bytes required,
       CASE 
       WHEN bytes > POWER(2,50) THEN ROUND(bytes/POWER(2,50),3)||' P'
       WHEN bytes > POWER(2,40) THEN ROUND(bytes/POWER(2,40),3)||' T'
       WHEN bytes > POWER(2,30) THEN ROUND(bytes/POWER(2,30),3)||' G'
       WHEN bytes > POWER(2,20) THEN ROUND(bytes/POWER(2,20),3)||' M'
       WHEN bytes > POWER(2,10) THEN ROUND(bytes/POWER(2,10),3)||' K'
       WHEN bytes > 0 THEN bytes||' B' END approx1,
       memory_target,
       CASE 
       WHEN memory_target > POWER(2,50) THEN ROUND(memory_target/POWER(2,50),3)||' P'
       WHEN memory_target > POWER(2,40) THEN ROUND(memory_target/POWER(2,40),3)||' T'
       WHEN memory_target > POWER(2,30) THEN ROUND(memory_target/POWER(2,30),3)||' G'
       WHEN memory_target > POWER(2,20) THEN ROUND(memory_target/POWER(2,20),3)||' M'
       WHEN memory_target > POWER(2,10) THEN ROUND(memory_target/POWER(2,10),3)||' K'
       WHEN memory_target > 0 THEN memory_target||' B' END approx2,
       memory_max_target,
       CASE 
       WHEN memory_max_target > POWER(2,50) THEN ROUND(memory_max_target/POWER(2,50),3)||' P'
       WHEN memory_max_target > POWER(2,40) THEN ROUND(memory_max_target/POWER(2,40),3)||' T'
       WHEN memory_max_target > POWER(2,30) THEN ROUND(memory_max_target/POWER(2,30),3)||' G'
       WHEN memory_max_target > POWER(2,20) THEN ROUND(memory_max_target/POWER(2,20),3)||' M'
       WHEN memory_max_target > POWER(2,10) THEN ROUND(memory_max_target/POWER(2,10),3)||' K'
       WHEN memory_max_target > 0 THEN memory_max_target||' B' END approx3,
       sga_target,
       CASE 
       WHEN sga_target > POWER(2,50) THEN ROUND(sga_target/POWER(2,50),3)||' P'
       WHEN sga_target > POWER(2,40) THEN ROUND(sga_target/POWER(2,40),3)||' T'
       WHEN sga_target > POWER(2,30) THEN ROUND(sga_target/POWER(2,30),3)||' G'
       WHEN sga_target > POWER(2,20) THEN ROUND(sga_target/POWER(2,20),3)||' M'
       WHEN sga_target > POWER(2,10) THEN ROUND(sga_target/POWER(2,10),3)||' K'
       WHEN sga_target > 0 THEN sga_target||' B' END approx4,
       sga_max_size,
       CASE 
       WHEN sga_max_size > POWER(2,50) THEN ROUND(sga_max_size/POWER(2,50),3)||' P'
       WHEN sga_max_size > POWER(2,40) THEN ROUND(sga_max_size/POWER(2,40),3)||' T'
       WHEN sga_max_size > POWER(2,30) THEN ROUND(sga_max_size/POWER(2,30),3)||' G'
       WHEN sga_max_size > POWER(2,20) THEN ROUND(sga_max_size/POWER(2,20),3)||' M'
       WHEN sga_max_size > POWER(2,10) THEN ROUND(sga_max_size/POWER(2,10),3)||' K'
       WHEN sga_max_size > 0 THEN sga_max_size||' B' END approx5,
       max_sga,
       CASE 
       WHEN max_sga > POWER(2,50) THEN ROUND(max_sga/POWER(2,50),3)||' P'
       WHEN max_sga > POWER(2,40) THEN ROUND(max_sga/POWER(2,40),3)||' T'
       WHEN max_sga > POWER(2,30) THEN ROUND(max_sga/POWER(2,30),3)||' G'
       WHEN max_sga > POWER(2,20) THEN ROUND(max_sga/POWER(2,20),3)||' M'
       WHEN max_sga > POWER(2,10) THEN ROUND(max_sga/POWER(2,10),3)||' K'
       WHEN max_sga > 0 THEN max_sga||' B' END approx6,
       pga_aggregate_target,
       CASE 
       WHEN pga_aggregate_target > POWER(2,50) THEN ROUND(pga_aggregate_target/POWER(2,50),3)||' P'
       WHEN pga_aggregate_target > POWER(2,40) THEN ROUND(pga_aggregate_target/POWER(2,40),3)||' T'
       WHEN pga_aggregate_target > POWER(2,30) THEN ROUND(pga_aggregate_target/POWER(2,30),3)||' G'
       WHEN pga_aggregate_target > POWER(2,20) THEN ROUND(pga_aggregate_target/POWER(2,20),3)||' M'
       WHEN pga_aggregate_target > POWER(2,10) THEN ROUND(pga_aggregate_target/POWER(2,10),3)||' K'
       WHEN pga_aggregate_target > 0 THEN pga_aggregate_target||' B' END approx7,
       max_pga,
       CASE
       WHEN max_pga > POWER(2,50) THEN ROUND(max_pga/POWER(2,50),3)||' P'
       WHEN max_pga > POWER(2,40) THEN ROUND(max_pga/POWER(2,40),3)||' T'
       WHEN max_pga > POWER(2,30) THEN ROUND(max_pga/POWER(2,30),3)||' G'
       WHEN max_pga > POWER(2,20) THEN ROUND(max_pga/POWER(2,20),3)||' M'
       WHEN max_pga > POWER(2,10) THEN ROUND(max_pga/POWER(2,10),3)||' K'
       WHEN max_pga > 0 THEN max_pga||' B' END approx8
  FROM them_all
 UNION ALL
SELECT TO_NUMBER(NULL) dbid,
       NULL db_name,
       NULL host_name,
       TO_NUMBER(NULL) instance_number,
       NULL instance_name,
       SUM(bytes) required,      
       CASE 
       WHEN SUM(bytes) > POWER(2,50) THEN ROUND(SUM(bytes)/POWER(2,50),3)||' P'
       WHEN SUM(bytes) > POWER(2,40) THEN ROUND(SUM(bytes)/POWER(2,40),3)||' T'
       WHEN SUM(bytes) > POWER(2,30) THEN ROUND(SUM(bytes)/POWER(2,30),3)||' G'
       WHEN SUM(bytes) > POWER(2,20) THEN ROUND(SUM(bytes)/POWER(2,20),3)||' M'
       WHEN SUM(bytes) > POWER(2,10) THEN ROUND(SUM(bytes)/POWER(2,10),3)||' K'
       WHEN SUM(bytes) > 0 THEN SUM(bytes)||' B' END approx1,
       SUM(memory_target) memory_target,
       CASE 
       WHEN SUM(memory_target) > POWER(2,50) THEN ROUND(SUM(memory_target)/POWER(2,50),3)||' P'
       WHEN SUM(memory_target) > POWER(2,40) THEN ROUND(SUM(memory_target)/POWER(2,40),3)||' T'
       WHEN SUM(memory_target) > POWER(2,30) THEN ROUND(SUM(memory_target)/POWER(2,30),3)||' G'
       WHEN SUM(memory_target) > POWER(2,20) THEN ROUND(SUM(memory_target)/POWER(2,20),3)||' M'
       WHEN SUM(memory_target) > POWER(2,10) THEN ROUND(SUM(memory_target)/POWER(2,10),3)||' K'
       WHEN SUM(memory_target) > 0 THEN SUM(memory_target)||' B' END approx2,
       SUM(memory_max_target) memory_max_target,
       CASE 
       WHEN SUM(memory_max_target) > POWER(2,50) THEN ROUND(SUM(memory_max_target)/POWER(2,50),3)||' P'
       WHEN SUM(memory_max_target) > POWER(2,40) THEN ROUND(SUM(memory_max_target)/POWER(2,40),3)||' T'
       WHEN SUM(memory_max_target) > POWER(2,30) THEN ROUND(SUM(memory_max_target)/POWER(2,30),3)||' G'
       WHEN SUM(memory_max_target) > POWER(2,20) THEN ROUND(SUM(memory_max_target)/POWER(2,20),3)||' M'
       WHEN SUM(memory_max_target) > POWER(2,10) THEN ROUND(SUM(memory_max_target)/POWER(2,10),3)||' K'
       WHEN SUM(memory_max_target) > 0 THEN SUM(memory_max_target)||' B' END approx3,
       SUM(sga_target) sga_target,
       CASE 
       WHEN SUM(sga_target) > POWER(2,50) THEN ROUND(SUM(sga_target)/POWER(2,50),3)||' P'
       WHEN SUM(sga_target) > POWER(2,40) THEN ROUND(SUM(sga_target)/POWER(2,40),3)||' T'
       WHEN SUM(sga_target) > POWER(2,30) THEN ROUND(SUM(sga_target)/POWER(2,30),3)||' G'
       WHEN SUM(sga_target) > POWER(2,20) THEN ROUND(SUM(sga_target)/POWER(2,20),3)||' M'
       WHEN SUM(sga_target) > POWER(2,10) THEN ROUND(SUM(sga_target)/POWER(2,10),3)||' K'
       WHEN SUM(sga_target) > 0 THEN SUM(sga_target)||' B' END approx4,
       SUM(sga_max_size) sga_max_size,
       CASE
       WHEN SUM(sga_max_size) > POWER(2,50) THEN ROUND(SUM(sga_max_size)/POWER(2,50),3)||' P'
       WHEN SUM(sga_max_size) > POWER(2,40) THEN ROUND(SUM(sga_max_size)/POWER(2,40),3)||' T'
       WHEN SUM(sga_max_size) > POWER(2,30) THEN ROUND(SUM(sga_max_size)/POWER(2,30),3)||' G'
       WHEN SUM(sga_max_size) > POWER(2,20) THEN ROUND(SUM(sga_max_size)/POWER(2,20),3)||' M'
       WHEN SUM(sga_max_size) > POWER(2,10) THEN ROUND(SUM(sga_max_size)/POWER(2,10),3)||' K'
       WHEN SUM(sga_max_size) > 0 THEN SUM(sga_max_size)||' B' END approx5,
       SUM(max_sga) max_sga,
       CASE 
       WHEN SUM(max_sga) > POWER(2,50) THEN ROUND(SUM(max_sga)/POWER(2,50),3)||' P'
       WHEN SUM(max_sga) > POWER(2,40) THEN ROUND(SUM(max_sga)/POWER(2,40),3)||' T'
       WHEN SUM(max_sga) > POWER(2,30) THEN ROUND(SUM(max_sga)/POWER(2,30),3)||' G'
       WHEN SUM(max_sga) > POWER(2,20) THEN ROUND(SUM(max_sga)/POWER(2,20),3)||' M'
       WHEN SUM(max_sga) > POWER(2,10) THEN ROUND(SUM(max_sga)/POWER(2,10),3)||' K'
       WHEN SUM(max_sga) > 0 THEN SUM(max_sga)||' B' END approx6,
       SUM(pga_aggregate_target) pga_aggregate_target,
       CASE 
       WHEN SUM(pga_aggregate_target) > POWER(2,50) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,50),3)||' P'
       WHEN SUM(pga_aggregate_target) > POWER(2,40) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,40),3)||' T'
       WHEN SUM(pga_aggregate_target) > POWER(2,30) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,30),3)||' G'
       WHEN SUM(pga_aggregate_target) > POWER(2,20) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,20),3)||' M'
       WHEN SUM(pga_aggregate_target) > POWER(2,10) THEN ROUND(SUM(pga_aggregate_target)/POWER(2,10),3)||' K'
       WHEN SUM(pga_aggregate_target) > 0 THEN SUM(pga_aggregate_target)||' B' END approx7,
       SUM(max_pga) max_pga,
       CASE 
       WHEN SUM(max_pga) > POWER(2,50) THEN ROUND(SUM(max_pga)/POWER(2,50),3)||' P'
       WHEN SUM(max_pga) > POWER(2,40) THEN ROUND(SUM(max_pga)/POWER(2,40),3)||' T'
       WHEN SUM(max_pga) > POWER(2,30) THEN ROUND(SUM(max_pga)/POWER(2,30),3)||' G'
       WHEN SUM(max_pga) > POWER(2,20) THEN ROUND(SUM(max_pga)/POWER(2,20),3)||' M'
       WHEN SUM(max_pga) > POWER(2,10) THEN ROUND(SUM(max_pga)/POWER(2,10),3)||' K'
       WHEN SUM(max_pga) > 0 THEN SUM(max_pga)||' B' END approx8
  FROM them_all
]';
END;
/
@@&&skip_if_missing.edb360_9a_pre_one.sql

DEF title = 'Database Size on Disk';
DEF main_table = '&&gv_view_prefix.DATABASE';
DEF abstract = 'Displays Space on Disk including datafiles, tempfiles, log and control files.<br />'
DEF foot = 'Consider "Tera Bytes (TB)" column for sizing.'
BEGIN
  :sql_text := q'[
WITH 
sizes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       'Data' file_type,
       SUM(bytes) bytes
  FROM &&v_object_prefix.datafile
 UNION ALL
SELECT 'Temp' file_type,
       SUM(bytes) bytes
  FROM &&v_object_prefix.tempfile
 UNION ALL
SELECT 'Log' file_type,
       SUM(bytes) * MAX(members) bytes
  FROM &&v_object_prefix.log
 UNION ALL
SELECT 'Control' file_type,
       SUM(block_size * file_size_blks) bytes
  FROM &&v_object_prefix.controlfile
),
dbsize AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       'Total' file_type,
       SUM(bytes) bytes
  FROM sizes
)
SELECT d.dbid,
       d.name db_name,
       s.file_type,
       s.bytes,
       CASE 
       WHEN s.bytes > POWER(10,15) THEN ROUND(s.bytes/POWER(10,15),3)||' P'
       WHEN s.bytes > POWER(10,12) THEN ROUND(s.bytes/POWER(10,12),3)||' T'
       WHEN s.bytes > POWER(10,9) THEN ROUND(s.bytes/POWER(10,9),3)||' G'
       WHEN s.bytes > POWER(10,6) THEN ROUND(s.bytes/POWER(10,6),3)||' M'
       WHEN s.bytes > POWER(10,3) THEN ROUND(s.bytes/POWER(10,3),3)||' K'
       WHEN s.bytes > 0 THEN s.bytes||' B' END approx
  FROM &&v_object_prefix.database d,
       sizes s
 UNION ALL
SELECT d.dbid,
       d.name db_name,
       s.file_type,
       s.bytes,
       CASE 
       WHEN s.bytes > POWER(10,15) THEN ROUND(s.bytes/POWER(10,15),3)||' P'
       WHEN s.bytes > POWER(10,12) THEN ROUND(s.bytes/POWER(10,12),3)||' T'
       WHEN s.bytes > POWER(10,9) THEN ROUND(s.bytes/POWER(10,9),3)||' G'
       WHEN s.bytes > POWER(10,6) THEN ROUND(s.bytes/POWER(10,6),3)||' M'
       WHEN s.bytes > POWER(10,3) THEN ROUND(s.bytes/POWER(10,3),3)||' K'
       WHEN s.bytes > 0 THEN s.bytes||' B' END approx
  FROM &&v_object_prefix.database d,
       dbsize s
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'IOPS and MBPS';
DEF main_table = 'STATS$SYSSTAT';
DEF abstract = 'I/O Operations per Second (IOPS) and I/O Mega Bytes per Second (MBPS). Includes Peak (max), percentiles and average for read (R), write (W) and read+write (RW) operations.<br />'
DEF foot = 'Consider Peak or high Percentile for sizing.'
BEGIN
  :sql_text := q'[
WITH 
sysstat_io AS (
SELECT /* ignore if it fails to parse */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE WHEN name = 'physical read total IO requests' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN name IN ('physical write total IO requests', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN name = 'physical read total bytes' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN name IN ('physical write total bytes', 'redo size') THEN value ELSE 0 END) w_bytes
  FROM &&statspack_user..stats$sysstat
 WHERE 1=1
   AND snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
   AND name IN ('physical read total IO requests', 'physical write total IO requests', 'redo writes', 'physical read total bytes', 'physical write total bytes', 'redo size')
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
snaps AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       --begin_interval_time, lag(snapshot_time) over (order by snap_id)
       lag(snap_time) over (order by snap_id) begin_interval_time,
       --end_interval_time,   -- these fields do not exist
       snap_time end_interval_time,
       --((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 24 * 60 * 60) elapsed_sec, -- NA
       nvl(((snap_time - lag(snap_time) over (order by snap_id)) * 24 * 60 * 60),0) elapsed_sec,
       startup_time
  FROM &&statspack_user..stats$snapshot
 WHERE 1=1
   AND snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
),
rw_per_snap_and_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       t1.snap_id,
       t1.dbid,
       t1.instance_number,
       di.instance_name,
       di.db_name,
       /* LOWER(SUBSTR(di.host_name||'.', 1, INSTR(di.host_name||'.', '.') - 1)) */ 
       LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_name,
       ROUND((t1.r_reqs - t0.r_reqs) / s1.elapsed_sec) r_iops,
       ROUND((t1.w_reqs - t0.w_reqs) / s1.elapsed_sec) w_iops,
       ROUND((t1.r_bytes - t0.r_bytes) / POWER(10,6) / s1.elapsed_sec) r_mbps,
       ROUND((t1.w_bytes - t0.w_bytes) / POWER(10,6)/ s1.elapsed_sec) w_mbps
  FROM sysstat_io t0,
       sysstat_io t1,
       snaps s0,
       snaps s1,
       &&statspack_user..stats$database_instance di
 WHERE 1=1
   AND t1.snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
   AND t1.snap_id = t0.snap_id + 1
   AND t1.dbid = t0.dbid
   AND t1.instance_number = t0.instance_number
   AND s0.snap_id = t0.snap_id
   AND s0.dbid = t0.dbid
   AND s0.instance_number = t0.instance_number
   AND s1.snap_id = t1.snap_id
   AND s1.dbid = t1.dbid
   AND s1.instance_number = t1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.elapsed_sec > 60 -- ignore snaps too close
   AND di.dbid = s1.dbid
   AND di.instance_number = s1.instance_number
   AND di.startup_time = s1.startup_time
),
rw_per_snap_and_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       db_name,
       SUM(r_iops) r_iops,
       SUM(w_iops) w_iops,
       SUM(r_mbps) r_mbps,
       SUM(w_mbps) w_mbps
  FROM rw_per_snap_and_inst
 GROUP BY
       snap_id,
       dbid,
       db_name
),
rw_max_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       instance_number,
       instance_name,
       db_name,
       host_name,
       MAX(r_iops + w_iops) peak_rw_iops,
       MAX(r_mbps + w_mbps) peak_rw_mbps,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_99_99_rw_iops,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_99_99_rw_mbps,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_99_9_rw_iops,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_99_9_rw_mbps,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_99_rw_iops,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_99_rw_mbps,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_95_rw_iops,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_95_rw_mbps,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_90_rw_iops,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_90_rw_mbps,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_75_rw_iops,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_75_rw_mbps,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_50_rw_iops,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_50_rw_mbps,
       ROUND(AVG(r_iops + w_iops)) avg_rw_iops,
       ROUND(AVG(r_mbps + w_mbps)) avg_rw_mbps,
       ROUND(AVG(r_iops)) avg_r_iops,
       ROUND(AVG(w_iops)) avg_w_iops,
       ROUND(AVG(r_mbps)) avg_r_mbps,
       ROUND(AVG(w_mbps)) avg_w_mbps
  FROM rw_per_snap_and_inst
 GROUP BY
       dbid,
       instance_number,
       instance_name,
       db_name,
       host_name
),
rw_max_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       db_name,
       MAX(r_iops + w_iops) peak_rw_iops,
       MAX(r_mbps + w_mbps) peak_rw_mbps,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_99_99_rw_iops,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_99_99_rw_mbps,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_99_9_rw_iops,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_99_9_rw_mbps,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_99_rw_iops,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_99_rw_mbps,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_95_rw_iops,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_95_rw_mbps,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_90_rw_iops,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_90_rw_mbps,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_75_rw_iops,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_75_rw_mbps,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_50_rw_iops,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_50_rw_mbps,
       ROUND(AVG(r_iops + w_iops)) avg_rw_iops,
       ROUND(AVG(r_mbps + w_mbps)) avg_rw_mbps,
       ROUND(AVG(r_iops)) avg_r_iops,
       ROUND(AVG(w_iops)) avg_w_iops,
       ROUND(AVG(r_mbps)) avg_r_mbps,
       ROUND(AVG(w_mbps)) avg_w_mbps
  FROM rw_per_snap_and_cluster
 GROUP BY
       dbid,
       db_name
),
peak_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops peak_r_iops,
       r.w_iops peak_w_iops,
       m.peak_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.peak_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
peak_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps peak_r_mbps,
       r.w_mbps peak_w_mbps,
       m.peak_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.peak_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_99_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_99_99_r_iops,
       r.w_iops perc_99_99_w_iops,
       m.perc_99_99_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_99_99_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_99_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_99_99_r_mbps,
       r.w_mbps perc_99_99_w_mbps,
       m.perc_99_99_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_99_99_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_9_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_99_9_r_iops,
       r.w_iops perc_99_9_w_iops,
       m.perc_99_9_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_99_9_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_9_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_99_9_r_mbps,
       r.w_mbps perc_99_9_w_mbps,
       m.perc_99_9_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_99_9_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_99_r_iops,
       r.w_iops perc_99_w_iops,
       m.perc_99_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_99_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_99_r_mbps,
       r.w_mbps perc_99_w_mbps,
       m.perc_99_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_99_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_95_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_95_r_iops,
       r.w_iops perc_95_w_iops,
       m.perc_95_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_95_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_95_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_95_r_mbps,
       r.w_mbps perc_95_w_mbps,
       m.perc_95_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_95_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_90_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_90_r_iops,
       r.w_iops perc_90_w_iops,
       m.perc_90_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_90_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_90_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_90_r_mbps,
       r.w_mbps perc_90_w_mbps,
       m.perc_90_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_90_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_75_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_75_r_iops,
       r.w_iops perc_75_w_iops,
       m.perc_75_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_75_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_75_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_75_r_mbps,
       r.w_mbps perc_75_w_mbps,
       m.perc_75_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_75_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_50_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_50_r_iops,
       r.w_iops perc_50_w_iops,
       m.perc_50_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_50_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_50_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_50_r_mbps,
       r.w_mbps perc_50_w_mbps,
       m.perc_50_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_50_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
peak_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_iops peak_r_iops,
       r.w_iops peak_w_iops,
       m.peak_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.peak_rw_iops
   AND r.dbid = m.dbid
),
peak_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_mbps peak_r_mbps,
       r.w_mbps peak_w_mbps,
       m.peak_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.peak_rw_mbps
   AND r.dbid = m.dbid
),
perc_99_99_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_99_99_r_iops,
       r.w_iops perc_99_99_w_iops,
       m.perc_99_99_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_99_99_rw_iops
   AND r.dbid = m.dbid
),
perc_99_99_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_99_99_r_mbps,
       r.w_mbps perc_99_99_w_mbps,
       m.perc_99_99_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_99_99_rw_mbps
   AND r.dbid = m.dbid
),
perc_99_9_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_99_9_r_iops,
       r.w_iops perc_99_9_w_iops,
       m.perc_99_9_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_99_9_rw_iops
   AND r.dbid = m.dbid
),
perc_99_9_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_99_9_r_mbps,
       r.w_mbps perc_99_9_w_mbps,
       m.perc_99_9_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_99_9_rw_mbps
   AND r.dbid = m.dbid
),
perc_99_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_99_r_iops,
       r.w_iops perc_99_w_iops,
       m.perc_99_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_99_rw_iops
   AND r.dbid = m.dbid
),
perc_99_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_99_r_mbps,
       r.w_mbps perc_99_w_mbps,
       m.perc_99_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_99_rw_mbps
   AND r.dbid = m.dbid
),
perc_95_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_95_r_iops,
       r.w_iops perc_95_w_iops,
       m.perc_95_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_95_rw_iops
   AND r.dbid = m.dbid
),
perc_95_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_95_r_mbps,
       r.w_mbps perc_95_w_mbps,
       m.perc_95_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_95_rw_mbps
   AND r.dbid = m.dbid
),
perc_90_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_90_r_iops,
       r.w_iops perc_90_w_iops,
       m.perc_90_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_90_rw_iops
   AND r.dbid = m.dbid
),
perc_90_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_90_r_mbps,
       r.w_mbps perc_90_w_mbps,
       m.perc_90_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_90_rw_mbps
   AND r.dbid = m.dbid
),
perc_75_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_75_r_iops,
       r.w_iops perc_75_w_iops,
       m.perc_75_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_75_rw_iops
   AND r.dbid = m.dbid
),
perc_75_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_75_r_mbps,
       r.w_mbps perc_75_w_mbps,
       m.perc_75_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_75_rw_mbps
   AND r.dbid = m.dbid
),
perc_50_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_50_r_iops,
       r.w_iops perc_50_w_iops,
       m.perc_50_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_50_rw_iops
   AND r.dbid = m.dbid
),
perc_50_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_50_r_mbps,
       r.w_mbps perc_50_w_mbps,
       m.perc_50_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_50_rw_mbps
   AND r.dbid = m.dbid
),
per_instance AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       x.dbid,
       x.db_name,
       x.instance_number,
       x.instance_name,
       x.host_name,
       x.peak_rw_iops,
       (SELECT i.peak_r_iops FROM peak_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) peak_r_iops,
       (SELECT i.peak_w_iops FROM peak_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) peak_w_iops,
       x.peak_rw_mbps,       
       (SELECT m.peak_r_mbps FROM peak_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) peak_r_mbps,
       (SELECT m.peak_w_mbps FROM peak_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) peak_w_mbps,
       x.perc_99_99_rw_iops,
       (SELECT i.perc_99_99_r_iops FROM perc_99_99_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_99_99_r_iops,
       (SELECT i.perc_99_99_w_iops FROM perc_99_99_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_99_99_w_iops,
       x.perc_99_99_rw_mbps,       
       (SELECT m.perc_99_99_r_mbps FROM perc_99_99_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_99_99_r_mbps,
       (SELECT m.perc_99_99_w_mbps FROM perc_99_99_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_99_99_w_mbps,
       x.perc_99_9_rw_iops,
       (SELECT i.perc_99_9_r_iops FROM perc_99_9_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_99_9_r_iops,
       (SELECT i.perc_99_9_w_iops FROM perc_99_9_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_99_9_w_iops,
       x.perc_99_9_rw_mbps,       
       (SELECT m.perc_99_9_r_mbps FROM perc_99_9_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_99_9_r_mbps,
       (SELECT m.perc_99_9_w_mbps FROM perc_99_9_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_99_9_w_mbps,
       x.perc_99_rw_iops,
       (SELECT i.perc_99_r_iops FROM perc_99_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_99_r_iops,
       (SELECT i.perc_99_w_iops FROM perc_99_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_99_w_iops,
       x.perc_99_rw_mbps,       
       (SELECT m.perc_99_r_mbps FROM perc_99_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_99_r_mbps,
       (SELECT m.perc_99_w_mbps FROM perc_99_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_99_w_mbps,
       x.perc_95_rw_iops,
       (SELECT i.perc_95_r_iops FROM perc_95_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_95_r_iops,
       (SELECT i.perc_95_w_iops FROM perc_95_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_95_w_iops,
       x.perc_95_rw_mbps,       
       (SELECT m.perc_95_r_mbps FROM perc_95_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_95_r_mbps,
       (SELECT m.perc_95_w_mbps FROM perc_95_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_95_w_mbps,
       x.perc_90_rw_iops,
       (SELECT i.perc_90_r_iops FROM perc_90_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_90_r_iops,
       (SELECT i.perc_90_w_iops FROM perc_90_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_90_w_iops,
       x.perc_90_rw_mbps,       
       (SELECT m.perc_90_r_mbps FROM perc_90_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_90_r_mbps,
       (SELECT m.perc_90_w_mbps FROM perc_90_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_90_w_mbps,
       x.perc_75_rw_iops,
       (SELECT i.perc_75_r_iops FROM perc_75_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_75_r_iops,
       (SELECT i.perc_75_w_iops FROM perc_75_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_75_w_iops,
       x.perc_75_rw_mbps,       
       (SELECT m.perc_75_r_mbps FROM perc_75_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_75_r_mbps,
       (SELECT m.perc_75_w_mbps FROM perc_75_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_75_w_mbps,
       x.perc_50_rw_iops,
       (SELECT i.perc_50_r_iops FROM perc_50_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_50_r_iops,
       (SELECT i.perc_50_w_iops FROM perc_50_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_50_w_iops,
       x.perc_50_rw_mbps,       
       (SELECT m.perc_50_r_mbps FROM perc_50_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_50_r_mbps,
       (SELECT m.perc_50_w_mbps FROM perc_50_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_50_w_mbps,
       x.avg_rw_iops,
       x.avg_r_iops,
       x.avg_w_iops,
       x.avg_rw_mbps,
       x.avg_r_mbps,
       x.avg_w_mbps
  FROM rw_max_per_inst x
 ORDER BY
       x.dbid,
       x.instance_number
),
per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       x.dbid,
       x.db_name,
       TO_NUMBER(NULL) instance_number,
       NULL instance_name,
       NULL host_name,
       x.peak_rw_iops,
       (SELECT i.peak_r_iops FROM peak_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) peak_r_iops,
       (SELECT i.peak_w_iops FROM peak_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) peak_w_iops,
       x.peak_rw_mbps,       
       (SELECT m.peak_r_mbps FROM peak_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) peak_r_mbps,
       (SELECT m.peak_w_mbps FROM peak_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) peak_w_mbps,
       x.perc_99_99_rw_iops,
       (SELECT i.perc_99_99_r_iops FROM perc_99_99_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_99_99_r_iops,
       (SELECT i.perc_99_99_w_iops FROM perc_99_99_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_99_99_w_iops,
       x.perc_99_99_rw_mbps,       
       (SELECT m.perc_99_99_r_mbps FROM perc_99_99_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_99_99_r_mbps,
       (SELECT m.perc_99_99_w_mbps FROM perc_99_99_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_99_99_w_mbps,
       x.perc_99_9_rw_iops,
       (SELECT i.perc_99_9_r_iops FROM perc_99_9_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_99_9_r_iops,
       (SELECT i.perc_99_9_w_iops FROM perc_99_9_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_99_9_w_iops,
       x.perc_99_9_rw_mbps,       
       (SELECT m.perc_99_9_r_mbps FROM perc_99_9_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_99_9_r_mbps,
       (SELECT m.perc_99_9_w_mbps FROM perc_99_9_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_99_9_w_mbps,
       x.perc_99_rw_iops,
       (SELECT i.perc_99_r_iops FROM perc_99_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_99_r_iops,
       (SELECT i.perc_99_w_iops FROM perc_99_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_99_w_iops,
       x.perc_99_rw_mbps,       
       (SELECT m.perc_99_r_mbps FROM perc_99_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_99_r_mbps,
       (SELECT m.perc_99_w_mbps FROM perc_99_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_99_w_mbps,
       x.perc_95_rw_iops,
       (SELECT i.perc_95_r_iops FROM perc_95_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_95_r_iops,
       (SELECT i.perc_95_w_iops FROM perc_95_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_95_w_iops,
       x.perc_95_rw_mbps,       
       (SELECT m.perc_95_r_mbps FROM perc_95_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_95_r_mbps,
       (SELECT m.perc_95_w_mbps FROM perc_95_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_95_w_mbps,
       x.perc_90_rw_iops,
       (SELECT i.perc_90_r_iops FROM perc_90_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_90_r_iops,
       (SELECT i.perc_90_w_iops FROM perc_90_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_90_w_iops,
       x.perc_90_rw_mbps,       
       (SELECT m.perc_90_r_mbps FROM perc_90_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_90_r_mbps,
       (SELECT m.perc_90_w_mbps FROM perc_90_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_90_w_mbps,
       x.perc_75_rw_iops,
       (SELECT i.perc_75_r_iops FROM perc_75_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_75_r_iops,
       (SELECT i.perc_75_w_iops FROM perc_75_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_75_w_iops,
       x.perc_75_rw_mbps,       
       (SELECT m.perc_75_r_mbps FROM perc_75_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_75_r_mbps,
       (SELECT m.perc_75_w_mbps FROM perc_75_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_75_w_mbps,
       x.perc_50_rw_iops,
       (SELECT i.perc_50_r_iops FROM perc_50_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_50_r_iops,
       (SELECT i.perc_50_w_iops FROM perc_50_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_50_w_iops,
       x.perc_50_rw_mbps,       
       (SELECT m.perc_50_r_mbps FROM perc_50_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_50_r_mbps,
       (SELECT m.perc_50_w_mbps FROM perc_50_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_50_w_mbps,
       x.avg_rw_iops,
       x.avg_r_iops,
       x.avg_w_iops,
       x.avg_rw_mbps,
       x.avg_r_mbps,
       x.avg_w_mbps
  FROM rw_max_per_cluster x
)
SELECT * FROM per_instance
 UNION ALL
SELECT * FROM per_cluster
]';
END;
/
@@&&skip_if_missing.edb360_9a_pre_one.sql

DEF title = 'CPU usage';
DEF main_table = 'STATS$SYS_TIME_MODEL';
DEF abstract = 'CPU usage as reported in stats$sys_time_model. Includes Peak (max), percentiles and average for CPU operations.<br />'
DEF foot = 'Consider Peak or high Percentile for sizing.'
BEGIN
  :sql_text := q'[
WITH 
sys_cpu AS (
SELECT /* ignore if it fails to parse */ /* &&section_id..&&report_sequence. */
       ss.snap_id snap_id,
       ss.dbid dbid,
       ss.instance_number instance_number,
       SUM(CASE WHEN vs.stat_name IN ('DB CPU','background cpu time') THEN ss.value ELSE 0 END) cpu
 FROM &&statspack_user..stats$sys_time_model ss, &&v_object_prefix.sys_time_model vs
 WHERE 1=1
   AND ss.snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
   AND vs.stat_name IN ('DB CPU','background cpu time')
   AND ss.stat_id = vs.stat_id
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
snaps AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       --begin_interval_time, lag(snapshot_time) over (order by snap_id)
       lag(snap_time) over (order by snap_id) begin_interval_time,
       --end_interval_time,   -- these fields do not exist
       snap_time end_interval_time,
       --((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 24 * 60 * 60) elapsed_sec, -- NA
       nvl(((snap_time - lag(snap_time) over (order by snap_id)) * 24 * 60 * 60),0) elapsed_sec,
       startup_time
  FROM &&statspack_user..stats$snapshot
 WHERE 1=1
   AND snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
),
cpu_per_snap_and_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       t1.snap_id,
       t1.dbid,
       t1.instance_number,
       di.instance_name,
       di.db_name,
       /* LOWER(SUBSTR(di.host_name||'.', 1, INSTR(di.host_name||'.', '.') - 1)) */ 
       LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_name,
       ROUND((t1.cpu - t0.cpu) / 1000000 / s1.elapsed_sec) cpu_s
  FROM sys_cpu t0,
       sys_cpu t1,
       snaps s0,
       snaps s1,
       &&statspack_user..stats$database_instance di
 WHERE 1=1
   AND t1.snap_id BETWEEN &&sp_minimum_snap_id. AND &&sp_maximum_snap_id.
   AND t1.snap_id = t0.snap_id + 1
   AND t1.dbid = t0.dbid
   AND t1.instance_number = t0.instance_number
   AND s0.snap_id = t0.snap_id
   AND s0.dbid = t0.dbid
   AND s0.instance_number = t0.instance_number
   AND s1.snap_id = t1.snap_id
   AND s1.dbid = t1.dbid
   AND s1.instance_number = t1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.elapsed_sec > 60 -- ignore snaps too close
   AND di.dbid = s1.dbid
   AND di.instance_number = s1.instance_number
   AND di.startup_time = s1.startup_time
),
cpu_per_snap_and_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       db_name,
       SUM(cpu_s) cpu_s
  FROM cpu_per_snap_and_inst
 GROUP BY
       snap_id,
       dbid,
       db_name
),
cpu_max_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       instance_number,
       instance_name,
       db_name,
       host_name,
       MAX(cpu_s) peak_cpu_s,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY cpu_s) perc_99_99_cpu_s,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY cpu_s) perc_99_9_cpu_s,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY cpu_s) perc_99_cpu_s,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY cpu_s) perc_95_cpu_s,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY cpu_s) perc_90_cpu_s,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY cpu_s) perc_75_cpu_s,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY cpu_s) perc_50_cpu_s,
       ROUND(AVG(cpu_s)) avg_cpu_s
  FROM cpu_per_snap_and_inst
 GROUP BY
       dbid,
       instance_number,
       instance_name,
       db_name,
       host_name
),
cpu_max_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       db_name,
       MAX(cpu_s) peak_cpu_s,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY cpu_s) perc_99_99_cpu_s,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY cpu_s) perc_99_9_cpu_s,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY cpu_s) perc_99_cpu_s,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY cpu_s) perc_95_cpu_s,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY cpu_s) perc_90_cpu_s,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY cpu_s) perc_75_cpu_s,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY cpu_s) perc_50_cpu_s,
       ROUND(AVG(cpu_s)) avg_cpu_s
  FROM cpu_per_snap_and_cluster
 GROUP BY
       dbid,
       db_name
),
peak_cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       m.peak_cpu_s peak_cpu_s
  FROM cpu_per_snap_and_inst r,
       cpu_max_per_inst m
 WHERE r.cpu_s = m.peak_cpu_s
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_99_cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       m.perc_99_99_cpu_s perc_99_99_cpu_s
  FROM cpu_per_snap_and_inst r,
       cpu_max_per_inst m
 WHERE r.cpu_s = m.perc_99_99_cpu_s
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_9_cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       m.perc_99_9_cpu_s perc_99_9_cpu_s
  FROM cpu_per_snap_and_inst r,
       cpu_max_per_inst m
 WHERE r.cpu_s = m.perc_99_9_cpu_s
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       m.perc_99_cpu_s perc_99_cpu_s
  FROM cpu_per_snap_and_inst r,
       cpu_max_per_inst m
 WHERE r.cpu_s = m.perc_99_cpu_s
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_95_cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       m.perc_95_cpu_s per_95_cpu_s
  FROM cpu_per_snap_and_inst r,
       cpu_max_per_inst m
 WHERE r.cpu_s = m.perc_95_cpu_s
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_90_cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       m.perc_90_cpu_s perc_90_cpu_s
  FROM cpu_per_snap_and_inst r,
       cpu_max_per_inst m
 WHERE r.cpu_s = m.perc_90_cpu_s
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_75_cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       m.perc_75_cpu_s perc_75_cpu_s
  FROM cpu_per_snap_and_inst r,
       cpu_max_per_inst m
 WHERE r.cpu_s = m.perc_75_cpu_s
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_50_cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       m.perc_50_cpu_s
  FROM cpu_per_snap_and_inst r,
       cpu_max_per_inst m
 WHERE r.cpu_s = m.perc_50_cpu_s
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
peak_cpu_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       m.peak_cpu_s peak_cpu_s
  FROM cpu_per_snap_and_cluster r,
       cpu_max_per_cluster m
 WHERE r.cpu_s = m.peak_cpu_s
   AND r.dbid = m.dbid
),
perc_99_99_cpu_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       m.perc_99_99_cpu_s perc_99_99_cpu_s
  FROM cpu_per_snap_and_cluster r,
       cpu_max_per_cluster m
 WHERE r.cpu_s = m.perc_99_99_cpu_s
   AND r.dbid = m.dbid
),
perc_99_9_cpu_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       m.perc_99_9_cpu_s perc_99_9_cpu_s
  FROM cpu_per_snap_and_cluster r,
       cpu_max_per_cluster m
 WHERE r.cpu_s = m.perc_99_9_cpu_s
   AND r.dbid = m.dbid
),
perc_99_cpu_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       m.perc_99_cpu_s perc_99_cpu_s
  FROM cpu_per_snap_and_cluster r,
       cpu_max_per_cluster m
 WHERE r.cpu_s = m.perc_99_cpu_s
   AND r.dbid = m.dbid
),
perc_95_cpu_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       m.perc_95_cpu_s per_95_cpu_s
  FROM cpu_per_snap_and_cluster r,
       cpu_max_per_cluster m
 WHERE r.cpu_s = m.perc_95_cpu_s
   AND r.dbid = m.dbid
),
perc_90_cpu_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       m.perc_90_cpu_s perc_90_cpu_s
  FROM cpu_per_snap_and_cluster r,
       cpu_max_per_cluster m
 WHERE r.cpu_s = m.perc_90_cpu_s
   AND r.dbid = m.dbid
),
perc_75_cpu_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       m.perc_75_cpu_s perc_75_cpu_s
  FROM cpu_per_snap_and_cluster r,
       cpu_max_per_cluster m
 WHERE r.cpu_s = m.perc_75_cpu_s
   AND r.dbid = m.dbid
),
perc_50_cpu_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.dbid,
       m.perc_50_cpu_s
  FROM cpu_per_snap_and_cluster r,
       cpu_max_per_cluster m
 WHERE r.cpu_s = m.perc_50_cpu_s
   AND r.dbid = m.dbid
),
per_instance AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       x.dbid,
       x.db_name,
       x.instance_number,
       x.instance_name,
       x.host_name,
       x.peak_cpu_s,
       x.perc_99_99_cpu_s,
       x.perc_99_9_cpu_s,
       x.perc_99_cpu_s,
       x.perc_95_cpu_s,
       x.perc_90_cpu_s,
       x.perc_75_cpu_s,
       x.perc_50_cpu_s,
       x.avg_cpu_s
  FROM cpu_max_per_inst x
 ORDER BY
       x.dbid,
       x.instance_number
),
per_cluster AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       x.dbid,
       x.db_name,
       TO_NUMBER(NULL) instance_number,
       NULL instance_name,
       NULL host_name,
       x.peak_cpu_s,
       x.perc_99_99_cpu_s,
       x.perc_99_9_cpu_s,
       x.perc_99_cpu_s,
       x.perc_95_cpu_s,
       x.perc_90_cpu_s,
       x.perc_75_cpu_s,
       x.perc_50_cpu_s,
       x.avg_cpu_s
  FROM cpu_max_per_cluster x
)
SELECT * FROM per_instance
 UNION ALL
SELECT * FROM per_cluster
]';
END;
/
@@&&skip_if_missing.edb360_9a_pre_one.sql

DEF abstract = '';
DEF foot = '';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
