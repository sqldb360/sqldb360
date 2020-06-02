@@&&edb360_0g.tkprof.sql
DEF section_id = '3h';
DEF section_name = 'Sessions';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Sessions Aggregate per Type';
DEF main_table = '&&gv_view_prefix.SESSION';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT COUNT(*),
	   &&skip_noncdb.con_id,
       inst_id,
       type,
       server,
       status,
       state
  FROM &&gv_object_prefix.session
 GROUP BY
	   &&skip_noncdb.con_id,
       inst_id,
       type,
       server,
       status,
       state
)
SELECT x.*
      &&skip_noncdb.,c.name con_name
FROM x
     &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       1 DESC,
	   &&skip_noncdb.x.con_id,
	   x.inst_id, x.type, x.server, x.status, x.state
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sessions Aggregate per User and Type';
DEF main_table = '&&gv_view_prefix.SESSION';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT COUNT(*),
	   &&skip_noncdb.con_id,
       username,
       inst_id,
       type,
       server,
       status,
       state
  FROM &&gv_object_prefix.session
 GROUP BY
	   &&skip_noncdb.con_id,
       username,
       inst_id,
       type,
       server,
       status,
       state
)
SELECT x.*
      &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       1 DESC,
	   &&skip_noncdb.x.con_id,
	   x.username, x.inst_id, x.type, x.server, x.status, x.state
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sessions Aggregate per Module and Action';
DEF main_table = '&&gv_view_prefix.SESSION';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT COUNT(*),
	   &&skip_noncdb.con_id,
       module,
       action,
       inst_id,
       type,
       server,
       status,
       state
  FROM &&gv_object_prefix.session
 GROUP BY
	   &&skip_noncdb.con_id,
       module,
       action,
       inst_id,
       type,
       server,
       status,
       state
)
SELECT x.*
      &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       1 DESC,
	   &&skip_noncdb.x.con_id,
	   x.module, x.action, x.inst_id, x.type, x.server, x.status, x.state
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sessions List';
DEF main_table = '&&gv_view_prefix.SESSION';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&gv_object_prefix.session
 ORDER BY
       inst_id,
       sid
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Database and Schema Triggers';
DEF main_table = '&&cdb_view_prefix.TRIGGERS';
BEGIN
  :sql_text := q'[
SELECT x.*
      &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.triggers x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE base_object_type IN ('DATABASE', 'SCHEMA')
 ORDER BY
       x.base_object_type,
	   &&skip_noncdb.x.con_id,
	   x.owner, x.trigger_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL in logon storms';
DEF main_table = '&&cdb_awr_hist_prefix.ACTIVE_SESS_HISTORY';
-- Exclude PX slave sessions and Jobs
BEGIN
  :sql_text := q'[
WITH
ash AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_ver_le_11.con_id,
       NVL(h.sql_id, 'null_sql_id') sql_id,
       COUNT(DISTINCT h.program) programs,
       MIN(h.program) min_program,
       MAX(h.program) max_program,
       COUNT(DISTINCT h.module) modules,
       MIN(h.module) min_module,
       MAX(h.module) max_module,
       COUNT(DISTINCT h.action) actions,
       MIN(h.action) min_action,
       MAX(h.action) max_action,
       COUNT(DISTINCT h.snap_id||'.'||h.instance_number||'.'||h.session_id||'.'||h.session_serial#) sessions
  FROM &&cdb_awr_object_prefix.active_sess_history h
 WHERE h.session_type = 'FOREGROUND'
   AND h.program not like '%(J%'
   AND h.qc_session_id is null
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
 GROUP BY
       &&skip_ver_le_11.h.con_id,
       h.sql_id
)
SELECT * from (
  SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
         &&skip_ver_le_11.s.con_id,
         s.sessions,
         s.sql_id,
         s.programs,
         s.min_program,
         s.max_program,
         s.modules,
         s.min_module,
         s.max_module,
         s.actions,
         s.min_action,
         s.max_action,
		 &&skip_noncdb.c.name con_name,
         DBMS_LOB.SUBSTR(t.sql_text, 1000) sql_text
    FROM ash s
	     &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
	     LEFT OUTER JOIN &&cdb_awr_object_prefix.sqltext t
		 ON t.dbid = &&edb360_dbid.
		 AND t.sql_id = s.sql_id
		 &&skip_noncdb.AND t.con_id = s.con_id
 )
  WHERE ROWNUM < 101
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

WITH
ash AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       NVL(h.sql_id, 'null_sql_id') sql_id
  FROM &&cdb_awr_object_prefix.active_sess_history h
 WHERE h.session_type = 'FOREGROUND'
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND '&&skip_diagnostics.' IS NULL
 GROUP BY
       h.sql_id
 ORDER BY
       COUNT(DISTINCT h.snap_id||'.'||h.instance_number||'.'||h.session_id||'.'||h.session_serial#) DESC
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       NVL(MIN(CASE ROWNUM WHEN 01 THEN sql_id END),'not_sql_id_01') tit_01,
       NVL(MIN(CASE ROWNUM WHEN 02 THEN sql_id END),'not_sql_id_02') tit_02,
       NVL(MIN(CASE ROWNUM WHEN 03 THEN sql_id END),'not_sql_id_03') tit_03,
       NVL(MIN(CASE ROWNUM WHEN 04 THEN sql_id END),'not_sql_id_04') tit_04,
       NVL(MIN(CASE ROWNUM WHEN 05 THEN sql_id END),'not_sql_id_05') tit_05,
       NVL(MIN(CASE ROWNUM WHEN 06 THEN sql_id END),'not_sql_id_06') tit_06,
       NVL(MIN(CASE ROWNUM WHEN 07 THEN sql_id END),'not_sql_id_07') tit_07,
       NVL(MIN(CASE ROWNUM WHEN 08 THEN sql_id END),'not_sql_id_08') tit_08,
       NVL(MIN(CASE ROWNUM WHEN 09 THEN sql_id END),'not_sql_id_09') tit_09,
       NVL(MIN(CASE ROWNUM WHEN 10 THEN sql_id END),'not_sql_id_10') tit_10,
       NVL(MIN(CASE ROWNUM WHEN 11 THEN sql_id END),'not_sql_id_11') tit_11,
       NVL(MIN(CASE ROWNUM WHEN 12 THEN sql_id END),'not_sql_id_12') tit_12,
       NVL(MIN(CASE ROWNUM WHEN 13 THEN sql_id END),'not_sql_id_13') tit_13,
       NVL(MIN(CASE ROWNUM WHEN 14 THEN sql_id END),'not_sql_id_14') tit_14,
       NVL(MIN(CASE ROWNUM WHEN 15 THEN sql_id END),'not_sql_id_15') tit_15
  FROM ash
 WHERE ROWNUM < 16
/

DEF title = 'SQL in logon storms - Time Series';
DEF main_table = '&&cdb_awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF skip_lch = '';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Sessions (stacked)';
DEF vbaseline = '';

BEGIN
  :sql_text := q'[
WITH
ash AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_noncdb.h.con_id,
       h.snap_id,
       TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       NVL(h.sql_id, 'null_sql_id') sql_id,
       COUNT(DISTINCT h.instance_number||'.'||h.session_id||'.'||h.session_serial#) sessions
  FROM &&cdb_awr_object_prefix.active_sess_history h
 WHERE h.session_type = 'FOREGROUND'
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND NVL(h.sql_id, 'null_sql_id') IN
       ('&&tit_01.',
        '&&tit_02.',
        '&&tit_03.',
        '&&tit_04.',
        '&&tit_05.',
        '&&tit_06.',
        '&&tit_07.',
        '&&tit_08.',
        '&&tit_09.',
        '&&tit_10.',
        '&&tit_11.',
        '&&tit_12.',
        '&&tit_13.',
        '&&tit_14.',
        '&&tit_15.')
 GROUP BY
       &&skip_noncdb.h.con_id,
       h.snap_id,
       h.sql_id
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       snap_id,
       MIN(begin_time) begin_time,
       MIN(end_time) end_time,
       SUM(CASE sql_id WHEN '&&tit_01.' THEN sessions ELSE 0 END) "&&tit_01.",
       SUM(CASE sql_id WHEN '&&tit_02.' THEN sessions ELSE 0 END) "&&tit_02.",
       SUM(CASE sql_id WHEN '&&tit_03.' THEN sessions ELSE 0 END) "&&tit_03.",
       SUM(CASE sql_id WHEN '&&tit_04.' THEN sessions ELSE 0 END) "&&tit_04.",
       SUM(CASE sql_id WHEN '&&tit_05.' THEN sessions ELSE 0 END) "&&tit_05.",
       SUM(CASE sql_id WHEN '&&tit_06.' THEN sessions ELSE 0 END) "&&tit_06.",
       SUM(CASE sql_id WHEN '&&tit_07.' THEN sessions ELSE 0 END) "&&tit_07.",
       SUM(CASE sql_id WHEN '&&tit_08.' THEN sessions ELSE 0 END) "&&tit_08.",
       SUM(CASE sql_id WHEN '&&tit_09.' THEN sessions ELSE 0 END) "&&tit_09.",
       SUM(CASE sql_id WHEN '&&tit_10.' THEN sessions ELSE 0 END) "&&tit_10.",
       SUM(CASE sql_id WHEN '&&tit_11.' THEN sessions ELSE 0 END) "&&tit_11.",
       SUM(CASE sql_id WHEN '&&tit_12.' THEN sessions ELSE 0 END) "&&tit_12.",
       SUM(CASE sql_id WHEN '&&tit_13.' THEN sessions ELSE 0 END) "&&tit_13.",
       SUM(CASE sql_id WHEN '&&tit_14.' THEN sessions ELSE 0 END) "&&tit_14.",
       SUM(CASE sql_id WHEN '&&tit_15.' THEN sessions ELSE 0 END) "&&tit_15."
  FROM ash
 GROUP BY
       &&skip_noncdb.con_id,
	   snap_id
 ORDER BY
       &&skip_noncdb.con_id,
	   snap_id
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Most executed SQL';
DEF main_table = '&&cdb_awr_hist_prefix.SQLSTAT';
BEGIN
  :sql_text := q'[
WITH
totals AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       /* &&section_id..&&report_sequence. */
       &&skip_ver_le_11.con_id,
       sql_id,
       SUM(executions_delta) executions,
       SUM(rows_processed_delta) rows_processed,
       SUM(parse_calls_delta) parses,
       SUM(fetches_delta) fetches,
       SUM(buffer_gets_delta) buffer_gets,
       SUM(disk_reads_delta) disk_reads,
       SUM(direct_writes_delta) direct_writes,
       ROUND(SUM(elapsed_time_delta)/1e6) elapsed_secs,
       ROUND(SUM(cpu_time_delta)/1e6) cpu_secs,
       ROUND(SUM(iowait_delta)/1e6) io_secs,
       ROUND(SUM(clwait_delta)/1e6) clust_secs,
       ROUND(SUM(apwait_delta)/1e6) appl_secs,
       ROUND(SUM(ccwait_delta)/1e6) conc_secs,
       ROUND(SUM(plsexec_time_delta)/1e6) pls_exec_secs,
       ROUND(SUM(javexec_time_delta)/1e6) java_secs,
       COUNT(DISTINCT plan_hash_value) plans,
       ROUND(AVG(optimizer_cost)) avg_cost,
       COUNT(DISTINCT module) modules,
       MIN(module) min_module,
       MAX(module) max_module,
       COUNT(DISTINCT action) actions,
       MIN(action) min_action,
       MAX(action) max_action
  FROM &&cdb_awr_object_prefix.sqlstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       &&skip_ver_le_11.con_id,
       sql_id
)
SELECT * FROM (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
       s.sql_id,
       s.executions,
       s.rows_processed,
       ROUND(s.rows_processed/NULLIF(s.executions,0), 3) rows_per_exec,
       s.parses,
       s.fetches,
       s.buffer_gets,
       s.disk_reads,
       s.direct_writes,
       s.elapsed_secs,
       s.cpu_secs,
       s.io_secs,
       s.clust_secs,
       s.appl_secs,
       s.conc_secs,
       s.pls_exec_secs,
       s.java_secs,
       s.plans,
       s.avg_cost,
       s.modules,
       s.min_module,
       s.max_module,
       s.actions,
       s.min_action,
       s.max_action,
       DBMS_LOB.SUBSTR(t.sql_text, 1000) sql_text
	   &&skip_noncdb.,c.name con_name
  FROM totals s
       LEFT OUTER JOIN &&cdb_awr_object_prefix.sqltext t
	   ON t.sql_id = s.sql_id
       AND t.dbid = &&edb360_dbid.
       &&skip_ver_le_11.AND t.con_id = s.con_id
	   &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
  ORDER BY s.executions DESC
 )
   WHERE ROWNUM < 101
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

WITH
totals AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       /* &&section_id..&&report_sequence. */
       NVL(sql_id, 'null_sql_id') sql_id
  FROM &&cdb_awr_object_prefix.sqlstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND '&&skip_diagnostics.' IS NULL
 GROUP BY
       sql_id
 ORDER BY
       SUM(executions_delta) DESC
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       NVL(MIN(CASE ROWNUM WHEN 01 THEN sql_id END),'not_sql_id_01') tit_01,
       NVL(MIN(CASE ROWNUM WHEN 02 THEN sql_id END),'not_sql_id_02') tit_02,
       NVL(MIN(CASE ROWNUM WHEN 03 THEN sql_id END),'not_sql_id_03') tit_03,
       NVL(MIN(CASE ROWNUM WHEN 04 THEN sql_id END),'not_sql_id_04') tit_04,
       NVL(MIN(CASE ROWNUM WHEN 05 THEN sql_id END),'not_sql_id_05') tit_05,
       NVL(MIN(CASE ROWNUM WHEN 06 THEN sql_id END),'not_sql_id_06') tit_06,
       NVL(MIN(CASE ROWNUM WHEN 07 THEN sql_id END),'not_sql_id_07') tit_07,
       NVL(MIN(CASE ROWNUM WHEN 08 THEN sql_id END),'not_sql_id_08') tit_08,
       NVL(MIN(CASE ROWNUM WHEN 09 THEN sql_id END),'not_sql_id_09') tit_09,
       NVL(MIN(CASE ROWNUM WHEN 10 THEN sql_id END),'not_sql_id_10') tit_10,
       NVL(MIN(CASE ROWNUM WHEN 11 THEN sql_id END),'not_sql_id_11') tit_11,
       NVL(MIN(CASE ROWNUM WHEN 12 THEN sql_id END),'not_sql_id_12') tit_12,
       NVL(MIN(CASE ROWNUM WHEN 13 THEN sql_id END),'not_sql_id_13') tit_13,
       NVL(MIN(CASE ROWNUM WHEN 14 THEN sql_id END),'not_sql_id_14') tit_14,
       NVL(MIN(CASE ROWNUM WHEN 15 THEN sql_id END),'not_sql_id_15') tit_15
  FROM totals
 WHERE ROWNUM < 16
/

DEF title = 'Most executed SQL - Time Series';
DEF main_table = '&&cdb_awr_hist_prefix.SQLSTAT';
DEF skip_lch = '';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Executions (stacked)';
DEF vbaseline = '';

BEGIN
  :sql_text := q'[
WITH
stat AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       snap_id,
       NVL(sql_id, 'null_sql_id') sql_id,
       SUM(executions_delta) executions
  FROM &&cdb_awr_object_prefix.sqlstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND NVL(sql_id, 'null_sql_id') IN
       ('&&tit_01.',
        '&&tit_02.',
        '&&tit_03.',
        '&&tit_04.',
        '&&tit_05.',
        '&&tit_06.',
        '&&tit_07.',
        '&&tit_08.',
        '&&tit_09.',
        '&&tit_10.',
        '&&tit_11.',
        '&&tit_12.',
        '&&tit_13.',
        '&&tit_14.',
        '&&tit_15.')
 GROUP BY
       &&skip_noncdb.con_id,
	   snap_id,
       sql_id
), x as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.t.con_id,
       t.snap_id,
       TO_CHAR(MIN(s.begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(s.end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE t.sql_id WHEN '&&tit_01.' THEN t.executions ELSE 0 END) "&&tit_01.",
       SUM(CASE t.sql_id WHEN '&&tit_02.' THEN t.executions ELSE 0 END) "&&tit_02.",
       SUM(CASE t.sql_id WHEN '&&tit_03.' THEN t.executions ELSE 0 END) "&&tit_03.",
       SUM(CASE t.sql_id WHEN '&&tit_04.' THEN t.executions ELSE 0 END) "&&tit_04.",
       SUM(CASE t.sql_id WHEN '&&tit_05.' THEN t.executions ELSE 0 END) "&&tit_05.",
       SUM(CASE t.sql_id WHEN '&&tit_06.' THEN t.executions ELSE 0 END) "&&tit_06.",
       SUM(CASE t.sql_id WHEN '&&tit_07.' THEN t.executions ELSE 0 END) "&&tit_07.",
       SUM(CASE t.sql_id WHEN '&&tit_08.' THEN t.executions ELSE 0 END) "&&tit_08.",
       SUM(CASE t.sql_id WHEN '&&tit_09.' THEN t.executions ELSE 0 END) "&&tit_09.",
       SUM(CASE t.sql_id WHEN '&&tit_10.' THEN t.executions ELSE 0 END) "&&tit_10.",
       SUM(CASE t.sql_id WHEN '&&tit_11.' THEN t.executions ELSE 0 END) "&&tit_11.",
       SUM(CASE t.sql_id WHEN '&&tit_12.' THEN t.executions ELSE 0 END) "&&tit_12.",
       SUM(CASE t.sql_id WHEN '&&tit_13.' THEN t.executions ELSE 0 END) "&&tit_13.",
       SUM(CASE t.sql_id WHEN '&&tit_14.' THEN t.executions ELSE 0 END) "&&tit_14.",
       SUM(CASE t.sql_id WHEN '&&tit_15.' THEN t.executions ELSE 0 END) "&&tit_15."
  FROM stat t,
       &&cdb_awr_object_prefix.snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND t.snap_id = s.snap_id
 GROUP BY
       &&skip_noncdb.t.con_id,
	   t.snap_id
)
SELECT x.*
      &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       x.snap_id
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'SQL executed row-by-row';
DEF main_table = '&&cdb_awr_hist_prefix.SQLSTAT';
BEGIN
  :sql_text := q'[
WITH
totals AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       /* &&section_id..&&report_sequence. */
       &&skip_ver_le_11.con_id,
       sql_id,
       SUM(executions_delta) executions,
       SUM(rows_processed_delta) rows_processed,
       SUM(parse_calls_delta) parses,
       SUM(fetches_delta) fetches,
       SUM(buffer_gets_delta) buffer_gets,
       SUM(disk_reads_delta) disk_reads,
       SUM(direct_writes_delta) direct_writes,
       ROUND(SUM(elapsed_time_delta)/1e6) elapsed_secs,
       ROUND(SUM(cpu_time_delta)/1e6) cpu_secs,
       ROUND(SUM(iowait_delta)/1e6) io_secs,
       ROUND(SUM(clwait_delta)/1e6) clust_secs,
       ROUND(SUM(apwait_delta)/1e6) appl_secs,
       ROUND(SUM(ccwait_delta)/1e6) conc_secs,
       ROUND(SUM(plsexec_time_delta)/1e6) pls_exec_secs,
       ROUND(SUM(javexec_time_delta)/1e6) java_secs,
       COUNT(DISTINCT plan_hash_value) plans,
       ROUND(AVG(optimizer_cost)) avg_cost,
       COUNT(DISTINCT module) modules,
       MIN(module) min_module,
       MAX(module) max_module,
       COUNT(DISTINCT action) actions,
       MIN(action) min_action,
       MAX(action) max_action
  FROM &&cdb_awr_object_prefix.sqlstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       &&skip_ver_le_11.con_id,
       sql_id
)
SELECT * FROM (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.s.con_id,
       s.sql_id,
       s.executions,
       s.rows_processed,
       ROUND(s.rows_processed/NULLIF(s.executions,0), 3) rows_per_exec,
       s.parses,
       s.fetches,
       s.buffer_gets,
       s.disk_reads,
       s.direct_writes,
       s.elapsed_secs,
       s.cpu_secs,
       s.io_secs,
       s.clust_secs,
       s.appl_secs,
       s.conc_secs,
       s.pls_exec_secs,
       s.java_secs,
       s.plans,
       s.avg_cost,
       s.modules,
       s.min_module,
       s.max_module,
       s.actions,
       s.min_action,
       s.max_action,
	   &&skip_noncdb.c.name con_name,
       DBMS_LOB.SUBSTR(t.sql_text, 1000) sql_text
  FROM totals s
       LEFT OUTER JOIN &&cdb_awr_object_prefix.sqltext t
       ON t.sql_id = s.sql_id
       AND t.dbid = &&edb360_dbid.
	   &&skip_ver_le_11.AND t.con_id = s.con_id
	   &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
 WHERE s.executions>1
   AND (s.rows_processed/greatest(s.executions,1))<2
   ORDER BY s.executions DESC
   )
WHERE ROWNUM < 101
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Processes List';
DEF main_table = '&&gv_view_prefix.PROCESS';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&gv_object_prefix.process
 ORDER BY
       inst_id,
       pid,
       spid
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Processes Memory';
DEF main_table = '&&gv_view_prefix.PROCESS_MEMORY';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&gv_object_prefix.process_memory
 ORDER BY
       inst_id,
       pid,
       serial#,
       category
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Processes Memory Aggregate';
DEF main_table = '&&gv_view_prefix.PROCESS_MEMORY';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := q'[
SELECT category,
       SUM(allocated) sum_allocated,
       SUM(used) sum_used,
       SUM(max_allocated) sum_max_allocated,
       ROUND(AVG(allocated)) avg_allocated,
       ROUND(AVG(used)) avg_used,
       ROUND(AVG(max_allocated)) avg_max_allocated,
       MEDIAN(allocated) median_allocated,
       MEDIAN(used) median_used,
       MEDIAN(max_allocated) median_max_allocated,
       MAX(allocated) max_allocated,
       MAX(used) max_used,
       MAX(max_allocated) max_max_allocated
  FROM &&gv_object_prefix.process_memory
 GROUP BY
       category
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Active Sessions (detail)';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
SELECT /* active_sessions */
       se.*, sq.sql_text
  FROM &&gv_object_prefix.session se,
       &&gv_object_prefix.sql sq
 WHERE se.status = 'ACTIVE'
   AND sq.inst_id = se.inst_id
   AND sq.sql_id = se.sql_id
   AND sq.child_number = se.sql_child_number
   &&skip_ver_le_11.and sq.con_id = se.con_id
   AND sq.sql_text NOT LIKE 'SELECT /* active_sessions */%'
 ORDER BY
       se.inst_id, se.sid, se.serial#
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Active Sessions (more detail)';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- provided by Frits Hoogland
select /*+ rule as.sql */
    &&skip_noncdb.a.con_id,
	a.sid||','||a.serial#||',@'||a.inst_id as sid_serial_inst,
	d.spid as ospid,
	substr(a.program,1,19) prog,
	a.module, a.action, a.client_info,
	'SQL:'||b.sql_id as sql_id, child_number child, plan_hash_value, executions execs,
	(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
	decode(a.plsql_object_id,null,sql_text,sqla.object_name||'.'||sqlb.procedure_name) sql_text,
	(c.wait_time_micro/1000000) wait_s,
	decode(a.plsql_object_id,null,decode(c.wait_time,0,decode(a.blocking_session,null,c.event,c.event||'> Blocked by (inst:sid): '||a.final_blocking_instance||':'||a.final_blocking_session),'ON CPU:SQL'),'ON CPU:PLSQL:'||o.object_name) as wait_or_cpu
	&&skip_noncdb.,c.name con_name
FROM &&gv_object_prefix.session a
     LEFT OUTER JOIN &&cdb_object_prefix.procedures sqla
	 ON sqla.object_id=a.plsql_object_id
	 &&skip_noncdb.AND sqla.con_id = a.con_id
	 LEFT OUTER JOIN &&cdb_object_prefix.procedures sqlb
	 ON sqlb.object_id = a.plsql_object_id
     and sqlb.subprogram_id = a.plsql_subprogram_id
	 &&skip_noncdb.AND sqlb.con_id = a.con_id
	 LEFT OUTER JOIN &&cdb_object_prefix.objects o
	 ON o.object_id=a.plsql_object_id
	 &&skip_noncdb.AND o.con_id = a.con_id
	 &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = a.con_id
   , &&gv_object_prefix.sql b, &&gv_object_prefix.session_wait c, &&gv_object_prefix.process d
where a.status = 'ACTIVE'
and a.username is not null
and a.sql_id = b.sql_id
and a.inst_id = b.inst_id
&&skip_ver_le_11.and a.con_id = b.con_id
and a.sid = c.sid
and a.inst_id = c.inst_id
and a.inst_id = d.inst_id
and a.paddr = d.addr
and a.sql_child_number = b.child_number
and sql_text not like 'select /*+ rule as.sql */%' /* dont show this query */
order by sql_id, sql_child_number
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Sessions Waiting';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- borrowed from orachk
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
	   x.inst_id, x.sid, x.event,
       ROUND(seconds_in_wait,2)  waiting_seconds,
       ROUND(wait_time/100,2)    waited_seconds,
       p1,p2,p3, BLOCKING_SESSION
FROM &&gv_object_prefix.session x
where event not in
(
  'SQL*Net message from client',
  'SQL*Net message to client',
  'rdbms ipc message'
)
and state = 'WAITING'
and username not in &&exclusion_list.
and username not in &&exclusion_list2.
and (seconds_in_wait > 1 OR wait_time > 100)
order by
      &&skip_noncdb.x.con_id,
      x.inst_id, x.sid
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Session Blockers and Waiters';
DEF abstract = 'Blockers (B) and Waiters (W)<br />';
DEF main_table = '&&gv_view_prefix.SESSION_BLOCKERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       b.inst_id b_inst_id,
       b.sql_id b_sql_id,
       b.sql_child_number b_child,
       b.sid b_sid,
       b.serial# b_serial#,
       b.process b_process,
       b.machine b_machine,
       b.program b_program,
       b.module b_module,
       b.client_info b_client_info,
       b.client_identifier b_client_identifier,
       b.event b_event,
       TO_CHAR(b.logon_time, 'DD-MON-YY HH24:MI:SS') b_logon_time,
       TO_CHAR(b.sql_exec_start, 'DD-MON-YY HH24:MI:SS') b_sql_exec_start,
       SUBSTR(bs.sql_text, 1, 500) b_sql_text,
       w.inst_id w_inst_id,
       w.sql_id w_sql_id,
       w.sql_child_number w_child,
       w.sid w_sid,
       w.serial# w_serial#,
       w.process w_process,
       w.machine w_machine,
       w.program w_program,
       w.module w_module,
       w.client_info w_client_info,
       w.client_identifier w_client_identifier,
       w.event w_event,
       TO_CHAR(w.logon_time, 'DD-MON-YY HH24:MI:SS') w_logon_time,
       TO_CHAR(w.sql_exec_start, 'DD-MON-YY HH24:MI:SS') w_sql_exec_start,
       SUBSTR(ws.sql_text, 1, 500) w_sql_text
  FROM &&gv_object_prefix.session_blockers sb,
       &&gv_object_prefix.session w,
       &&gv_object_prefix.session b,
       &&gv_object_prefix.sql ws,
       &&gv_object_prefix.sql bs
 WHERE w.inst_id = sb.inst_id
   AND w.sid = sb.sid
   AND w.serial# = sb.sess_serial#
   AND b.inst_id = sb.blocker_instance_id
   AND b.sid = sb.blocker_sid
   AND b.serial# = sb.blocker_sess_serial#
   AND ws.inst_id(+) = w.inst_id
   AND ws.sql_id(+) = w.sql_id
   AND ws.child_number(+) = w.sql_child_number
   &&skip_ver_le_11.AND ws.con_id(+) = w.con_id
   AND bs.inst_id(+) = b.inst_id
   AND bs.sql_id(+) = b.sql_id
   AND bs.child_number(+) = b.sql_child_number
   &&skip_ver_le_11.AND bs.con_id(+) = b.con_id
 ORDER BY
       b.inst_id,
       b.sql_id,
       b.sql_child_number,
       b.sid,
       b.serial#,
       w.inst_id,
       w.sql_id,
       w.sql_child_number,
       w.sid,
       w.serial#
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'SQL blocking SQL';
DEF main_table = '&&cdb_awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := q'[
WITH
w AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_noncdb.h.con_id,
       h.dbid,
       h.sql_id,
       h.event,
       h.blocking_session,
       h.blocking_session_serial#,
       TRUNC(h.sample_time, 'HH') sample_hh,
       MIN(h.sample_time) min_sample_time,
       MAX(h.sample_time) max_sample_time,
       COUNT(*) samples,
       RANK() OVER (ORDER BY COUNT(*) DESC NULLS LAST) AS w_rank
  FROM &&cdb_awr_object_prefix.active_sess_history h
 WHERE h.sql_id IS NOT NULL
   AND h.blocking_session IS NOT NULL
   AND h.session_state = 'WAITING'
   AND h.blocking_session_status IN ('VALID', 'GLOBAL')
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
 GROUP BY
       &&skip_noncdb.h.con_id,
       h.dbid,
       h.sql_id,
       h.event,
       h.blocking_session,
       h.blocking_session_serial#,
       TRUNC(h.sample_time, 'HH')
),
b AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_noncdb.w.con_id,
       w.dbid,
       w.sql_id w_sql_id,
       w.event w_event,
       RANK() OVER (ORDER BY COUNT(*) DESC NULLS LAST) AS b_rank,
       h.sql_id b_sql_id,
       COUNT(*) b_samples
       FROM w,
       &&cdb_awr_object_prefix.active_sess_history h
 WHERE w.w_rank < 101
   AND h.dbid = w.dbid
   AND h.session_id = w.blocking_session
   AND h.session_serial# = w.blocking_session_serial#
   AND TRUNC(h.sample_time, 'HH') = w.sample_hh
   AND h.sample_time BETWEEN w.min_sample_time AND w.max_sample_time
   AND h.sql_id IS NOT NULL
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
 GROUP BY
       &&skip_noncdb.w.con_id,
       w.dbid,
       w.sql_id,
       w.event,
       h.sql_id
),
w2 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       dbid,
       sql_id w_sql_id,
       event w_event,
       SUM(samples) w_samples,
       MIN(w_rank) w_rank
  FROM w
 GROUP BY
       &&skip_noncdb.con_id,
       dbid,
       sql_id,
       event
),
w3 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       dbid,
       w_sql_id,
       SUM(w_samples) w_samples
  FROM w2
 GROUP BY
       &&skip_noncdb.con_id,
       dbid,
       w_sql_id
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       DISTINCT
       (10 * w2.w_samples) w_seconds,
	   &&skip_noncdb.w2.con_id,
       w2.w_sql_id,
       w2.w_event,
       (10 * b.b_samples) b_seconds,
       b.b_sql_id,
	   &&skip_noncdb.c.name con_name,
       DBMS_LOB.SUBSTR(s1.sql_text, 1000) w_sql_text,
       DBMS_LOB.SUBSTR(s2.sql_text, 1000) b_sql_text
  FROM w2
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = w2.con_id
	   LEFT OUTER JOIN &&cdb_awr_object_prefix.sqltext s1
       ON s1.sql_id = w2.w_sql_id
       AND s1.dbid = w2.dbid
	  ,b
       LEFT OUTER JOIN &&cdb_awr_object_prefix.sqltext s2
       ON s2.sql_id = b.b_sql_id
       AND s2.dbid = b.dbid
	  ,w3
 WHERE b.dbid = w2.dbid
   AND b.w_sql_id = w2.w_sql_id
   AND b.w_event = w2.w_event
   AND w3.dbid = w2.dbid
   AND w3.w_sql_id = w2.w_sql_id
 ORDER BY
       1 DESC, 2, 3, 4 DESC, 5
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

column hold_module heading 'Holding Module'
column hold_action heading 'Holding Action'
column hold_program heading 'Holding Program'
column hold_event heading 'Holding Event'
column wait_event  heading 'Waiting Event'
DEF title = 'Profile of Blocking Sessions';
DEF main_table = '&&cdb_awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := q'[
-- developed by David Kurtz
WITH w AS ( --waiting sessions
	SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
	       /* &&section_id..&&report_sequence. */
		        &&skip_noncdb.con_id,
	            dbid
		,       instance_number
        ,       snap_id
	,       sample_id, sample_time
        ,       session_type wait_session_type
        ,       session_id, session_serial#
        ,       sql_id, sql_plan_hash_value, sql_plan_line_id
--simplified program name removing anything after first @ or dot until open a bracket
        ,       regexp_substr(program,'[^\.@]+',1,1)||' '||
                regexp_replace(regexp_substR(regexp_substr(program,'[\.@].+',1,1),'[\(].+',1,1),'[[:digit:]]','n',1,0) wait_program
        ,       module wait_module
        ,       CASE WHEN upper(program) LIKE 'ORACLE%'
                     THEN REGEXP_REPLACE(action,'[[:digit:]]+','nnn',1,1)
                     ELSE action END wait_action
        ,       NVL(event,'CPU+CPU wait')  wait_event
        ,       xid    wait_xid
        ,       blocking_inst_id, blocking_session, blocking_session_serial#
        FROM    &&cdb_awr_object_prefix.active_Sess_history h
        WHERE   blocking_session_status = 'VALID' --holding a lock
--add dbid/date/snap_id criteria here
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
), x as (
SELECT /*+ &&sq_fact_hints. */
       /* &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
        w.*
,       h.sample_id hold_sample_id
,       h.sample_time hold_Sample_time
,       h.session_Type hold_session_type
,       CASE WHEN h.sample_id IS NULL THEN 'Idle Blocker'
             ELSE NVL(h.event,'CPU+CPU Wait')
        END as   hold_event
,       regexp_substr(h.program,'[^\.@]+',1,1)||' '||
        regexp_replace(regexp_substR(regexp_substr(h.program,'[\.@].+',1,1),'[\(].+',1,1),'[[:digit:]]','n',1,0) hold_program
,       h.module hold_module
,       CASE WHEN upper(h.program) LIKE 'ORACLE%'
             THEN REGEXP_REPLACE(h.action,'[[:digit:]]+','nnn',1,1)
             ELSE h.action END hold_action
,       h.xid hold_xid
,       CASE WHEN w.blocking_inst_id != w.instance_number THEN 'CI' END AS ci --cross-instance
FROM    w
        LEFT OUTER JOIN &&cdb_awr_object_prefix.active_Sess_History h --holding session
        ON  h.dbid = w.dbid
        AND h.instance_number = w.blocking_inst_id
        AND h.snap_id = w.snap_id
        AND h.sample_time >= w.sample_time -2/86400
        AND h.sample_time <  w.sample_time +2/86400 --rough match cross instance
        AND (h.sample_id = w.sample_id OR h.instance_number != w.instance_number) --exact match local instance
        AND h.session_id = w.blocking_Session
        AND h.session_serial# = w.blocking_Session_serial#
--add same dbid/date/snap_id criteria here
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
), y as (
SELECT
  &&skip_noncdb.con_id,
  hold_program, hold_module, hold_action, wait_event, hold_event
, ci
, SUM(10) ash_Secs
FROM x
GROUP BY
  &&skip_noncdb.con_id,
  hold_program, hold_module, hold_action, wait_event, hold_event, ci
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ y.*
&&skip_noncdb.,c.name con_name
FROM   y
&&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = y.con_id
ORDER BY ash_Secs DESC
]';
END;
/
--@@&&skip_diagnostics.edb360_9a_pre_one.sql

column hold_sql_id heading 'Holding|SQL ID'
column hold_sql_plan_hash_value heading 'Holding|SQL Plan|Hash Value'

DEF title = 'Profile of Blocking Sessions with SQL_ID';
DEF main_table = '&&cdb_awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := q'[
-- developed by David Kurtz
WITH w AS ( --waiting sessions
	SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
	       /* &&section_id..&&report_sequence. */
	            &&skip_noncdb.con_id
	    ,       dbid, instance_number
        ,       snap_id
	,       sample_id, sample_time
        ,       session_type wait_session_type
        ,       session_id, session_serial#
        ,       sql_id, sql_plan_hash_value, sql_plan_line_id
--simplified program name removing anything after first @ or dot until open a bracket
        ,       regexp_substr(program,'[^\.@]+',1,1) ||' '||
                regexp_replace(regexp_substR(regexp_substr(program,'[\.@].+',1,1),'[\(].+',1,1),'[[:digit:]]','n',1,0) wait_program
        ,       CASE WHEN module=program THEN '[not set]' ELSE module END as wait_module
        ,       CASE WHEN upper(program) LIKE 'ORACLE%' OR 1=1
                     THEN REGEXP_REPLACE(action,'[[:digit:]]+','nnn',1,1)
                     ELSE action END wait_action
        ,       NVL(event,'CPU+CPU wait')  wait_event
        ,       xid    wait_xid
        ,       blocking_inst_id, blocking_session, blocking_session_serial#
        FROM    &&cdb_awr_object_prefix.active_Sess_history h
        WHERE   blocking_session_status = 'VALID' --holding a lock
--add dbid/date/snap_id criteria here
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
), x as (
SELECT  /*+ &&sq_fact_hints. */
        /* &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
        /* &&section_id..&&report_sequence. */
      w.*
,       h.sample_id hold_sample_id
,       h.sample_time hold_Sample_time
,       h.session_Type hold_session_type
,       h.sql_id hold_sql_id
,       h.sql_plan_hash_Value hold_sql_plan_hash_Value
,       CASE WHEN h.sample_id IS NULL THEN 'Idle Blocker'
             ELSE NVL(h.event,'CPU+CPU Wait')
        END as   hold_event
,       regexp_substr(h.program,'[^\.@]+',1,1)||' '||
        regexp_replace(regexp_substR(regexp_substr(h.program,'[\.@].+',1,1),'[\(].+',1,1),'[[:digit:]]','n',1,0) hold_program
,       CASE WHEN h.module=h.program THEN '[not set]' ELSE h.module END as hold_module
,       CASE WHEN upper(h.program) LIKE 'ORACLE%' OR 1=1
             THEN REGEXP_REPLACE(h.action,'[[:digit:]]+','nnn',1,1)
             ELSE h.action END hold_action
,       h.xid hold_xid
,       CASE WHEN w.blocking_inst_id != w.instance_number THEN 'CI' END AS ci --cross-instance
FROM    w
        LEFT OUTER JOIN &&cdb_awr_object_prefix.active_Sess_History h --holding session
        ON  h.dbid = w.dbid
        AND h.instance_number = w.blocking_inst_id
        AND h.snap_id = w.snap_id
        AND h.sample_time >= w.sample_time -2/86400
        AND h.sample_time <  w.sample_time +2/86400 --rough match cross instance
        AND (h.sample_id = w.sample_id OR h.instance_number != w.instance_number) --exact match local instance
        AND h.session_id = w.blocking_Session
        AND h.session_serial# = w.blocking_Session_serial#
--add same dbid/date/snap_id criteria here
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
), y as (
select &&skip_noncdb.con_id,
  hold_program, hold_module, hold_action, wait_event, hold_event
, hold_sql_id, hold_sql_plan_hash_value
, sum(10) ash_Secs
  &&skip_noncdb.,c.name con_name
from x
group by &&skip_noncdb.con_id,
  hold_program, hold_module, hold_action, wait_event, hold_event
, hold_sql_id, hold_sql_plan_hash_value
)
select y.*
from y
	 &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = y.con_id
order by ash_Secs desc
]';
END;
/
--@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Distributed Transactions awaiting Recovery';
DEF main_table = '&&cdb_view_prefix.2PC_PENDING';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&cdb_object_prefix.2pc_pending
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Connections for Pending Transactions';
DEF main_table = '&&cdb_view_prefix.2PC_NEIGHBORS';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&cdb_object_prefix.2pc_neighbors
 ORDER BY
       1
]';
END;
/
@@edb360_9a_pre_one.sql

BEGIN
 :sql_text_backup := q'[
WITH
by_instance_and_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       MAX(r.current_utilization) current_utilization,
       MAX(r.max_utilization) max_utilization
  FROM &&awr_object_prefix.resource_limit r,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name = '@resource_name@'
   AND s.instance_number = '@instance_number@'
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(current_utilization) current_utilization,
       SUM(max_utilization) max_utilization,
       0 dummy_03,
       0 dummy_04,
       0 dummy_05,
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
  FROM by_instance_and_snap
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Processes Time Series for Cluster';
DEF main_table = '&&awr_hist_prefix.RESOURCE_LIMIT';
DEF vaxis = 'Processes';
DEF tit_01 = 'Current Utilization';
DEF tit_02 = 'Max Utilization';
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
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup, '@resource_name@', 'processes');
EXEC :sql_text := REPLACE(:sql_text_backup2, '''@instance_number@''', 'r.instance_number');
@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Processes Time Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Processes Time Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Processes Time Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Processes Time Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Processes Time Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Processes Time Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Processes Time Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql
DEF skip_lch = '';
DEF title = 'Processes Time Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions Time Series for Cluster';
DEF main_table = '&&awr_hist_prefix.RESOURCE_LIMIT';
DEF vaxis = 'Sessions';
DEF tit_01 = 'Current Utilization';
DEF tit_02 = 'Max Utilization';
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
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup, '@resource_name@', 'sessions');
EXEC :sql_text := REPLACE(:sql_text_backup2, '''@instance_number@''', 'r.instance_number');
@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Sessions Time Series for Instance 1';
DEF abstract = '&&abstract_uom.';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_inst1.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Sessions Time Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_inst2.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Sessions Time Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_inst3.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Sessions Time Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_inst4.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Sessions Time Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_inst5.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Sessions Time Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_inst6.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Sessions Time Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_inst7.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Sessions Time Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_inst8.&&skip_diagnostics.edb360_9a_pre_one.sql


SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
