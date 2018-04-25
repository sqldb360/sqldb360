@@&&edb360_0g.tkprof.sql
DEF section_id = '3b';
DEF section_name = 'Plan Stability';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

@@&&skip_tuning.&&skip_10g_script.&&skip_11r1_script.edb360_3b_autotunereport.sql

DEF title = 'SQL Patches';
DEF main_table = '&&dva_view_prefix.SQL_PATCHES';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.sql_patches
 ORDER BY
       created DESC
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql       

DEF title = 'SQL Profiles';
DEF main_table = '&&dva_view_prefix.SQL_PROFILES';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.sql_profiles
 ORDER BY
       created DESC
]';
END;
/
@@&&skip_tuning.edb360_9a_pre_one.sql       

DEF title = 'SQL Plan Profiles Summary by Type and Status';
DEF main_table = '&&dva_view_prefix.SQL_PROFILES';
BEGIN
  :sql_text := q'[
SELECT COUNT(*),
       category,
       type,
       status,
       MIN(created) min_created,
       MAX(created) max_created,
       MEDIAN(created) median_created
  FROM &&dva_object_prefix.sql_profiles
 GROUP BY
       category,
       type,
       status
 ORDER BY
       1 DESC, 2, 3, 4
]';
END;
/
@@&&skip_tuning.edb360_9a_pre_one.sql       

DEF title = 'SQL Profiles Summary by Creation Month';
DEF main_table = '&&dva_view_prefix.SQL_PROFILES';
BEGIN
  :sql_text := q'[
SELECT TO_CHAR(TRUNC(created, 'MM'), 'YYYY-MM') created,
       COUNT(*) profiles,
       SUM(CASE status WHEN 'ENABLED' THEN 1 ELSE 0 END) enabled,
       SUM(CASE status WHEN 'DISABLED' THEN 1 ELSE 0 END) disabled
  FROM &&dva_object_prefix.sql_profiles
 GROUP BY
       TRUNC(created, 'MM')
 ORDER BY
       1
]';
END;
/
@@&&skip_tuning.edb360_9a_pre_one.sql       

DEF title = 'SQL Plan Baselines';
DEF main_table = '&&dva_view_prefix.SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.sql_plan_baselines
 ORDER BY
       created DESC
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql       

DEF title = 'SQL Plan Baselines Summary by Status';
DEF main_table = '&&dva_view_prefix.SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
SELECT COUNT(*),
       enabled,
       accepted,
       fixed,
       reproduced,
       MIN(created) min_created,
       MAX(created) max_created,
       MEDIAN(created) median_created
  FROM &&dva_object_prefix.sql_plan_baselines
 GROUP BY
       enabled,
       accepted,
       fixed,
       reproduced
 ORDER BY
       1 DESC, 2, 3, 4, 5
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql       

DEF title = 'SQL Plan Baselines Summary by Creation Month';
DEF main_table = '&&dva_view_prefix.SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
SELECT TO_CHAR(TRUNC(created, 'MM'), 'YYYY-MM') created,
       COUNT(*) baselines,
       SUM(CASE enabled WHEN 'YES' THEN 1 ELSE 0 END) enabled,
       SUM(CASE enabled WHEN 'YES' THEN (CASE accepted WHEN 'YES' THEN 1 ELSE 0 END) ELSE 0 END) accepted,
       &&skip_11r1_column.SUM(CASE enabled WHEN 'YES' THEN (CASE accepted WHEN 'YES' THEN (CASE reproduced WHEN 'YES' THEN 1 ELSE 0 END) ELSE 0 END) ELSE 0 END) reproduced,
       SUM(CASE enabled WHEN 'NO' THEN 1 ELSE 0 END) disabled
  FROM &&dva_object_prefix.sql_plan_baselines
 GROUP BY
       TRUNC(created, 'MM')
 ORDER BY
       1
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql       

DEF title = 'SQL Plan Baselines State by SQL';
DEF main_table = '&&dva_view_prefix.SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
SELECT q.signature,
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
       MIN(q.sql_text) min_sql_text
  FROM &&dva_object_prefix.sql_plan_baselines q
 GROUP BY
       q.signature,
       q.sql_handle
 ORDER BY
       q.signature,
       q.sql_handle
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql       

DEF title = 'SQL Plan Directives';
DEF main_table = '&&dva_view_prefix.SQL_PLAN_DIRECTIVES';
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
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql       

DEF title = 'SQL Plan Directives - Objects';
DEF main_table = '&&dva_view_prefix.SQL_PLAN_DIR_OBJECTS';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.sql_plan_dir_objects
 ORDER BY
       1,2,3,4
 ]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql       

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
