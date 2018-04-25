@@&&edb360_0g.tkprof.sql
DEF section_id = '6b';
DEF section_name = 'Active Session History (ASH) - Top Timed Events';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&gv_view_prefix.ACTIVE_SESSION_HISTORY';
DEF bar_height = '45%';

BEGIN
  :sql_text_backup := q'[
WITH
hist AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class END wait_class,
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class||' "'||event||'"' END timed_class,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
       COUNT(*) samples
  FROM &&gv_object_prefix.active_session_history
 WHERE @filter_predicate@
   AND (session_state = 'ON CPU' OR wait_class <> 'Idle')
 GROUP BY
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class END,
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class||' "'||event||'"' END
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ SUM(samples) samples FROM hist
)
SELECT h.timed_class||' ('||ROUND(100 * h.samples / t.samples, 1)||'%)' bucket,
       ROUND(100 * h.samples / t.samples, 1) percent,
       &&wait_class_colors.
       &&wait_class_colors2.
       &&wait_class_colors3.
       &&wait_class_colors4. color,
       h.samples||' 1s-samples ('||ROUND(100 * h.samples / t.samples, 1)||'% of DB Time)' tooltip
  FROM hist h,
       total t
 --WHERE ROUND(100 * h.samples / t.samples, 1) >= 3 /* only if >= 3% */
 ORDER BY 2 DESC NULLS LAST
]';
END;
/


/*****************************************************************************************/

DEF skip_bch = '';
DEF title = 'ASH Top Timed Events for Cluster from MEM';
DEF vaxis = 'Percent of total DB Time';
DEF haxis = 'Timed Event';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1 /* all instances */');
@@&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 1;
DEF title = 'ASH Top Timed Events for Instance 1 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 1');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 2;
DEF title = 'ASH Top Timed Events for Instance 2 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 2');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 3;
DEF title = 'ASH Top Timed Events for Instance 3 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 3');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 4;
DEF title = 'ASH Top Timed Events for Instance 4 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 4');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 5;
DEF title = 'ASH Top Timed Events for Instance 5 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 5');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 6;
DEF title = 'ASH Top Timed Events for Instance 6 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 6');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 7;
DEF title = 'ASH Top Timed Events for Instance 7 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 7');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 8;
DEF title = 'ASH Top Timed Events for Instance 8 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 8');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text_backup := q'[
WITH
hist AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class END wait_class,
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class||' "'||event||'"' END timed_class,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
       COUNT(*) samples
  FROM &&awr_object_prefix.active_sess_history h
 WHERE @filter_predicate@
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND (session_state = 'ON CPU' OR wait_class <> 'Idle')
 GROUP BY
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class END,
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class||' "'||event||'"' END
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ SUM(samples) samples FROM hist
)
SELECT h.timed_class||' ('||ROUND(100 * h.samples / t.samples, 1)||'%)' bucket,
       ROUND(100 * h.samples / t.samples, 1) percent,
       &&wait_class_colors.
       &&wait_class_colors2.
       &&wait_class_colors3.
       &&wait_class_colors4. color,
       h.samples||' 10s-samples ('||ROUND(100 * h.samples / t.samples, 1)||'% of DB Time)' tooltip
  FROM hist h,
       total t
 --WHERE ROUND(100 * h.samples / t.samples, 1) >= 3 /* only if >= 3% */
 ORDER BY 2 DESC NULLS LAST
]';
END;
/

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 1, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;

DEF skip_bch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS')||', and between &&edb360_conf_work_time_from. and &&edb360_conf_work_time_to. hours' between_times FROM DUAL;

DEF skip_bch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;

DEF skip_bch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT '&&between_dates., and between &&edb360_conf_work_time_from. and &&edb360_conf_work_time_to. hours' between_times FROM DUAL;

DEF skip_bch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT '&&between_dates.' between_times FROM DUAL;

DEF skip_bch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_bch = 'Y';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
