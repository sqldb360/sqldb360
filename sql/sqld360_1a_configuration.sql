DEF section_id = '1a';
DEF section_name = 'Database Configuration';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF processor_model = 'Unknown';
COL processor_model NEW_V processor_model
HOS rm cpuinfo.sql
HOS cat /proc/cpuinfo | grep -i name | sort | uniq >> cpuinfo.sql
HOS lsconf | grep Processor >> cpuinfo.sql
HOS psrinfo -v >> cpuinfo.sql
GET cpuinfo.sql
A ' processor_model FROM DUAL;
0 SELECT '
/
SELECT REPLACE(REPLACE(REPLACE(REPLACE('&&processor_model.', CHR(9)), CHR(10)), ':'), 'model name ') processor_model FROM DUAL;
HOS rm cpuinfo.sql

COL system_item FOR A40 HEA 'Covers one database'
COL system_value HEA ''

DEF title = 'System Under Observation';
DEF main_table = 'DUAL';
BEGIN
  :sql_text := q'[
WITH  
rac AS (SELECT /*+ &&sq_fact_hints. */ COUNT(*) instances, CASE COUNT(*) WHEN 1 THEN 'Single-instance' ELSE COUNT(*)||'-node RAC cluster' END db_type FROM gv$instance),
mem AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'memory_target'),
sga AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'sga_target'),
pga AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'pga_aggregate_target'),
db_block AS (SELECT /*+ &&sq_fact_hints. */ value bytes FROM v$system_parameter2 WHERE name = 'db_block_size'),
db AS (SELECT /*+ &&sq_fact_hints. */ name, platform_name FROM v$database),
&&skip_10g.&&skip_11g.  pdbs AS (SELECT /*+ &&sq_fact_hints. */ * FROM v$pdbs), -- need 12c flag
inst AS (SELECT /*+ &&sq_fact_hints. */ host_name, version db_version FROM v$instance),
data AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) bytes, COUNT(*) files, COUNT(DISTINCT ts#) tablespaces FROM v$datafile),
temp AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) bytes FROM v$tempfile),
log AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) * MAX(members) bytes FROM v$log),
control AS (SELECT /*+ &&sq_fact_hints. */ SUM(block_size * file_size_blks) bytes FROM v$controlfile),
&&skip_10g.&&skip_11g. cell AS (SELECT /*+ &&sq_fact_hints. */ COUNT(DISTINCT cell_name) cnt FROM v$cell_state),
core AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) cnt FROM gv$osstat WHERE stat_name = 'NUM_CPU_CORES'),
cpu AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) cnt FROM gv$osstat WHERE stat_name = 'NUM_CPUS'),
pmem AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) bytes FROM gv$osstat WHERE stat_name = 'PHYSICAL_MEMORY_BYTES')
SELECT /*+ &&top_level_hints. */ 'Database name:' system_item, db.name system_value FROM db
 UNION ALL
&&skip_10g.&&skip_11g. SELECT '    pdb:'||name, 'Open Mode:'||open_mode FROM pdbs -- need 12c flag
&&skip_10g.&&skip_11g. UNION ALL
SELECT 'Oracle Database version:', inst.db_version FROM inst
 UNION ALL
SELECT 'Database block size:', TRIM(TO_CHAR(db_block.bytes / POWER(2,10), '90'))||' KB' FROM db_block
 UNION ALL
SELECT 'Database size:', TRIM(TO_CHAR(ROUND((data.bytes + temp.bytes + log.bytes + control.bytes) / POWER(10,12), 3), '999,999,990.000'))||' TB'
  FROM db, data, temp, log, control
 UNION ALL
SELECT 'Datafiles:', data.files||' (on '||data.tablespaces||' tablespaces)' FROM data
 UNION ALL
SELECT 'Database configuration:', rac.db_type FROM rac
 UNION ALL
SELECT 'Database memory:', 
       CASE WHEN mem.target > 0 THEN 'MEMORY'  ||TRIM(TO_CHAR(ROUND(mem.target / POWER(2,30), 1), '999,990.0'))||' GB, ' END||
       CASE WHEN sga.target > 0 THEN 'SGA '   ||TRIM(TO_CHAR(ROUND(sga.target / POWER(2,30), 1), '999,990.0'))||' GB, ' END||
       CASE WHEN pga.target > 0 THEN 'PGA '   ||TRIM(TO_CHAR(ROUND(pga.target / POWER(2,30), 1), '999,990.0'))||' GB, ' END||
       CASE WHEN mem.target > 0 THEN 'AMM ' ELSE CASE WHEN sga.target > 0 THEN 'ASMM' ELSE 'MANUAL' END END
  FROM mem, sga, pga
 UNION ALL
&&skip_10g.&&skip_11g.SELECT 'Hardware:', CASE WHEN cell.cnt > 0 THEN 'Engineered System '||
&&skip_10g.&&skip_11g.        CASE WHEN '&&processor_model.' LIKE '%5675%' THEN 'X2-2 ' END|| 
&&skip_10g.&&skip_11g.        CASE WHEN '&&processor_model.' LIKE '%2690%' THEN 'X3-2 ' END|| 
&&skip_10g.&&skip_11g.        CASE WHEN '&&processor_model.' LIKE '%2697%' THEN 'X4-2 ' END|| 
&&skip_10g.&&skip_11g.        CASE WHEN '&&processor_model.' LIKE '%2699%' THEN 'X5-2 ' END|| 
&&skip_10g.&&skip_11g.        CASE WHEN '&&processor_model.' LIKE '%8870%' THEN 'X3-8 ' END|| 
&&skip_10g.&&skip_11g.        CASE WHEN '&&processor_model.' LIKE '%8895%' THEN 'X4-8 or X5-8 ' END|| 
&&skip_10g.&&skip_11g.        'with '||cell.cnt||' storage servers' 
&&skip_10g.&&skip_11g.        ELSE 'Unknown' END FROM cell
&&skip_10g.&&skip_11g. UNION ALL
SELECT 'Processor:', '&&processor_model.' FROM DUAL
 UNION ALL
SELECT 'Physical CPUs:', core.cnt||' cores'||CASE WHEN rac.instances > 0 THEN ', on '||rac.db_type END FROM rac, core
 UNION ALL
SELECT 'Oracle CPUs:', cpu.cnt||' CPUs (threads)'||CASE WHEN rac.instances > 0 THEN ', on '||rac.db_type END FROM rac, cpu
 UNION ALL
SELECT 'Physical RAM:', TRIM(TO_CHAR(ROUND(pmem.bytes / POWER(2,30), 1), '999,990.0'))||' GB'||CASE WHEN rac.instances > 0 THEN ', on '||rac.db_type END FROM rac, pmem
 UNION ALL
SELECT 'Operating system:', db.platform_name FROM db
]';
END;        
/
@@sqld360_9a_pre_one.sql


DEF title = 'Identification';
DEF main_table = 'V$DATABASE';
BEGIN
  :sql_text := q'[
SELECT d.dbid,
       d.name dbname,
       d.db_unique_name,
       d.platform_name,
       i.version,
       i.inst_id,
       i.instance_number,
       i.instance_name,
       LOWER(SUBSTR(i.host_name||'.', 1, INSTR(i.host_name||'.', '.') - 1)) host_name,
       LPAD(ORA_HASH(LOWER(SUBSTR(i.host_name||'.', 1, INSTR(i.host_name||'.', '.') - 1)),999999),6,'6') host_hv,
       p.value cpu_count,
       '&&ebs_release.' ebs_release,
       '&&ebs_system_name.' ebs_system_name,
       '&&siebel_schema.' siebel_schema,
       '&&siebel_app_ver.' siebel_app_ver,
       '&&psft_schema.' psft_schema,
       '&&psft_tools_rel.' psft_tools_rel
  FROM v$database d,
       gv$instance i,
       gv$system_parameter2 p
 WHERE p.inst_id = i.inst_id
   AND p.name = 'cpu_count'
]';
END;
/
@@sqld360_9a_pre_one.sql

DEF title = 'Version';
DEF main_table = 'V$VERSION';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM v$version
]';
END;
/
@@sqld360_9a_pre_one.sql

DEF title = 'Database';
DEF main_table = 'V$DATABASE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM v$database
]';
END;
/
@@sqld360_9a_pre_one.sql

DEF title = 'Instance';
DEF main_table = 'GV$INSTANCE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$instance
 ORDER BY
       inst_id
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Modified Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 WHERE ismodified = 'MODIFIED'
 ORDER BY
       name,
       inst_id,
       ordinal
]';
END;
/
@@sqld360_9a_pre_one.sql

DEF title = 'Non-default Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 WHERE isdefault = 'FALSE'
 ORDER BY
       name,
       inst_id,
       ordinal
]';
END;
/
@@sqld360_9a_pre_one.sql

DEF title = 'All Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 ORDER BY
       name,
       inst_id,
       ordinal
]';
END;
/
@@sqld360_9a_pre_one.sql

DEF title = 'Parameter File';
DEF main_table = 'V$SPPARAMETER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM v$spparameter
 WHERE isspecified = 'TRUE'
 ORDER BY
       name,
       sid,
       ordinal
]';
END;
/
@@sqld360_9a_pre_one.sql

DEF title = 'System Parameters Change Log';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
WITH 
all_parameters AS (
SELECT snap_id,
       dbid,
       instance_number,
       parameter_name,
       value,
       isdefault,
       ismodified,
       lag(value) OVER (PARTITION BY dbid, instance_number, parameter_hash ORDER BY snap_id) prior_value
  FROM dba_hist_parameter
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND '&&diagnostics_pack.' = 'Y'
   AND dbid = &&sqld360_dbid.
)
SELECT TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI') begin_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI') end_time,
       p.snap_id,
       --p.dbid,
       p.instance_number,
       p.parameter_name,
       p.value,
       p.isdefault,
       p.ismodified,
       p.prior_value
  FROM all_parameters p,
       dba_hist_snapshot s
 WHERE p.value != p.prior_value
   AND s.snap_id = p.snap_id
   AND s.dbid = p.dbid
   AND s.instance_number = p.instance_number
 ORDER BY
       s.begin_interval_time DESC,
       --p.dbid,
       p.instance_number,
       p.parameter_name
]';
END;
/
@@&&from_edb360.sqld360_9a_pre_one.sql


COL address NOPRI
COL hash_value NOPRI
COL sql_id NOPRI
COL child_address NOPRI

DEF title = 'Optimizer Environment';
DEF main_table = 'GV$SQL_OPTIMIZER_ENV';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sql_optimizer_env
 WHERE sql_id = '&&sqld360_sqlid.'
 ORDER BY inst_id, sql_id, child_number, id
]';
END;
/
@@&&sqld360_skip_cboenv.sqld360_9a_pre_one.sql


DEF title = 'Non-default Optimizer Environment';
DEF main_table = 'GV$SQL_OPTIMIZER_ENV';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sql_optimizer_env
 WHERE sql_id = '&&sqld360_sqlid.'
   AND isdefault = 'NO'
 ORDER BY inst_id, sql_id, child_number, id
]';
END;
/
@@&&sqld360_skip_cboenv.sqld360_9a_pre_one.sql

COL address PRI
COL hash_value PRI
COL sql_id PRI
COL child_address PRI



DEF title = 'System Stats';
DEF main_table = 'SYS.AUX_STATS$';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM sys.aux_stats$
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'IO Calibration';
DEF main_table = 'DBA_RSRC_IO_CALIBRATE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM dba_rsrc_io_calibrate
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Non-default Fix Controls';
DEF main_table = 'DBA_RSRC_IO_CALIBRATE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM v$system_fix_control
 WHERE is_default = 0
 ORDER BY bugno
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'All Fix Controls';
DEF main_table = 'V$SYSTEM_FIX_CONTROL';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM v$system_fix_control
 ORDER BY bugno
]';
END;
/
@@sqld360_9a_pre_one.sql


COL addr NOPRI

DEF title = 'Optimizer Processing Rate';
DEF main_table = 'V$OPTIMIZER_PROCESSING_RATE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       *
  FROM v$optimizer_processing_rate
 ORDER BY operation_name 
]';
END;
/
@@&&skip_10g.&&skip_11g.sqld360_9a_pre_one.sql

COL addr PRI

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;