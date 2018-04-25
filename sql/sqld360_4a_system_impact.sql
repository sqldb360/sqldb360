DEF section_id = '4a';
DEF section_name = 'System Impact';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = '&&sqld360_sqlid.';
DEF tit_02 = 'Total System Elapsed Time';
DEF tit_03 = '';
DEF tit_04 = '';
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

COL db_name FOR A9;
COL host_name FOR A64;
COL instance_name FOR A16;
COL db_unique_name FOR A30;
COL platform_name FOR A101;
COL version FOR A17;

--COL sql_elapsed FOR 999999990.000;
--COL system_elapsed FOR 999999990.000;

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'SQL Execute Elapsed Time in secs';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(c.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(c.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       SUM(NVL(b.sql_val,0))/1000000 sql_elapsed,
       SUM(a.system_val)/1000000 system_elapsed, 
       TRUNC((SUM(NVL(b.sql_val,0))/SUM(a.system_val))*100,3) sql_impact_percentage,
       0 dummy_04,
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
  FROM (SELECT snap_id, instance_number, value-LAG(value,1) OVER (PARTITION BY instance_number ORDER BY snap_id ) system_val 
          FROM dba_hist_sys_time_model 
         WHERE stat_name LIKE 'sql execute%') a,
       (SELECT snap_id, instance_number, SUM(elapsed_time_delta) sql_val
          FROM dba_hist_sqlstat
         WHERE sql_id = '&&sqld360_sqlid.'
         GROUP BY snap_id, instance_number) b,
       (SELECT snap_id, instance_number, begin_interval_time, end_interval_time
          FROM dba_hist_snapshot
         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) c
 WHERE c.snap_id = b.snap_id(+)
   AND c.instance_number = b.instance_number(+)
   AND a.instance_number = @instance_number@
   AND a.snap_id(+) = c.snap_id
   AND '&&diagnostics_pack.' = 'Y'
   AND a.instance_number(+) = c.instance_number
   AND a.system_val(+) > 0 -- skip the first snapshot where we can''t compute DELTA
                        -- and those where the value would be negative (restart in between)
 GROUP BY
       TO_CHAR(c.begin_interval_time, 'YYYY-MM-DD HH24:MI'), 
       TO_CHAR(c.end_interval_time, 'YYYY-MM-DD HH24:MI')
 ORDER BY
       TO_CHAR(c.end_interval_time, 'YYYY-MM-DD HH24:MI')
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'SQL Execute Time for Cluster';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'SQL Execute Time for Instance 1';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'SQL Execute Time for Instance 2';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'SQL Execute Time for Instance 3';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'SQL Execute Time for Instance 4';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'SQL Execute Time for Instance 5';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'SQL Execute Time for Instance 6';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'SQL Execute Time for Instance 7';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'SQL Execute Time for Instance 8';
DEF abstract = 'SQL Execute Time for SQL ID &&sqld360_sqlid. compared to the total System SQL Execute Time'
DEF foot = 'SQL Execute Elapsed Time'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';

----------------------------
----------------------------

DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Peak Demand for recent executions';
DEF foot = 'Chart represents how many CPUs are busy running the SQL at peak per time'
DEF vaxis = 'Active Sessions running the SQL'


BEGIN
  :sql_text_backup := q'[
SELECT 0 snap_id,
       TO_CHAR(end_time, 'YYYY-MM-DD HH24:MI') begin_time, 
       TO_CHAR(end_time, 'YYYY-MM-DD HH24:MI') end_time,
       num_sessions_min,
       num_sessions_oncpu_min,
       0 dummy_03,
       0 dummy_04,
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
  FROM (SELECT TRUNC(end_time,'mi') end_time,
               MAX(num_sessions) num_sessions_min,
               MAX(num_sessions_oncpu) num_sessions_oncpu_min
          FROM (SELECT timestamp end_time,
                       COUNT(position||'-'||cpu_cost||'-'||io_cost) num_sessions, 
                       COUNT(CASE WHEN object_node = 'ON CPU' THEN position||'-'||cpu_cost||'-'||io_cost ELSE NULL END) num_sessions_oncpu
                  FROM plan_table
                 WHERE statement_id = 'SQLD360_ASH_DATA_MEM'
                   AND position =  @instance_number@
                   AND remarks = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                 GROUP BY timestamp)
         GROUP BY TRUNC(end_time,'mi'))
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF tit_01 = 'Peak Demand';
DEF tit_02 = 'Peak CPU Demand';
DEF tit_03 = '';
DEF tit_04 = '';
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

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Peak Demand for recent executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Peak Demand for recent executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Peak Demand for recent executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Peak Demand for recent executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Peak Demand for recent executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Peak Demand for recent executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Peak Demand for recent executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Peak Demand for recent executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Peak Demand for recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
------------------------------
------------------------------

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Peak Demand for historical executions';
DEF foot = 'Chart represents how many CPUs are busy running the SQL at peak per time'
DEF vaxis = 'Active Sessions running the SQL'


BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(num_sessions_hour,0) num_sessions_hour,
       NVL(num_sessions_oncpu_hour,0) num_sessions_oncpu_hour,
       0 dummy_03,
       0 dummy_04,
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
  FROM (SELECT snap_id,
               MAX(num_sessions) num_sessions_hour,
               MAX(num_sessions_oncpu) num_sessions_oncpu_hour
          FROM (SELECT cardinality snap_id,
                       timestamp end_time,
                       COUNT(position||'-'||cpu_cost||'-'||io_cost) num_sessions, 
                       COUNT(CASE WHEN object_node = 'ON CPU' THEN position||'-'||cpu_cost||'-'||io_cost ELSE NULL END) num_sessions_oncpu
                  FROM plan_table
                 WHERE statement_id = 'SQLD360_ASH_DATA_HIST'
                   AND position =  @instance_number@
                   AND remarks = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                 GROUP BY cardinality, timestamp)
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

DEF tit_01 = 'Peak Demand';
DEF tit_02 = 'Peak CPU Demand';
DEF tit_03 = '';
DEF tit_04 = '';
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

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Peak Demand for historical executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Peak Demand for historical executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Peak Demand for historical executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Peak Demand for historical executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Peak Demand for historical executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Peak Demand for historical executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Peak Demand for historical executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Peak Demand for historical executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Peak Demand for historical executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';

-------------------------
-------------------------

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Distinct sessions executing this SQL (including PX slaves)';
DEF foot = 'Chart represents how many distinct sessions executed this SQL per snap_id'
DEF vaxis = 'Distinct Sessions running the SQL'


BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(unique_sessions,0) unique_sessions,
       0 dummy_02,
       0 dummy_03,
       0 dummy_04,
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
  FROM (SELECT cardinality snap_id,
               COUNT(DISTINCT position||'-'||cpu_cost||'-'||io_cost) unique_sessions
          FROM plan_table
         WHERE statement_id = 'SQLD360_ASH_DATA_HIST'
           AND position =  @instance_number@
           AND remarks = '&&sqld360_sqlid.'
           AND '&&diagnostics_pack.' = 'Y'
         GROUP BY cardinality) ash,
       dba_hist_snapshot b
 WHERE ash.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF tit_01 = 'Sessions';
DEF tit_02 = '';
DEF tit_03 = '';
DEF tit_04 = '';
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

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Distinct number of sessions executing for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Distinct number of sessions executing for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Distinct number of sessions executing for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Distinct number of sessions executing for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Distinct number of sessions executing for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Distinct number of sessions executing for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Distinct number of sessions executing for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Distinct number of sessions executing for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Distinct number of sessions executing for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';

-------------------------
-------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Buffer Gets';
DEF tit_02 = 'Disk Reads';
DEF tit_03 = '';
DEF tit_04 = '';
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

--COL buffer_gets FOR 999999990.000;
--COL physical_reads FOR 999999990.000;

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Buffer gets and disk reads';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(a.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(SUM(b.buffer_gets_delta),0) buffer_gets,
       NVL(SUM(b.disk_reads_delta),0) physical_reads, 
       0 dummy_03,
       0 dummy_04,
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
  FROM (SELECT snap_id, instance_number, buffer_gets_delta, disk_reads_delta
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
DEF title = 'Total Buffer Gets for Cluster';
DEF abstract = 'Buffer gets and disk reads for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total Buffer Gets for Instance 1';
DEF abstract = 'Buffer gets and disk reads for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total Buffer Gets for Instance 2';
DEF abstract = 'Buffer gets and disk reads for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total Buffer Gets for Instance 3';
DEF abstract = 'Buffer gets and disk reads for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total Buffer Gets for Instance 4';
DEF abstract = 'Buffer gets and disk reads for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total Buffer Gets for Instance 5';
DEF abstract = 'Buffer gets and disk reads for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total Buffer Gets for Instance 6';
DEF abstract = 'Buffer gets and disk reads for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total Buffer Gets per Instance 7';
DEF abstract = 'Buffer gets and disk reads for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total Buffer Gets per Instance 8';
DEF abstract = 'Buffer gets and disk reads for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';

------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Rows processed';
DEF tit_02 = 'Fetch Calls';
DEF tit_03 = '';
DEF tit_04 = '';
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

--COL rows_processed FOR 999999990.000;
--COL fetch_calls FOR 999999990.000;

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Rows processed and Fetch calls';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(a.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(SUM(b.rows_processed_delta),0) rows_processed,
       NVL(SUM(b.fetches_delta),0) fetch_calls, 
       0 dummy_03,
       0 dummy_04,
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
  FROM (SELECT snap_id, instance_number, rows_processed_delta, fetches_delta
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
DEF title = 'Total Rows Processed per for Cluster';
DEF abstract = 'Rows processed and fetch calls for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total Rows Processed per for Instance 1';
DEF abstract = 'Rows processed and fetch calls for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total Rows Processed per for Instance 2';
DEF abstract = 'Rows processed and fetch calls for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total Rows Processed per for Instance 3';
DEF abstract = 'Rows processed and fetch calls for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total Rows Processed per for Instance 4';
DEF abstract = 'Rows processed and fetch calls for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total Rows Processed per for Instance 5';
DEF abstract = 'Rows processed and fetch calls for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total Rows Processed per for Instance 6';
DEF abstract = 'Rows processed and fetch calls for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total Rows Processed per for Instance 7';
DEF abstract = 'Rows processed and fetch calls for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total Rows Processed per for Instance 8';
DEF abstract = 'Rows processed and fetch calls for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';


------------------------------------
------------------------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Executions';
DEF tit_02 = 'Parse Calls';
DEF tit_03 = '';
DEF tit_04 = '';
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

--COL executions_delta FOR 999999990.000;
--COL parse_calls FOR 999999990.000;

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Executions and Parse calls';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := q'[
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(a.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(SUM(b.executions_delta),0) executions_delta,
       NVL(SUM(b.parse_calls_delta),0) parse_calls, 
       0 dummy_03,
       0 dummy_04,
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
  FROM (SELECT snap_id, instance_number, executions_delta, parse_calls_delta
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
DEF title = 'Total number of Executions for Cluster';
DEF abstract = 'Executions and parse calls for Cluster over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total number of Executions for Instance 1';
DEF abstract = 'Executions and parse calls for Instance 1 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total number of Executions for Instance 2';
DEF abstract = 'Executions and parse calls for Instance 2 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total number of Executions for Instance 3';
DEF abstract = 'Executions and parse calls for Instance 3 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total number of Executions for Instance 4';
DEF abstract = 'Executions and parse calls for Instance 4 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total number of Executions for Instance 5';
DEF abstract = 'Executions and parse calls for Instance 5 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total number of Executions for Instance 6';
DEF abstract = 'Executions and parse calls for Instance 6 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total number of Executions per Instance 7';
DEF abstract = 'Executions and parse calls for Instance 7 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total number of Executions per Instance 8';
DEF abstract = 'Executions and parse calls for Instance 8 over time from AWR'
DEF foot = 'Low number of executions or long executing SQL make values less accurate'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';

----------------------
----------------------

DEF chartype = 'LineChart';
DEF stacked = '';
DEF tit_01 = 'Version Count';
DEF tit_02 = 'Sharable Memory';
DEF tit_03 = '';
DEF tit_04 = '';
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

DEF series_01 = 'targetAxisIndex: 0'
DEF series_02 = 'targetAxisIndex: 1'

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF vaxis = 'Version Count';
DEF vaxis2 = 'Sharable Memory'
DEF vbaseline = '';

BEGIN
  :sql_text_backup := q'[
SELECT MIN(a.snap_id) snap_id, 
       TO_CHAR(a.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(a.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       SUM(NVL(b.version_count,0)) version_count,
       SUM(NVL(b.sharable_mem,0)) sharable_mem, 
       0 dummy_03,
       0 dummy_04,
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
  FROM (SELECT snap_id, instance_number, version_count, sharable_mem
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
DEF title = 'Version Count and Sharable Memory for Cluster';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'a.instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Version Count and Sharable Memory for Instance 1';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Version Count and Sharable Memory for Instance 2';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Version Count and Sharable Memory for Instance 3';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Version Count and Sharable Memory for Instance 4';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Version Count and Sharable Memory for Instance 5';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Version Count and Sharable Memory for Instance 6';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Version Count and Sharable Memory for Instance 7';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Version Count and Sharable Memory for Instance 8';
DEF abstract = 'Number of Child Cursors and Sharable Memory accounted for'
DEF foot = 'Number of Child Cursors and Sharable Memory accounted for'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF series_01 = ''
DEF series_02 = ''
DEF vaxis2 = ''

----------------------
----------------------


SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;