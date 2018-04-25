-- time zero for edb360 (begin)
VAR edb360_main_time0 NUMBER;
EXEC :edb360_main_time0 := DBMS_UTILITY.GET_TIME;

DEF v_dollar = 'V$';
COL my_sid NEW_V my_sid;
SELECT TO_CHAR(sid) my_sid FROM &&v_dollar.mystat WHERE ROWNUM = 1;

SET TERM ON;
SPO 00000_readme_first_&&my_sid..txt
-- initial validation
PRO If eDB360 disconnects right after this message it means the user executing it
PRO owns a table called PLAN_TABLE that is not the Oracle seeded GTT plan table
PRO owned by SYS (PLAN_TABLE$ table with a PUBLIC synonym PLAN_TABLE).
PRO eDB360 requires the Oracle seeded PLAN_TABLE, consider dropping the one in this schema.
WHENEVER SQLERROR EXIT;
DECLARE
 is_plan_table_in_usr_schema NUMBER; 
BEGIN
 SELECT COUNT(*)
   INTO is_plan_table_in_usr_schema
   FROM user_tables
  WHERE table_name = 'PLAN_TABLE';
  -- user has a physical table called PLAN_TABLE, abort
  IF is_plan_table_in_usr_schema > 0 THEN
    RAISE_APPLICATION_ERROR(-20100, 'PLAN_TABLE physical table present in user schema '||USER||'.');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;

-- parameters (reset readme)
SPO 00000_readme_first_&&my_sid..txt
PRO
PRO Parameter 1: 
PRO If your Database is licensed to use the Oracle Tuning pack please enter T.
PRO If you have a license for Diagnostics pack but not for Tuning pack, enter D.
PRO If you have both Tuning and Diagnostics packs, enter T.
PRO Be aware value N reduces the output content substantially. Avoid N if possible.
PRO
PRO Oracle Pack License? (Tuning, Diagnostics or None) [ T | D | N ] (required)
COL license_pack NEW_V license_pack FOR A1;
SELECT NVL(UPPER(SUBSTR(TRIM('&1.'), 1, 1)), '?') license_pack FROM DUAL;
WHENEVER SQLERROR EXIT SQL.SQLCODE;
BEGIN
  IF NOT '&&license_pack.' IN ('T', 'D', 'N') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Invalid Oracle Pack License "&&license_pack.". Valid values are T, D and N.');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;
SET TERM OFF;
COL diagnostics_pack NEW_V diagnostics_pack FOR A1;
SELECT CASE WHEN '&&license_pack.' IN ('T', 'D') THEN 'Y' ELSE 'N' END diagnostics_pack FROM DUAL;
COL skip_diagnostics NEW_V skip_diagnostics FOR A1;
SELECT CASE WHEN '&&license_pack.' IN ('T', 'D') THEN NULL ELSE 'Y' END skip_diagnostics FROM DUAL;
COL tuning_pack NEW_V tuning_pack FOR A1;
SELECT CASE WHEN '&&license_pack.' = 'T' THEN 'Y' ELSE 'N' END tuning_pack FROM DUAL;
COL skip_tuning NEW_V skip_tuning FOR A1;
SELECT CASE WHEN '&&license_pack.' = 'T' THEN NULL ELSE 'Y' END skip_tuning FROM DUAL;
SET TERM ON;
SELECT 'Be aware value "N" reduces output content substantially. Avoid "N" if possible.' warning FROM dual WHERE '&&license_pack.' = 'N';
BEGIN
  IF '&&license_pack.' = 'N' THEN
    DBMS_LOCK.SLEEP(10); -- sleep few seconds
  END IF;
END;
/

PRO
PRO Parameter 2:
PRO Name of an optional custom configuration file executed right after 
PRO sql/edb360_00_config.sql. If such file name is provided, then corresponding file
PRO should exist under edb360-master/sql. Filename is case sensitivive and its existence
PRO is not validated. Example: custom_config_01.sql
PRO If no custom configuration file is needed, simply hit the "return" key.
PRO
PRO Custom configuration filename? (optional)
COL custom_config_filename NEW_V custom_config_filename NOPRI;
SELECT NVL(TRIM('&2.'), 'null') custom_config_filename FROM DUAL;

SPO OFF;

-- ash verification
DEF edb360_estimated_hrs = '0';
@@&&ash_validation.&&skip_diagnostics.verify_stats_wr_sys.sql
@@&&ash_validation.&&skip_diagnostics.awr_ash_pre_check.sql

SET HEA OFF TERM OFF;
SPO edb360_pause.sql
SELECT 'PAUSE *** eDB360 may take over 8 hours to execute, hit "return" to continue, or control-c to quit. ' FROM DUAL WHERE &&edb360_estimated_hrs. > 8;
SPO OFF;
SET HEA ON TERM ON;
@edb360_pause.sql
HOS rm edb360_pause.sql

-- reset readme
SET TERM OFF;
SPO 00000_readme_first_&&my_sid..txt
PRO
PRO Open and read 00001_edb360_<dbname>_index.html
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO initial log:
PRO
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
DEF
@@edb360_00_config.sql
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO custom configuration filename: "&&custom_config_filename."
PRO
SET SUF '';
@@&&custom_config_filename.
SET SUF sql;
@@&&custom_config_filename.

-- links
DEF edb360_conf_tool_page = '<a href="http://carlos-sierra.net/edb360-an-oracle-database-360-degree-view/" target="_blank">';
DEF edb360_conf_all_pages_icon = '<a href="http://carlos-sierra.net/edb360-an-oracle-database-360-degree-view/" target="_blank"><img src="edb360_img.jpg" alt="eDB360" height="33" width="52" /></a>';
DEF edb360_conf_all_pages_logo = '';
DEF edb360_conf_google_charts = '<script type="text/javascript" src="https://www.google.com/jsapi"></script>';
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO config log:
PRO
DEF
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO setup log:
PRO
@@edb360_0b_pre.sql
DEF section_id = '0a';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
DEF max_col_number = '7';
DEF column_number = '0';
SPO &&edb360_main_report..html APP;
PRO <table><tr class="main">
PRO <td class="c">1/&&max_col_number.</td>
PRO <td class="c">2/&&max_col_number.</td>
PRO <td class="c">3/&&max_col_number.</td>
PRO <td class="c">4/&&max_col_number.</td>
PRO <td class="c">5/&&max_col_number.</td>
PRO <td class="c">6/&&max_col_number.</td>
PRO <td class="c">7/&&max_col_number.</td>
PRO </tr><tr class="main"><td>
PRO &&edb360_conf_tool_page.<img src="edb360_img.jpg" alt="eDB360" height="201" width="313" /></a>
PRO <br />
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '1';

@@&&edb360_1a.configuration.sql
@@&&edb360_1b.security.sql
@@&&edb360_1c.audit.sql
@@&&edb360_1d.memory.sql
@@&&edb360_1e.resources.sql
@@&&edb360_1f.resources_statspack.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '2';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&edb360_2a.admin.sql
@@&&edb360_2b.storage.sql
@@&&edb360_2c.asm.sql
@@&&edb360_2d.rman.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '3';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&edb360_3a.resource_mgm.sql
@@&&edb360_3b.plan_stability.sql
@@&&edb360_3c.cbo_stats.sql
@@&&edb360_3d.performance.sql
@@&&skip_diagnostics.&&edb360_3e.os_stats.sql
@@&&is_single_instance.&&skip_diagnostics.&&edb360_3f.ic_latency.sql
@@&&is_single_instance.&&skip_diagnostics.&&edb360_3g.ic_performance.sql
@@&&edb360_3h.sessions.sql
@@&&edb360_3i.jdbc_sessions.sql
@@&&edb360_3j.non_jdbc_sessions.sql
@@&&edb360_3k.dataguard.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '4';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.&&edb360_4a.sga_stats.sql
@@&&skip_diagnostics.&&edb360_4b.pga_stats.sql
@@&&skip_diagnostics.&&edb360_4c.mem_stats.sql
@@&&skip_diagnostics.&&edb360_4d.time_model.sql
@@&&skip_diagnostics.&&edb360_4e.time_model_comp.sql
@@&&skip_diagnostics.&&skip_10g_script.&&edb360_4f.io_waits.sql
@@&&skip_diagnostics.&&skip_10g_script.&&edb360_4g.io_waits_top_histog.sql
@@&&skip_diagnostics.&&skip_10g_script.&&edb360_4h.io_waits_top_trend.sql
@@&&skip_diagnostics.&&skip_10g_script.&&edb360_4i.io_waits_top_relation.sql
@@&&edb360_4j.parallel_execution.sql
@@&&skip_diagnostics.&&edb360_4k.sysmetric_history.sql
@@&&skip_diagnostics.&&edb360_4l.sysmetric_summary.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '5';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.&&edb360_5a.ash.sql
@@&&skip_diagnostics.&&edb360_5b.ash_wait.sql
@@&&skip_diagnostics.&&edb360_5c.ash_top.sql
@@&&skip_diagnostics.&&edb360_5d.sysstat.sql
@@&&skip_diagnostics.&&edb360_5e.sysstat_exa.sql
@@&&skip_diagnostics.&&edb360_5f.sysstat_current.sql
@@&&skip_diagnostics.&&edb360_5g.exadata.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '6';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.&&edb360_6a.ash_class.sql
@@&&skip_diagnostics.&&edb360_6b.ash_event.sql
@@&&skip_diagnostics.&&edb360_6c.ash_sql.sql
@@&&skip_diagnostics.&&edb360_6d.ash_sql_ts.sql
@@&&skip_diagnostics.&&edb360_6e.ash_programs.sql
@@&&skip_diagnostics.&&edb360_6f.ash_modules.sql
@@&&skip_diagnostics.&&edb360_6g.ash_users.sql
@@&&skip_diagnostics.&&edb360_6h.ash_plsql.sql
@@&&skip_diagnostics.&&edb360_6i.ash_objects.sql
@@&&skip_diagnostics.&&edb360_6j.ash_services.sql
@@&&skip_diagnostics.&&edb360_6k.ash_phv.sql
@@&&skip_diagnostics.&&skip_10g_script.&&edb360_6l.ash_signature.sql
@@&&skip_diagnostics.&&skip_10g_script.&&skip_11g_script.&&edb360_6m.ash_pdbs.sql
@@&&skip_diagnostics.&&skip_10g_script.&&skip_11g_script.&&edb360_6n.ash_pdbs_ts.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '7';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.&&skip_non_repo_script.&&edb360_7a.rpt.sql
@@&&skip_diagnostics.&&skip_non_repo_column.&&edb360_7b.sql_sample.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- log footer
SPO &&edb360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
DEF;
PRO Parameters
COL sid FOR A40;
COL name FOR A40;
COL value FOR A50;
COL display_value FOR A50;
COL update_comment NOPRI;
SELECT *
  FROM &&v_object_prefix.spparameter
 WHERE isspecified = 'TRUE'
 ORDER BY
       name,
       sid,
       ordinal;
COL sid CLE;
COL name CLE;
COL value CLE;
COL display_value CLE;
COL update_comment CLE;
SHOW PARAMETERS;
PRO
SELECT ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3) elapsed_hours FROM DUAL;
PRO
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
PRO end log
SPO OFF;

-- main footer
SPO &&edb360_main_report..html APP;
PRO
PRO </td></tr></table>
SPO OFF;
-- time one for edb360 (end)
VAR edb360_main_time1 NUMBER;
EXEC :edb360_main_time1 := DBMS_UTILITY.GET_TIME;
@@edb360_0c_post.sql
EXEC DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
UNDEF 1 2

