DEF section_id = '4b';
DEF section_name = 'Execution metrics';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Elapsed Time';
DEF tit_02 = 'CPU Time';
DEF tit_03 = 'IO Wait Time';
DEF tit_04 = 'Cluster Wait Time';
DEF tit_05 = 'Application Wait Time';
DEF tit_06 = 'Concurrency Wait Time';
DEF tit_07 = 'Unaccounted Time';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

--COL elapsed_time FOR 999999990.000;
--COL db_time FOR 999999990.000;
--COL cpu_time FOR 999999990.000;
--COL io_time FOR 999999990.000;
--COL cluster_time FOR 999999990.000;
--COL application_time FOR 999999990.000;
--COL concurrency_time FOR 999999990.000;
--COL unaccounted_time FOR 999999990.000;

DEF series_01 = 'color :''#000000''';
DEF series_02 = 'color :''#34CF27''';
DEF series_03 = 'color :''#0252D7''';
DEF series_04 = 'color :''#CEC3B5''';
DEF series_05 = 'color :''#C42A05''';
DEF series_06 = 'color :''#871C12''';
DEF series_07 = 'color :''#F571A0''';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'SQL Execute Elapsed Time in secs';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(a.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       ROUND(SUM(NVL(b.elapsed_time_delta,0))/1e6,6) elapsed_time,
       ROUND(SUM(NVL(b.cpu_time_delta,0))/1e6,6) cpu_time, 
       ROUND(SUM(NVL(b.iowait_delta,0))/1e6,6) io_time,
       ROUND(SUM(NVL(b.clwait_delta,0))/1e6,6) cluster_time,
       ROUND(SUM(NVL(b.apwait_delta,0))/1e6,6) application_time,
       ROUND(SUM(NVL(b.ccwait_delta,0))/1e6,6) concurrency_time,
       ROUND((SUM(NVL(b.elapsed_time_delta,0)) - 
         (SUM(NVL(b.cpu_time_delta,0)) +
          SUM(NVL(b.iowait_delta,0))   +
          SUM(NVL(b.clwait_delta,0))   +
          SUM(NVL(b.apwait_delta,0))   +
          SUM(NVL(b.ccwait_delta,0)))
       ) / 1e6,6) unaccounted_time,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id, instance_number, 
               elapsed_time_delta, cpu_time_delta, iowait_delta, clwait_delta, apwait_delta, ccwait_delta 
          FROM dba_hist_sqlstat
         WHERE sql_id = '&&sqld360_sqlid.') b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a
 WHERE a.snap_id = b.snap_id(+)
   AND a.instance_number = b.instance_number(+)
   AND '&&diagnostics_pack.' = 'Y'
   AND a.instance_number = @instance_number@
 GROUP BY
       TO_CHAR(a.begin_interval_time, 'YYYY-MM-DD HH24:MI'), 
       TO_CHAR(a.end_interval_time, 'YYYY-MM-DD HH24:MI')
 ORDER BY
       TO_CHAR(a.end_interval_time, 'YYYY-MM-DD HH24:MI')
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'SQL Execute Time by Wait Class for Cluster';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'SQL Execute Time by Wait Class for Instance 1';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'SQL Execute Time by Wait Class for Instance 2';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'SQL Execute Time by Wait Class for Instance 3';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'SQL Execute Time by Wait Class for Instance 4';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'SQL Execute Time by Wait Class for Instance 5';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'SQL Execute Time by Wait Class for Instance 6';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'SQL Execute Time by Wait Class for Instance 7';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'SQL Execute Time by Wait Class for Instance 8';
DEF abstract = 'SQL Execute Time compared by Wait Class'
DEF foot = 'Unaccounted Time computed as difference between Elapsed Time and [CPU+IO+App+Clu+Concu] Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF series_01 = '';
DEF series_02 = '';
DEF series_03 = '';
DEF series_04 = '';
DEF series_05 = '';
DEF series_06 = '';
DEF series_07 = '';
------------------------
------------------------

DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Elapsed Time per recent executions, in seconds, rounded to the 1 second';
DEF foot = 'Data rounded to the 1 second';
DEF skip_lch = 'Y';

BEGIN
  :sql_text_backup := q'[
SELECT NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) instance_id,
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) session_id,
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) session_serial#,
       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,',',1,13)+1)) user_id, 
       partition_id sql_exec_id,
       TO_CHAR(TO_DATE(distribution, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') sql_exec_start,
       TO_CHAR(MIN(timestamp), 'YYYY-MM-DD HH24:MI:SS')  start_time,
       TO_CHAR(MAX(timestamp), 'YYYY-MM-DD HH24:MI:SS')  end_time,
       bytes plan_hash_value,
       --LEAST(1+86400*(MAX(timestamp)-MIN(timestamp)),COUNT(*)) elapsed_time,
       &&sqld360_ashsample.+86400*(MAX(timestamp)-MIN(timestamp)) elapsed_time,
       SUM(CASE WHEN object_node = 'ON CPU' THEN &&sqld360_ashsample. ELSE 0 END) cpu_time,
       SUM(&&sqld360_ashsample.) db_time,
       COUNT(DISTINCT position||'-'||cpu_cost||'-'||io_cost) num_processes_ash,
       MAX(TRUNC(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,10)+1,INSTR(partition_stop,',',1,11)-INSTR(partition_stop,',',1,10)-1)) / 2097152)) max_px_degree_ash,
       MAX(px_servers_requested) px_servers_requested_sqlmon, 
       MAX(px_servers_allocated) px_servers_allocated_sqlmon
  FROM plan_table a,
       (SELECT inst_id, 
               sid,
               session_serial#,
               sql_exec_id, 
               sql_exec_start, 
               px_servers_requested, 
               px_servers_allocated
          FROM gv$sql_monitor
         WHERE sql_id = '&&sqld360_sqlid.'
           AND '&&tuning_pack.' = 'Y'
           AND px_qcsid IS NULL) b
 WHERE statement_id = 'SQLD360_ASH_DATA_MEM'
   AND position =  @instance_number@
   AND remarks = '&&sqld360_sqlid.'
   AND '&&diagnostics_pack.' = 'Y'
   AND b.sql_exec_id(+) = a.partition_id
   AND b.inst_id(+) = NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)
   AND b.sid(+) = NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)
   AND b.session_serial#(+) = NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)
   AND b.sql_exec_start(+) = TO_DATE(distribution, 'YYYYMMDDHH24MISS')
 GROUP BY partition_id, 
       bytes,
       TO_CHAR(TO_DATE(distribution, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'),
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position),
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost),
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost),
       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,',',1,13)+1)) 
 ORDER BY
       TO_CHAR(MIN(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
       partition_id
]';
END;
/

DEF skip_all = '&&is_single_instance.';
DEF title = 'Elapsed Time per recent executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Elapsed Time per recent executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Elapsed Time per recent executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Elapsed Time per recent executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Elapsed Time per recent executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Elapsed Time per recent executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Elapsed Time per recent executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Elapsed Time per recent executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Elapsed Time per recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

------------------------------------------------
------------------------------------------------

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Elapsed Time per historical execution, in seconds, rounded to the 10 seconds';
DEF foot = 'Data rounded to the 10 seconds';


BEGIN
  :sql_text_backup := q'[
SELECT NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position) instance_id,
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost) session_id,
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost) session_serial#,
       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,',',1,13)+1)) user_id, 
       partition_id sql_exec_id,
       TO_CHAR(TO_DATE(distribution, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') sql_exec_start,
       TO_CHAR(MIN(timestamp), 'YYYY-MM-DD HH24:MI:SS')  start_time,
       TO_CHAR(MAX(timestamp), 'YYYY-MM-DD HH24:MI:SS')  end_time,
       bytes plan_hash_value,
       --LEAST(10+86400*(MAX(timestamp)-MIN(timestamp)),SUM(10)) elapsed_time, 
       &&sqld360_ashtimevalue.+86400*(MAX(timestamp)-MIN(timestamp)) elapsed_time,
       SUM(CASE WHEN object_node = 'ON CPU' THEN &&sqld360_ashtimevalue. ELSE 0 END) cpu_time,
       SUM(&&sqld360_ashtimevalue.) db_time,
       COUNT(DISTINCT position||'-'||cpu_cost||'-'||io_cost) num_processes_ash,
       MAX(TRUNC(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,10)+1,INSTR(partition_stop,',',1,11)-INSTR(partition_stop,',',1,10)-1)) / 2097152)) max_px_degree_ash,
       MAX(px_servers_requested) px_servers_requested_sqlmon, 
       MAX(px_servers_allocated) px_servers_allocated_sqlmon
  FROM plan_table a,
       (SELECT inst_id, 
               sid,
               session_serial#,
               sql_exec_id, 
               sql_exec_start, 
               px_servers_requested, 
               px_servers_allocated
          FROM gv$sql_monitor
         WHERE sql_id = '&&sqld360_sqlid.'
           AND '&&tuning_pack.' = 'Y'
           AND px_qcsid IS NULL) b
 WHERE statement_id = 'SQLD360_ASH_DATA_HIST'
   AND position =  @instance_number@
   AND remarks = '&&sqld360_sqlid.'
   AND '&&diagnostics_pack.' = 'Y'
   AND b.sql_exec_id(+) = a.partition_id
   AND b.inst_id(+) = NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)
   AND b.sid(+) = NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)
   AND b.session_serial#(+) = NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)
   AND b.sql_exec_start(+) = TO_DATE(distribution, 'YYYYMMDDHH24MISS')
 GROUP BY partition_id, 
       bytes,
       TO_CHAR(TO_DATE(distribution, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'),
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position),
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost),
       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost),
       TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,',',1,13)+1)) 
 ORDER BY
       TO_CHAR(MIN(timestamp), 'YYYY-MM-DD HH24:MI:SS'),
       partition_id
]';
END;
/

DEF skip_all = '&&is_single_instance.';
DEF title = 'Elapsed Time per historical executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Elapsed Time per historical executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Elapsed Time per historical executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Elapsed Time per historical executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Elapsed Time per historical executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Elapsed Time per historical executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Elapsed Time per historical executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Elapsed Time per historical executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Elapsed Time per historical executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

---------------------
---------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Avg Buffer Gets/exec (total)';
DEF tit_02 = 'Avg Buffer Gets/exec (total) Trend';
DEF tit_03 = 'Avg Buffer Gets/exec (delta)';
DEF tit_04 = 'Avg Buffer Gets/exec (delta) Trend';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Avg Buffer Gets per Execution';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT snap_id snap_id, 
       TO_CHAR(begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(buffer_gets_tot, 0) buffer_gets_tot,
       NVL(AVG(buffer_gets_tot) OVER (ORDER BY snap_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0) buffer_gets_trend_tot,
       NVL(buffer_gets_del, 0) buffer_gets_del,
       NVL(AVG(buffer_gets_del) OVER (ORDER BY snap_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0) buffer_gets_trend_del,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT a.snap_id, 
               MIN(begin_interval_time) begin_interval_time, 
               MIN(end_interval_time) end_interval_time,
               TRUNC(SUM(b.buffer_gets_total)/SUM(NVL(NULLIF(executions_total,0),1)),3) buffer_gets_tot,
               TRUNC(SUM(b.buffer_gets_delta)/SUM(NVL(NULLIF(executions_delta,0),1)),3) buffer_gets_del
          FROM (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
                  FROM dba_hist_snapshot
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a,
               (SELECT snap_id, instance_number, buffer_gets_total, executions_total, buffer_gets_delta, executions_delta
                  FROM dba_hist_sqlstat
                 WHERE sql_id = '&&sqld360_sqlid.') b
          WHERE a.snap_id = b.snap_id(+)
            AND a.instance_number = b.instance_number(+)
            AND '&&diagnostics_pack.' = 'Y'
            AND a.instance_number = @instance_number@
          GROUP BY a.snap_id)
 ORDER BY
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Buffer Gets/Execution for Cluster';
DEF abstract = 'Avg Buffer Gets/Execution for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Buffer Gets/Execution for Instance 1';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Buffer Gets/Execution for Instance 2';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Buffer Gets/Execution for Instance 3';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Buffer Gets/Execution for Instance 4';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Buffer Gets/Execution for Instance 5';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Buffer Gets/Execution for Instance 6';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Buffer Gets/Execution for Instance 7';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Buffer Gets/Execution for Instance 8';
DEF abstract = 'Avg Buffer Gets/Execution for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';


------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Avg Rows Processed/exec (total) ';
DEF tit_02 = 'Avg Rows Processed/exec (total) Trend';
DEF tit_03 = 'Avg Rows Processed/exec (delta) ';
DEF tit_04 = 'Avg Rows Processed/exec (delta) Trend';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Avg Rows Processed per Execution';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT snap_id snap_id, 
       TO_CHAR(begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(rows_processed_tot,0) rows_processed_tot,
       NVL(AVG(rows_processed_tot) OVER (ORDER BY snap_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0) rows_processed_trend_tot,
       NVL(rows_processed_del,0) rows_processed_del,
       NVL(AVG(rows_processed_del) OVER (ORDER BY snap_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0) rows_processed_trend_del,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT a.snap_id,
               MIN(begin_interval_time) begin_interval_time, 
               MIN(end_interval_time) end_interval_time,
               TRUNC(SUM(b.rows_processed_total)/SUM(NVL(NULLIF(executions_total,0),1)),3) rows_processed_tot,
               TRUNC(SUM(b.rows_processed_delta)/SUM(NVL(NULLIF(executions_delta,0),1)),3) rows_processed_del
          FROM (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
                  FROM dba_hist_snapshot
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a,
               (SELECT snap_id, instance_number, rows_processed_total, executions_total, rows_processed_delta, executions_delta 
                  FROM dba_hist_sqlstat
                 WHERE sql_id = '&&sqld360_sqlid.') b
         WHERE a.snap_id = b.snap_id(+)
           AND a.instance_number = b.instance_number(+)
           AND '&&diagnostics_pack.' = 'Y'
           AND a.instance_number = @instance_number@
         GROUP BY a.snap_id)
 ORDER BY
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Rows Processed/Execution for Cluster';
DEF abstract = 'Avg Rows Processed/Execution for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Rows Processed/Execution for Instance 1';
DEF abstract = 'Avg Rows Processed/Execution for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Rows Processed/Execution for Instance 2';
DEF abstract = 'Avg Rows Processed/Execution for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Rows Processed/Execution for Instance 3';
DEF abstract = 'Avg Rows Processed/Execution for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Rows Processed/Execution for Instance 4';
DEF abstract = 'Avg Rows Processed/Execution for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Rows Processed/Execution for Instance 5';
DEF abstract = 'Avg Rows Processed/Execution for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Rows Processed/Execution for Instance 6';
DEF abstract = 'Avg Rows Processed/Execution for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Rows Processed/Execution for Instance 7';
DEF abstract = 'Avg Rows Processed/Execution for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Rows Processed/Execution for Instance 8';
DEF abstract = 'Avg Rows Processed/Execution for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';


------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Avg Elapsed Time/exec';
DEF tit_02 = 'Avg CPU Time/exec';
DEF tit_03 = 'Avg IO Time/exec';
DEF tit_04 = 'Avg Cluster Time/exec';
DEF tit_05 = 'Avg Application Time/exec';
DEF tit_06 = 'Avg Concurrency Time/exec';
DEF tit_07 = 'Avg Elapsed Time/exec Trend';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Avg Elapsed Time per Execution in &&sqld360_awr_timescale_l.';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT snap_id snap_id, 
       TO_CHAR(begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(elapsed_time,0) elapsed_time,
       NVL(cpu_time,0) cpu_time, 
       NVL(iowait,0) iowait,
       NVL(clwait,0) clwait,
       NVL(apwait,0) apwait,
       NVL(ccwait,0) ccwait,
       NVL(AVG(elapsed_time) OVER (ORDER BY snap_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),0) elapsed_time_trend,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT a.snap_id, 
               MIN(begin_interval_time) begin_interval_time, 
               MIN(end_interval_time) end_interval_time,
               ROUND(SUM(elapsed_time_total)/SUM(NVL(NULLIF(executions_total,0),1))/&&sqld360_awr_timescale_d.,6) elapsed_time, 
               ROUND(SUM(cpu_time_total)    /SUM(NVL(NULLIF(executions_total,0),1))/&&sqld360_awr_timescale_d.,6) cpu_time, 
               ROUND(SUM(iowait_total)      /SUM(NVL(NULLIF(executions_total,0),1))/&&sqld360_awr_timescale_d.,6) iowait, 
               ROUND(SUM(clwait_total)      /SUM(NVL(NULLIF(executions_total,0),1))/&&sqld360_awr_timescale_d.,6) clwait, 
               ROUND(SUM(apwait_total)      /SUM(NVL(NULLIF(executions_total,0),1))/&&sqld360_awr_timescale_d.,6) apwait, 
               ROUND(SUM(ccwait_total)      /SUM(NVL(NULLIF(executions_total,0),1))/&&sqld360_awr_timescale_d.,6) ccwait
          FROM (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
                  FROM dba_hist_snapshot
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a,
               (SELECT snap_id, instance_number,  elapsed_time_total, cpu_time_total, 
                       iowait_total, clwait_total, apwait_total, ccwait_total, executions_total
                  FROM dba_hist_sqlstat
                 WHERE sql_id = '&&sqld360_sqlid.') b
         WHERE a.snap_id = b.snap_id(+)
           AND a.instance_number = b.instance_number(+)
           AND '&&diagnostics_pack.' = 'Y'
           AND a.instance_number = @instance_number@
         GROUP BY a.snap_id)
 ORDER BY
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution (total) for Cluster';
DEF abstract = 'Avg Elapsed Time/Execution for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution (total) for Instance 1';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution (total) for Instance 2';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution (total) for Instance 3';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution (total) for Instance 4';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution (total) for Instance 5';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution (total) for Instance 6';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution (total) for Instance 7';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution (total) for Instance 8';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';

------------------------
------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Avg Elapsed Time/exec';
DEF tit_02 = 'Avg CPU Time/exec';
DEF tit_03 = 'Avg IO Time/exec';
DEF tit_04 = 'Avg Cluster Time/exec';
DEF tit_05 = 'Avg Application Time/exec';
DEF tit_06 = 'Avg Concurrency Time/exec';
DEF tit_07 = 'Avg Elapsed Time/exec Trend';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Avg Elapsed Time per Execution in &&sqld360_awr_timescale_l.';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT snap_id snap_id, 
       TO_CHAR(begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(elapsed_time,0) elapsed_time,
       NVL(cpu_time,0) cpu_time, 
       NVL(iowait,0) iowait,
       NVL(clwait,0) clwait,
       NVL(apwait,0) apwait,
       NVL(ccwait,0) ccwait,
       NVL(AVG(elapsed_time) OVER (ORDER BY snap_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),0) elapsed_time_trend,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT a.snap_id, 
               MIN(begin_interval_time) begin_interval_time, 
               MIN(end_interval_time) end_interval_time,
               ROUND(SUM(elapsed_time_delta)/SUM(NVL(NULLIF(executions_delta,0),1))/&&sqld360_awr_timescale_d.,6) elapsed_time, 
               ROUND(SUM(cpu_time_delta)    /SUM(NVL(NULLIF(executions_delta,0),1))/&&sqld360_awr_timescale_d.,6) cpu_time, 
               ROUND(SUM(iowait_delta)      /SUM(NVL(NULLIF(executions_delta,0),1))/&&sqld360_awr_timescale_d.,6) iowait, 
               ROUND(SUM(clwait_delta)      /SUM(NVL(NULLIF(executions_delta,0),1))/&&sqld360_awr_timescale_d.,6) clwait, 
               ROUND(SUM(apwait_delta)      /SUM(NVL(NULLIF(executions_delta,0),1))/&&sqld360_awr_timescale_d.,6) apwait, 
               ROUND(SUM(ccwait_delta)      /SUM(NVL(NULLIF(executions_delta,0),1))/&&sqld360_awr_timescale_d.,6) ccwait
          FROM (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
                  FROM dba_hist_snapshot
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a,
               (SELECT snap_id, instance_number,  elapsed_time_delta, cpu_time_delta, 
                       iowait_delta, clwait_delta, apwait_delta, ccwait_delta, executions_delta
                  FROM dba_hist_sqlstat
                 WHERE sql_id = '&&sqld360_sqlid.') b
         WHERE a.snap_id = b.snap_id(+)
           AND a.instance_number = b.instance_number(+)
           AND '&&diagnostics_pack.' = 'Y'
           AND a.instance_number = @instance_number@
         GROUP BY a.snap_id)
 ORDER BY
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution (delta) for Cluster';
DEF abstract = 'Avg Elapsed Time/Execution for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution (delta) for Instance 1';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution (delta) for Instance 2';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution (delta) for Instance 3';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution (delta) for Instance 4';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution (delta) for Instance 5';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution (delta) for Instance 6';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution (delta) for Instance 7';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution (delta) for Instance 8';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';


------------------------
------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Avg Elapsed Time/exec';
DEF tit_02 = 'Avg CPU Time/exec';
DEF tit_03 = 'Avg IO Time/exec';
DEF tit_04 = 'Avg Cluster Time/exec';
DEF tit_05 = 'Avg Application Time/exec';
DEF tit_06 = 'Avg Concurrency Time/exec';
DEF tit_07 = 'Avg Elapsed Time/exec Trend';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Avg Elapsed Time per Execution in &&sqld360_awr_timescale_l.';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT snap_id snap_id, 
       TO_CHAR(begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(ROUND(SUM(elapsed_time_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
            /NVL(NULLIF(SUM(execs_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) elapsed_time,
       NVL(ROUND(SUM(cpu_time_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
            /NVL(NULLIF(SUM(execs_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) cpu_time,
       NVL(ROUND(SUM(iowait_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
            /NVL(NULLIF(SUM(execs_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) iowait,
       NVL(ROUND(SUM(clwait_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
            /NVL(NULLIF(SUM(execs_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) clwait,
       NVL(ROUND(SUM(apwait_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
            /NVL(NULLIF(SUM(execs_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) apwait,
       NVL(ROUND(SUM(ccwait_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
            /NVL(NULLIF(SUM(execs_per_snap) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) ccwait,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT a.snap_id, 
               MIN(begin_interval_time) begin_interval_time, 
               MIN(end_interval_time) end_interval_time,
               SUM(elapsed_time_delta) elapsed_time_per_snap,
               SUM(cpu_time_delta) cpu_time_per_snap,
               SUM(iowait_delta) iowait_per_snap,
               SUM(clwait_delta) clwait_per_snap,
               SUM(apwait_delta) apwait_per_snap,
               SUM(ccwait_delta) ccwait_per_snap,
               SUM(executions_delta) execs_per_snap
          FROM (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
                  FROM dba_hist_snapshot
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) a,
               (SELECT snap_id, instance_number,  elapsed_time_delta, cpu_time_delta, 
                       iowait_delta, clwait_delta, apwait_delta, ccwait_delta, executions_delta
                  FROM dba_hist_sqlstat
                 WHERE sql_id = '&&sqld360_sqlid.') b
         WHERE a.snap_id = b.snap_id(+)
           AND a.instance_number = b.instance_number(+)
           AND '&&diagnostics_pack.' = 'Y'
           AND a.instance_number = @instance_number@
         GROUP BY a.snap_id)
 ORDER BY
       TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI')
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Cluster';
DEF abstract = 'Avg Elapsed Time/Execution for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Instance 1';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Instance 2';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Instance 3';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Instance 4';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Instance 5';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Instance 6';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Instance 7';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution (moving 1d) for Instance 8';
DEF abstract = 'Avg Elapsed Time/Execution for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';

------------------------
------------------------

DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Average and Median Elapsed Time per execution for recent executions, in seconds, from ASH ';
DEF foot = 'Data rounded to the 1 second'
DEF vaxis = 'Average Elapsed Time in secs, rounded to 1 sec'

BEGIN
  :sql_text_backup := q'[
SELECT 0 snap_id,
       TO_CHAR(start_time, 'YYYY-MM-DD HH24:MI') begin_time, 
       TO_CHAR(start_time, 'YYYY-MM-DD HH24:MI') end_time,
       avg_et,
       med_et,
       percth_et,
       avg_cpu_time,
       med_cpu_time,
       percth_cpu_time,
       avg_db_time,
       med_db_time,
       percth_db_time,
       NVL(AVG(avg_et) OVER (ORDER BY start_time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),0) avg_et_trend,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT start_time,
               TRUNC(AVG(et),3) avg_et,
               TRUNC(MEDIAN(et),3) med_et,
               TRUNC(PERCENTILE_DISC(0.&&sqld360_conf_avg_et_percth.) WITHIN GROUP (ORDER BY et),3) percth_et,
               TRUNC(AVG(cpu_time),3) avg_cpu_time,
               TRUNC(MEDIAN(cpu_time),3) med_cpu_time,
               TRUNC(PERCENTILE_DISC(0.&&sqld360_conf_avg_et_percth.) WITHIN GROUP (ORDER BY cpu_time),3) percth_cpu_time,
               TRUNC(AVG(db_time),3) avg_db_time,
               TRUNC(MEDIAN(db_time),3) med_db_time,
               TRUNC(PERCENTILE_DISC(0.&&sqld360_conf_avg_et_percth.) WITHIN GROUP (ORDER BY db_time),3) percth_db_time
          FROM (SELECT TO_DATE(SUBSTR(distribution,1,12),'YYYYMMDDHH24MI') start_time,
                       NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                        NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                        NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                        NVL(partition_id,0)||'-'||NVL(distribution,'x') uniq_exec, 
                       &&sqld360_ashsample.+86400*(MAX(timestamp)-MIN(timestamp)) et, 
                       SUM(CASE WHEN object_node = 'ON CPU' THEN &&sqld360_ashsample. ELSE 0 END) cpu_time,
                       SUM(&&sqld360_ashsample.) db_time
                  FROM plan_table
                 WHERE statement_id = 'SQLD360_ASH_DATA_MEM'
                   AND position =  @instance_number@
                   AND remarks = '&&sqld360_sqlid.' 
                   AND partition_id IS NOT NULL
                   AND '&&diagnostics_pack.' = 'Y'
                 GROUP BY TO_DATE(SUBSTR(distribution,1,12),'YYYYMMDDHH24MI'), 
                          NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                           NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                           NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                           NVL(partition_id,0)||'-'||NVL(distribution,'x'))
          GROUP BY start_time)
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF tit_01 = 'Average Elapsed Time/exec';
DEF tit_02 = 'Median Elapsed Time/exec';
DEF tit_03 = '&&sqld360_conf_avg_et_percth.th Elapsed Time/exec';
DEF tit_04 = 'Average Time on CPU/exec';
DEF tit_05 = 'Median Time on CPU/exec';
DEF tit_06 = '&&sqld360_conf_avg_et_percth.th CPU Time/exec';
DEF tit_07 = 'Average DB Time/exec';
DEF tit_08 = 'Median DB Time/exec';
DEF tit_09 = '&&sqld360_conf_avg_et_percth.th DB Time/exec';
DEF tit_10 = 'Average Elapsed Time/exec Trend';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg and Median Elapsed Time/Execution for recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql


DEF skip_lch = 'Y';
------------------------------
------------------------------

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Average and Median elapsed time per execution for historical executions, in seconds, from ASH';
DEF foot = 'Data rounded to the 10 seconds';
DEF vaxis = 'Average Elapsed Time in secs, rounded to 10 sec'

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(avg_et,0) avg_et,
       NVL(med_et,0) med_et,
       NVL(percth_et,0) percth_et,
       NVL(avg_cpu_time,0) avg_cpu_time,
       NVL(med_cpu_time,0) med_cpu_time,
       NVL(percth_cpu_time,0) percth_cpu_time,
       NVL(avg_db_time,0) avg_db_time,
       NVL(med_db_time,0) med_db_time,
       NVL(percth_db_time,0) percth_db_time,
       NVL(AVG(avg_et) OVER (ORDER BY b.snap_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),0) avg_et_trend,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT snap_id,
               MAX(avg_et) avg_et,
               MAX(med_et) med_et,
               MAX(percth_et) percth_et,
               MAX(avg_cpu_time) avg_cpu_time,
               MAX(med_cpu_time) med_cpu_time,
               MAX(percth_cpu_time) percth_cpu_time,
               MAX(avg_db_time) avg_db_time,
               MAX(med_db_time) med_db_time,
               MAX(percth_db_time) percth_db_time
          FROM (SELECT start_time,
                       MIN(start_snap_id) snap_id,
                       TRUNC(AVG(et),3) avg_et,
                       TRUNC(MEDIAN(et),3) med_et,
                       TRUNC(PERCENTILE_DISC(0.&&sqld360_conf_avg_et_percth.) WITHIN GROUP (ORDER BY et),3) percth_et,
                       TRUNC(AVG(cpu_time),3) avg_cpu_time,
                       TRUNC(MEDIAN(cpu_time),3) med_cpu_time,
                       TRUNC(PERCENTILE_DISC(0.&&sqld360_conf_avg_et_percth.) WITHIN GROUP (ORDER BY cpu_time),3) percth_cpu_time,
                       TRUNC(AVG(db_time),3) avg_db_time,
                       TRUNC(MEDIAN(db_time),3) med_db_time,
                       TRUNC(PERCENTILE_DISC(0.&&sqld360_conf_avg_et_percth.) WITHIN GROUP (ORDER BY db_time),3) percth_db_time
                  FROM (SELECT TO_DATE(SUBSTR(distribution,1,12),'YYYYMMDDHH24MI') start_time,
                               NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                                NVL(partition_id,0)||'-'||NVL(distribution,'x') uniq_exec, 
                               MIN(cardinality) start_snap_id,
                               &&sqld360_ashtimevalue.+86400*(MAX(timestamp)-MIN(timestamp)) et, 
                               SUM(CASE WHEN object_node = 'ON CPU' THEN &&sqld360_ashtimevalue. ELSE 0 END) cpu_time,
                               SUM(&&sqld360_ashtimevalue.) db_time
                          FROM plan_table
                         WHERE statement_id = 'SQLD360_ASH_DATA_HIST'
                           AND partition_id IS NOT NULL
                           AND position =  @instance_number@
                           AND remarks = '&&sqld360_sqlid.'
                           AND '&&diagnostics_pack.' = 'Y'
                         GROUP BY TO_DATE(SUBSTR(distribution,1,12),'YYYYMMDDHH24MI'), 
                                  NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                                   NVL(partition_id,0)||'-'||NVL(distribution,'x'))                
                 GROUP BY start_time)
         GROUP BY snap_id) ash,
      dba_hist_snapshot b
 WHERE ash.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF tit_01 = 'Average Elapsed Time/exec';
DEF tit_02 = 'Median Elapsed Time/exec';
DEF tit_03 = '&&sqld360_conf_avg_et_percth.th Elapsed Time/exec';
DEF tit_04 = 'Average Time on CPU/exec';
DEF tit_05 = 'Median Time on CPU/exec';
DEF tit_06 = '&&sqld360_conf_avg_et_percth.th CPU Time/exec';
DEF tit_07 = 'Average DB Time/exec';
DEF tit_08 = 'Median DB Time/exec';
DEF tit_09 = '&&sqld360_conf_avg_et_percth.th DB Time/exec';
DEF tit_10 = 'Average Elapsed Time/exec Trend/exec';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg and Median Elapsed Time/Execution for historical executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql


DEF skip_lch = 'Y';

--------------------
--------------------

DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Streak of non-executing SQL for recent execs, in seconds, rounded to the 1 second';
DEF foot = 'Usually refer to parsing SQL, data rounded to the 1 second';
DEF skip_lch = 'Y';

BEGIN
  :sql_text_backup := q'[
SELECT inst_id, session_id, session_serial#, COUNT(DISTINCT event) num_events, MIN(event) min_event, MAX(event) max_event, MIN(sample_time) streak_start, MAX(sample_time) streak_end, COUNT(*) streak_num_samples
  FROM (SELECT inst_id, session_id, session_serial#, sample_time, event, nvl(start_of_streak, 
               MAX(start_of_streak) OVER (PARTITION BY inst_id, session_id, session_serial# ORDER BY sample_time ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)) start_of_streak
          FROM (SELECT inst_id, session_id, session_serial#, sample_time, event, 
                       CASE WHEN diff_in_sample IS NULL OR diff_in_sample > 1 THEN sample_time ELSE NULL END start_of_streak
                  FROM (SELECT position inst_id, cpu_cost session_id, io_cost session_serial#, timestamp sample_time, object_node event,
                               TRUNC((timestamp-LAG(timestamp) OVER (PARTITION BY position, cpu_cost, io_cost ORDER BY timestamp))*86400) diff_in_sample
                          FROM plan_table
                         WHERE remarks = '&&sqld360_sqlid.'
                           AND statement_id = 'SQLD360_ASH_DATA_MEM'
                           AND '&&diagnostics_pack.' = 'Y'
                           AND position =  @instance_number@
                           AND partition_id IS NULL)))
 GROUP BY inst_id, session_id, session_serial#, start_of_streak 
 HAVING COUNT(*) > 1
 ORDER BY start_of_streak, inst_id, session_id, session_serial#      
]';
END;
/

DEF skip_all = '&&is_single_instance.';
DEF title = 'Streak of non-executing SQL for recent executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql


-----------------------------------------
-----------------------------------------


DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Streak of non-executing SQL for historical execs, in seconds, rounded to the 10 second';
DEF foot = 'Usually refer to parsing SQL, data rounded to the 10 second';
DEF skip_lch = 'Y';

BEGIN
  :sql_text_backup := q'[
SELECT inst_id, session_id, session_serial#, COUNT(DISTINCT event) num_events, MIN(event) min_event, MAX(event) max_event, MIN(sample_time) streak_start, MAX(sample_time) streak_end, COUNT(*) streak_num_samples
  FROM (SELECT inst_id, session_id, session_serial#, sample_time, event, nvl(start_of_streak, 
               MAX(start_of_streak) OVER (PARTITION BY inst_id, session_id, session_serial# ORDER BY sample_time ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)) start_of_streak
          FROM (SELECT inst_id, session_id, session_serial#, sample_time, event,
                       CASE WHEN diff_in_sample IS NULL OR diff_in_sample > &&sqld360_ashtimevalue. THEN sample_time ELSE NULL END start_of_streak
                  FROM (SELECT position inst_id, cpu_cost session_id, io_cost session_serial#, timestamp sample_time, object_node event,
                               TRUNC((timestamp-LAG(timestamp) OVER (PARTITION BY position, cpu_cost, io_cost ORDER BY timestamp))*86400) diff_in_sample
                          FROM plan_table
                         WHERE remarks = '&&sqld360_sqlid.'
                           AND statement_id = 'SQLD360_ASH_DATA_HIST'
                           AND '&&diagnostics_pack.' = 'Y'
                           AND position =  @instance_number@
                           AND partition_id IS NULL)))
 GROUP BY inst_id, session_id, session_serial#, start_of_streak 
 HAVING COUNT(*) > 1
 ORDER BY start_of_streak, inst_id, session_id, session_serial#      
]';
END;
/

DEF skip_all = '&&is_single_instance.';
DEF title = 'Streak of non-executing SQL for historical executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Streak of non-executing SQL for historical executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Streak of non-executing SQL for historical executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Streak of non-executing SQL for historical executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Streak of non-executing SQL for historical executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Streak of non-executing SQL for historical executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Streak of non-executing SQL for historical executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Streak of non-executing SQL for historical executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Streak of non-executing SQL for recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

---------------------
---------------------


SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;