@@&&edb360_0g.tkprof.sql
DEF section_id = '6l';
DEF section_name = 'Active Session History (ASH) - Top Signature';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&gv_view_prefix.ACTIVE_SESSION_HISTORY';
BEGIN
  :sql_text_backup := q'[
WITH
hist AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       force_matching_signature,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
       COUNT(DISTINCT sql_id) distinct_sql_id,
       MIN(sql_id) min_sql_id,
       MAX(sql_id) max_sql_id,
       COUNT(*) samples
  FROM &&gv_object_prefix.active_session_history
 WHERE @filter_predicate@
   AND sql_id IS NOT NULL
   AND force_matching_signature > 0
 GROUP BY
       &&skip_noncdb.con_id,
       force_matching_signature
HAVING COUNT(DISTINCT sql_id)>1
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ SUM(samples) samples FROM hist
)
SELECT DISTINCT
       h.force_matching_signature||'('||h.distinct_sql_id||')' force_matching_signature,
       h.samples,
       ROUND(100 * h.samples / t.samples, 1) percent,
       h.min_sql_id,
       h.max_sql_id,
       v2.sql_text sample_sql_text
  FROM hist h,
       total t,
       &&gv_object_prefix.sql v2
 WHERE h.samples >= t.samples / 1000 AND rn <= 14
   AND v2.sql_id(+) = h.min_sql_id
   &&skip_ver_le_11.AND v2.con_id(+) = h.con_id
 UNION ALL
SELECT 'Others',
       NVL(SUM(h.samples), 0) samples,
       NVL(ROUND(100 * SUM(h.samples) / AVG(t.samples), 1), 0) percent,
       NULL min_sql_id,
       NULL max_sql_id,
       NULL sample_sql_text
  FROM hist h,
       total t
 WHERE h.samples < t.samples / 1000 OR rn > 14
 ORDER BY 2 DESC NULLS LAST
]';
END;
/

/*****************************************************************************************/

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Cluster from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1 /* all instances */');
@@&&is_single_instance.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 1;
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 1 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 1');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 2;
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 2 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 2');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 3;
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 3 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 3');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 4;
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 4 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 4');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 5;
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 5 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 5');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 6;
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 6 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 6');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 7;
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 7 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 7');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE inst_id = 8;
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 8 from MEM';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'inst_id = 8');
@@&&skip_all.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF main_table = '&&cdb_awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text_backup := q'[
WITH
hist AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */
       /* &&section_id..&&report_sequence. */
       &&skip_noncdb.con_id,
       force_matching_signature,
       dbid,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
       COUNT(DISTINCT sql_id) distinct_sql_id,
       MIN(sql_id) min_sql_id,
       MAX(sql_id) max_sql_id,
       COUNT(*) samples
  FROM &&cdb_awr_hist_prefix.active_sess_history h
 WHERE @filter_predicate@
   AND sql_id IS NOT NULL
   AND force_matching_signature > 0
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       &&skip_noncdb.con_id,
       force_matching_signature,
       dbid
HAVING COUNT(DISTINCT sql_id)>1
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ SUM(samples) samples FROM hist
)
SELECT h.force_matching_signature||'('||h.distinct_sql_id||')' force_matching_signature,
       h.samples,
       ROUND(100 * h.samples / t.samples, 1) percent,
       --h.min_sql_id,
       --h.max_sql_id,
       (CASE WHEN s.sql_text IS NULL 
        THEN (SELECT g.sql_text FROM &&gv_object_prefix.sqlarea g where g.force_matching_signature = h.force_matching_signature and g.sql_text is not null and rownum=1)
        ELSE DBMS_LOB.SUBSTR(s.sql_text, 1000) 
        END )sample_sql_text
  FROM hist h,
       total t,
       &&cdb_awr_hist_prefix.sqltext s
 WHERE h.samples >= t.samples / 1000 AND rn <= 14
   AND s.sql_id(+) = h.max_sql_id AND s.dbid(+) = h.dbid 
   &&skip_noncdb.AND s.con_id(+) = h.con_id
 UNION ALL
SELECT 'Others',
       NVL(SUM(h.samples), 0) samples,
       NVL(ROUND(100 * SUM(h.samples) / AVG(t.samples), 1), 0) percent,
       --NULL min_sql_id,
       --NULL max_sql_id,
       NULL sample_sql_text
  FROM hist h,
       total t
 WHERE h.samples < t.samples / 1000 OR rn > 14
 ORDER BY 2 DESC NULLS LAST
]';
END;
/

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 1, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Cluster for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&is_single_instance.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 1 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 2 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 3 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 4 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 5 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 6 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 7 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 8 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS')||', and between &&edb360_conf_work_time_from. and &&edb360_conf_work_time_to. hours' between_times FROM DUAL;

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Cluster for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&is_single_instance.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 1 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 2 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 3 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 4 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 5 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 6 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 7 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 8 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Cluster for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&is_single_instance.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 1 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 2 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 3 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 4 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 5 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 6 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 7 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 8 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT '&&between_dates., and between &&edb360_conf_work_time_from. and &&edb360_conf_work_time_to. hours' between_times FROM DUAL;

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Cluster for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&is_single_instance.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 1 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 2 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 3 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 4 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 5 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 6 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 7 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 8 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT '&&between_dates.' between_times FROM DUAL;

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Cluster for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
@@&&is_single_instance.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 1 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 2 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 3 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 4 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 5 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 6 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 7 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top FORCE_MATCHING_SIGNATURE for Instance 8 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
