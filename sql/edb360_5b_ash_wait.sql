@@&&edb360_0g.tkprof.sql
DEF section_id = '5b';
DEF section_name = 'Active Session History (ASH) on Wait Class';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

@&&chart_setup_driver.;

DEF main_table = '&&cdb_awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
DEF vbaseline = '';

BEGIN
  :sql_text_backup := q'[
SELECT /*+ &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       snap_id,
       --TO_CHAR(LAG(MAX(sample_time)) OVER (ORDER BY snap_id), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(CASE instance_number WHEN 1 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_01,
       ROUND(SUM(CASE instance_number WHEN 2 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_02,
       ROUND(SUM(CASE instance_number WHEN 3 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_03,
       ROUND(SUM(CASE instance_number WHEN 4 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_04,
       ROUND(SUM(CASE instance_number WHEN 5 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_05,
       ROUND(SUM(CASE instance_number WHEN 6 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_06,
       ROUND(SUM(CASE instance_number WHEN 7 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_07,
       ROUND(SUM(CASE instance_number WHEN 8 THEN 10 ELSE 0 END) / (GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(LAG(MAX(sample_time)) OVER (ORDER BY snap_id) AS DATE), (1/24/3600)) * 24 * 3600), 3) inst_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM &&cdb_awr_hist_prefix.active_sess_history h
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND @filter_predicate@
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/
-- end from 5a

DEF skip_lch = '';
DEF title = 'AAS Total per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS On CPU per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'session_state = ''ON CPU''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on User IO per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''User I/O''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on System IO per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''System I/O''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Cluster per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Cluster''');
@@&&is_single_instance.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Commit per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Commit''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Concurrency per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Concurrency''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Application per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Application''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_application');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Administrative per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Administrative''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Configuration per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Configuration''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Network per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Network''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Queueing per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Queueing''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Scheduler per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Scheduler''');
@@edb360_9a_pre_one.sql

/*
DEF skip_lch = '';
DEF title = 'AAS waiting on Idle per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Idle''');
@@edb360_9a_pre_one.sql
*/

DEF skip_lch = '';
DEF title = 'AAS waiting on Other per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other''');
@@edb360_9a_pre_one.sql

DEF skip_lch = '--skip--';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
