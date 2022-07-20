@@&&edb360_0g.tkprof.sql
DEF section_id = '1a';
DEF section_name = 'Database Configuration';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
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
A ', 1, 1000) processor_model FROM DUAL;
0 SELECT SUBSTR('
/
SELECT SUBSTR(REPLACE(REPLACE(REPLACE(REPLACE('&&processor_model.', CHR(9)), CHR(10)), ':'), 'model name '), 1, 1000) processor_model FROM DUAL;
HOS rm cpuinfo.sql

-- Exadata Cells
DEF exa_cells = 0;
col exa_cells NEW_V exa_cells
SELECT COUNT(DISTINCT cell_name) exa_cells FROM v$cell_state;

col exa_storage new_v exa_storage
col exa_storage_ver new_v exa_storage_ver
select NULL exa_storage, NULL exa_storage_ver from dual;

SELECT LISTAGG(make_model||' with '||cpu_count||' CPUs')
       within group (order by make_model) over (partition by make_model) exa_storage
      ,LISTAGG(cv_cellVersion||' in '||cv_flashcachemode||' mode',' | ')  
       within group (order by make_model) over (partition by make_model) exa_storage_ver
  FROM (
        SELECT DISTINCT
            CAST(EXTRACT(XMLTYPE(confval), '/cli-output/cell/releaseVersion/text()') AS VARCHAR2(20))  cv_cellVersion
          , CAST(EXTRACT(XMLTYPE(confval), '/cli-output/cell/flashCacheMode/text()') AS VARCHAR2(20))  cv_flashcachemode
          , CAST(EXTRACT(XMLTYPE(confval), '/cli-output/cell/cpuCount/text()')       AS VARCHAR2(10))  cpu_count
          , CAST(EXTRACT(XMLTYPE(confval), '/cli-output/cell/makeModel/text()')      AS VARCHAR2(50))  make_model
        FROM
            v$cell_config  -- gv isn't needed, all cells should be visible in all instances
        WHERE
            conftype = 'CELL'
       )
/

COL system_item FOR A40 HEA 'Covers one database'
COL system_value HEA ''

DEF title = 'System Under Observation';
DEF main_table = 'DUAL';
DEF abstract = '&&abstract_uom.';
BEGIN
  :sql_text := q'[
WITH /* &&section_id..&&report_sequence. */
 rac AS (SELECT /*+ &&sq_fact_hints. */ COUNT(*) instances, CASE COUNT(*) WHEN 1 THEN 'Single-instance' ELSE COUNT(*)||'-node RAC cluster' END db_type FROM &&gv_object_prefix.instance),
hrac AS (SELECT /*+ &&sq_fact_hints. */ CASE &&hosts_count. WHEN 1 THEN ' (historically Single-instance in AWR)' ELSE ' (historicly &&hosts_count.-node RAC cluster in AWR)' END db_type
           FROM rac WHERE TO_CHAR(RAC.instances)<>&&hosts_count.),
mem AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM &&gv_object_prefix.system_parameter2 WHERE name = 'memory_target'),
sga AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM &&gv_object_prefix.system_parameter2 WHERE name = 'sga_target'),
pga AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM &&gv_object_prefix.system_parameter2 WHERE name = 'pga_aggregate_target'),
db_block AS (SELECT /*+ &&sq_fact_hints. */ value bytes FROM &&v_object_prefix.system_parameter2 WHERE name = 'db_block_size'),
db AS (SELECT /*+ &&sq_fact_hints. */ name, platform_name FROM &&v_object_prefix.database),
&&skip_ver_le_11. pdbs AS (SELECT /*+ &&sq_fact_hints. */ * FROM v$pdbs), -- need 12c flag
inst AS (SELECT /*+ &&sq_fact_hints. */ host_name, version db_version FROM &&v_object_prefix.instance),
data AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) bytes, COUNT(*) files, COUNT(DISTINCT ts#) tablespaces FROM &&v_object_prefix.datafile),
temp AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) bytes FROM &&v_object_prefix.tempfile),
log AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) * MAX(members) bytes FROM &&v_object_prefix.log),
control AS (SELECT /*+ &&sq_fact_hints. */ SUM(block_size * file_size_blks) bytes FROM &&v_object_prefix.controlfile),
core AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) cnt FROM &&gv_object_prefix.osstat WHERE stat_name = 'NUM_CPU_CORES'),
cpu AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) cnt FROM &&gv_object_prefix.osstat WHERE stat_name = 'NUM_CPUS'),
pmem AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) bytes FROM &&gv_object_prefix.osstat WHERE stat_name = 'PHYSICAL_MEMORY_BYTES')
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       'Database name:' system_item, db.name system_value FROM db
UNION ALL
&&skip_ver_le_11. SELECT '    pdb:'||name, 'Open Mode:'||open_mode FROM pdbs -- need 12c flag
&&skip_ver_le_11.  UNION ALL
SELECT 'Oracle Database version:', inst.db_version FROM inst
 UNION ALL
SELECT 'Database block size:', TRIM(TO_CHAR(db_block.bytes / POWER(2,10), '90'))||' KB' FROM db_block
 UNION ALL
SELECT 'Database size:', TRIM(TO_CHAR(ROUND((data.bytes + temp.bytes + log.bytes + control.bytes) / POWER(10,12), 3), '999,999,990.000'))||' TB'
  FROM db, data, temp, log, control
 UNION ALL
SELECT 'Datafiles:', data.files||' (on '||data.tablespaces||' tablespaces)' FROM data
 UNION ALL
SELECT 'Instance configuration:', rac.db_type||(select hrac.db_type FROM hrac ) FROM rac
 UNION ALL
SELECT 'Database memory:',
CASE WHEN mem.target > 0 THEN 'MEMORY '||TRIM(TO_CHAR(ROUND(mem.target / POWER(2,30), 1), '999,990.0'))||' GB, ' END||
CASE WHEN sga.target > 0 THEN 'SGA '   ||TRIM(TO_CHAR(ROUND(sga.target / POWER(2,30), 1), '999,990.0'))||' GB, ' END||
CASE WHEN pga.target > 0 THEN 'PGA '   ||TRIM(TO_CHAR(ROUND(pga.target / POWER(2,30), 1), '999,990.0'))||' GB, ' END||
CASE WHEN mem.target > 0 THEN 'AMM' ELSE CASE WHEN sga.target > 0 THEN 'ASMM' ELSE 'MANUAL' END END
  FROM mem, sga, pga
 UNION ALL
SELECT 'Hardware:', ']'
||(CASE WHEN &&exa_cells.>0 THEN
   'Engineered System '||
    CASE WHEN '&&processor_model.' LIKE '%5675%' THEN 'X2-2 ' END||
    CASE WHEN '&&processor_model.' LIKE '%2690%' THEN 'X3-2 ' END||
    CASE WHEN '&&processor_model.' LIKE '%2697%' THEN 'X4-2 ' END||
    CASE WHEN '&&processor_model.' LIKE '%2699%v3%' THEN 'X-5 ' END||
    CASE WHEN '&&processor_model.' LIKE '%2699%v4%' THEN 'X-6 ' END||
    CASE WHEN '&&processor_model.' LIKE '%8160%' THEN 'X7-2 ' END||
    CASE WHEN '&&processor_model.' LIKE '%8260%' THEN 'X8-2 ' END|| 
    CASE WHEN '&&processor_model.' LIKE '%8358%' THEN 'X9M  ' END|| 
    CASE WHEN '&&processor_model.' LIKE '%8870%' THEN 'X3-8 ' END||
    CASE WHEN '&&processor_model.' LIKE '%8895%v2%' THEN 'X4-8 ' END||
    CASE WHEN '&&processor_model.' LIKE '%8895%v3%' THEN 'X5-8 ' END|| 
   'with &&exa_cells. storage servers' 
  ELSE 'Unknown' END)
||q'[' FROM dual
 UNION ALL
SELECT 'Storage:','&&exa_storage.' FROM DUAL WHERE '&&exa_storage.' IS NOT NULL
 UNION ALL
SELECT 'Storage Version:','&&exa_storage_ver.' FROM DUAL WHERE '&&exa_storage_ver.' IS NOT NULL
 UNION ALL 
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
@@edb360_9a_pre_one.sql

COL maxval_max       heading 'MAXVAL|Maximum'
COL maxval_avg       heading 'MAXVAL|Average'
COL maxval_median    heading 'MAXVAL|Median'
COL maxval_99th_perc heading 'MAXVAL|99th|Percentile'
COL maxval_98th_perc heading 'MAXVAL|98th|Percentile'
COL maxval_97th_perc heading 'MAXVAL|97th|Percentile'
COL maxval_96th_perc heading 'MAXVAL|96th|Percentile'
COL maxval_95th_perc heading 'MAXVAL|95th|Percentile'
COL maxval_90th_perc heading 'MAXVAL|90th|Percentile'
COL maxval_85th_perc heading 'MAXVAL|85th|Percentile'
COL maxval_80th_perc heading 'MAXVAL|80th|Percentile'
COL maxval_75th_perc heading 'MAXVAL|75th|Percentile'

BEGIN
  :sql_text_backup := q'[
WITH
by_snap AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       metric_unit,
       metric_id,
       metric_name,
       XXX(maxval) maxval
  FROM &&awr_object_prefix.sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = 2
   AND metric_name LIKE '@filter_predicate@'
 GROUP BY
       snap_id,
       metric_unit,
       metric_id,
       metric_name
),
by_metric_name AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       metric_unit,
       metric_id,
       metric_name,
       MAX(maxval) maxval_max,
       AVG(maxval) maxval_avg,
       MEDIAN(maxval) maxval_median,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY maxval) maxval_99th_perc,
       PERCENTILE_DISC(0.98) WITHIN GROUP (ORDER BY maxval) maxval_98th_perc,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY maxval) maxval_97th_perc,
       PERCENTILE_DISC(0.96) WITHIN GROUP (ORDER BY maxval) maxval_96th_perc,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY maxval) maxval_95th_perc,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY maxval) maxval_90th_perc,
       PERCENTILE_DISC(0.85) WITHIN GROUP (ORDER BY maxval) maxval_85th_perc,
       PERCENTILE_DISC(0.80) WITHIN GROUP (ORDER BY maxval) maxval_80th_perc,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY maxval) maxval_75th_perc
  FROM by_snap
 GROUP BY
       metric_unit,
       metric_id,
       metric_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       metric_name,
       ROUND(maxval_max, 6 - LENGTH(ROUND(maxval_max * 1000))) maxval_max,
       ROUND(maxval_avg, 6 - LENGTH(ROUND(maxval_avg * 1000))) maxval_avg,
       ROUND(maxval_median, 6 - LENGTH(ROUND(maxval_median * 1000))) maxval_median,
       metric_unit,
       ROUND(maxval_99th_perc, 6 - LENGTH(ROUND(maxval_99th_perc * 1000))) maxval_99th_perc,
       ROUND(maxval_98th_perc, 6 - LENGTH(ROUND(maxval_98th_perc * 1000))) maxval_98th_perc,
       ROUND(maxval_97th_perc, 6 - LENGTH(ROUND(maxval_97th_perc * 1000))) maxval_97th_perc,
       ROUND(maxval_96th_perc, 6 - LENGTH(ROUND(maxval_96th_perc * 1000))) maxval_96th_perc,
       ROUND(maxval_95th_perc, 6 - LENGTH(ROUND(maxval_95th_perc * 1000))) maxval_95th_perc,
       ROUND(maxval_90th_perc, 6 - LENGTH(ROUND(maxval_90th_perc * 1000))) maxval_90th_perc,
       ROUND(maxval_85th_perc, 6 - LENGTH(ROUND(maxval_85th_perc * 1000))) maxval_85th_perc,
       ROUND(maxval_80th_perc, 6 - LENGTH(ROUND(maxval_80th_perc * 1000))) maxval_80th_perc,
       ROUND(maxval_75th_perc, 6 - LENGTH(ROUND(maxval_75th_perc * 1000))) maxval_75th_perc
  FROM by_metric_name
 ORDER BY
       metric_id
]';
END;
/

DEF main_table = '&&awr_hist_prefix.SYSMETRIC_SUMMARY';

DEF title = 'Load Profile - Per Sec';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '%er Sec%');
EXEC :sql_text := REPLACE(:sql_text, 'XXX', 'SUM');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Load Profile - Per Txn';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '%Per Txn%');
EXEC :sql_text := REPLACE(:sql_text, 'XXX', 'MAX');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Load Profile - Count';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '%Count');
EXEC :sql_text := REPLACE(:sql_text, 'XXX', 'SUM');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Identification';
DEF main_table = '&&v_view_prefix.DATABASE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       d.dbid,
       d.name dbname,
       d.db_unique_name,
       d.platform_name,
       i.version,
       i.inst_id,
       i.instance_number,
       i.instance_name,
       LOWER(SUBSTR(i.host_name||'.', 1, INSTR(i.host_name||'.', '.') - 1)) host_name,
           LPAD(ORA_HASH(
       LOWER(SUBSTR(i.host_name||'.', 1, INSTR(i.host_name||'.', '.') - 1))
           ,999999),6,'6') host_hv,
       p.value cpu_count,
       '&&ebs_release.' ebs_release,
       '&&ebs_system_name.' ebs_system_name,
       '&&siebel_schema.' siebel_schema,
       '&&siebel_app_ver.' siebel_app_ver,
       '&&psft_schema.' psft_schema,
       '&&psft_tools_rel.' psft_tools_rel
  FROM &&v_object_prefix.database d,
       &&gv_object_prefix.instance i,
       &&gv_object_prefix.system_parameter2 p
 WHERE p.inst_id = i.inst_id
   AND p.name = 'cpu_count'
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Version';
DEF main_table = '&&v_view_prefix.VERSION';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.version
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Options';
DEF main_table = '&&v_view_prefix.OPTION';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.option
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Database';
DEF main_table = '&&v_view_prefix.DATABASE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.database
]';
END;
/
@@edb360_9a_pre_one.sql

COL version_legacy heading 'Version|Legacy'
COL version_full   heading 'Version|Full'

DEF title = 'Instance';
DEF main_table = '&&gv_view_prefix.INSTANCE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.instance
 ORDER BY
       inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Pluggable Databases';
DEF main_table = '&&cdb_view_prefix.PDBS';
BEGIN
  :sql_text := q'[
SELECT pdb1.*, pdb2.open_mode, pdb2.restricted, pdb2.open_time, pdb2.total_size, pdb2.block_size, pdb2.recovery_status
&&skip_noncdb.,c.name con_name
FROM  &&cdb_object_prefix.pdbs pdb1
 join &&v_object_prefix.pdbs pdb2 on pdb1.con_id=pdb2.con_id
 LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = pdb1.con_id
ORDER BY pdb1.con_id
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Pluggable Databases Saved States';
DEF main_table = '&&cdb_view_prefix.PDB_SAVED_STATES';
BEGIN
  :sql_text := q'[
SELECT *
FROM  &&cdb_object_prefix.pdb_saved_states
ORDER BY 1
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Database and Instance History';
DEF main_table = '&&cdb_awr_hist_prefix.DATABASE_INSTANCE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&cdb_awr_object_prefix.database_instance
 ORDER BY
       &&skip_noncdb.con_id,
       dbid,
       instance_number,
       startup_time
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Instance Recovery';
DEF main_table = '&&gv_view_prefix.INSTANCE_RECOVERY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.instance_recovery
 ORDER BY
       inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Database Properties';
DEF main_table = 'DATABASE_PROPERTIES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM database_properties
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Registry';
DEF main_table = '&&cdb_view_prefix.REGISTRY';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.registry x
       &&skip_noncdb.LEFT OUTER JOIN v$containers c ON c.con_id = x.con_id
ORDER BY
       &&skip_noncdb.x.con_id,
	   x.comp_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Registry SQL Patch';
DEF main_table = '&&cdb_view_prefix.REGISTRY_SQLPATCH';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.registry_sqlpatch x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY 
     &&skip_ver_le_12_1  2,
     1
	   &&skip_noncdb.,x.con_id
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Registry History';
DEF main_table = '&&cdb_view_prefix.REGISTRY_HISTORY';
DEF abstract = 'Review MOS 1360790.1<br />';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.registry_history x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY 1
	   &&skip_noncdb.,x.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Registry Hierarchy';
DEF main_table = '&&cdb_view_prefix.REGISTRY_HIERARCHY';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.registry_hierarchy x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       1, 2, 3
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Feature Usage Statistics';
DEF main_table = '&&cdb_view_prefix.FEATURE_USAGE_STATISTICS';
COL detected_usages heading 'Detected|Usages'
COL total_samples   heading 'Total|Samples'
COL aux_count       heading 'Aux|Count'
col feature_info    format a100
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.feature_usage_statistics x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.name,
       x.version
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'License';
DEF main_table = '&&gv_view_prefix.LICENSE';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.license
 ORDER BY
       inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Limit';
DEF main_table = '&&gv_view_prefix.RESOURCE_LIMIT';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.resource_limit
 ORDER BY
       resource_name,
       inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'HWM Statistics';
DEF main_table = '&&cdb_view_prefix.HIGH_WATER_MARK_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.high_water_mark_statistics x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.dbid,
       x.name
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Database Links';
DEF main_table = '&&cdb_view_prefix.DB_LINKS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.db_links x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.owner,
       x.db_link
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Application Schemas';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id, c.name con_name,
	   x.owner, SUM(x.num_rows) num_rows, SUM(x.blocks) blocks, COUNT(*) tables
  FROM &&cdb_object_prefix.tables x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 GROUP BY
       &&skip_noncdb.x.con_id, c.name,
       x.owner
HAVING SUM(x.num_rows) > 0
 ORDER BY
       num_rows DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Application Schema Objects';
DEF main_table = '&&cdb_view_prefix.OBJECTS';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
	   x.owner,
       SUM(CASE x.object_type WHEN 'TABLE' THEN 1 ELSE 0 END) tables,
       SUM(CASE x.object_type WHEN 'TABLE PARTITION' THEN 1 ELSE 0 END) table_partitions,
       SUM(CASE x.object_type WHEN 'TABLE SUBPARTITION' THEN 1 ELSE 0 END) table_subpartitions,
       SUM(CASE x.object_type WHEN 'INDEX' THEN 1 ELSE 0 END) indexes,
       SUM(CASE x.object_type WHEN 'INDEX PARTITION' THEN 1 ELSE 0 END) index_partitions,
       SUM(CASE x.object_type WHEN 'INDEX SUBPARTITION' THEN 1 ELSE 0 END) index_subpartitions,
       SUM(CASE x.object_type WHEN 'VIEW' THEN 1 ELSE 0 END) views,
       SUM(CASE x.object_type WHEN 'MATERIALIZED VIEW' THEN 1 ELSE 0 END) materialized_views,
       SUM(CASE x.object_type WHEN 'TRIGGER' THEN 1 ELSE 0 END) triggers,
       SUM(CASE x.object_type WHEN 'PACKAGE' THEN 1 ELSE 0 END) packages,
       SUM(CASE x.object_type WHEN 'PROCEDURE' THEN 1 ELSE 0 END) procedures,
       SUM(CASE x.object_type WHEN 'FUNCTION' THEN 1 ELSE 0 END) functions,
       SUM(CASE x.object_type WHEN 'LIBRARY' THEN 1 ELSE 0 END) libraries,
       SUM(CASE x.object_type WHEN 'SYNONYM' THEN 1 ELSE 0 END) synonyms,
       SUM(CASE x.object_type WHEN 'TYPE' THEN 1 ELSE 0 END) types,
       SUM(CASE x.object_type WHEN 'SEQUENCE' THEN 1 ELSE 0 END) sequences
  FROM &&cdb_object_prefix.objects x
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
   AND x.object_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 'VIEW',
                       'MATERIALIZED VIEW', 'TRIGGER', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'LIBRARY', 'SYNONYM', 'TYPE', 'SEQUENCE')
 GROUP BY
       &&skip_noncdb.x.con_id,
       x.owner
)
SELECT x.*
	   &skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.owner
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Modified Parameters';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&gv_object_prefix.system_parameter2 x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.ismodified = 'MODIFIED'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.name,
       x.inst_id,
       x.ordinal
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Non-default Parameters';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&gv_object_prefix.system_parameter2 x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.name,
       x.inst_id,
       x.ordinal
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'All Parameters';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&gv_object_prefix.system_parameter2 x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.name,
       x.inst_id,
       x.ordinal
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Parameter File';
DEF main_table = '&&v_view_prefix.SPPARAMETER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&v_object_prefix.spparameter x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.isspecified = 'TRUE'
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.name,
       x.sid,
       x.ordinal
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'PDB Parameter File';
DEF main_table = 'PDB_SPFILE$';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
         pdb.pdb_id
       , pdb.pdb_name
       --, SUBSTR(pst.inst_name, 1, 9) db_name
       , UPPER(spf.db_uniq_name) db_unique_name
       , spf.sid
       , spf.name
       , spf.value$ value
       --, spf.pdb_uid
       --, pst.pdb_guid
  FROM pdb_spfile$ spf,
       pdbstate$ pst,
       dba_pdbs pdb
 WHERE pst.pdb_uid = spf.pdb_uid
   AND pdb.guid = pst.pdb_guid
 ORDER BY
       1, 2, 3, 4, 5
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'System Parameters Change Log';
DEF main_table = '&&awr_object_prefix.PARAMETER';
BEGIN
  :sql_text := q'[
WITH
all_parameters AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       &&skip_ver_le_11.con_id,
       instance_number,
       parameter_name,
       value,
       isdefault,
       ismodified,
       lag(value) OVER (PARTITION BY dbid,
       &&skip_ver_le_11.con_id,
       instance_number, parameter_hash ORDER BY snap_id) prior_value
  FROM &&awr_object_prefix.parameter
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_ver_le_11.&&skip_noncdb.x.con_id,
	   TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI:SS') end_time,
       x.snap_id,
       x.dbid,
       x.instance_number,
       x.parameter_name,
       x.value,
       x.isdefault,
       x.ismodified,
       x.prior_value
	   &&skip_noncdb.,c.name con_name
  FROM all_parameters x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
      ,&&awr_object_prefix.snapshot s
 WHERE x.value != x.prior_value
   AND s.snap_id = x.snap_id
   AND s.dbid = x.dbid
   AND s.instance_number = x.instance_number
 ORDER BY
       s.begin_interval_time DESC,
	   &&skip_noncdb.x.con_id,
       x.dbid,
       x.instance_number,
       x.parameter_name
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

COL spfile_value FOR A12;
COL spfile_sid FOR A10;
COL recommended_gb heading 'Recommended|GB' format a11
DEF title = 'Memory Configuration';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
DEF foot = 'Recommended GB to be filled out during HC.';
BEGIN
  :sql_text := q'[
WITH
system_parameter AS (
SELECT inst_id,
       name,
       value
  FROM &&gv_object_prefix.system_parameter2
 WHERE name IN
( 'memory_max_target'
, 'memory_target'
, 'pga_aggregate_target'
, 'sga_max_size'
, 'sga_target'
, 'db_cache_size'
, 'shared_pool_size'
, 'shared_pool_reserved_size'
, 'large_pool_size'
, 'java_pool_size'
, 'streams_pool_size'
, 'result_cache_max_size'
, 'db_keep_cache_size'
, 'db_recycle_cache_size'
, 'db_32k_cache_size'
, 'db_16k_cache_size'
, 'db_8k_cache_size'
, 'db_4k_cache_size'
, 'db_2k_cache_size'
)),
spparameter_inst AS (
SELECT i.inst_id,
       p.name,
       p.display_value
  FROM &&v_object_prefix.spparameter p,
       &&gv_object_prefix.instance i
 WHERE p.isspecified = 'TRUE'
   AND p.sid <> '*'
   AND i.instance_name = p.sid
),
spparameter_all AS (
SELECT p.name,
       p.display_value
  FROM &&v_object_prefix.spparameter p
 WHERE p.isspecified = 'TRUE'
   AND p.sid = '*'
)
SELECT s.name,
       s.inst_id,
       CASE WHEN i.name IS NOT NULL THEN TO_CHAR(i.inst_id) ELSE (CASE WHEN a.name IS NOT NULL THEN '*' END) END spfile_sid,
       NVL(i.display_value, a.display_value) spfile_value,
       CASE s.value WHEN '0' THEN '0' ELSE TRIM(TO_CHAR(ROUND(TO_NUMBER(s.value)/POWER(2,30),3),'9990.000'))||'G' END current_gb,
       NULL recommended_gb
  FROM system_parameter s,
       spparameter_inst i,
       spparameter_all  a
 WHERE i.inst_id(+) = s.inst_id
   AND i.name(+)    = s.name
   AND a.name(+)    = s.name
 ORDER BY
       CASE s.name
       WHEN 'memory_max_target'         THEN  1
       WHEN 'memory_target'             THEN  2
       WHEN 'pga_aggregate_target'      THEN  3
       WHEN 'sga_max_size'              THEN  4
       WHEN 'sga_target'                THEN  5
       WHEN 'db_cache_size'             THEN  6
       WHEN 'shared_pool_size'          THEN  7
       WHEN 'shared_pool_reserved_size' THEN  8
       WHEN 'large_pool_size'           THEN  9
       WHEN 'java_pool_size'            THEN 10
       WHEN 'streams_pool_size'         THEN 11
       WHEN 'result_cache_max_size'     THEN 12
       WHEN 'db_keep_cache_size'        THEN 13
       WHEN 'db_recycle_cache_size'     THEN 14
       WHEN 'db_32k_cache_size'         THEN 15
       WHEN 'db_16k_cache_size'         THEN 16
       WHEN 'db_8k_cache_size'          THEN 17
       WHEN 'db_4k_cache_size'          THEN 18
       WHEN 'db_2k_cache_size'          THEN 19
       END,
       s.inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

COL detected_usages  clear
COL total_samples    clear
COL aux_count        clear
COL recommended_gb   clear

COL maxval_max       clear
COL maxval_avg       clear
COL maxval_median    clear
COL maxval_99th_perc clear
COL maxval_98th_perc clear
COL maxval_97th_perc clear
COL maxval_96th_perc clear
COL maxval_95th_perc clear
COL maxval_90th_perc clear
COL maxval_85th_perc clear
COL maxval_80th_perc clear
COL maxval_75th_perc clear

COL version_legacy   clear
COL version_full     clear
