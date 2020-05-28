@@&&edb360_0g.tkprof.sql
DEF section_id = '3a';
DEF section_name = 'Database Resource Management (DBRM)';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

COL consumer_group_id heading 'Consumer|Group ID'
COL consumer_group heading 'Consumer|Group'
COL grant_option heading 'Grant|Option'
COL initial_group heading 'Initial|Group'
COL num_plan_directives heading 'Number of Plan|Directives'
COL mandatory heading 'Mandatory'

DEF title = 'Consumer Groups';
DEF main_table = '&&cdb_view_prefix.RSRC_CONSUMER_GROUPS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.rsrc_consumer_groups x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Consumer Group Users and Roles';
DEF main_table = '&&cdb_view_prefix.RSRC_CONSUMER_GROUP_PRIVS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.rsrc_consumer_group_privs x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Groups Mappings';
DEF main_table = '&&cdb_view_prefix.RSRC_GROUP_MAPPINGS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.rsrc_group_mappings x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Groups Mapping Priorities';
DEF main_table = '&&cdb_view_prefix.RSRC_MAPPING_PRIORITY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.rsrc_mapping_priority x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Plan Directives';
DEF main_table = '&&cdb_view_prefix.RSRC_PLAN_DIRECTIVES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.rsrc_plan_directives x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Plans';
DEF main_table = '&&cdb_view_prefix.RSRC_PLANS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.rsrc_plans x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Plan Directives for PDBs';
DEF main_table = '&&cdb_view_prefix.CDB_RSRC_PLAN_DIRECTIVES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.cdb_rsrc_plan_directives x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Resource Plans for PDBs';
DEF main_table = '&&cdb_view_prefix.CDB_RSRC_PLANS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.cdb_rsrc_plans x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Active Resource Consumer Groups';
DEF main_table = '&&gv_view_prefix.RSRC_CONSUMER_GROUP';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
	   &&skip_noncdb.,c.name con_name
  FROM &&gv_object_prefix.rsrc_consumer_group x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY
       &&skip_noncdb.x.con_id,
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Consumer Group History';
DEF main_table = '&&gv_view_prefix.RSRC_CONS_GROUP_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.rsrc_cons_group_history
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Plan';
DEF main_table = '&&gv_view_prefix.RSRC_PLAN';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.rsrc_plan
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resource Plan History';
DEF main_table = '&&gv_view_prefix.RSRC_PLAN_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.rsrc_plan_history
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'RM Stats per Session';
DEF main_table = '&&gv_view_prefix.RSRC_SESSION_INFO';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.rsrc_session_info
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Resources Consumed per Consumer Group';
DEF main_table = '&&gv_view_prefix.RSRCMGRMETRIC';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.rsrcmgrmetric
 ORDER BY
       1, 2
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Resources Consumed History';
DEF main_table = '&&gv_view_prefix.RSRCMGRMETRIC_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.rsrcmgrmetric_history
 ORDER BY
       1, 2
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

COL consumer_group_id heading clear
COL consumer_group heading clear
COL grant_option heading clear
COL initial_group heading clear
COL mandatory heading clear
