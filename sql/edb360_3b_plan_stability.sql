@@&&edb360_0g.tkprof.sql
DEF section_id = '3b';
DEF section_name = 'Plan Stability';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

@@&&skip_tuning.&&skip_ver_le_11_1.edb360_3b_autotunereport.sql

DEF title = 'SQL Patches';
DEF main_table = '&&cdb_view_prefix.SQL_PATCHES';
BEGIN
  :sql_text := q'[
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.sql_patches x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.created DESC
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'SQL Profiles';
DEF main_table = '&&cdb_view_prefix.SQL_PROFILES';
BEGIN
  :sql_text := q'[
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.sql_profiles x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.created DESC
]';
END;
/
@@&&skip_tuning.edb360_9a_pre_one.sql

DEF title = 'SQL Plan Profiles Summary by Type and Status';
DEF main_table = '&&cdb_view_prefix.SQL_PROFILES';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT COUNT(*) profiles,
       &&skip_noncdb.con_id,
       category,
       type,
       status,
       MIN(created) min_created,
       MAX(created) max_created,
       MEDIAN(created) median_created
  FROM &&cdb_object_prefix.sql_profiles
 GROUP BY
       &&skip_noncdb.con_id,
       category,
       type,
       status
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.profiles DESC, x.category, x.type, x.status
]';
END;
/
@@&&skip_tuning.edb360_9a_pre_one.sql

DEF title = 'SQL Profiles Summary by Creation Month';
DEF main_table = '&&cdb_view_prefix.SQL_PROFILES';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT &&skip_noncdb.con_id,
	   TO_CHAR(TRUNC(created, 'MM'), 'YYYY-MM') created,
       COUNT(*) profiles,
       SUM(CASE status WHEN 'ENABLED' THEN 1 ELSE 0 END) enabled,
       SUM(CASE status WHEN 'DISABLED' THEN 1 ELSE 0 END) disabled
  FROM &&cdb_object_prefix.sql_profiles
 GROUP BY
       &&skip_noncdb.con_id,
	   TRUNC(created, 'MM')
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.created
]';
END;
/
@@&&skip_tuning.edb360_9a_pre_one.sql

DEF title = 'SQL Plan Baselines';
DEF main_table = '&&cdb_view_prefix.SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.sql_plan_baselines x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.created DESC
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'SQL Plan Baselines Summary by Status';
DEF main_table = '&&cdb_view_prefix.SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
WITH x AS (
SELECT COUNT(*) baselines,
       &&skip_noncdb.con_id,
       enabled,
       accepted,
       fixed,
       reproduced,
       MIN(created) min_created,
       MAX(created) max_created,
       MEDIAN(created) median_created
  FROM &&cdb_object_prefix.sql_plan_baselines
 GROUP BY
       &&skip_noncdb.con_id,
       enabled,
       accepted,
       fixed,
       reproduced
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.baselines DESC,
	   &&skip_noncdb.x.con_id,
	   x.enabled, x.accepted, x.fixed, x.reproduced
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'SQL Plan Baselines Summary by Creation Month';
DEF main_table = '&&cdb_view_prefix.SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT TO_CHAR(TRUNC(created, 'MM'), 'YYYY-MM') created,
       &&skip_noncdb.con_id,
       COUNT(*) baselines,
       SUM(CASE enabled WHEN 'YES' THEN 1 ELSE 0 END) enabled,
       SUM(CASE enabled WHEN 'YES' THEN (CASE accepted WHEN 'YES' THEN 1 ELSE 0 END) ELSE 0 END) accepted,
       &&skip_ver_le_11_1.SUM(CASE enabled WHEN 'YES' THEN (CASE accepted WHEN 'YES' THEN (CASE reproduced WHEN 'YES' THEN 1 ELSE 0 END) ELSE 0 END) ELSE 0 END) reproduced,
       SUM(CASE enabled WHEN 'NO' THEN 1 ELSE 0 END) disabled
  FROM &&cdb_object_prefix.sql_plan_baselines
 GROUP BY
       &&skip_noncdb.con_id,
	   TRUNC(created, 'MM')
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       x.created
	   &&skip_noncdb.,x.con_id
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'SQL Plan Baselines State by SQL';
DEF main_table = '&&cdb_view_prefix.SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
WITH x as (
SELECT &&skip_noncdb.q.con_id,
	   q.signature,
       q.sql_handle,
       MIN(q.created) created,
       MAX(q.last_modified) last_modified,
       MAX(q.last_executed) last_executed,
       MAX(q.last_verified) last_verified,
       COUNT(*) plans_in_history,
       SUM(CASE q.enabled WHEN 'YES' THEN 1 ELSE 0 END) enabled,
       SUM(CASE q.enabled||q.accepted WHEN 'YESYES' THEN 1 ELSE 0 END) enabled_and_accepted,
       SUM(CASE q.enabled||q.accepted||q.reproduced WHEN 'YESYESYES' THEN 1 ELSE 0 END) enabled_accepted_reproduced,
       SUM(CASE q.enabled||q.accepted||q.reproduced||q.fixed WHEN 'YESYESYESYES' THEN 1 ELSE 0 END) enabled_accept_reprod_fixed,
       SUM(CASE q.enabled||q.accepted WHEN 'YESNO' THEN 1 ELSE 0 END) pending,
       SUM(CASE q.enabled WHEN 'NO' THEN 1 ELSE 0 END) disabled,
       --MIN(q.sql_text) min_sql_text
	   MIN(DBMS_LOB.SUBSTR(q.sql_text,1,32767)) min_sql_text
  FROM &&cdb_object_prefix.sql_plan_baselines q
 GROUP BY
       &&skip_noncdb.q.con_id,
	   q.signature,
       q.sql_handle
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
FROM   x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
	   x.signature,
       x.sql_handle
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'SQL Plan Directives';
DEF main_table = '&&cdb_view_prefix.SQL_PLAN_DIRECTIVES';
BEGIN
  :sql_text := q'[
SELECT d.dir_id,
       d.type,
       d.enabled,
       (CASE WHEN d.internal_state = 'HAS_STATS' OR d.redundant = 'YES' THEN 'SUPERSEDED'
             WHEN d.internal_state IN ('NEW', 'MISSING_STATS', 'PERMANENT') THEN 'USABLE'
             ELSE 'UNKNOWN'
         END) state,
       d.auto_drop,
       f.reason,
       d.created,
       d.last_modified,
       d.last_used,
       d.internal_state,
       d.redundant
  FROM sys."_BASE_OPT_DIRECTIVE" d,
       sys."_BASE_OPT_FINDING" f
  WHERE d.f_id = f.f_id
 ORDER BY 1
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'SQL Plan Directives - Objects';
DEF main_table = '&&cdb_view_prefix.SQL_PLAN_DIR_OBJECTS';
BEGIN
  :sql_text := q'[
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.sql_plan_dir_objects x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY 1,2,3,4,5
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
