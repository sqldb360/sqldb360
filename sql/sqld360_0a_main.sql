@@sqld360_00_config.sql
@@sqld360_0b_pre.sql
@@&&skip_diagnostics.sqld360_0x_xtract_ash.sql
@@sqld360_0t_xtract_tables.sql
DEF max_col_number = '5';
DEF column_number = '0';
SPO &&sqld360_main_report..html APP;
PRO <table><tr class="main">
PRO <td class="c">1/&&max_col_number.</td>
PRO <td class="c">2/&&max_col_number.</td>
PRO <td class="c">3/&&max_col_number.</td>
PRO <td class="c">4/&&max_col_number.</td>
PRO <td class="c">5/&&max_col_number.</td>
PRO </tr><tr class="main"><td>
PRO &&sqld360_conf_tool_page.<img src="SQLd360_img.jpg" alt="SQLd360" height="201" width="313"></a>
PRO <br>
PRO
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '1';

@@sqld360_1a_configuration.sql
@@sqld360_1e_nls.sql
@@sqld360_1f_observations.sql


PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '2';

SPO &&sqld360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@sqld360_2a_identification.sql
@@sqld360_2b_performance.sql
@@&&from_edb360.&&skip_force_match.&&sqld360_skip_fmatch.sqld360_2c_performance_fm.sql
@@sqld360_2d_plans.sql
@@sqld360_2e_plan_control.sql
@@&&skip_tuning.&&skip_10g.&&sqld360_skip_sqlmon.sqld360_2f_sql_monitor.sql
@@sqld360_2g_binds.sql
@@sqld360_2h_cursor_sharing.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '3';

SPO &&sqld360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@sqld360_3a_objects.sql
@@&&sqld360_skip_stats_h.sqld360_3c_stats_history.sql
@@&&skip_10g.&&skip_11g.&&skip_12r101.sqld360_3d_inmemory.sql
@@&&skip_10g.&&skip_11g.sqld360_3e_bt_cache.sql
@@&&sqld360_skip_metadata.sqld360_3f_metadata.sql


PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '4';

SPO &&sqld360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@sqld360_4a_system_impact.sql
@@sqld360_4b_execution_metrics.sql
@@sqld360_4c_execution_metrics_per_phv.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '5';

SPO &&sqld360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_10g.&&skip_11r1.sqld360_5a_10053.sql
@@&&skip_tuning.&&skip_10g.&&sqld360_skip_sqlmon.sqld360_5b_sqlmon.sql
@@&&skip_diagnostics.&&sqld360_skip_awrrpt.sqld360_5c_awr.sql
@@&&skip_diagnostics.&&sqld360_skip_ashrpt.sqld360_5d_ash.sql
@@&&skip_tcb.&&skip_10g.&&sqld360_skip_tcb.&&sqld360_local_exec.sqld360_5e_tcb.sql
@@&&from_edb360.&&skip_diagnostics.&&sqld360_skip_rawash.sqld360_5f_rawash.sql
@@&&sqld360_skip_stats.sqld360_5i_stats.sql
@@&&from_edb360.&&skip_diagnostics.&&sqld360_skip_eadam.sqld360_5g_eadam_ash.sql
@@&&skip_tuning.&&sqld360_skip_sta.sqld360_5h_sta.sql


PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- log footer
SPO &&sqld360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
DEF;
PRO
PRO end log
SPO OFF;

-- main footer
SPO &&sqld360_main_report..html APP;
PRO
PRO </td></tr></table>
SPO OFF;
@@sqld360_0c_post.sql