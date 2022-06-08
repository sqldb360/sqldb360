@@&&edb360_0g.tkprof.sql
DEF section_id = '2d';
DEF section_name = 'Backup and Recovery';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Block Corruption';
DEF main_table = '&&v_view_prefix.DATABASE_BLOCK_CORRUPTION';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.database_block_corruption
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Nonlogged Datafile Blocks';
DEF main_table = '&&v_view_prefix.NONLOGGED_BLOCK';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.nonlogged_block
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Blocks with Corruption or Nonlogged';
DEF main_table = '&&v_view_prefix.DATABASE_BLOCK_CORRUPTION';
BEGIN
  :sql_text := q'[
With -- requested by Gabriel Alonso
CORR  As (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.e.con_id,
       e.owner, e.segment_type, e.segment_name, e.partition_name, c.file#
     , greatest(e.block_id, c.block#) corr_start_block#
     , least(e.block_id+e.blocks-1, c.block#+c.blocks-1) corr_end_block#
     , least(e.block_id+e.blocks-1, c.block#+c.blocks-1)
       - greatest(e.block_id, c.block#) + 1 blocks_corrupted
     , null description
  FROM &&cdb_object_prefix.extents e, &&v_object_prefix.database_block_corruption c
WHERE e.file_id = c.file#
   AND e.block_id <= c.block# + c.blocks - 1
   AND e.block_id + e.blocks - 1 >= c.block#
   &&skip_noncdb.AND e.con_id = c.con_id
UNION
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
       s.owner, s.segment_type, s.segment_name, s.partition_name, c.file#
     , header_block corr_start_block#
     , header_block corr_end_block#
     , 1 blocks_corrupted
     , 'Segment Header' description
  FROM &&cdb_object_prefix.segments s, &&v_object_prefix.database_block_corruption c
WHERE s.header_file = c.file#
   AND s.header_block between c.block# and c.block# + c.blocks - 1
   &&skip_noncdb.AND s.con_id = c.con_id
UNION
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.f.con_id,
       null owner, null segment_type, null segment_name, null partition_name, c.file#
     , greatest(f.block_id, c.block#) corr_start_block#
     , least(f.block_id+f.blocks-1, c.block#+c.blocks-1) corr_end_block#
     , least(f.block_id+f.blocks-1, c.block#+c.blocks-1)
       - greatest(f.block_id, c.block#) + 1 blocks_corrupted
     , 'Free Block' description
  FROM &&cdb_object_prefix.free_space f, &&v_object_prefix.database_block_corruption c
WHERE f.file_id = c.file#
   AND f.block_id <= c.block# + c.blocks - 1
   AND f.block_id + f.blocks - 1 >= c.block#
   &&skip_noncdb.AND f.con_id = c.con_id
),NOLOG As (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.e.con_id,
       e.owner, e.segment_type, e.segment_name, e.partition_name, c.file#
     , greatest(e.block_id, c.block#) corr_start_block#
     , least(e.block_id+e.blocks-1, c.block#+c.blocks-1) corr_end_block#
     , least(e.block_id+e.blocks-1, c.block#+c.blocks-1)
       - greatest(e.block_id, c.block#) + 1 blocks_corrupted
     , null description
  FROM &&cdb_object_prefix.extents e, &&v_object_prefix.nonlogged_block c
WHERE e.file_id = c.file#
   AND e.block_id <= c.block# + c.blocks - 1
   AND e.block_id + e.blocks - 1 >= c.block#
   &&skip_noncdb.AND e.con_id = c.con_id
UNION
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
       s.owner, s.segment_type, s.segment_name, s.partition_name, c.file#
     , header_block corr_start_block#
     , header_block corr_end_block#
     , 1 blocks_corrupted
     , 'Segment Header' description
  FROM &&cdb_object_prefix.segments s, &&v_object_prefix.nonlogged_block c
 WHERE s.header_file = c.file#
   AND s.header_block between c.block# and c.block# + c.blocks - 1
   &&skip_noncdb.AND s.con_id = c.con_id
UNION
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.f.con_id,
       null owner, null segment_type, null segment_name, null partition_name, c.file#
     , greatest(f.block_id, c.block#) corr_start_block#
     , least(f.block_id+f.blocks-1, c.block#+c.blocks-1) corr_end_block#
     , least(f.block_id+f.blocks-1, c.block#+c.blocks-1)
       - greatest(f.block_id, c.block#) + 1 blocks_corrupted
     , 'Free Block' description
  FROM &&cdb_object_prefix.free_space f, &&v_object_prefix.nonlogged_block  c
WHERE f.file_id = c.file#
   AND f.block_id <= c.block# + c.blocks - 1
   AND f.block_id + f.blocks - 1 >= c.block#
   &&skip_noncdb.AND f.con_id = c.con_id
), x as (
Select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ * from corr
Union
Select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ * from nolog
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.file#, x.corr_start_block#
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Block Change Tracking';
DEF main_table = '&&v_view_prefix.BLOCK_CHANGE_TRACKING';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.block_change_tracking
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'RMAN Backup Job Details';
DEF main_table = '&&v_view_prefix.RMAN_BACKUP_JOB_DETAILS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.rman_backup_job_details
 --WHERE start_time >= (SYSDATE - 100)
 ORDER BY
       start_time DESC
]';
END;
/
-- skipped on 10g due to bug as per mos 420200.1
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'RMAN Backup Set Details';
DEF main_table = '&&v_view_prefix.BACKUP_SET_DETAILS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.backup_set_details
 ORDER BY
       1, 2, 3, 4, 5
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'RMAN Output';
DEF main_table = '&&v_view_prefix.RMAN_OUTPUT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.rman_output
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'RMAN Backup Summary';
DEF main_table = '&&v_view_prefix.BACKUP_SET_DETAILS';
BEGIN
  :sql_text := q'[
  -- requested by David Loinaz
WITH list AS (SELECT session_stamp,
               CASE WHEN backup_type = 'D' then
                     CASE WHEN CONTROLFILE_INCLUDED = 'YES' then
                        'CONTROLFILE'
                     ELSE
                        'FULL'
                     END
                   WHEN backup_type = 'I' THEN
                     CASE INCREMENTAL_LEVEL WHEN 0 then
                        'INC LEVEL 0'
                     ELSE
                        'INC LEVEL 1'
                     END
                    WHEN backup_type = 'L' then
                     'ARCHIVELOG'
               END BACKUP_TYPE,
               start_time, completion_time, output_bytes
              FROM &&v_object_prefix.backup_set_details
              ORDER BY 1),
       bck AS (SELECT session_stamp, backup_type, min(start_time) start_time,
                  max(completion_time) completion_time, sum(output_bytes) output_bytes, count(1) CNT
               FROM list
               GROUP BY session_stamp, backup_type
               ORDER BY session_stamp, start_time)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
        session_stamp, backup_type,
        decode(to_char(start_time, 'd'), 1, 'Sunday', 2, 'Monday',
                                         3, 'Tuesday', 4, 'Wednesday',
                                         5, 'Thursday', 6, 'Friday',
                                         7, 'Saturday') dow,
        start_time, completion_time, output_bytes,
        CASE
          WHEN output_bytes BETWEEN 0 AND 1023 THEN output_bytes ||' Bytes'
          WHEN output_bytes < POWER(1024,2) THEN ROUND(output_bytes / 1024,2) ||' KB'
          WHEN output_bytes < POWER(1024,3) THEN ROUND(output_bytes / POWER(1024,2),2) ||' MB'
          WHEN output_bytes < POWER(1024,4) THEN ROUND(output_bytes / POWER(1024,3),2) ||' GB'
          WHEN output_bytes < POWER(1024,5) THEN ROUND(output_bytes / POWER(1024,4),2) ||' TB'
          WHEN output_bytes < POWER(1024,6) THEN ROUND(output_bytes / POWER(1024,5),2) ||' PB'
          WHEN output_bytes < POWER(1024,7) THEN ROUND(output_bytes / POWER(1024,6),2) ||' EB'
          WHEN output_bytes < POWER(1024,8) THEN ROUND(output_bytes / POWER(1024,7),2) ||' ZB'
          WHEN output_bytes < POWER(1024,9) THEN ROUND(output_bytes / POWER(1024,8),2) ||' YB'
         ELSE
          'Invalid value for bytes'
         END "Output Size", cnt "Set Count"
FROM bck
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Fast Recovery Area';
DEF main_table = '&&v_view_prefix.RECOVERY_FILE_DEST';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.recovery_file_dest
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Fast Recovery Area Usage';
DEF main_table = '&&v_view_prefix.RECOVERY_AREA_USAGE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.recovery_area_usage
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Restore Point';
DEF main_table = '&&v_view_prefix.RESTORE_POINT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.restore_point
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Flashback Statistics';
DEF main_table = '&&gv_view_prefix.FLASHBACK_DATABASE_STAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.flashback_database_stat
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Flashback Log';
DEF main_table = '&&gv_view_prefix.FLASHBACK_DATABASE_LOG';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.flashback_database_log
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'REDO LOG';
DEF main_table = '&&v_view_prefix.LOG';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
     *
  FROM &&v_object_prefix.log
 ORDER BY 1, 2, 3, 4
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'REDO LOG Files';
DEF main_table = '&&v_view_prefix.LOGFILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
     *
  FROM &&v_object_prefix.logfile
 ORDER BY 1, 2, 3, 4
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'REDO LOG History';
DEF main_table = '&&v_view_prefix.LOG_HISTORY';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
 THREAD#, TO_CHAR(trunc(FIRST_TIME), 'YYYY-MON-DD') day, count(*)
FROM &&v_object_prefix.log_history
where FIRST_TIME >= (sysdate - 31)
group by rollup(THREAD#, trunc(FIRST_TIME))
order by THREAD#, trunc(FIRST_TIME)
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'REDO LOG Switches Frequency Map';
DEF main_table = '&&v_view_prefix.LOG_HISTORY';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := q'[
-- requested by Weidong
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       thread#,
       TO_CHAR(TRUNC(first_time), 'YYYY-MM-DD') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), 'Dy') day,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '00', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '01', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '02', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '03', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '04', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '05', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '06', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '07', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '08', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '09', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '10', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '11', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '12', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '13', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '14', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '15', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '16', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '17', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '18', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '19', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '20', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '21', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '22', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '23', 1, 0)) h23,
       COUNT(*) per_day
  FROM &&v_object_prefix.log_history
 GROUP BY
       thread#,
       TRUNC(first_time)
 ORDER BY
       thread#,
       TRUNC(first_time) DESC NULLS LAST
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ROWNUM row_num_noprint, log.*
  FROM log
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       thread#,
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
 GROUP BY
       thread#
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.thread# = ms.thread#
   AND log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.thread#,
       log.yyyy_mm_dd DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ARCHIVED LOG';
DEF main_table = '&&v_view_prefix.ARCHIVED_LOG';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&v_object_prefix.archived_log
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ARCHIVED LOG Frequency Map per Thread';
DEF main_table = '&&v_view_prefix.ARCHIVED_LOG';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := q'[
-- requested by Abdul Khan and Srinivas Kanaparthy
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       --DISTINCT
       thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM &&v_object_prefix.archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       thread#,
       TO_CHAR(TRUNC(first_time), 'YYYY-MM-DD') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), 'Dy') day,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '00', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '01', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '02', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '03', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '04', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '05', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '06', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '07', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '08', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '09', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '10', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '11', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '12', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '13', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '14', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '15', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '16', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '17', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '18', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '19', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '20', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '21', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '22', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '23', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(10,9), 1) TOT_GB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(10,9) / COUNT(*), 1) AVG_GB
  FROM log
 GROUP BY
       thread#,
       TRUNC(first_time)
 ORDER BY
       thread#,
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       thread#,
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
 GROUP BY
       thread#
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.thread# = ms.thread#
   AND log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.thread#,
       log.yyyy_mm_dd DESC
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ARCHIVED LOG Frequency Map per Cluster';
DEF main_table = '&&v_view_prefix.ARCHIVED_LOG';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := q'[
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       --DISTINCT
       thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM &&v_object_prefix.archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       TO_CHAR(TRUNC(first_time), 'YYYY-MM-DD') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), 'Dy') day,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '00', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '01', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '02', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '03', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '04', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '05', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '06', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '07', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '08', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '09', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '10', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '11', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '12', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '13', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '14', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '15', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '16', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '17', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '18', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '19', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '20', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '21', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '22', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '23', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(10,9), 1) TOT_GB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(10,9) / COUNT(*), 1) AVG_GB
  FROM log
 GROUP BY
       TRUNC(first_time)
 ORDER BY
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.yyyy_mm_dd DESC
]';
END;
/
@@edb360_9a_pre_one.sql

-- special contribution from David Mann
-- http://ba6.us/?q=ArchivedLogRedoInGB_HeatMap
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&common_edb360_prefix._&&section_id._&&report_sequence._archived_redo_log_heat_map' one_spool_filename FROM DUAL;
SET SERVEROUT ON
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SPO &&edb360_output_directory.&&one_spool_filename..html
@@2016-03-08-RedoLogSizeHeatMap.sql
SPO OFF
SET SERVEROUT OFF
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.&&one_spool_filename..html >> &&edb360_log3..txt
-- update main report
SPO &&edb360_main_report..html APP;
PRO <li title="&&v_view_prefix.ARCHIVED_LOG">ARCHIVED REDO LOG Heat Map for past 31 Days
PRO <a href="&&one_spool_filename..html">html</a>
PRO </li>
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt
-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

DEF title = 'NOLOGGING Objects';
DEF main_table = '&&cdb_view_prefix.TABLESPACES';
BEGIN
  :sql_text := q'[
WITH
objects AS (
SELECT 1 record_type,
       'TABLESPACE' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       NULL owner,
       NULL name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM &&cdb_object_prefix.tablespaces
 WHERE logging = 'NOLOGGING'
   AND contents != 'TEMPORARY'
UNION ALL
SELECT 2 record_type,
       'TABLE' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       owner,
       table_name name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM &&cdb_object_prefix.all_tables
 WHERE logging = 'NO'
   AND temporary = 'N'
UNION ALL
SELECT 3 record_type,
       'INDEX' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       owner,
       index_name name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM &&CDB_object_prefix.indexes
 WHERE logging = 'NO'
   AND temporary = 'N'
UNION ALL
SELECT 4 record_type,
       'LOB' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       NULL partition,
       NULL subpartition
  FROM &&CDB_object_prefix.lobs
 WHERE logging = 'NO'
UNION ALL
SELECT 5 record_type,
       'TAB_PARTITION' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       table_owner owner,
       table_name name,
       NULL column_name,
       partition_name partition,
       NULL subpartition
  FROM &&cdb_object_prefix.tab_partitions
 WHERE logging = 'NO'
UNION ALL
SELECT 6 record_type,
       'IND_PARTITION' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       index_owner owner,
       index_name name,
       NULL column_name,
       partition_name partition,
       NULL subpartition
  FROM &&cdb_object_prefix.ind_partitions
 WHERE logging = 'NO'
UNION ALL
SELECT 7 record_type,
       'LOB_PARTITION' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       table_owner owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       partition_name partition,
       NULL subpartition
  FROM &&cdb_object_prefix.lob_partitions
 WHERE logging = 'NO'
UNION ALL
SELECT 8 record_type,
       'TAB_SUBPARTITION' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       table_owner owner,
       table_name name,
       NULL column_name,
       partition_name partition,
       subpartition_name subpartition
  FROM &&cdb_object_prefix.tab_subpartitions
 WHERE logging = 'NO'
UNION ALL
SELECT 9 record_type,
       'IND_SUBPARTITION' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       index_owner owner,
       index_name name,
       NULL column_name,
       partition_name partition,
       subpartition_name subpartition
  FROM &&cdb_object_prefix.ind_subpartitions
 WHERE logging = 'NO'
UNION ALL
SELECT 10 record_type,
       'LOB_SUBPARTITION' object_type,
       &&skip_noncdb.con_id,
       tablespace_name,
       table_owner owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       lob_partition_name partition,
       subpartition_name subpartition
  FROM &&cdb_object_prefix.lob_subpartitions
 WHERE logging = 'NO'
)
SELECT x.object_type,
       &&skip_noncdb.x.con_id,
	   x.tablespace_name,
       x.owner,
       x.name,
       x.column_name,
       x.partition,
       x.subpartition
	   &&skip_noncdb.,c.name con_name
  FROM objects x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.record_type,
       &&skip_noncdb.con_id,
	   x.tablespace_name,
       x.owner,
       x.name,
       x.column_name,
       x.partition,
       x.subpartition
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unrecoverable Datafile';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&v_object_prefix.datafile x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE x.unrecoverable_change# > 0
 ORDER BY
       x.file#
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unrecoverable Datafile after Backup';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
-- from http://www.pythian.com/blog/oracle-what-is-an-unrecoverable-data-file/
-- by Catherine Chow
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
df.name data_file_name, df.unrecoverable_time
	   &&skip_noncdb.,df.con_id
FROM   &&v_object_prefix.datafile df
      ,&&v_object_prefix.backup bk
WHERE  df.file#=bk.file#
and    df.unrecoverable_change#!=0
and    df.unrecoverable_time >
    NVL((select max(end_time)
	    FROM   &&v_object_prefix.rman_backup_job_details
        where  INPUT_TYPE in ('DB FULL' ,'DB INCR')
		and    status = 'COMPLETED')
    ,to_date('01/01/1900','dd/mm/yyyy'))
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Objects affected by Unrecoverable Operations';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
-- from http://www.pythian.com/blog/oracle-what-is-an-unrecoverable-data-file/
-- by Catherine Chow
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       distinct &&skip_noncdb.dbo.con_id,
	   dbo.owner,dbo.object_name, dbo.object_type, dfs.tablespace_name,
       dbt.logging table_level_logging, ts.logging tablespace_level_logging
	   &&skip_noncdb.,c.name con_name
FROM   &&cdb_object_prefix.objects dbo
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = dbo.con_id
      ,&&v_object_prefix.segstat ss, &&cdb_object_prefix.tablespaces ts, &&cdb_object_prefix.tables dbt,
       &&v_object_prefix.datafile df, &&cdb_object_prefix.data_files dfs, &&v_object_prefix.tablespace vts
where ss.statistic_name ='physical writes direct'
&&skip_noncdb.AND dbo.con_id = ss.con_id
and dbo.object_id = ss.obj#
&&skip_noncdb.AND vts.con_id = ss.con_id
and vts.ts# = ss.ts#
&&skip_noncdb.AND ts.con_id = vts.con_id
and ts.tablespace_name = vts.name
and ss.value != 0
and df.unrecoverable_change# != 0
&&skip_noncdb.AND dfs.con_id = df.con_id
and dfs.file_name = df.name
&&skip_noncdb.AND ts.con_id = dfs.con_id
and ts.tablespace_name = dfs.tablespace_name
&&skip_noncdb.AND dbt.con_id = dbo.con_id
and dbt.owner = dbo.owner
and dbt.table_name = dbo.object_name
]';
END;
/
--@@edb360_9a_pre_one.sql too slow! possibly bug 1532624.1

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
