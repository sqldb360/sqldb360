DEF section_id = '2e';
DEF section_name = 'Plan Control';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

COL sql_text NOPRI

DEF title = 'SQL Profiles';
DEF main_table = 'DBA_SQL_PROFILES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM dba_sql_profiles 
 WHERE signature IN ( &&exact_matching_signature. , &&force_matching_signature. ) 
   AND '&&tuning_pack.' = 'Y'
 ORDER BY category, name
]';
END;
/
@@sqld360_9a_pre_one.sql

COL sql_text PRI

DEF title = 'SQL Profile Data';
DEF main_table = 'DBMSHSXP_SQL_PROFILE_ATTR';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM dbmshsxp_sql_profile_attr 
 WHERE profile_name IN (SELECT name 
                          FROM dba_sql_profiles 
                         WHERE signature IN ( &&exact_matching_signature. , &&force_matching_signature. )) 
   AND '&&tuning_pack.' = 'Y'
 ORDER BY profile_name
]';
END;
/
@@sqld360_9a_pre_one.sql


COL sql_text NOPRI

DEF title = 'SQL Plan Baselines';
DEF main_table = 'DBA_SQL_PLAN_BASELINES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM dba_sql_plan_baselines
 WHERE signature IN ( &&exact_matching_signature. , &&force_matching_signature. ) 
 ORDER BY plan_name
]';
END;
/
@@sqld360_9a_pre_one.sql

COL sql_text PRI



COL sql_text NOPRI

DEF title = 'SQL Patches';
DEF main_table = 'DBA_SQL_PATCHES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM dba_sql_patches
 WHERE signature IN ( &&exact_matching_signature. , &&force_matching_signature. ) 
 ORDER BY category, name
]';
END;
/
@@sqld360_9a_pre_one.sql

COL sql_text PRI


DEF title = 'SQL Plan Directives';
DEF main_table = 'DBA_SQL_PLAN_DIRECTIVES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM (SELECT d.dir_id directive_id,
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
          WHERE d.f_id = f.f_id)
 WHERE directive_id IN (SELECT directive_id
                          FROM dba_sql_plan_dir_objects
                         WHERE (owner, object_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')) 
 ORDER BY directive_id
]';
END;
/
@@&&skip_10g.&&skip_11g.sqld360_9a_pre_one.sql


--DEF title = 'SQL Plan Directives Objects';
--DEF main_table = 'DBA_SQL_PLAN_DIR_OBJECTS';
--BEGIN
--  :sql_text := '
--SELECT /*+ &&top_level_hints. */
--       directive_id, owner, object_name, subobject_name, object_type
--  FROM dba_sql_plan_dir_objects
-- WHERE (owner, object_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
-- ORDER BY owner, object_name, directive_id
--';
--END;
--/
--@@&&skip_10g.&&skip_11g.sqld360_9a_pre_one.sql

-- this only makes sense in 12.2 because of the other object_type so can't filter on just owner, object_name
DEF title = 'SQL Plan Directives Objects';
DEF main_table = 'DBA_SQL_PLAN_DIR_OBJECTS';
BEGIN
  :sql_text := q'[
WITH dir_id AS (SELECT directive_id 
                  FROM dba_sql_plan_dir_objects
                 WHERE (owner, object_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.'))
SELECT /*+ &&top_level_hints. */ *
  FROM dba_sql_plan_dir_objects
 WHERE directive_id IN (SELECT directive_id FROM dir_id)
 ORDER BY owner, object_name, directive_id
]';
END;
/
@@&&skip_10g.&&skip_11g.sqld360_9a_pre_one.sql


COL ADDRESS NOPRI

DEF title = 'SQL ReOptimization Hints';
DEF main_table = 'GV$SQL_REOPTIMIZATION_HINTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$sql_reoptimization_hints
 WHERE sql_id = '&&sqld360_sqlid.' 
 ORDER BY inst_id, child_number, hint_id
]';
END;
/
@@&&skip_10g.&&skip_11g.sqld360_9a_pre_one.sql

COL ADDRESS PRI

DEF title = 'Mapped SQL';
DEF main_table = 'GV$MAPPED_SQL';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       * 
  FROM gv$mapped_sql
 WHERE mapped_sql_id = '&&sqld360_sqlid.' OR sql_id = '&&sqld360_sqlid.'
 ORDER BY inst_id
]';
END;
/
@@&&skip_10g.&&skip_11g.sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;