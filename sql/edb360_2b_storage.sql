@@&&edb360_0g.tkprof.sql
DEF section_id = '2b';
DEF section_name = 'Storage';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Tablespace Usage Metrics';
DEF main_table = '&&cdb_view_prefix.TABLESPACE_USAGE_METRICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.t.con_id,
       t.tablespace_name,
       m.used_space,
       m.tablespace_size,
       ROUND(m.used_percent, 1) used_percent,
       ROUND(m.used_space * t.block_size / POWER(2,30), 3) used_space_gb,
       ROUND(m.tablespace_size * t.block_size / POWER(2,30), 3) tablespace_size_gb
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tablespace_usage_metrics m,
       &&cdb_object_prefix.tablespaces t
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = t.con_id
 WHERE t.tablespace_name = m.tablespace_name
&&skip_noncdb.   AND t.con_id = m.con_id
 ORDER BY
       &&skip_noncdb.t.con_id,
       t.tablespace_name
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Tablespace';
DEF main_table = '&&v_view_prefix.TABLESPACE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&v_object_prefix.tablespace x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       ts#
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tablespaces';
DEF main_table = '&&cdb_view_prefix.TABLESPACES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tablespaces x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.tablespace_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tablespace Groups';
DEF main_table = '&&cdb_view_prefix.TABLESPACE_GROUPS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.tablespace_groups x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.group_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Default Tablespace Use';
DEF main_table = '&&cdb_view_prefix.USERS';
COL number_of_users heading 'Number|of Users'
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
	   default_tablespace, COUNT(*) number_of_users
  FROM &&cdb_object_prefix.users
 GROUP BY
       &&skip_noncdb.con_id,
	   default_tablespace
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
 FROM  x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       default_tablespace
]';
END;
/
@@edb360_9a_pre_one.sql

COL temporary_tablespace heading 'Temporary|Tablespace'
DEF title = 'Temporary Tablespace Use';
DEF main_table = '&&cdb_view_prefix.USERS';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
	   temporary_tablespace, COUNT(*) number_of_users
  FROM &&cdb_object_prefix.users
 GROUP BY
       &&skip_noncdb.con_id,
	   temporary_tablespace
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
 FROM  x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       temporary_tablespace
]';
END;
/
@@edb360_9a_pre_one.sql
COL number_of_users CLEAR

DEF title = 'UNDO Stat';
DEF main_table = '&&gv_view_prefix.UNDOSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.undostat
]';
END;
/
@@edb360_9a_pre_one.sql


DEF title = 'Tablespace Usage';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
COL pct_used FOR 999990.0;
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
-- fixed by Rodigo Righetti
WITH
files AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       tablespace_name,
       SUM(DECODE(autoextensible, 'YES', maxbytes, bytes)) / POWER(10,9) Max_size_gb,
       SUM( bytes) / POWER(10,9) Size_gb
  FROM &&cdb_object_prefix.data_files
 GROUP BY
       &&skip_noncdb.con_id,
       tablespace_name
),
segments AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
	   tablespace_name,
       SUM(bytes) / POWER(10,9) used_gb
  FROM &&cdb_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
 GROUP BY
       &&skip_noncdb.con_id,
       tablespace_name
),
tablespaces AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.files.con_id,
       files.tablespace_name,
       ROUND(files.size_gb, 1) size_gb,
       ROUND(segments.used_gb, 1) used_gb,
       ROUND(100 * segments.used_gb / files.size_gb, 1) pct_used,
       ROUND(files.max_size_gb, 1) max_size_gb
  FROM files,
       segments
 WHERE files.size_gb > 0
   AND files.tablespace_name = segments.tablespace_name(+)
   &&skip_noncdb.AND files.con_id = segments.con_id(+)
 ORDER BY
       &&skip_noncdb.files.con_id,
       files.tablespace_name
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       'Total' tablespace_name,
       SUM(size_gb) size_gb,
       SUM(used_gb) used_gb,
       ROUND(100 * SUM(used_gb) / SUM(size_gb), 1) pct_used,
       sum(max_size_gb) max_size_gb
  FROM tablespaces
)
SELECT &&skip_noncdb.con_id,
       tablespace_name,
       size_gb,
       used_gb,
       pct_used,
       max_size_gb
  FROM tablespaces
 UNION ALL
SELECT &&skip_noncdb.NULL,
       tablespace_name,
       size_gb,
       used_gb,
       pct_used,
       max_size_gb
  FROM total
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Temp Tablespace Usage';
DEF main_table = '&&gv_view_prefix.TEMP_EXTENT_POOL';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       a.tablespace_name, ROUND(A.AVAIL_SIZE_GB,1) AVAIL_SIZE_GB,
       ROUND(B.TOT_GBBYTES_CACHED,1) TOT_GBBYTES_CACHED ,
       ROUND(B.TOT_GBBYTES_USED,1) TOT_GBBYTES_USED,
       ROUND(100*(B.TOT_GBBYTES_CACHED/A.AVAIL_SIZE_GB),1) PERC_CACHED,
       ROUND(100*(B.TOT_GBBYTES_USED/A.AVAIL_SIZE_GB),1) PERC_USED
FROM  (SELECT &&skip_noncdb.con_id,
              tablespace_name,sum(bytes)/POWER(10,9) AVAIL_SIZE_GB
       from   &&cdb_object_prefix.temp_files
       group by &&skip_noncdb.con_id,
	            tablespace_name
      ) A,
      (SELECT &&skip_noncdb.con_id,
	          tablespace_name,
              SUM(BYTES_CACHED)/POWER(10,9) TOT_GBBYTES_CACHED,
              SUM(BYTES_USED)/POWER(10,9) TOT_GBBYTES_USED
       FROM   &&gv_object_prefix.temp_extent_pool
       GROUP BY &&skip_noncdb.con_id,
	            TABLESPACE_NAME
       ) B
WHERE a.tablespace_name=b.tablespace_name
&&skip_noncdb.AND   a.con_id = b.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tablespace Quotas';
DEF main_table = '&&cdb_view_prefix.TS_QUOTAS';
BEGIN
  :sql_text := q'[
-- by berx
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.ts_quotas x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.username NOT IN &&exclusion_list.
   and x.username not in &&exclusion_list2.
ORDER BY &&skip_noncdb.x.con_id,
       x.tablespace_name, x.username
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Datafile';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&v_object_prefix.datafile x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.file#
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Data Files';
DEF main_table = '&&cdb_view_prefix.DATA_FILES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.data_files x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.file_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Data Files Usage';
DEF main_table = '&&cdb_view_prefix.DATA_FILES';
COL pct_used FOR 999990.0;
COL pct_free FOR 999990.0;
BEGIN
  :sql_text := q'[
WITH alloc AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       tablespace_name,
       COUNT(*) datafiles,
       ROUND(SUM(bytes)/POWER(10,9)) gb
  FROM &&cdb_object_prefix.data_files
 GROUP BY
       &&skip_noncdb.con_id,
       tablespace_name
),free AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
	   tablespace_name,
       ROUND(SUM(bytes)/POWER(10,9)) gb
  FROM &&cdb_object_prefix.free_space
 GROUP BY
       &&skip_noncdb.con_id,
       tablespace_name
),tablespaces AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.a.con_id,
       a.tablespace_name,
       a.datafiles,
       a.gb alloc_gb,
       (a.gb - f.gb) used_gb,
       f.gb free_gb
  FROM alloc a, free f
 WHERE a.tablespace_name = f.tablespace_name
   &&skip_noncdb.AND a.con_id = f.con_id
 ORDER BY
       &&skip_noncdb.a.con_id,
       a.tablespace_name
&&skip_noncdb.),pdb_total AS (
&&skip_noncdb.SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
&&skip_noncdb.       con_id,
&&skip_noncdb.	     SUM(alloc_gb) alloc_gb,
&&skip_noncdb.       SUM(used_gb) used_gb,
&&skip_noncdb.       SUM(free_gb) free_gb
&&skip_noncdb.  FROM tablespaces
&&skip_noncdb. GROUP BY con_id
),total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(alloc_gb) alloc_gb,
       SUM(used_gb) used_gb,
       SUM(free_gb) free_gb
  FROM tablespaces
), v as (
SELECT &&skip_noncdb.con_id,
       tablespace_name,
       datafiles,
       alloc_gb,
       used_gb,
       free_gb
  FROM tablespaces
&&skip_noncdb. UNION ALL
&&skip_noncdb.SELECT con_id,
&&skip_noncdb.       'PDB Total' tablespace_name,
&&skip_noncdb.       TO_NUMBER(NULL) datafiles,
&&skip_noncdb.       alloc_gb,
&&skip_noncdb.       used_gb,
&&skip_noncdb.       free_gb
&&skip_noncdb.  FROM pdb_total
 UNION ALL
SELECT &&skip_noncdb.NULL,
       'Total' tablespace_name,
       TO_NUMBER(NULL) datafiles,
       alloc_gb,
       used_gb,
       free_gb
  FROM total
)
SELECT &&skip_noncdb.v.con_id,
       v.tablespace_name,
       v.datafiles,
       v.alloc_gb,
       v.used_gb,
       CASE WHEN v.alloc_gb > 0 THEN
       LPAD(TRIM(TO_CHAR(ROUND(100 * v.used_gb / v.alloc_gb, 1), '990.0')), 8)
       END pct_used,
       v.free_gb,
       CASE WHEN v.alloc_gb > 0 THEN
       LPAD(TRIM(TO_CHAR(ROUND(100 * v.free_gb / v.alloc_gb, 1), '990.0')), 8)
       END pct_free
	   &&skip_noncdb.,c.name con_name
  FROM v
       &&skip_noncdb.LEFT OUTER JOIN v$containers c ON c.con_id = v.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tempfile';
DEF main_table = '&&v_view_prefix.TEMPFILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&v_object_prefix.tempfile x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       file#
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Temp Files';
DEF main_table = '&&cdb_view_prefix.TEMP_FILES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.temp_files x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       file_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'I/O Statistics for DB Files';
DEF main_table = '&&v_view_prefix.IOSTAT_FILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&v_object_prefix.iostat_file x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       1
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Kernel I/O taking long';
DEF main_table = '&&v_view_prefix.KERNEL_IO_OUTLIER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.kernel_io_outlier
 ORDER BY
       1
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Log Writer I/O taking long';
DEF main_table = '&&v_view_prefix.LGWRIO_OUTLIER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.lgwrio_outlier
 ORDER BY
       1
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'I/O taking long';
DEF main_table = '&&v_view_prefix.IO_OUTLIER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.io_outlier
 ORDER BY
       1
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'SYSAUX Occupants';
DEF main_table = '&&v_view_prefix.SYSAUX_OCCUPANTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       v.*, ROUND(v.space_usage_kbytes / POWER(10,6), 3) space_usage_gbs
  FROM &&v_object_prefix.sysaux_occupants v
 ORDER BY 1
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Database Growth per Month';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       TO_CHAR(creation_time, 'YYYY-MM') creation_month,
       ROUND(SUM(bytes)/POWER(10,6)) mb_growth,
       ROUND(SUM(bytes)/POWER(10,9)) gb_growth,
       ROUND(SUM(bytes)/POWER(10,12), 1) tb_growth
  FROM &&v_object_prefix.datafile
 GROUP BY
       TO_CHAR(creation_time, 'YYYY-MM')
 ORDER BY 1
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Database Growth per Month per CDB';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
	   TO_CHAR(creation_time, 'YYYY-MM') creation_month,
       ROUND(SUM(bytes)/POWER(10,6)) mb_growth,
       ROUND(SUM(bytes)/POWER(10,9)) gb_growth,
       ROUND(SUM(bytes)/POWER(10,12), 1) tb_growth
  FROM &&v_object_prefix.datafile
 GROUP BY
       &&skip_noncdb.con_id,
	   TO_CHAR(creation_time, 'YYYY-MM')
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       creation_month
]';
END;
/
@@&&skip_noncdb.edb360_9a_pre_one.sql

DEF title = 'Largest 200 Objects';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
COL gb FOR 999990.000;
BEGIN
  :sql_text := q'[
WITH schema_object AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       segment_type,
       owner,
       segment_name,
       tablespace_name,
       COUNT(*) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes
  FROM &&cdb_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
 GROUP BY
       &&skip_noncdb.con_id,
       segment_type,
       owner,
       segment_name,
       tablespace_name
), totals AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes
  FROM schema_object
), top_200_pre AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ROWNUM rank, v1.*
       FROM (
SELECT &&skip_noncdb.so.con_id,
       so.segment_type,
       so.owner,
       so.segment_name,
       so.tablespace_name,
       so.segments,
       so.extents,
       so.blocks,
       so.bytes,
       ROUND((so.segments / t.segments) * 100, 3) segments_perc,
       ROUND((so.extents / t.extents) * 100, 3) extents_perc,
       ROUND((so.blocks / t.blocks) * 100, 3) blocks_perc,
       ROUND((so.bytes / t.bytes) * 100, 3) bytes_perc
  FROM schema_object so,
       totals t
 ORDER BY
       bytes_perc DESC NULLS LAST
) v1
 WHERE ROWNUM < 201
), top_200 AS (
SELECT p.*,
       (SELECT object_id
          FROM &&cdb_object_prefix.objects o
         WHERE o.object_type = p.segment_type
		   &&skip_noncdb.AND o.con_id = p.con_id
           AND o.owner = p.owner
           AND o.object_name = p.segment_name
           AND o.object_type NOT LIKE '%PARTITION%') object_id,
       (SELECT data_object_id
          FROM &&cdb_object_prefix.objects o
         WHERE o.object_type = p.segment_type
           &&skip_noncdb.AND o.con_id = p.con_id
           AND o.owner = p.owner
           AND o.object_name = p.segment_name
           AND o.object_type NOT LIKE '%PARTITION%') data_object_id,
       (SELECT SUM(p2.bytes_perc) FROM top_200_pre p2 WHERE p2.rank <= p.rank) bytes_perc_cum
  FROM top_200_pre p
), top_200_totals AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes,
       SUM(segments_perc) segments_perc,
       SUM(extents_perc) extents_perc,
       SUM(blocks_perc) blocks_perc,
       SUM(bytes_perc) bytes_perc
  FROM top_200
), top_100_totals AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes,
       SUM(segments_perc) segments_perc,
       SUM(extents_perc) extents_perc,
       SUM(blocks_perc) blocks_perc,
       SUM(bytes_perc) bytes_perc
  FROM top_200
 WHERE rank < 101
), top_20_totals AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes,
       SUM(segments_perc) segments_perc,
       SUM(extents_perc) extents_perc,
       SUM(blocks_perc) blocks_perc,
       SUM(bytes_perc) bytes_perc
  FROM top_200
 WHERE rank < 21
)
SELECT v.rank,
       v.segment_type,
	   &&skip_noncdb.v.con_id,
       v.owner,
       v.segment_name,
       v.object_id,
       v.data_object_id,
       v.tablespace_name,
       CASE
       WHEN v.segment_type LIKE 'INDEX%' THEN
         (SELECT i.table_name
            FROM &&cdb_object_prefix.indexes i
           WHERE i.owner = v.owner
		     &&skip_noncdb.AND i.con_id = v.con_id
		     AND i.index_name = v.segment_name)
       WHEN v.segment_type LIKE 'LOB%' THEN
         (SELECT l.table_name
            FROM &&cdb_object_prefix.lobs l
           WHERE l.owner = v.owner
		     &&skip_noncdb.AND l.con_id = v.con_id
		     AND l.segment_name = v.segment_name)
       END table_name,
       v.segments,
       v.extents,
       v.blocks,
       v.bytes,
       ROUND(v.bytes / POWER(10,9), 3) gb,
       LPAD(TO_CHAR(v.segments_perc, '990.000'), 7) segments_perc,
       LPAD(TO_CHAR(v.extents_perc, '990.000'), 7) extents_perc,
       LPAD(TO_CHAR(v.blocks_perc, '990.000'), 7) blocks_perc,
       LPAD(TO_CHAR(v.bytes_perc, '990.000'), 7) bytes_perc,
       LPAD(TO_CHAR(v.bytes_perc_cum, '990.000'), 7) perc_cum
	   &&skip_noncdb.,c.name con_name
  FROM (
SELECT d.rank,
       d.segment_type,
	   &&skip_noncdb.d.con_id,
       d.owner,
       d.segment_name,
       d.object_id,
       d.data_object_id,
       d.tablespace_name,
       d.segments,
       d.extents,
       d.blocks,
       d.bytes,
       d.segments_perc,
       d.extents_perc,
       d.blocks_perc,
       d.bytes_perc,
       d.bytes_perc_cum
  FROM top_200 d
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
	   &&skip_noncdb.NULL con_id,
       NULL owner,
       NULL segment_name,
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       'TOP  20' tablespace_name,
       st.segments,
       st.extents,
       st.blocks,
       st.bytes,
       st.segments_perc,
       st.extents_perc,
       st.blocks_perc,
       st.bytes_perc,
       TO_NUMBER(NULL) bytes_perc_cum
  FROM top_20_totals st
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
	   &&skip_noncdb.NULL con_id,
       NULL owner,
       NULL segment_name,
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       'TOP 100' tablespace_name,
       st.segments,
       st.extents,
       st.blocks,
       st.bytes,
       st.segments_perc,
       st.extents_perc,
       st.blocks_perc,
       st.bytes_perc,
       TO_NUMBER(NULL) bytes_perc_cum
  FROM top_100_totals st
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
	   &&skip_noncdb.NULL con_id,
       NULL owner,
       NULL segment_name,
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       'TOP 200' tablespace_name,
       st.segments,
       st.extents,
       st.blocks,
       st.bytes,
       st.segments_perc,
       st.extents_perc,
       st.blocks_perc,
       st.bytes_perc,
       TO_NUMBER(NULL) bytes_perc_cum
  FROM top_200_totals st
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
	   &&skip_noncdb.NULL con_id,
       NULL owner,
       NULL segment_name,
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       'TOTAL' tablespace_name,
       t.segments,
       t.extents,
       t.blocks,
       t.bytes,
       100 segemnts_perc,
       100 extents_perc,
       100 blocks_perc,
       100 bytes_perc,
       TO_NUMBER(NULL) bytes_perc_cum
  FROM totals t) v
  &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = v.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

REM dmk 15.11.2018 added report
column blocks             heading 'Blocks'
column num_rows           heading 'Number|of Rows'
column ranking            heading 'Rank'
column column_id          heading 'Column|ID'
column column_name        heading 'Column|Name'
column partitioning_level heading 'Partitioning|Level'
column partitioning_type  heading 'Partitioning|Type'
column column_position    heading 'Partitioning|Key Column|Position'
column num_distinct       heading 'Distinct|Values'
column sample_size        heading 'Sample|Size'
column num_nulls          heading 'Number|of Nulls'
column EQUALITY_PREDS     heading 'Equality|Predicates'
column EQUIJOIN_PREDS     heading 'EquiJoin|Predicates'
column NONEQUIJOIN_PREDS  heading 'NonEquiJoin|Predicates'
column RANGE_PREDS        heading 'Range|Predicates'
column LIKE_PREDS         heading 'Like|Predicates'
column NULL_PREDS         heading 'NULL|Predicates'

DEF title = 'Column Usage of 100 Largest Tables';
DEF main_table = '&&dva_view_prefix.TABLES';

BEGIN
  :sql_text := q'[
WITH k as (
SELECT owner, name, column_position, column_name
,      'Partition' partitioning_level
FROM   &&dva_view_prefix.part_key_columns
WHERE  object_type = 'TABLE'
AND    owner NOT IN &&exclusion_list.
AND    owner NOT IN &&exclusion_list.
UNION ALL
SELECT owner, name, column_position, column_name
,      'Subpartition'
FROM   &&dva_view_prefix.subpart_key_columns
WHERE  object_type = 'TABLE'
AND    owner NOT IN &&exclusion_list.
AND    owner NOT IN &&exclusion_list.
), c AS (
SELECT c.owner, c.table_name
,      c.column_id, c.column_name, c.num_distinct, c.num_nulls
,      u.EQUALITY_PREDS
,      u.EQUIJOIN_PREDS
,      u.NONEQUIJOIN_PREDS
,      u.RANGE_PREDS
,      u.LIKE_PREDS
,      u.NULL_PREDS
,      u.TIMESTAMP
FROM   &&dva_view_prefix.objects o
,      &&dva_view_prefix.tab_columns c
,      sys.col_usage$ u
WHERE  o.object_type = 'TABLE'
AND    o.owner = c.owner
AND    o.object_name = c.table_name
AND    u.obj# = o.object_id
AND    u.intcol# = c.column_id
AND    o.owner NOT IN &&exclusion_list.
AND    o.owner NOT IN &&exclusion_list2.
), x as (
SELECT dense_rank() over (order by t.blocks desc, t.owner, t.table_name) ranking
,      t.owner, t.table_name
,      c.column_id, c.column_name
,      k.partitioning_level
,      CASE WHEN k.partitioning_level = 'Partition'    THEN    p.partitioning_type
            WHEN k.partitioning_level = 'Subpartition' THEN p.subpartitioning_type
            WHEN p.table_name IS NULL                  THEN 'None'
       END as partitioning_type
,      k.column_position
,      t.blocks, t.num_rows
,      c.num_distinct, c.num_nulls
,      c.EQUALITY_PREDS
,      c.EQUIJOIN_PREDS
,      c.NONEQUIJOIN_PREDS
,      c.RANGE_PREDS
,      c.LIKE_PREDS
,      c.NULL_PREDS
,      c.TIMESTAMP
FROM   &&dva_view_prefix.tables t
  LEFT OUTER JOIN &&dva_view_prefix.part_tables p
    ON p.owner = t.owner
   AND p.table_name = t.table_name
  LEFT OUTER JOIN c
    ON c.owner = t.owner
   AND c.table_name = t.table_name
  LEFT OUTER JOIN k
    ON k.owner = c.owner
   AND k.name = c.table_name
   AND k.column_name = c.column_name
WHERE  t.blocks>0
AND    t.owner NOT IN &&exclusion_list.
AND    t.owner NOT IN &&exclusion_list.
)
SELECT x.*
from x
where ranking <= 100
ORDER BY 1,2,3,4
]';
END;
/
@@edb360_9a_pre_one.sql
column blocks             clear
column num_rows           clear
column ranking            clear
column column_id          clear
column column_name        clear
column partitioning_level clear
column partitioning_type  clear
column column_position    clear
column num_distinct       clear
column sample_size        clear
column num_nulls          clear
column EQUALITY_PREDS     clear
column EQUIJOIN_PREDS     clear
column NONEQUIJOIN_PREDS  clear
column RANGE_PREDS        clear
column LIKE_PREDS         clear
column NULL_PREDS         clear


DEF title = 'Tables with one extent and no rows';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by David Kurtz--performance fix 25.10.2021
WITH s AS (
SELECT  /*+ MATERIALIZE*/ s.owner, s.segment_name, s.tablespace_name, s.blocks
&&skip_noncdb.,s.con_id
FROM    &&cdb_object_prefix.segments s
WHERE   s.owner not in &&exclusion_list.
AND     s.owner not in &&exclusion_list2.
and     s.segment_type = 'TABLE'
and     s.extents =  1
and     s.partition_name IS NULL
)
SELECT  &&skip_noncdb.t.con_id,
		t.owner, t.table_name, t.tablespace_name, t.num_rows, t.blocks hwm_blocks, t.last_analyzed, s.blocks seg_blocks
		&&skip_noncdb.,c.name con_name
FROM    &&cdb_object_prefix.tables t
        &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = t.con_id
,       s
WHERE   '&&edb360_conf_incl_segments.' = 'Y'
AND     t.owner not in &&exclusion_list.
AND     t.owner not in &&exclusion_list2.
&&skip_noncdb.AND     t.con_id = s.con_id
AND     t.owner = s.owner
AND     t.table_name = s.segment_name
AND     t.tablespace_name = s.tablespace_name
AND     t.segment_created = 'YES'
AND     (  t.num_rows = 0
        OR t.num_rows IS NULL
        )
ORDER BY
        &&skip_noncdb.t.con_id,
        t.owner, t.table_name
]';
END;
/
BRE ON REPORT;
COMP SUM LAB TOTAL OF hwm_blocks ON REPORT;
COMP SUM LAB TOTAL OF seg_blocks ON REPORT;
@@&&skip_ver_le_10.edb360_9a_pre_one.sql
CL BRE;
CL COMP;

DEF title = 'Partitions with one extent and no rows';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by David Kurtz
SELECT  /* LEADING(T) USE_NL(S) */ -- removed hint as per Luis Calvo
        &&skip_noncdb.t.con_id,
        t.table_owner, t.table_name, t.partition_name, t.tablespace_name, t.num_rows, t.blocks hwm_blocks, t.last_analyzed, s.blocks seg_blocks
        &&skip_noncdb.,c.name con_name
FROM    &&cdb_object_prefix.tab_partitions t
        &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = t.con_id
,       &&cdb_object_prefix.segments s
WHERE   '&&edb360_conf_incl_segments.' = 'Y'
AND     t.table_owner not in &&exclusion_list.
AND     t.table_owner not in &&exclusion_list2.
AND     s.segment_type = 'TABLE PARTITION'
&&skip_noncdb.AND     t.con_id = s.con_id
AND     t.table_owner = s.owner
AND     t.table_name = s.segment_name
AND     t.tablespace_name = s.tablespace_name
AND     t.partition_name = s.partition_name
AND     t.segment_created = 'YES'
AND     (  t.num_rows = 0
        OR t.num_rows IS NULL
        )
AND     s.extents =  1
ORDER BY
        &&skip_noncdb.t.con_id,
        t.table_owner, t.table_name, t.partition_name
]';
END;
/
BRE ON REPORT;
COMP SUM LAB TOTAL OF hwm_blocks ON REPORT;
COMP SUM LAB TOTAL OF seg_blocks ON REPORT;
@@&&skip_ver_le_10.edb360_9a_pre_one.sql
CL BRE;
CL COMP;

DEF title = 'Subpartitions with one extent and no rows';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by David Kurtz
SELECT  /* LEADING(T) USE_NL(S) */ -- removed hint as per Luis Calvo
        &&skip_noncdb.t.con_id,
        t.table_owner, t.table_name, t.partition_name, t.subpartition_name, t.tablespace_name, t.num_rows, t.blocks hwm_blocks, t.last_analyzed, s.blocks seg_blocks
FROM    &&cdb_object_prefix.tab_subpartitions t
        &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = t.con_id
,       &&cdb_object_prefix.segments s
WHERE   '&&edb360_conf_incl_segments.' = 'Y'
AND     t.table_owner not in &&exclusion_list.
AND     t.table_owner not in &&exclusion_list2.
AND     s.segment_type = 'TABLE SUBPARTITION'
&&skip_noncdb.AND     t.con_id = s.con_id
AND     t.table_owner = s.owner
AND     t.table_name = s.segment_name
AND     t.subpartition_name = s.partition_name
AND     t.tablespace_name = s.tablespace_name
AND     t.segment_created = 'YES'
AND     (  t.num_rows = 0
        OR t.num_rows IS NULL
        )
AND     s.extents =  1
ORDER BY
        &&skip_noncdb.t.con_id,
        t.table_owner, t.table_name, t.partition_name, t.subpartition_name
]';
END;
/
BRE ON REPORT;
COMP SUM LAB TOTAL OF hwm_blocks ON REPORT;
COMP SUM LAB TOTAL OF seg_blocks ON REPORT;
@@&&skip_ver_le_10.edb360_9a_pre_one.sql
CL BRE;
CL COMP;

DEF title = 'Tables and their indexes larger than 1 GB';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
COL gb FOR 999990.000;
BEGIN
  :sql_text := q'[
WITH
tables AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       segment_name,
       SUM(bytes) bytes,
       COUNT(*) segments
  FROM &&cdb_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND segment_type LIKE 'TABLE%'
GROUP BY
       &&skip_noncdb.con_id,
       owner,
       segment_name
),
indexes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       segment_name,
       SUM(bytes) bytes,
       COUNT(*) segments
  FROM &&cdb_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND segment_type LIKE 'INDEX%'
GROUP BY
       &&skip_noncdb.con_id,
       owner,
       segment_name
),
idx_tbl AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.d.con_id,
       d.table_owner,
       d.table_name,
       SUM(i.bytes) bytes,
       SUM(i.segments) segments
  FROM indexes i,
       &&cdb_object_prefix.indexes d
WHERE i.owner = d.owner
  &&skip_noncdb.AND i.con_id = d.con_id
  AND i.segment_name = d.index_name
GROUP BY
       &&skip_noncdb.d.con_id,
       d.table_owner,
       d.table_name
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.t.con_id,
       t.owner,
       t.segment_name table_name,
       (t.bytes + NVL(i.bytes, 0)) bytes,
       t.bytes table_bytes,
       NVL(i.bytes, 0) indexes_bytes,
       (t.segments + NVL(i.segments, 0)) segs,
       t.segments tab_segs,
       NVL(i.segments, 0) idx_segs
  FROM tables t,
       idx_tbl i
WHERE t.owner = i.table_owner(+)
   &&skip_noncdb.AND t.con_id = i.con_id(+)
   AND t.segment_name = i.table_name(+)
)
SELECT &&skip_noncdb.con_id,
       owner,
       table_name,
       ROUND(bytes / POWER(10,9), 3) total_gb,
       ROUND(table_bytes / POWER(10,9), 3) table_gb,
       ROUND(indexes_bytes / POWER(10,9), 3) indexes_gb,
       segs,
       tab_segs,
       idx_segs
  FROM total
WHERE bytes > POWER(10,9)
ORDER BY
       bytes DESC NULLS LAST
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Indexes larger than their Table';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
COL gb FOR 999990.000;
BEGIN
  :sql_text := q'[
WITH
tables AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       segment_name,
       SUM(bytes) bytes
  FROM &&cdb_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND segment_type LIKE 'TABLE%'
GROUP BY
       &&skip_noncdb.con_id,
       owner,
       segment_name
),
indexes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       owner,
       segment_name,
       SUM(bytes) bytes
  FROM &&cdb_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND segment_type LIKE 'INDEX%'
GROUP BY
       &&skip_noncdb.con_id,
       owner,
       segment_name
),
idx_tbl AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.d.con_id,
       d.table_owner,
       d.table_name,
       d.owner,
       d.index_name,
       SUM(i.bytes) bytes
  FROM indexes i,
       &&cdb_object_prefix.indexes d
WHERE i.owner = d.owner
   &&skip_noncdb.AND i.con_id = d.con_id
   AND i.segment_name = d.index_name
GROUP BY
       &&skip_noncdb.d.con_id,
       d.table_owner,
       d.table_name,
       d.owner,
       d.index_name
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.t.con_id,
       t.owner table_owner,
       t.segment_name table_name,
       t.bytes t_bytes,
       i.owner index_owner,
       i.index_name,
       i.bytes i_bytes
  FROM tables t,
       idx_tbl i
WHERE t.owner = i.table_owner
   &&skip_noncdb.AND t.con_id = i.con_id
   AND t.segment_name = i.table_name
   AND i.bytes > t.bytes
   AND t.bytes > POWER(10,7) /* 10M */
)
SELECT &&skip_noncdb.con_id,
       table_owner,
       table_name,
       ROUND(t_bytes / POWER(10,9), 3) table_gb,
       index_owner,
       index_name,
       ROUND(i_bytes / POWER(10,9), 3) index_gb,
       ROUND((i_bytes - t_bytes) / POWER(10,9), 3) dif_gb,
       ROUND(100 * (i_bytes - t_bytes) / t_bytes, 1) dif_perc
  FROM total
ORDER BY
       &&skip_noncdb.con_id,
      table_owner,
       table_name,
       index_owner,
       index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Candidate Tables for Partitioning';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.t.con_id,
	   t.owner, t.table_name, t.blocks, t.block_size,
       ROUND(t.blocks * t.block_size / POWER(10,6)) mb,
       num_rows, avg_row_len, degree, sample_size, last_analyzed
	   &&skip_noncdb.,c.name con_name
  from &&cdb_object_prefix.tables t
      ,&&cdb_object_prefix.tablespaces s
 where s.tablespace_name = t.tablespace_name
   &&skip_noncdb.AND s.con_id = t.con_id
   and (t.blocks * t.block_size / POWER(10,6)) >= POWER(10,3)
   and t.partitioned = 'NO'
   and t.owner not in &&exclusion_list.
   and t.owner not in &&exclusion_list2.
order by
       &&skip_noncdb.t.con_id,
	   t.owner, mb desc
]';
END;
/
--@@edb360_9a_pre_one.sql (redundant with "Largest 200 Objects")

DEF title = 'Temporary Segments in Permanent Tablespaces';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- http://askdba.org/weblog/2009/07/cleanup-temporary-segments-in-permanent-tablespace/
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
tablespace_name, owner, segment_name,
ROUND(sum(bytes/POWER(10,6))) mega_bytes
from &&dva_object_prefix.segments
where '&&edb360_conf_incl_segments.' = 'Y'
and segment_type = 'TEMPORARY'
group by tablespace_name, owner, segment_name
having ROUND(sum(bytes/POWER(10,6))) > 0
order by tablespace_name, owner, segment_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Segments in Reserved Tablespaces';
DEF main_table = '&&cdb_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
	   s.owner, s.segment_type, s.tablespace_name, COUNT(1) segments
  FROM &&cdb_object_prefix.segments s
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND s.owner NOT IN ('SYS','SYSTEM','OUTLN','AURORA$JIS$UTILITY$','OSE$HTTP$ADMIN','ORACACHE','ORDSYS',
                       'CTXSYS','DBSNMP','DMSYS','EXFSYS','MDSYS','OLAPSYS','SYSMAN','TSMSYS','WMSYS','XDB',
                       'GSMADMIN_INTERNAL'
                      )
   AND s.tablespace_name IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM &&cdb_object_prefix.tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')
                                )
   AND s.owner not in &&exclusion_list.
   AND s.owner not in &&exclusion_list2.
 GROUP BY &&skip_noncdb.s.con_id,
          s.owner, s.segment_type, s.tablespace_name
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY &&skip_noncdb.x.con_id,
          x.owner, x.segment_type, x.tablespace_name
]';
END;
/
BRE ON REPORT;
COMP SUM LAB TOTAL OF segments ON REPORT;
@@edb360_9a_pre_one.sql
CL BRE;
CL COMP;

DEF title = 'Segment Shrink Recommendations';
DEF main_table = 'DBMS_SPACE';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
FROM TABLE(dbms_space.asa_recommendations())
Where segment_owner not in &&exclusion_list. and
   segment_owner not in &&exclusion_list2.
order by reclaimable_space desc
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Objects in Recycle Bin';
DEF main_table = '&&cdb_view_prefix.RECYCLEBIN';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.recyclebin x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.owner NOT IN &&exclusion_list.
   AND x.owner NOT IN &&exclusion_list2.
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.owner,
       x.object_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Consumers of Recycle Bin';
DEF main_table = '&&dva_view_prefix.RECYCLEBIN';
BEGIN
  :sql_text := q'[
-- requested by Dimas Chbane
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.r.con_id,
	   ROUND(SUM(r.space * t.block_size) / POWER(10,6)) mb_space,
       r.owner
  FROM &&cdb_object_prefix.recyclebin r,
       &&cdb_object_prefix.tablespaces t
 WHERE r.ts_name = t.tablespace_name
   &&skip_noncdb.AND r.con_id = t.con_id
 GROUP BY
       &&skip_noncdb.r.con_id,
	   r.owner
HAVING ROUND(SUM(r.space * t.block_size) / POWER(10,6)) > 0
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       1 DESC, 2
]';
END;
/
@@edb360_9a_pre_one.sql

/****************************************************************************************/

-- add seq to spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&common_edb360_prefix._&&section_id._&&report_sequence._tables_with_actual_size_greater_than_estimated' one_spool_filename FROM DUAL;
SPO &&edb360_output_directory.&&one_spool_filename..txt

-- SELECT only those tables with an estimated space saving percent greater than 25%
VAR savings_percent NUMBER;
EXEC :savings_percent := 25;
-- SELECT only tables with current size (as per cbo stats) greater then 10MB
VAR minimum_size_mb NUMBER;
EXEC :minimum_size_mb := 10;

SET SERVEROUT ON ECHO OFF FEED OFF VER OFF TAB OFF LINES 300;

COL report_date NEW_V report_date;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') report_date FROM DUAL;

DECLARE
  l_used_bytes  NUMBER;
  l_alloc_bytes NUMBER;
  l_percent     NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('PDB: '||SYS_CONTEXT('USERENV', 'CON_NAME'));
  DBMS_OUTPUT.PUT_LINE('---');
  DBMS_OUTPUT.PUT_LINE(
    RPAD('OWNER.TABLE_NAME', 35)||' '||
    LPAD('SAVING %', 10)||' '||
    LPAD('CURRENT SIZE', 20)||' '||
    LPAD('ESTIMATED SIZE', 20)||'  '||
    RPAD('COMMAND', 150));
  DBMS_OUTPUT.PUT_LINE(
    RPAD('-', 35, '-')||' '||
    LPAD('-', 10, '-')||' '||
    LPAD('-', 20, '-')||' '||
    LPAD('-', 20, '-')||'  '||
    RPAD('-', 150, '-'));
  FOR i IN (SELECT x.table_name, x.owner,
                   x.tablespace_name, MAX(s.avg_row_len) avg_row_len, SUM(s.num_rows) num_rows, x.pct_free,
                   SUM(s.blocks) * TO_NUMBER(p.value) table_size,
                   REPLACE(DBMS_METADATA.GET_DDL('TABLE',x.table_name,x.owner),CHR(10),CHR(32)) ddl
              FROM dba_tab_statistics s, dba_tables x, dba_users u, v$parameter p
             WHERE x.owner NOT IN &&exclusion_list. -- exclude non-application schemas
               AND x.owner NOT IN &&exclusion_list2. -- exclude more non-application schemas
               &&skip_ver_le_11.AND u.oracle_maintained = 'N'
               AND x.owner = u.username
               AND x.tablespace_name NOT IN ('SYSTEM','SYSAUX')
               AND x.iot_type IS NULL
               AND x.nested = 'NO'
               AND x.status = 'VALID'
               AND x.temporary = 'N'
               AND x.dropped = 'NO'
               &&skip_ver_le_11.AND x.segment_created = 'YES'
               AND p.name = 'db_block_size'
               AND s.owner = x.owner
               AND s.table_name = x.table_name
             GROUP BY
                   x.tablespace_name, x.table_name, x.owner, x.pct_free, p.value
             HAVING
                   SUM(s.blocks) * TO_NUMBER(p.value) > :minimum_size_mb * POWER(2,20)
	       AND SUM(s.num_rows) > 0
	       AND MAX(s.avg_row_len) > 0
             ORDER BY
                   table_size DESC)
  LOOP
    DBMS_SPACE.CREATE_TABLE_COST(i.tablespace_name,i.avg_row_len,i.num_rows,i.pct_free,l_used_bytes,l_alloc_bytes);
    IF i.table_size * (100 - :savings_percent) / 100 > l_alloc_bytes THEN
      l_percent := 100 * (i.table_size - l_alloc_bytes) / i.table_size;
      DBMS_OUTPUT.PUT_LINE(
        RPAD(i.owner||'.'||i.table_name, 35)||' '||
        LPAD(TO_CHAR(ROUND(l_percent, 1), '990.0')||' % ', 10)||' '||
        LPAD(TO_CHAR(ROUND(i.table_size / POWER(2,20), 1), '999,999,990.0')||' MB', 20)||' '||
        LPAD(TO_CHAR(ROUND(l_alloc_bytes / POWER(2,20), 1), '999,999,990.0')||' MB', 20)||'  '||
        RPAD('EXEC DBMS_REDEFINITION.REDEF_TABLE(uname=>'''||LOWER(i.owner)||''',tname=>'''||LOWER(i.table_name)||''',table_part_tablespace=>'''||LOWER(i.tablespace_name)||''');', 150));
    END IF;
  END LOOP;
END;
/

SPO OFF
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.&&one_spool_filename..txt >> &&edb360_log3..txt
-- update main report
SPO &&edb360_main_report..html APP;
PRO <li title="&&dva_view_prefix.TABLES">Tables with actual size greater than estimated
PRO <a href="&&one_spool_filename..txt">text</a>
PRO </li>
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt
-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

/****************************************************************************************/

DEF title = 'Tables with excessive wasted space';
DEF main_table = '&&cdb_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
WITH x AS (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
      (ROUND(SUM(s.blocks) * x.block_size / POWER(10,6))) -
      (ROUND(SUM(s.num_rows) * MAX(s.avg_row_len) * (1+(t.pct_free/100)) * DECODE(t.compression,'ENABLED',0.50,1.00) / POWER(10,6))) over_allocated_mb,
      &&skip_noncdb.t.con_id,
      t.owner, t.table_name, SUM(s.blocks), x.block_size, t.pct_free,
      ROUND(SUM(s.blocks) * x.block_size / POWER(10,6)) actual_mb,
      ROUND(SUM(s.num_rows) * MAX(s.avg_row_len) * (1+(t.pct_free/100)) * DECODE(t.compression,'ENABLED',0.50,1.00) / POWER(10,6)) estimate_mb,
      SUM(s.num_rows), MAX(s.avg_row_len), t.compression
from  &&cdb_object_prefix.tables t,
      &&cdb_object_prefix.tab_statistics s,
      &&cdb_object_prefix.tablespaces x
where s.owner = t.owner
&&skip_noncdb.and   s.con_id = t.con_id
and   s.table_name = t.table_name
&&skip_noncdb.and   x.con_id = t.con_id
and   x.tablespace_name = t.tablespace_name
and   t.owner not in &&exclusion_list.
and   t.owner not in &&exclusion_list2.
group by
      &&skip_noncdb.t.con_id,
   t.owner, t.table_name, x.block_size, t.pct_free, t.compression
having
   (SUM(s.blocks) * x.block_size / POWER(10,6)) >= 100 and -- actual_mb
      abs(ROUND(SUM(s.blocks) * x.block_size / POWER(10,6)) - ROUND(SUM(s.num_rows) * MAX(s.avg_row_len) * (1+(t.pct_free/100)) * DECODE(t.compression,'ENABLED',0.50,1.00) / POWER(10,6))) /
      (ROUND(SUM(s.blocks) * x.block_size / POWER(10,6))) >= 0.25
	  )
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       1 desc,
	   &&skip_noncdb.x.con_id,
       x.owner, x.table_name
]';
END;
/
@@edb360_9a_pre_one.sql

/****************************************************************************************/

-- special addition from https://carlos-sierra.net/2017/07/12/script-to-identify-index-rebuild-candidates-on-12c/
-- add seq to spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&common_edb360_prefix._&&section_id._&&report_sequence._indexes_with_actual_size_greater_than_estimated' one_spool_filename FROM DUAL;
SPO &&edb360_output_directory.&&one_spool_filename..txt

-- select only those indexes with an estimated space saving percent greater than 25%
VAR savings_percent NUMBER;
EXEC :savings_percent := 25;
-- select only indexes with current size (as per cbo stats) greater then 10MB
VAR minimum_size_mb NUMBER;
EXEC :minimum_size_mb := 10;

SET SERVEROUT ON ECHO OFF FEED OFF VER OFF TAB OFF LINES 300;

COL report_date NEW_V report_date;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') report_date FROM DUAL;

DECLARE
  l_used_bytes  NUMBER;
  l_alloc_bytes NUMBER;
  l_percent     NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('PDB: '||SYS_CONTEXT('USERENV', 'CON_NAME'));
  DBMS_OUTPUT.PUT_LINE('---');
  DBMS_OUTPUT.PUT_LINE(
    RPAD('TABLE_NAME', 30)||' '||
    RPAD('OWNER.INDEX_NAME', 35)||' '||
    LPAD('SAVING %', 10)||' '||
    LPAD('CURRENT SIZE', 20)||' '||
    LPAD('ESTIMATED SIZE', 20)||'  '||
    RPAD('COMMAND', 75));
  DBMS_OUTPUT.PUT_LINE(
    RPAD('-', 30, '-')||' '||
    RPAD('-', 35, '-')||' '||
    LPAD('-', 10, '-')||' '||
    LPAD('-', 20, '-')||' '||
    LPAD('-', 20, '-')||'  '||
    RPAD('-', 75, '-'));
  FOR i IN (SELECT x.table_name, x.owner, x.index_name, SUM(s.leaf_blocks) * TO_NUMBER(p.value) index_size,
                   REPLACE(DBMS_METADATA.GET_DDL('INDEX',x.index_name,x.owner),CHR(10),CHR(32)) ddl
              FROM dba_ind_statistics s, dba_indexes x, dba_users u, v$parameter p
             WHERE x.owner NOT IN &&exclusion_list. -- exclude non-application schemas
               AND x.owner NOT IN &&exclusion_list2. -- exclude more non-application schemas
               &&skip_ver_le_11.AND u.oracle_maintained = 'N'
               AND x.owner = u.username
               AND x.tablespace_name NOT IN ('SYSTEM','SYSAUX')
               AND x.index_type LIKE '%NORMAL%'
               AND x.table_type = 'TABLE'
               AND x.status = 'VALID'
               AND x.temporary = 'N'
               AND x.dropped = 'NO'
               &&skip_ver_le_11.AND x.visibility = 'VISIBLE'
               &&skip_ver_le_11.AND x.segment_created = 'YES'
               &&skip_ver_le_11.AND x.orphaned_entries = 'NO'
               AND p.name = 'db_block_size'
               AND s.owner = x.owner
               AND s.index_name = x.index_name
             GROUP BY
                   x.table_name, x.owner, x.index_name, p.value
             HAVING
                   SUM(s.leaf_blocks) * TO_NUMBER(p.value) > :minimum_size_mb * POWER(2,20)
             ORDER BY
                   index_size DESC)
  LOOP
    DBMS_SPACE.CREATE_INDEX_COST(i.ddl,l_used_bytes,l_alloc_bytes);
    IF i.index_size * (100 - :savings_percent) / 100 > l_alloc_bytes THEN
      l_percent := 100 * (i.index_size - l_alloc_bytes) / i.index_size;
      DBMS_OUTPUT.PUT_LINE(
        RPAD(i.table_name, 30)||' '||
        RPAD(i.owner||'.'||i.index_name, 35)||' '||
        LPAD(TO_CHAR(ROUND(l_percent, 1), '990.0')||' % ', 10)||' '||
        LPAD(TO_CHAR(ROUND(i.index_size / POWER(2,20), 1), '999,999,990.0')||' MB', 20)||' '||
        LPAD(TO_CHAR(ROUND(l_alloc_bytes / POWER(2,20), 1), '999,999,990.0')||' MB', 20)||'  '||
        RPAD('ALTER INDEX '||LOWER(i.owner||'.'||i.index_name)||' REBUILD ONLINE;', 75));
    END IF;
  END LOOP;
END;
/

SPO OFF
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.&&one_spool_filename..txt >> &&edb360_log3..txt
-- update main report
SPO &&edb360_main_report..html APP;
PRO <li title="&&dva_view_prefix.INDEXES">Indexes with actual size greater than estimated
PRO <a href="&&one_spool_filename..txt">text</a>
PRO </li>
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt
-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

/****************************************************************************************/

DEF title = 'Tables over 10GB and no partitions';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
Select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       t.owner, t.table_name, t.blocks, s.block_size, t.blocks*s.block_size bytes,
       Case When t.blocks*s.block_size between 1024*1024*1024      and 1024*1024*1024*1024-1
                 Then to_char(round(t.blocks*s.block_size /1024/1024/1024          ),'9999') ||' Gb'
            When t.blocks*s.block_size between 1024*1024*1024      and 1024*1024*1024*1024*1024-1
                 Then to_char(round(t.blocks*s.block_size /1024/1024/1024/1024     ),'9999') ||' Tb'
            When t.blocks*s.block_size between 1024*1024*1024*1024 and 1024*1024*1024*1024*1024*1024-1
                 Then to_char(round(t.blocks*s.block_size /1024/1024/1024/1024/1024),'9999') ||' Pb'
       Else To_char(t.blocks*s.block_size) End  display
From   &&dva_object_prefix.tables t, &&dva_object_prefix.tablespaces s
Where  t.tablespace_name = s.tablespace_name
And    t.blocks*s.block_size > 10*1024*1024*1024
And    t.partitioned='NO'
And    t.owner Not In &&exclusion_list.
And    t.owner Not In &&exclusion_list2.
order by blocks desc
]';
END;
/

@@edb360_9a_pre_one.sql

/****************************************************************************************/

/*
DEF title = 'Indexes with actual size greater than estimated';
DEF abstract = 'Actual and Estimated sizes for Indexes.<br />';
DEF main_table = '&&dva_view_prefix.INDEXES';
VAR random1 VARCHAR2(30);
VAR random2 VARCHAR2(30);
EXEC :random1 := DBMS_RANDOM.string('A', 30);
EXEC :random2 := DBMS_RANDOM.string('X', 30);
COL random1 NEW_V random1 FOR A30;
COL random2 NEW_V random2 FOR A30;
SELECT :random1 random1, :random2 random2 FROM DUAL;
DELETE plan_table WHERE statement_id IN (:random1, :random2);
SET SERVEROUT ON;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
-- log
SPO &&edb360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&title.
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
DECLARE
  sql_text CLOB;
BEGIN
  IF '&&edb360_conf_incl_metadata.' = 'Y' /*AND '&&db_version.' < '11.2.0.3'* / AND '&&db_version.' >= '11.2.0.4' THEN -- avoids DBMS_METADATA.GET_DDL: Query Against SYS.KU$_INDEX_VIEW Is Slow In 11.2.0.3 as per 1459841.1
    FOR i IN (SELECT idx.owner, idx.index_name
                FROM &&dva_object_prefix.indexes idx,
                     &&dva_object_prefix.tables tbl
               WHERE idx.owner NOT IN &&exclusion_list. -- exclude non-application schemas
                 AND idx.owner NOT IN &&exclusion_list2. -- exclude more non-application schemas
                 AND idx.index_type IN ('NORMAL', 'FUNCTION-BASED NORMAL', 'BITMAP', 'NORMAL/REV') -- exclude domain and lob
                 AND idx.status != 'UNUSABLE' -- only valid indexes
                 AND idx.temporary = 'N'
                 AND tbl.owner = idx.table_owner
                 AND tbl.table_name = idx.table_name
                 AND tbl.last_analyzed IS NOT NULL -- only tables with statistics
                 AND tbl.num_rows > 0 -- only tables with rows as per statistics
                 AND tbl.blocks > 128 -- skip small tables
                 AND tbl.temporary = 'N')
    LOOP
      BEGIN
        sql_text :=  'EXPLAIN PLAN SET STATEMENT_ID = '''||:random1||''' FOR '||REPLACE(DBMS_METADATA.get_ddl('INDEX', i.index_name, i.owner), CHR(10), ' ');
        -- cbo estimates index size based on explain plan for create index ddl
        EXECUTE IMMEDIATE sql_text;
        -- index owner and name do not fit on statement_id, thus using object_owner and object_name, using statement_id as processing state
        DELETE plan_table WHERE statement_id = :random1 AND (other_xml IS NULL OR NVL(DBMS_LOB.instr(other_xml, 'index_size'), 0) = 0);
        UPDATE plan_table SET object_owner = i.owner, object_name = i.index_name, statement_id = :random2 WHERE statement_id = :random1;
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE(i.owner||'.'||i.index_name||': '||SQLERRM);
          DBMS_OUTPUT.PUT_LINE(DBMS_LOB.substr(sql_text));
      END;
    END LOOP;
  ELSE
    DBMS_OUTPUT.PUT_LINE('*** skip on &&db_version. as per MOS 1459841.1');
  END IF;
END;
/
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
SPO OFF;
SET SERVEROUT OFF;

BEGIN
  :sql_text := q'[
-- from estimate_index_size.sql
-- http://carlos-sierra.net/2014/07/18/free-script-to-very-quickly-and-cheaply-estimate-the-size-of-an-index-if-it-were-to-be-rebuilt/
WITH
indexes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. * /
       pt.object_owner,
       pt.object_name,
       TO_NUMBER(EXTRACTVALUE(VALUE(d), '/info')) estimated_bytes
  FROM plan_table pt,
       TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(pt.other_xml), '/other_xml/info'))) d
 WHERE pt.statement_id = '&&random2.'
   AND pt.other_xml IS NOT NULL -- redundant
   AND DBMS_LOB.instr(pt.other_xml, 'index_size') > 0 -- redundant
   AND EXTRACTVALUE(VALUE(d), '/info/@type') = 'index_size' -- grab index_size type
),
segments AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. * /
       owner, segment_name, SUM(bytes) actual_bytes
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND owner NOT IN &&exclusion_list. -- exclude non-application schemas
   AND owner NOT IN &&exclusion_list2. -- exclude more non-application schemas
   AND segment_type LIKE 'INDEX%'
HAVING SUM(bytes) > POWER(10,6) -- only indexes with actual size > 1 MB
 GROUP BY
       owner,
       segment_name
),
list_bytes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. * /
       (s.actual_bytes - i.estimated_bytes) actual_minus_estimated,
       s.actual_bytes,
       i.estimated_bytes,
       i.object_owner,
       i.object_name
  FROM indexes i,
       segments s
 WHERE i.estimated_bytes > POWER(10,6) -- only indexes with estimated size > 1 MB
   AND s.owner(+) = i.object_owner
   AND s.segment_name(+) = i.object_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. * /
       ROUND(actual_minus_estimated / POWER(10,6)) actual_minus_estimated,
       ROUND(actual_bytes / POWER(10,6)) actual_mb,
       ROUND(estimated_bytes / POWER(10,6)) estimated_mb,
       object_owner owner,
       object_name index_name
  FROM list_bytes
 WHERE actual_minus_estimated > POWER(10,6) -- only differences > 1 MB
 ORDER BY
       1 DESC,
       object_owner,
       object_name
]';
END;
/
@@edb360_9a_pre_one.sql
DELETE plan_table WHERE statement_id IN (:random1, :random2);
*/

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

COL temporary_tablespace clear
