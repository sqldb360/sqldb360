@@&&edb360_0g.tkprof.sql
DEF section_id = '6f';
DEF section_name = 'Active Session History (ASH) - Top Modules and Actions';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text_backup := q'[
WITH
h as (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       h.module
,      CASE WHEN h.module = 'DBMS_SCHEDULER' AND h.action LIKE 'ORA$%' THEN
                          REGEXP_SUBSTR(h.action,'([[:alpha:]\$_]+)')||'*'
            ELSE h.action END action
 FROM &&awr_object_prefix.active_sess_history h
WHERE @filter_predicate@
   AND h.module IS NOT NULL
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
),
hist AS (
SELECT /*+ &&sq_fact_hints. */ 
       /* &&section_id..&&report_sequence. */
       TRIM(module||' '||action) module_action,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
       COUNT(*) samples
  FROM h
 GROUP BY
       TRIM(module||' '||action)
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ SUM(samples) samples FROM hist
)
SELECT h.module_action,
       h.samples,
       ROUND(100 * h.samples / t.samples, 1) percent,
       NULL dummy_01
  FROM hist h,
       total t
 WHERE h.samples >= t.samples / 1000 AND rn <= 14
 UNION ALL
SELECT 'Others',
       NVL(SUM(h.samples), 0) samples,
       NVL(ROUND(100 * SUM(h.samples) / AVG(t.samples), 1), 0) percent,
       NULL dummy_01
  FROM hist h,
       total t
 WHERE h.samples < t.samples / 1000 OR rn > 14
 ORDER BY 2 DESC NULLS LAST
]';
END;
/

VAR sql2_text_backup varchar2(4000);
BEGIN
  :sql2_text_backup := q'[
WITH
awr as (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       TRIM(CASE WHEN h.module = 'DBMS_SCHEDULER' AND h.action LIKE 'ORA$%' 
                 THEN 'DBMS_SCHEDULER:'||REGEXP_SUBSTR(h.action,'([[:alpha:]\$_]+)')||'*'
                 WHEN h.module in ('DBMS_SCHEDULER','MMON_SLAVE') THEN h.module||':'||h.action
                 ELSE h.module 
            END) module
      ,sql_opname
      ,instance_number
 FROM &&awr_object_prefix.active_sess_history h
WHERE @filter_predicate@
   AND h.module IS NOT NULL
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
),
id_inst as (
SELECT /*+  &&sq_fact_hints.  */
       module,
       sql_opname,
       MAX(CASE instance_number WHEN 1 THEN '1,' END)||
       MAX(CASE instance_number WHEN 2 THEN '2,' END)||
       MAX(CASE instance_number WHEN 3 THEN '3,' END)||
       MAX(CASE instance_number WHEN 4 THEN '4,' END)||
       MAX(CASE instance_number WHEN 5 THEN '5,' END)||
       MAX(CASE instance_number WHEN 6 THEN '6,' END)||
       MAX(CASE instance_number WHEN 7 THEN '7,' END)||
       MAX(CASE instance_number WHEN 8 THEN '8' END) instances,
       COUNT(*) samples
 FROM awr 
 GROUP BY
       module,sql_opname
),
hist_sql AS (
SELECT /*+  &&sq_fact_hints.  */
       module,sql_opname,
       COUNT(*) samples
  FROM awr
 GROUP BY 
       module,sql_opname
),
hist AS (
SELECT /*+  &&sq_fact_hints.  */
       module,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
       COUNT(*) samples
  FROM awr
 GROUP BY
       module
),
total AS (
SELECT /*+  &&sq_fact_hints.  */ SUM(samples) samples FROM hist
)
select module,sql_opname,samples_per_sqlop,module_samples,pct_of_module_samples,pct_total_samples,instances 
 FROM (
       SELECT TRIM(hs.module) module,
              NVL(hs.sql_opname,'non-SQL oper') sql_opname,
              h.samples module_samples,
              hs.samples samples_per_sqlop,
              ROUND(100 * hs.samples / t.samples, 1) pct_total_samples,
              ROUND(100 * hs.samples / h.samples, 1) pct_of_module_samples,
              (SELECT instances 
                 FROM id_inst i
                WHERE i.module=hs.module 
                  AND nvl(i.sql_opname,'-')=nvl(hs.sql_opname,'-')) instances,
              rn dummy_01
         FROM hist h, hist_sql hs,
              total t 
        WHERE h.samples >= t.samples / 1000 AND h.rn <= 14
          AND hs.module=h.module
        UNION ALL
       SELECT 'Others' module,
              NVL(hs.sql_opname,'non-SQL oper') sql_opname,
              NVL(SUM(h.samples), 0) module_samples,
              NVL(SUM(hs.samples), 0) samples_per_sqlop,
              NVL(ROUND(100 * SUM(hs.samples) / AVG(t.samples), 1), 0) pct_total_samples,
              ROUND(100 * sum(hs.samples) / NVL(SUM(h.samples),1), 1) pct_of_module_samples,
              null,
              null dummy_01
         FROM hist h, hist_sql hs,
              total t
        WHERE (h.samples < t.samples / 1000 OR h.rn > 14)
          AND  hs.module=h.module
         GROUP BY 'Others', NVL(hs.sql_opname,'non-SQL oper')
 ) 
 ORDER BY module_samples DESC, samples_per_sqlop DESC ,module, sql_opname
]';
END;
/

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 1, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = 'Y';
DEF title = 'Operations profile of Top Modules for Cluster for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql2_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 1 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 2 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 3 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 4 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 5 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 6 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 7 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 8 for 1 day';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS')||', and between &&edb360_conf_work_time_from. and &&edb360_conf_work_time_to. hours' between_times FROM DUAL;

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = 'Y';
DEF title = 'Operations profile of Top Modules for Cluster for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql2_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 1 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 2 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 3 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
EF title = 'ASH Top Modules and Actions for Instance 4 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 5 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 6 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 7 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 8 for 5 working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = 'Y';
DEF title = 'Operations profile of Top Modules for Cluster for 7';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql2_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 1 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 2 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 3 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 4 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 5 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 6 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 7 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 8 for 7 days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT '&&between_dates., and between &&edb360_conf_work_time_from. and &&edb360_conf_work_time_to. hours' between_times FROM DUAL;

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = 'Y';
DEF title = 'Operations profile of Top Modules for Cluster for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql2_text_backup, '@filter_predicate@', 'TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 1 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 2 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 3 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 4 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
EF title = 'ASH Top Modules and Actions for Instance 5 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 6 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 7 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 8 for &&hist_work_days. working days';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');
@@&&skip_inst8.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT '&&between_dates.' between_times FROM DUAL;

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = 'Y';
DEF title = 'Operations profile of Top Modules for Cluster for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql2_text_backup, '@filter_predicate@', '1=1');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 1 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1');
@@&&skip_inst1.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 2 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2');
@@&&skip_inst2.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 3 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3');
@@&&skip_inst3.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 4 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4');
@@&&skip_inst4.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 5 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5');
@@&&skip_inst5.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 6 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6');
@@&&skip_inst6.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 7 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7');
@@&&skip_inst7.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'ASH Top Modules and Actions for Instance 8 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8');
@@&&skip_inst8.edb360_9a_pre_one.sql



/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
