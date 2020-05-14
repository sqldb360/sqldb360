@@&&edb360_0g.tkprof.sql
DEF section_id = '1d';
DEF section_name = 'Memory';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'SGA';
DEF main_table = '&&gv_view_prefix.SGA';
DEF abstract = '&&abstract_uom.';
BEGIN
  :sql_text := q'[
SELECT /*+ RESULT_CACHE */
       inst_id,
       name,
       value,
       CASE 
       WHEN value > POWER(2,50) THEN ROUND(value/POWER(2,50),1)||' P'
       WHEN value > POWER(2,40) THEN ROUND(value/POWER(2,40),1)||' T'
       WHEN value > POWER(2,30) THEN ROUND(value/POWER(2,30),1)||' G'
       WHEN value > POWER(2,20) THEN ROUND(value/POWER(2,20),1)||' M'
       WHEN value > POWER(2,10) THEN ROUND(value/POWER(2,10),1)||' K'
       ELSE value||' B' END approx
  FROM &&gv_object_prefix.sga
 ORDER BY
       name,
       inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SGA Info';
DEF main_table = '&&gv_view_prefix.SGAINFO';
DEF abstract = '&&abstract_uom.';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       name,
       bytes,
       CASE 
       WHEN bytes > POWER(2,50) THEN ROUND(bytes/POWER(2,50),1)||' P'
       WHEN bytes > POWER(2,40) THEN ROUND(bytes/POWER(2,40),1)||' T'
       WHEN bytes > POWER(2,30) THEN ROUND(bytes/POWER(2,30),1)||' G'
       WHEN bytes > POWER(2,20) THEN ROUND(bytes/POWER(2,20),1)||' M'
       WHEN bytes > POWER(2,10) THEN ROUND(bytes/POWER(2,10),1)||' K'
       ELSE bytes||' B' END approx,
       resizeable
  FROM &&gv_object_prefix.sgainfo
 ORDER BY
       name,
       inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SGA Stat';
DEF main_table = '&&gv_view_prefix.SGASTAT';
DEF abstract = '&&abstract_uom.';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       pool,
       name,
       inst_id,
       bytes,
       CASE 
       WHEN bytes > POWER(2,50) THEN ROUND(bytes/POWER(2,50),1)||' P'
       WHEN bytes > POWER(2,40) THEN ROUND(bytes/POWER(2,40),1)||' T'
       WHEN bytes > POWER(2,30) THEN ROUND(bytes/POWER(2,30),1)||' G'
       WHEN bytes > POWER(2,20) THEN ROUND(bytes/POWER(2,20),1)||' M'
       WHEN bytes > POWER(2,10) THEN ROUND(bytes/POWER(2,10),1)||' K'
       ELSE bytes||' B' END approx
  FROM &&gv_object_prefix.sgastat
 ORDER BY
       pool NULLS FIRST,
       name,
       inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'PGA Stat';
DEF main_table = '&&gv_view_prefix.PGASTAT';
DEF abstract = '&&abstract_uom.';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       name,
       value,
       unit,
       CASE unit WHEN 'bytes' THEN 
       CASE
       WHEN value > POWER(2,50) THEN ROUND(value/POWER(2,50),1)||' P'
       WHEN value > POWER(2,40) THEN ROUND(value/POWER(2,40),1)||' T'
       WHEN value > POWER(2,30) THEN ROUND(value/POWER(2,30),1)||' G'
       WHEN value > POWER(2,20) THEN ROUND(value/POWER(2,20),1)||' M'
       WHEN value > POWER(2,10) THEN ROUND(value/POWER(2,10),1)||' K'
       ELSE value||' B' END 
       END approx
  FROM &&gv_object_prefix.pgastat
 ORDER BY
       name,
       inst_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Dynamic Components';
DEF main_table = '&&gv_view_prefix.MEMORY_DYNAMIC_COMPONENTS';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.memory_dynamic_components

]';
END;
/
&&skip_ver_le_10.@@edb360_9a_pre_one.sql

DEF title = 'Memory Target Advice';
DEF main_table = '&&gv_view_prefix.MEMORY_TARGET_ADVICE';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.memory_target_advice

]';
END;
/
&&skip_ver_le_10.@@edb360_9a_pre_one.sql

DEF title = 'SGA Target Advice';
DEF main_table = '&&gv_view_prefix.SGA_TARGET_ADVICE';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.sga_target_advice

]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'PGA Target Advice';
DEF main_table = '&&gv_view_prefix.PGA_TARGET_ADVICE';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.pga_target_advice

]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL Workarea Histogram';
DEF main_table = '&&AWR_HIST_PREFIX.SQL_WORKAREA_HSTGRM';
BEGIN
  :sql_text := q'[
-- requested by Dimas Chbane, expanded by Abel Macias
-- replaced V dollar view with historic
WITH 
totals AS (
  SELECT /*+ &&sq_fact_hints. &&ds_hint. */ 
         /* &&section_id..&&report_sequence. */
        &&skip_ver_le_11.con_id,
        INSTANCE_NUMBER,
        LOW_OPTIMAL_SIZE lnum, 
        HIGH_OPTIMAL_SIZE+1 hnum,
        SUM(OPTIMAL_EXECUTIONS) optimal ,    
        SUM(ONEPASS_EXECUTIONS) onepass ,    
        SUM(MULTIPASSES_EXECUTIONS) multipasses,
        SUM(TOTAL_EXECUTIONS) totex
   FROM &&AWR_HIST_PREFIX.SQL_WORKAREA_HSTGRM
  WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
    AND dbid = &&edb360_dbid.
  GROUP BY 
        &&skip_ver_le_11.con_id,
        INSTANCE_NUMBER,
        LOW_OPTIMAL_SIZE,
        HIGH_OPTIMAL_SIZE
    )
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
  &&skip_ver_le_11.con_id,
  INSTANCE_NUMBER,
  (case when lnum between 1024           and 1024*1024-1                then to_char(round(lnum /1024),'9999') ||' Kb'
        when lnum between 1024*1024      and 1024*1024*1024-1           then to_char(round(lnum /1024/1024),'9999') ||' Mb'
        when lnum between 1024*1024*1024 and 1024*1024*1024*1024-1      then to_char(round(lnum /1024/1024/1024),'9999') ||' Gb'
        when lnum between 1024*1024*1024 and 1024*1024*1024*1024*1024-1 then to_char(round(lnum /1024/1024/1024/1024),'9999') ||' Tb'
   else to_char(lnum) end) LOW_OPTIMAL_SIZE,
  (case when hnum between 1024           and 1024*1024-1                then to_char(round(hnum /1024),'9999') ||' Kb'
        when hnum between 1024*1024      and 1024*1024*1024-1           then to_char(round(hnum /1024/1024),'9999') ||' Mb'
        when hnum between 1024*1024*1024 and 1024*1024*1024*1024-1      then to_char(round(hnum /1024/1024/1024),'9999') ||' Gb'
        when hnum between 1024*1024*1024 and 1024*1024*1024*1024*1024-1 then to_char(round(hnum /1024/1024/1024/1024),'9999') ||' Tb'
   else to_char(hnum) end) HIGH_OPTIMAL_SIZE,
  optimal OPTIMAL_EXECUTIONS,    
  onepass ONEPASS_EXECUTIONS,    
  multipasses MULTIPASSES_EXECUTIONS,
  totex TOTAL_EXECUTIONS
FROM totals
ORDER BY &&skip_ver_le_11.con_id,
         INSTANCE_NUMBER,
         lnum
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Resize Operations';
DEF main_table = '&&gv_view_prefix.MEMORY_RESIZE_OPS';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.memory_resize_ops
 ORDER BY
       inst_id,
       start_time DESC,
       component
]';
END;
/
&&skip_ver_le_10.@@edb360_9a_pre_one.sql

DEF title = 'Memory Current Resize Operations';
DEF main_table = '&&gv_view_prefix.MEMORY_CURRENT_RESIZE_OPS';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.memory_current_resize_ops
 ORDER BY
       inst_id,
       start_time DESC,
       component
]';
END;
/
&&skip_ver_le_10.@@edb360_9a_pre_one.sql

DEF title = 'Memory Resize Operations Hist';
DEF main_table = '&&awr_hist_prefix.MEMORY_RESIZE_OPS';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&awr_object_prefix.memory_resize_ops
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 ORDER BY
       instance_number,
       start_time DESC,
       component
]';
END;
/
&&skip_ver_le_10.@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Memory Target Advice Hist';
DEF main_table = '&&awr_hist_prefix.MEMORY_TARGET_ADVICE';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&awr_object_prefix.memory_target_advice
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 ORDER BY
       instance_number,
       snap_id DESC,
       memory_size,
       memory_size_factor
]';
END;
/
&&skip_ver_le_10.@@&&skip_diagnostics.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
