@@&&edb360_0g.tkprof.sql
DEF section_id = '4f';
DEF section_name = 'AAS per Class and Top Event';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Average Latency per Wait Class';
DEF main_table = '&&gv_view_prefix.WAITCLASSMETRIC';
BEGIN
  :sql_text := q'[
-- inspired by http://www.oraclerealworld.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       c.wait_class,
       m.inst_id,
       ROUND(10 * m.time_waited / m.wait_count, 3) avg_ms,
       m.wait_count,
       m.time_waited,
       ROUND(m.time_waited / 100) seconds_waited
  FROM &&gv_object_prefix.waitclassmetric m,
       &&gv_object_prefix.&&cdb_awr_con_option.system_wait_class c
 WHERE m.wait_count > 0
   AND c.inst_id = m.inst_id
   AND c.wait_class# = m.wait_class#
   AND c.wait_class <> 'Idle'
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

@&&chart_setup_driver.;

DELETE PLAN_TABLE;
INSERT INTO plan_table (id,partition_id,projection,object_type,partition_start,partition_stop,time,cost,position)
WITH
histogram AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id. */
       snap_id,
       dbid,
       instance_number,
       event_name,
       wait_class,
       (wait_count - LAG(wait_count) OVER (PARTITION BY dbid, instance_number, event_id, wait_time_milli ORDER BY snap_id)) * /* wait_count_this_snap */ 
       ((CASE WHEN wait_time_milli > &&min_wait_time_milli. THEN 0.75 ELSE 0.5 END)*LEAST(wait_time_milli,&&max_wait_time_milli.)) /* average wait_time_milli */
       wait_time_milli_total
  FROM &&cdb_awr_hist_prefix.event_histogram
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
),
history AS (
SELECT 
       snap_id,
       dbid,
       instance_number,
       event_name,
       wait_class,
       SUM(wait_time_milli_total) wait_time_milli_total
  FROM histogram
 WHERE wait_time_milli_total>0
 GROUP BY
       snap_id,
       dbid,
       instance_number,
       event_name,
       wait_class
),
per_snap AS (
SELECT 
       h.snap_id,
       s.begin_interval_time,
       s.end_interval_time,
       s.instance_number,
       event_name,
       wait_class,
       h.wait_time_milli_total,
       (cast(s.end_interval_time as date)-cast(s.begin_interval_time as date)) time_range
  FROM history           h,
       &&cdb_awr_hist_prefix.snapshot s
 WHERE s.snap_id         = h.snap_id
   AND s.dbid            = h.dbid
   AND s.instance_number = h.instance_number
),
event_list AS (
       SELECT event_name,
              wait_class,
              row_number () OVER (PARTITION BY wait_class ORDER BY sum(h.wait_time_milli_total) DESC) rn
         FROM history h
        GROUP BY event_name,wait_class
)
SELECT p.snap_id,
       p.instance_number,
       p.event_name,
       p.wait_class,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       1000*min(time_range) time_range,                            -- X1000 to avoid losing meaningful precision
       1000*sum(p.wait_time_milli_total) wait_time_milli_total,    -- X1000 to avoid losing meaningful precision
       e.rn
  FROM per_snap p,
       event_list e
 WHERE p.event_name=e.event_name
   AND time_range>0
 GROUP BY snap_id,p.instance_number,p.event_name,p.wait_class,e.rn
/

col between_times new_v between_times

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 1, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;
DEF title_suffix = '&&between_times.';

DEF main_table = '&&cdb_awr_hist_prefix.EVENT_HISTOGRAM';
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
DEF vbaseline = '';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';

BEGIN
  :sql_text_backup := q'[
  WITH 
per_inst AS ( 
SELECT /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       begin_time,
       end_time ,
       time_range,
       wait_time_milli_total 
  FROM (SELECT id               snap_id,
               object_type      wait_class,
               partition_id     instance_number,
               partition_start  begin_time,
               partition_stop   end_time ,
               time/1000        time_range,
               cost/1000        wait_time_milli_total
       FROM plan_table)
 WHERE @filter_predicate@
)
SELECT snap_id,
       begin_time,
       end_time,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE instance_number WHEN 1 THEN wait_time_milli_total ELSE 0 END), 2) inst_01,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE instance_number WHEN 2 THEN wait_time_milli_total ELSE 0 END), 2) inst_02,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE instance_number WHEN 3 THEN wait_time_milli_total ELSE 0 END), 2) inst_03,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE instance_number WHEN 4 THEN wait_time_milli_total ELSE 0 END), 2) inst_04,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE instance_number WHEN 5 THEN wait_time_milli_total ELSE 0 END), 2) inst_05,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE instance_number WHEN 6 THEN wait_time_milli_total ELSE 0 END), 2) inst_06,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE instance_number WHEN 7 THEN wait_time_milli_total ELSE 0 END), 2) inst_07,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE instance_number WHEN 8 THEN wait_time_milli_total ELSE 0 END), 2) inst_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM per_inst
 GROUP BY
       snap_id,
       begin_time,
       end_time
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'User I/O AAS per Instance';
DEF abstract = 'Average Active Sessions of User I/O class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''User I/O''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'System I/O AAS per Instance';
DEF abstract = 'Average Active Sessions of System I/O class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''System I/O''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Cluster AAS per Instance';
DEF abstract = 'Average Active Sessions of Cluster class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Cluster''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Commit AAs per Instance';
DEF abstract = 'Average Active Sessions of Commit class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Commit''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Concurrency AAS per Instance';
DEF abstract = 'Average Active Sessions of Concurrency class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Concurrency''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Application AAS per Instance';
DEF abstract = 'Average Active Sessions of Application class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Application''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Administrative AAS per Instance';
DEF abstract = 'Average Active Sessions of Administrative class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Administrative''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Configuration AAS per Instance';
DEF abstract = 'Average Active Sessions of Configuration class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Configuration''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Network AAS per Instance';
DEF abstract = 'Average Active Sessions of Network class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Network''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Queueing AAS per Instance';
DEF abstract = 'Average Active Sessions of Queueing class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Queueing''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Scheduler AAS per Instance';
DEF abstract = 'Average Active Sessions of Scheduler class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Scheduler''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = '';
DEF title = 'Other AAS per Instance';
DEF abstract = 'Average Active Sessions of Other class .<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other''');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Average Latency per Wait Event';
DEF main_table = '&&gv_view_prefix.EVENTMETRIC';
BEGIN
  :sql_text := q'[
-- inspired by http://www.oraclerealworld.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       e.wait_class,
       e.name event,
       m.inst_id,
       ROUND(10 * m.time_waited / m.wait_count, 3) avg_ms,
       m.wait_count,
       m.time_waited,
       ROUND(m.time_waited / 100) seconds_waited
  FROM &&gv_object_prefix.eventmetric m,
       &&gv_object_prefix.event_name e
 WHERE m.wait_count > 0
   AND e.inst_id = m.inst_id
   AND e.event_id = m.event_id
   AND e.wait_class <> 'Idle'
 ORDER BY
       1,2,3
]';
END;
/
@@edb360_9a_pre_one.sql

BEGIN
  :sql_text_backup := q'[
SELECT /* &&section_id..&&report_sequence. */
       snap_id,
       begin_time,
       end_time,
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE WHEN event_name IN 
       (
       '@item_01@', 
       '@item_02@', 
       '@item_03@', 
       '@item_04@', 
       '@item_05@', 
       '@item_06@', 
       '@item_07@', 
       '@item_08@', 
       '@item_09@', 
       '@item_10@', 
       '@item_11@', 
       '@item_12@', 
       '@item_13@', 
       '@item_14@'
       ) 
       THEN 0 ELSE wait_time_milli_total END) ,2 ) "Others",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_01@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_01@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_02@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_02@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_03@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_03@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_04@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_04@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_05@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_05@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_06@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_06@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_07@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_07@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_08@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_08@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_09@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_09@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_10@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_10@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_11@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_11@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_12@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_12@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_13@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_13@",
       ROUND( (1/(24*60*60*1000*MIN(time_range))) * SUM(CASE event_name WHEN '@item_14@' THEN wait_time_milli_total ELSE 0 END) ,2 ) "@title_14@"
  FROM (SELECT *
          FROM (SELECT id snap_id,
                       projection event_name,
                       object_type wait_class,
                       partition_id instance_number,
                       partition_start begin_time,
                       partition_stop end_time ,
                       time/1000 time_range,
                       cost/1000 wait_time_milli_total
                 FROM plan_table
                )
         WHERE @filter_predicate@
       )
 GROUP BY
       snap_id,begin_time,end_time
 ORDER BY
       snap_id
]';
END;
/

col top14_query new_v top14_query format a200

DEF skip_lch = '';
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
DEF title = 'AAS waiting on Top User I/O Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under User I/O Class<br />';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''User I/O''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''User I/O''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top System I/O Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under System I/O Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''System I/O''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''System I/O''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Cluster Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Cluster Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Cluster''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Cluster''' top14_query from dual;
@@edb360_top14_titles

@@&&is_single_instance.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Commit Wait Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Commit Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Commit''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Commit''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Concurrency Events';
DEDEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Concurrency Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Concurrency''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Concurrency''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Application Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Application Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Application''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Application''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Administrative Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Administrative Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Administrative''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Administrative''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Configuration Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Configuration Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Configuration''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Configuration''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Network Wait Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Network Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Network''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Network''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Queueing Wait Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Queueing Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Queueing''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Queueing''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top Scheduler Wait Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 Wait Events under Scheduler Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Scheduler''');

select 'SELECT distinct projection title_name, position rn FROM plan_table WHERE object_type = ''Scheduler''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top "Other" Class Top non-PX non-latch Wait Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 non-PX non-latch Wait Events under "Other" Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other'' and event_name not like ''PX%'' and event_name not like ''latch%''');

select 'select projection title_name,dense_rank() over (order by position) rn from plan_table WHERE object_type = ''Other'' and projection not like ''PX%'' and projection not like ''latch%'' ' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top "Other" Class Top PX Wait Events';
DEF abstract = 'Average Active Sessions waiting on Top-14 PX Wait Events under "Other" Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other'' and event_name like ''PX%''');

select 'select projection title_name,dense_rank() over (order by position) rn from plan_table WHERE object_type = ''Other'' and projection like ''PX%'' ' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS waiting on Top "Other" Class Top latch Wait Events';;
DEF abstract = 'Average Active Sessions waiting on Top-14 latch Wait Events under "Other" Class<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other'' and event_name like ''latch%''');

select 'select projection title_name,dense_rank() over (order by position) rn from plan_table WHERE object_type = ''Other'' and projection like ''latch%''' top14_query from dual;
@@edb360_top14_titles

@@&&skip_diagnostics.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

DELETE PLAN_TABLE;