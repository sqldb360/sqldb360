@@&&edb360_0g.tkprof.sql
DEF section_id = '1c';
DEF section_name = 'Auditing';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Default Object Auditing Options';
DEF main_table = 'ALL_DEF_AUDIT_OPTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM all_def_audit_opts
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Object Auditing Options';
DEF main_table = '&&dva_view_prefix.OBJ_AUDIT_OPTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       o.*
  FROM &&dva_object_prefix.obj_audit_opts o
 --WHERE (o.alt,o.aud,o.com,o.del,o.gra,o.ind,o.ins,o.loc,o.ren,o.sel,o.upd,o.ref,o.exe,o.fbk,o.rea) NOT IN 
 --      (SELECT d.alt,d.aud,d.com,d.del,d.gra,d.ind,d.ins,d.loc,d.ren,d.sel,d.upd,d.ref,d.exe,d.fbk,d.rea FROM all_def_audit_opts d)
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Statement Auditing Options';
DEF main_table = '&&dva_view_prefix.STMT_AUDIT_OPTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM &&dva_object_prefix.stmt_audit_opts
 ORDER BY
       1 NULLS FIRST, 2 NULLS FIRST
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'System Privileges Auditing Options';
DEF main_table = '&&dva_view_prefix.PRIV_AUDIT_OPTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM &&dva_object_prefix.priv_audit_opts
 ORDER BY
       1 NULLS FIRST, 2 NULLS FIRST
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Audit related Initialization Parameters';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       inst_id, name "PARAMETER", value, isdefault, ismodified
  FROM &&gv_object_prefix.system_parameter2
 WHERE name LIKE '%audit%'
 ORDER BY 2,1,3
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unified Auditing';
DEF main_table = '&&v_view_prefix.OPTION';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       value "Unified Auditing"
  FROM &&v_object_prefix.option
 WHERE parameter = 'Unified Auditing' 
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Audit Configuration';
DEF main_table = '&&dva_view_prefix.AUDIT_MGMT_CONFIG_PARAMS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM &&dva_object_prefix.audit_mgmt_config_params
 ORDER BY 1,2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Audit Trail Locations';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       SUBSTR(owner||'.'||table_name,1,30) audit_trail, tablespace_name
  FROM &&dva_object_prefix.tables
 --WHERE table_name IN ('AUD$','AUDIT$','FGA$','FGA_LOG$')
 WHERE table_name IN ('AUD$','FGA_LOG$')
    OR table_name IN ('UNIFIED_AUDIT_TRAIL','CDB_UNIFIED_AUDIT_TRAIL','V_$UNIFIED_AUDIT_TRAIL','GV_$UNIFIED_AUDIT_TRAIL') -- 12c UAT
 ORDER BY 1,2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Object Level Privileges (Audit Trail)';
DEF main_table = '&&dva_view_prefix.TAB_PRIVS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       owner || '.' || table_name "TABLE", grantee, privilege, grantable
  FROM &&dva_object_prefix.tab_privs
 WHERE (   table_name IN ('AUD$','AUDIT$','FGA$','FGA_LOG$')
        OR table_name IN ('UNIFIED_AUDIT_TRAIL','CDB_UNIFIED_AUDIT_TRAIL','V_$UNIFIED_AUDIT_TRAIL','GV_$UNIFIED_AUDIT_TRAIL') -- 12c UAT
       )
   AND grantee NOT IN ('SYS','SYSTEM','DBA','AUDIT_ADMIN','AUDIT_VIEWER')
   AND owner IN ('SYS','SYSTEM')
 ORDER BY table_name, owner, grantee, privilege
]';
END;
/
@@edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
