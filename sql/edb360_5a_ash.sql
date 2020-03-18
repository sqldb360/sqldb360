@@&&edb360_0g.tkprof.sql
DEF section_id = '5a';
DEF section_name = 'Active Session History (ASH)';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
DEF vbaseline = '';

DEF tit_01 = 'On CPU';
DEF tit_02 = 'User I/O';
DEF tit_03 = 'System I/O';
DEF tit_04 = 'Cluster';
DEF tit_05 = 'Commit';
DEF tit_06 = 'Concurrency';
DEF tit_07 = 'Application';
DEF tit_08 = 'Administrative';
DEF tit_09 = 'Configuration';
DEF tit_10 = 'Network';
DEF tit_11 = 'Queueing';
DEF tit_12 = 'Scheduler';
DEF tit_13 = 'Other';
DEF tit_14 = '';
DEF tit_15 = '';

DEF series_01 = 'color :''#34CF27''';
DEF series_02 = 'color :''#0252D7''';
DEF series_03 = 'color :''#1E96DD''';
DEF series_04 = 'color :''#CEC3B5''';
DEF series_05 = 'color :''#EA6A05''';
DEF series_06 = 'color :''#871C12''';
DEF series_07 = 'color :''#C42A05''';
DEF series_08 = 'color :''#75763E''';
DEF series_09 = 'color :''#594611''';
DEF series_10 = 'color :''#989779''';
DEF series_11 = 'color :''#C6BAA5''';
DEF series_12 = 'color :''#9FFA9D''';
DEF series_13 = 'color :''#F571A0''';
DEF series_14 = 'color :''#000000''';
DEF series_15 = 'color :''#ff0000''';

COL aas_total FOR 999990.000;
COL aas_on_cpu FOR 999990.000;
COL aas_administrative FOR 999990.000;
COL aas_application FOR 999990.000;
COL aas_cluster FOR 999990.000;
COL aas_commit FOR 999990.000;
COL aas_concurrency FOR 999990.000;
COL aas_configuration FOR 999990.000;
COL aas_idle FOR 999990.000;
COL aas_network FOR 999990.000;
COL aas_other FOR 999990.000;
COL aas_queueing FOR 999990.000;
COL aas_scheduler FOR 999990.000;
COL aas_system_io FOR 999990.000;
COL aas_user_io FOR 999990.000;

BEGIN
  :sql_text_backup := q'[
SELECT /*+ &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       snap_id,
       --TO_CHAR(LAG(MAX(sample_time)) OVER (ORDER BY snap_id), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(CASE session_state WHEN 'ON CPU'         THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_on_cpu,
       ROUND(SUM(CASE wait_class    WHEN 'User I/O'       THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_user_io,
       ROUND(SUM(CASE wait_class    WHEN 'System I/O'     THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_system_io,
       ROUND(SUM(CASE wait_class    WHEN 'Cluster'        THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_cluster,
       ROUND(SUM(CASE wait_class    WHEN 'Commit'         THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_commit,
       ROUND(SUM(CASE wait_class    WHEN 'Concurrency'    THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_concurrency,
       ROUND(SUM(CASE wait_class    WHEN 'Application'    THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_application,
       ROUND(SUM(CASE wait_class    WHEN 'Administrative' THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_administrative,
       ROUND(SUM(CASE wait_class    WHEN 'Configuration'  THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_configuration,
       ROUND(SUM(CASE wait_class    WHEN 'Network'        THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_network,
       ROUND(SUM(CASE wait_class    WHEN 'Queueing'       THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_queueing,
       ROUND(SUM(CASE wait_class    WHEN 'Scheduler'      THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_scheduler,
       ROUND(SUM(CASE wait_class    WHEN  'Other'         THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) aas_other,
       0 dummy_14,
       0 dummy_15
  FROM &&awr_object_prefix.active_sess_history h
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&is_single_instance.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS per Wait Class for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_inst8.edb360_9a_pre_one.sql

DEF series_01 = '';
DEF series_02 = '';
DEF series_03 = '';
DEF series_04 = '';
DEF series_05 = '';
DEF series_06 = '';
DEF series_07 = '';
DEF series_08 = '';
DEF series_09 = '';
DEF series_10 = '';
DEF series_11 = '';
DEF series_12 = '';
DEF series_13 = '';
DEF series_14 = '';
DEF series_15 = '';

@&&chart_setup_driver.;

REM The query is the same as 5b so all the calls have been merged into 5b 

DEF skip_lch = '--skip--';
SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
