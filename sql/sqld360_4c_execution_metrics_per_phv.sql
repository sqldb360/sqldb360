DEF section_id = '4c';
DEF section_name = 'Execution metrics per PHV';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

--------------------------------------------------------
-- This file provides info on a PHV basis from both AWR 
-- and ASH, which are both useful depending on the situation.
-- *Which* execution plans to focus on is determined independentlythree times, 
-- two from ASH (mem vs hist) and one from AWR
-- this is intentional because each source may have info that are missing from the others
-- the side effect is the list of plans might be changing depending
-- on the report but I think having more plans (especially if they
-- are impacting) outweight the negative impact of a changing list
--------------------------------------------------------

-- computing AWR list of plans (ASH ones it's only used in two reports so each report computes its own one)

COL tit_01_awr NEW_V tit_01_awr 
COL tit_02_awr NEW_V tit_02_awr 
COL tit_03_awr NEW_V tit_03_awr 
COL tit_04_awr NEW_V tit_04_awr 
COL tit_05_awr NEW_V tit_05_awr 
COL tit_06_awr NEW_V tit_06_awr 
COL tit_07_awr NEW_V tit_07_awr 
COL tit_08_awr NEW_V tit_08_awr 
COL tit_09_awr NEW_V tit_09_awr 
COL tit_10_awr NEW_V tit_10_awr 
COL tit_11_awr NEW_V tit_11_awr 
COL tit_12_awr NEW_V tit_12_awr 
COL tit_13_awr NEW_V tit_13_awr 
COL tit_14_awr NEW_V tit_14_awr 
COL tit_15_awr NEW_V tit_15_awr 
COL phv_01_awr NEW_V phv_01_awr 
COL phv_02_awr NEW_V phv_02_awr 
COL phv_03_awr NEW_V phv_03_awr 
COL phv_04_awr NEW_V phv_04_awr 
COL phv_05_awr NEW_V phv_05_awr 
COL phv_06_awr NEW_V phv_06_awr 
COL phv_07_awr NEW_V phv_07_awr 
COL phv_08_awr NEW_V phv_08_awr 
COL phv_09_awr NEW_V phv_09_awr 
COL phv_10_awr NEW_V phv_10_awr 
COL phv_11_awr NEW_V phv_11_awr 
COL phv_12_awr NEW_V phv_12_awr 
COL phv_13_awr NEW_V phv_13_awr 
COL phv_14_awr NEW_V phv_14_awr 
COL phv_15_awr NEW_V phv_15_awr

SELECT MAX(CASE WHEN ranking = 1  THEN TO_CHAR(phv) ELSE '' END) tit_01_awr,
       MAX(CASE WHEN ranking = 2  THEN TO_CHAR(phv) ELSE '' END) tit_02_awr,              
       MAX(CASE WHEN ranking = 3  THEN TO_CHAR(phv) ELSE '' END) tit_03_awr, 
       MAX(CASE WHEN ranking = 4  THEN TO_CHAR(phv) ELSE '' END) tit_04_awr, 
       MAX(CASE WHEN ranking = 5  THEN TO_CHAR(phv) ELSE '' END) tit_05_awr, 
       MAX(CASE WHEN ranking = 6  THEN TO_CHAR(phv) ELSE '' END) tit_06_awr, 
       MAX(CASE WHEN ranking = 7  THEN TO_CHAR(phv) ELSE '' END) tit_07_awr, 
       MAX(CASE WHEN ranking = 8  THEN TO_CHAR(phv) ELSE '' END) tit_08_awr, 
       MAX(CASE WHEN ranking = 9  THEN TO_CHAR(phv) ELSE '' END) tit_09_awr, 
       MAX(CASE WHEN ranking = 10 THEN TO_CHAR(phv) ELSE '' END) tit_10_awr,
       MAX(CASE WHEN ranking = 11 THEN TO_CHAR(phv) ELSE '' END) tit_11_awr,
       MAX(CASE WHEN ranking = 12 THEN TO_CHAR(phv) ELSE '' END) tit_12_awr,
       MAX(CASE WHEN ranking = 13 THEN TO_CHAR(phv) ELSE '' END) tit_13_awr,
       MAX(CASE WHEN ranking = 14 THEN TO_CHAR(phv) ELSE '' END) tit_14_awr,
       MAX(CASE WHEN ranking = 15 THEN TO_CHAR(phv) ELSE '' END) tit_15_awr,
       MAX(CASE WHEN ranking = 1  THEN phv ELSE -1 END) phv_01_awr,
       MAX(CASE WHEN ranking = 2  THEN phv ELSE -1 END) phv_02_awr,              
       MAX(CASE WHEN ranking = 3  THEN phv ELSE -1 END) phv_03_awr, 
       MAX(CASE WHEN ranking = 4  THEN phv ELSE -1 END) phv_04_awr, 
       MAX(CASE WHEN ranking = 5  THEN phv ELSE -1 END) phv_05_awr, 
       MAX(CASE WHEN ranking = 6  THEN phv ELSE -1 END) phv_06_awr, 
       MAX(CASE WHEN ranking = 7  THEN phv ELSE -1 END) phv_07_awr, 
       MAX(CASE WHEN ranking = 8  THEN phv ELSE -1 END) phv_08_awr, 
       MAX(CASE WHEN ranking = 9  THEN phv ELSE -1 END) phv_09_awr, 
       MAX(CASE WHEN ranking = 10 THEN phv ELSE -1 END) phv_10_awr,
       MAX(CASE WHEN ranking = 11 THEN phv ELSE -1 END) phv_11_awr,
       MAX(CASE WHEN ranking = 12 THEN phv ELSE -1 END) phv_12_awr,
       MAX(CASE WHEN ranking = 13 THEN phv ELSE -1 END) phv_13_awr,
       MAX(CASE WHEN ranking = 14 THEN phv ELSE -1 END) phv_14_awr,
       MAX(CASE WHEN ranking = 15 THEN phv ELSE -1 END) phv_15_awr   
  FROM (SELECT 1 fake, phv, ranking  
          FROM (SELECT phv, COUNT(*) OVER (ORDER BY total_et) num_plans, ROW_NUMBER() OVER (ORDER BY total_et) ranking 
                  FROM (SELECT plan_hash_value phv, SUM(elapsed_time_delta) total_et 
                          FROM dba_hist_sqlstat 
                         WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                           AND sql_id = '&&sqld360_sqlid.'
                           AND '&&diagnostics_pack.' = 'Y' 
                         GROUP BY plan_hash_value)) 
         WHERE (ranking BETWEEN 1 AND 5 -- top 5 best performing plans
             OR ranking BETWEEN num_plans-10 AND num_plans)) ash, -- top 10 worse plans
       (SELECT 1 fake FROM dual) b  -- this is in case there is no row in AWR
 WHERE ash.fake(+) = b.fake
/

-----------------------------------

COL db_name FOR A9;
COL host_name FOR A64;
COL instance_name FOR A16;
COL db_unique_name FOR A30;
COL platform_name FOR A101;
COL version FOR A17;

------------------------------
------------------------------

DEF abstract = 'Total number of executions (regardless of elapsed time) per PHV from ASH';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF foot = 'Higher number of executions doesn''t imply higher impact if the plan is optimal';
--DEF slices = '15';
BEGIN
 :sql_text_backup := q'[
SELECT phv,
       num_execs,
       NULL style,
       phv||' - Number of execs: '||num_execs||' ('||TRUNC(100*RATIO_TO_REPORT(num_execs) OVER (),2)||'%)' tooltip
  FROM (SELECT bytes phv,
               COUNT(DISTINCT NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                              NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                              NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                              NVL(partition_id,0)||'-'||NVL(distribution,'x')
                    ) num_execs
          FROM plan_table
         WHERE remarks = '&&sqld360_sqlid.' 
           AND statement_id LIKE 'SQLD360_ASH_DATA%' 
           AND position =  @instance_number@
           AND '&&diagnostics_pack.' = 'Y'
         GROUP BY bytes)
 ORDER BY num_execs DESC
]';
END;
/ 

DEF skip_bch='';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Total number of Executions per PHV for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total number of Executions per PHV for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total number of Executions per PHV for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total number of Executions per PHV for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total number of Executions per PHV for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total number of Executions per PHV for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total number of Executions per PHV for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total number of Executions per PHV for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total number of Executions per PHV for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql


DEF skip_bch='Y';

--------------------------
--------------------------

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF abstract = 'Number of execution per Plan Hash Value from AWR, top best 5 and worst 10';
DEF foot = 'Low number of executions or long executing SQL make values less accurate';
DEF vaxis = 'Number of executions';

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

DEF tit_01 = '&&tit_01_awr.'
DEF tit_02 = '&&tit_02_awr.'
DEF tit_03 = '&&tit_03_awr.'
DEF tit_04 = '&&tit_04_awr.'
DEF tit_05 = '&&tit_05_awr.'
DEF tit_06 = '&&tit_06_awr.'
DEF tit_07 = '&&tit_07_awr.'
DEF tit_08 = '&&tit_08_awr.'
DEF tit_09 = '&&tit_09_awr.'
DEF tit_10 = '&&tit_10_awr.'
DEF tit_11 = '&&tit_11_awr.'
DEF tit_12 = '&&tit_12_awr.'
DEF tit_13 = '&&tit_13_awr.'
DEF tit_14 = '&&tit_14_awr.'
DEF tit_15 = '&&tit_15_awr.'

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(phv1 ,0) phv1_&&tit_01_awr.  ,
       NVL(phv2 ,0) phv2_&&tit_02_awr.  ,
       NVL(phv3 ,0) phv3_&&tit_03_awr.  ,
       NVL(phv4 ,0) phv4_&&tit_04_awr.  ,
       NVL(phv5 ,0) phv5_&&tit_05_awr.  ,
       NVL(phv6 ,0) phv6_&&tit_06_awr.  ,
       NVL(phv7 ,0) phv7_&&tit_07_awr.  ,
       NVL(phv8 ,0) phv8_&&tit_08_awr.  ,
       NVL(phv9 ,0) phv9_&&tit_09_awr.  ,
       NVL(phv10,0) phv10_&&tit_10_awr. ,
       NVL(phv11,0) phv11_&&tit_11_awr. ,
       NVL(phv12,0) phv12_&&tit_12_awr. ,
       NVL(phv13,0) phv13_&&tit_13_awr. ,
       NVL(phv14,0) phv14_&&tit_14_awr. ,
       NVL(phv15,0) phv15_&&tit_15_awr. 
  FROM (SELECT snap_id,
               MAX(CASE WHEN phv = &&phv_01_awr. THEN execs ELSE NULL END) phv1,
               MAX(CASE WHEN phv = &&phv_02_awr. THEN execs ELSE NULL END) phv2, 
               MAX(CASE WHEN phv = &&phv_03_awr. THEN execs ELSE NULL END) phv3, 
               MAX(CASE WHEN phv = &&phv_04_awr. THEN execs ELSE NULL END) phv4, 
               MAX(CASE WHEN phv = &&phv_05_awr. THEN execs ELSE NULL END) phv5, 
               MAX(CASE WHEN phv = &&phv_06_awr. THEN execs ELSE NULL END) phv6, 
               MAX(CASE WHEN phv = &&phv_07_awr. THEN execs ELSE NULL END) phv7, 
               MAX(CASE WHEN phv = &&phv_08_awr. THEN execs ELSE NULL END) phv8, 
               MAX(CASE WHEN phv = &&phv_09_awr. THEN execs ELSE NULL END) phv9, 
               MAX(CASE WHEN phv = &&phv_10_awr. THEN execs ELSE NULL END) phv10, 
               MAX(CASE WHEN phv = &&phv_11_awr. THEN execs ELSE NULL END) phv11, 
               MAX(CASE WHEN phv = &&phv_12_awr. THEN execs ELSE NULL END) phv12, 
               MAX(CASE WHEN phv = &&phv_13_awr. THEN execs ELSE NULL END) phv13, 
               MAX(CASE WHEN phv = &&phv_14_awr. THEN execs ELSE NULL END) phv14, 
               MAX(CASE WHEN phv = &&phv_15_awr. THEN execs ELSE NULL END) phv15 
          FROM (SELECT snap_id,
                       plan_hash_value phv, 
                       SUM(executions_delta) execs
                  FROM dba_hist_sqlstat
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                   AND sql_id = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                   AND instance_number = @instance_number@
                   AND plan_hash_value IN (&&phv_01_awr.,&&phv_02_awr.,&&phv_03_awr.,&&phv_04_awr.,&&phv_05_awr.,&&phv_06_awr.,
                                           &&phv_07_awr.,&&phv_08_awr.,&&phv_09_awr.,&&phv_10_awr.,&&phv_11_awr.,&&phv_12_awr.,
                                           &&phv_13_awr.,&&phv_14_awr.,&&phv_15_awr.)
                 GROUP BY snap_id, plan_hash_value)
          GROUP BY snap_id) awr, 
         dba_hist_snapshot b
 WHERE awr.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Number of execution per PHV from AWR for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Number of execution per PHV from AWR for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Number of execution per PHV from AWR for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Number of execution per PHV from AWR for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Number of execution per PHV from AWR for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Number of execution per PHV from AWR for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Number of execution per PHV from AWR for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Number of execution per PHV from AWR for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Number of execution per PHV from AWR for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';


---------------------------
---------------------------

DEF abstract = 'Total Elapsed Time (regardless of number of execs) for recent executions per PHV, in seconds, from ASH';
DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF foot = 'Time in seconds. A single exec with a poor plan impacts more than N executions with a good plan, bigger slice means higher impact';
--DEF slices = '15';
BEGIN
 :sql_text_backup := q'[
SELECT phv,
       num_samples,
       NULL style,
       --TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,
       phv||' - 1s-samples: '||num_samples||' ('||TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2)||'% of DB Time)' tooltip
  FROM (SELECT bytes phv,
               COUNT(*) num_samples
          FROM plan_table
         WHERE remarks = '&&sqld360_sqlid.' 
           AND statement_id = 'SQLD360_ASH_DATA_MEM' 
           AND position =  @instance_number@
           AND '&&diagnostics_pack.' = 'Y'
         GROUP BY bytes)
 ORDER BY num_samples DESC
]';
END;
/ 

DEF skip_bch='';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Total Elapsed Time for recent executions per PHV for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total Elapsed Time for recent executions per PHV for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total Elapsed Time for recent executions per PHV for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total Elapsed Time for recent executions per PHV for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total Elapsed Time for recent executions per PHV for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total Elapsed Time for recent executions per PHV for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total Elapsed Time for recent executions per PHV for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total Elapsed Time for recent executions per PHV for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total Elapsed Time for recent executions per PHV for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='Y';
---------------------
---------------------

DEF abstract = 'Total elapsed time (regardless of number of execs) for historical executions per PHV, in seconds, from ASH';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF foot = 'Time in seconds. A single exec with a poor plan impacts more than N executions with a good plan, bigger slice means higher impact';
--DEF slices = '15';
BEGIN
 :sql_text_backup := q'[
SELECT phv,
       num_samples,
       NULL style,
       phv||' - 10s-samples: '||num_samples||' ('||TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2)||'% of DB Time)' tooltip
       --TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,
  FROM (SELECT bytes phv,
               SUM(&&sqld360_ashtimevalue.) num_samples
          FROM plan_table
         WHERE remarks = '&&sqld360_sqlid.' 
           AND statement_id = 'SQLD360_ASH_DATA_HIST' 
           AND position =  @instance_number@
           AND '&&diagnostics_pack.' = 'Y'
         GROUP BY bytes)
 ORDER BY num_samples DESC
]';
END;
/ 

DEF skip_bch='';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Total Elapsed Time for historical executions per PHV for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total Elapsed Time for historical executions per PHV for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total Elapsed Time for historical executions per PHV for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total Elapsed Time for historical executions per PHV for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total Elapsed Time for historical executions per PHV for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total Elapsed Time for historical executions per PHV for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total Elapsed Time for historical executions per PHV for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total Elapsed Time for historical executions per PHV for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total Elapsed Time for historical executions per PHV for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_bch='Y';
----------------------------
----------------------------


DEF main_table = 'DBA_HIST_SQLSTAT';
DEF abstract = 'Total elapsed time per Plan Hash Value from AWR, top best 5 and worst 10';
DEF foot = 'Low number of executions or long executing SQL make values less accurate';
DEF vaxis = 'Total Elapsed Time in secs';

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

DEF tit_01 = '&&tit_01_awr.'
DEF tit_02 = '&&tit_02_awr.'
DEF tit_03 = '&&tit_03_awr.'
DEF tit_04 = '&&tit_04_awr.'
DEF tit_05 = '&&tit_05_awr.'
DEF tit_06 = '&&tit_06_awr.'
DEF tit_07 = '&&tit_07_awr.'
DEF tit_08 = '&&tit_08_awr.'
DEF tit_09 = '&&tit_09_awr.'
DEF tit_10 = '&&tit_10_awr.'
DEF tit_11 = '&&tit_11_awr.'
DEF tit_12 = '&&tit_12_awr.'
DEF tit_13 = '&&tit_13_awr.'
DEF tit_14 = '&&tit_14_awr.'
DEF tit_15 = '&&tit_15_awr.'

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(phv1 ,0) phv1_&&tit_01_awr.  ,
       NVL(phv2 ,0) phv2_&&tit_02_awr.  ,
       NVL(phv3 ,0) phv3_&&tit_03_awr.  ,
       NVL(phv4 ,0) phv4_&&tit_04_awr.  ,
       NVL(phv5 ,0) phv5_&&tit_05_awr.  ,
       NVL(phv6 ,0) phv6_&&tit_06_awr.  ,
       NVL(phv7 ,0) phv7_&&tit_07_awr.  ,
       NVL(phv8 ,0) phv8_&&tit_08_awr.  ,
       NVL(phv9 ,0) phv9_&&tit_09_awr.  ,
       NVL(phv10,0) phv10_&&tit_10_awr. ,
       NVL(phv11,0) phv11_&&tit_11_awr. ,
       NVL(phv12,0) phv12_&&tit_12_awr. ,
       NVL(phv13,0) phv13_&&tit_13_awr. ,
       NVL(phv14,0) phv14_&&tit_14_awr. ,
       NVL(phv15,0) phv15_&&tit_15_awr. 
  FROM (SELECT snap_id,
               MAX(CASE WHEN phv = &&phv_01_awr. THEN elapsed_time ELSE NULL END) phv1,
               MAX(CASE WHEN phv = &&phv_02_awr. THEN elapsed_time ELSE NULL END) phv2, 
               MAX(CASE WHEN phv = &&phv_03_awr. THEN elapsed_time ELSE NULL END) phv3, 
               MAX(CASE WHEN phv = &&phv_04_awr. THEN elapsed_time ELSE NULL END) phv4, 
               MAX(CASE WHEN phv = &&phv_05_awr. THEN elapsed_time ELSE NULL END) phv5, 
               MAX(CASE WHEN phv = &&phv_06_awr. THEN elapsed_time ELSE NULL END) phv6, 
               MAX(CASE WHEN phv = &&phv_07_awr. THEN elapsed_time ELSE NULL END) phv7, 
               MAX(CASE WHEN phv = &&phv_08_awr. THEN elapsed_time ELSE NULL END) phv8, 
               MAX(CASE WHEN phv = &&phv_09_awr. THEN elapsed_time ELSE NULL END) phv9, 
               MAX(CASE WHEN phv = &&phv_10_awr. THEN elapsed_time ELSE NULL END) phv10, 
               MAX(CASE WHEN phv = &&phv_11_awr. THEN elapsed_time ELSE NULL END) phv11, 
               MAX(CASE WHEN phv = &&phv_12_awr. THEN elapsed_time ELSE NULL END) phv12, 
               MAX(CASE WHEN phv = &&phv_13_awr. THEN elapsed_time ELSE NULL END) phv13, 
               MAX(CASE WHEN phv = &&phv_14_awr. THEN elapsed_time ELSE NULL END) phv14, 
               MAX(CASE WHEN phv = &&phv_15_awr. THEN elapsed_time ELSE NULL END) phv15 
          FROM (SELECT snap_id,
                       plan_hash_value phv, 
                       ROUND(SUM(elapsed_time_delta)/1e6,6) elapsed_time
                  FROM dba_hist_sqlstat
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                   AND sql_id = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                   AND instance_number = @instance_number@
                   AND plan_hash_value IN (&&phv_01_awr.,&&phv_02_awr.,&&phv_03_awr.,&&phv_04_awr.,&&phv_05_awr.,&&phv_06_awr.,
                                           &&phv_07_awr.,&&phv_08_awr.,&&phv_09_awr.,&&phv_10_awr.,&&phv_11_awr.,&&phv_12_awr.,
                                           &&phv_13_awr.,&&phv_14_awr.,&&phv_15_awr.)
                 GROUP BY snap_id, plan_hash_value)
          GROUP BY snap_id) awr, 
         dba_hist_snapshot b
 WHERE awr.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Total Elapsed Time per PHV from AWR for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Total Elapsed Time per PHV from AWR for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Total Elapsed Time per PHV from AWR for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Total Elapsed Time per PHV from AWR for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Total Elapsed Time per PHV from AWR for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Total Elapsed Time per PHV from AWR for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Total Elapsed Time per PHV from AWR for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Total Elapsed Time per PHV from AWR for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Total Elapsed Time per PHV from AWR for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';


----------------------------
----------------------------

DEF main_table = 'V$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Average Elapsed Time per execution per Plan Hash Value for recent executions in seconds, top best 5 and worst 10';
DEF foot = 'Data rounded to the 1 second';
DEF vaxis = 'Average Elapsed Time in secs, rounded to 1 sec';

COL tit_01 NEW_V tit_01 
COL tit_02 NEW_V tit_02 
COL tit_03 NEW_V tit_03 
COL tit_04 NEW_V tit_04 
COL tit_05 NEW_V tit_05 
COL tit_06 NEW_V tit_06 
COL tit_07 NEW_V tit_07 
COL tit_08 NEW_V tit_08 
COL tit_09 NEW_V tit_09 
COL tit_10 NEW_V tit_10 
COL tit_11 NEW_V tit_11 
COL tit_12 NEW_V tit_12 
COL tit_13 NEW_V tit_13 
COL tit_14 NEW_V tit_14 
COL tit_15 NEW_V tit_15 
COL phv_01 NEW_V phv_01 
COL phv_02 NEW_V phv_02 
COL phv_03 NEW_V phv_03 
COL phv_04 NEW_V phv_04 
COL phv_05 NEW_V phv_05 
COL phv_06 NEW_V phv_06 
COL phv_07 NEW_V phv_07 
COL phv_08 NEW_V phv_08 
COL phv_09 NEW_V phv_09 
COL phv_10 NEW_V phv_10 
COL phv_11 NEW_V phv_11 
COL phv_12 NEW_V phv_12 
COL phv_13 NEW_V phv_13 
COL phv_14 NEW_V phv_14 
COL phv_15 NEW_V phv_15

SELECT MAX(CASE WHEN ranking = 1  THEN TO_CHAR(phv) ELSE '' END) tit_01,
       MAX(CASE WHEN ranking = 2  THEN TO_CHAR(phv) ELSE '' END) tit_02,              
       MAX(CASE WHEN ranking = 3  THEN TO_CHAR(phv) ELSE '' END) tit_03, 
       MAX(CASE WHEN ranking = 4  THEN TO_CHAR(phv) ELSE '' END) tit_04, 
       MAX(CASE WHEN ranking = 5  THEN TO_CHAR(phv) ELSE '' END) tit_05, 
       MAX(CASE WHEN ranking = 6  THEN TO_CHAR(phv) ELSE '' END) tit_06, 
       MAX(CASE WHEN ranking = 7  THEN TO_CHAR(phv) ELSE '' END) tit_07, 
       MAX(CASE WHEN ranking = 8  THEN TO_CHAR(phv) ELSE '' END) tit_08, 
       MAX(CASE WHEN ranking = 9  THEN TO_CHAR(phv) ELSE '' END) tit_09, 
       MAX(CASE WHEN ranking = 10 THEN TO_CHAR(phv) ELSE '' END) tit_10,
       MAX(CASE WHEN ranking = 11 THEN TO_CHAR(phv) ELSE '' END) tit_11,
       MAX(CASE WHEN ranking = 12 THEN TO_CHAR(phv) ELSE '' END) tit_12,
       MAX(CASE WHEN ranking = 13 THEN TO_CHAR(phv) ELSE '' END) tit_13,
       MAX(CASE WHEN ranking = 14 THEN TO_CHAR(phv) ELSE '' END) tit_14,
       MAX(CASE WHEN ranking = 15 THEN TO_CHAR(phv) ELSE '' END) tit_15,
       MAX(CASE WHEN ranking = 1  THEN phv ELSE -1 END) phv_01,
       MAX(CASE WHEN ranking = 2  THEN phv ELSE -1 END) phv_02,              
       MAX(CASE WHEN ranking = 3  THEN phv ELSE -1 END) phv_03, 
       MAX(CASE WHEN ranking = 4  THEN phv ELSE -1 END) phv_04, 
       MAX(CASE WHEN ranking = 5  THEN phv ELSE -1 END) phv_05, 
       MAX(CASE WHEN ranking = 6  THEN phv ELSE -1 END) phv_06, 
       MAX(CASE WHEN ranking = 7  THEN phv ELSE -1 END) phv_07, 
       MAX(CASE WHEN ranking = 8  THEN phv ELSE -1 END) phv_08, 
       MAX(CASE WHEN ranking = 9  THEN phv ELSE -1 END) phv_09, 
       MAX(CASE WHEN ranking = 10 THEN phv ELSE -1 END) phv_10,
       MAX(CASE WHEN ranking = 11 THEN phv ELSE -1 END) phv_11,
       MAX(CASE WHEN ranking = 12 THEN phv ELSE -1 END) phv_12,
       MAX(CASE WHEN ranking = 13 THEN phv ELSE -1 END) phv_13,
       MAX(CASE WHEN ranking = 14 THEN phv ELSE -1 END) phv_14,
       MAX(CASE WHEN ranking = 15 THEN phv ELSE -1 END) phv_15   
  FROM (SELECT 1 fake, phv, ranking  
          FROM (SELECT phv, COUNT(*) OVER (ORDER BY avg_et) num_plans, ROW_NUMBER() OVER (ORDER BY avg_et) ranking 
                  FROM (SELECT bytes phv, COUNT(*)/COUNT(DISTINCT partition_id) avg_et 
                          FROM plan_table 
                         WHERE statement_id = 'SQLD360_ASH_DATA_MEM'
                           AND remarks = '&&sqld360_sqlid.'
                           AND partition_id IS NOT NULL -- to discard samples we can't attribute to any exec (likely parse)
                         GROUP BY bytes)) 
         WHERE (ranking BETWEEN 1 AND 5 -- top 5 best performing plans
             OR ranking BETWEEN num_plans-10 AND num_plans)) ash, -- top 10 worse plans
       (SELECT 1 fake FROM dual) b -- this is in case there is no row in ASH
 WHERE ash.fake(+) = b.fake
/

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

BEGIN
  :sql_text_backup := q'[
SELECT 0 snap_id,
       TO_CHAR(start_time, 'YYYY-MM-DD HH24:MI') begin_time, 
       TO_CHAR(start_time, 'YYYY-MM-DD HH24:MI') end_time,
       NVL(phv1 ,0) phv1_&&tit_01.  ,
       NVL(phv2 ,0) phv2_&&tit_02.  ,
       NVL(phv3 ,0) phv3_&&tit_03.  ,
       NVL(phv4 ,0) phv4_&&tit_04.  ,
       NVL(phv5 ,0) phv5_&&tit_05.  ,
       NVL(phv6 ,0) phv6_&&tit_06.  ,
       NVL(phv7 ,0) phv7_&&tit_07.  ,
       NVL(phv8 ,0) phv8_&&tit_08.  ,
       NVL(phv9 ,0) phv9_&&tit_09.  ,
       NVL(phv10,0) phv10_&&tit_10. ,
       NVL(phv11,0) phv11_&&tit_11. ,
       NVL(phv12,0) phv12_&&tit_12. ,
       NVL(phv13,0) phv13_&&tit_13. ,
       NVL(phv14,0) phv14_&&tit_14. ,
       NVL(phv15,0) phv15_&&tit_15. 
  FROM (SELECT TO_DATE(start_time,'YYYYMMDDHH24MI') start_time,
               MAX(CASE WHEN phv = &&phv_01. THEN avg_et_per_exec ELSE NULL END) phv1,
               MAX(CASE WHEN phv = &&phv_02. THEN avg_et_per_exec ELSE NULL END) phv2, 
               MAX(CASE WHEN phv = &&phv_03. THEN avg_et_per_exec ELSE NULL END) phv3, 
               MAX(CASE WHEN phv = &&phv_04. THEN avg_et_per_exec ELSE NULL END) phv4, 
               MAX(CASE WHEN phv = &&phv_05. THEN avg_et_per_exec ELSE NULL END) phv5, 
               MAX(CASE WHEN phv = &&phv_06. THEN avg_et_per_exec ELSE NULL END) phv6, 
               MAX(CASE WHEN phv = &&phv_07. THEN avg_et_per_exec ELSE NULL END) phv7, 
               MAX(CASE WHEN phv = &&phv_08. THEN avg_et_per_exec ELSE NULL END) phv8, 
               MAX(CASE WHEN phv = &&phv_09. THEN avg_et_per_exec ELSE NULL END) phv9, 
               MAX(CASE WHEN phv = &&phv_10. THEN avg_et_per_exec ELSE NULL END) phv10, 
               MAX(CASE WHEN phv = &&phv_11. THEN avg_et_per_exec ELSE NULL END) phv11, 
               MAX(CASE WHEN phv = &&phv_12. THEN avg_et_per_exec ELSE NULL END) phv12, 
               MAX(CASE WHEN phv = &&phv_13. THEN avg_et_per_exec ELSE NULL END) phv13, 
               MAX(CASE WHEN phv = &&phv_14. THEN avg_et_per_exec ELSE NULL END) phv14, 
               MAX(CASE WHEN phv = &&phv_15. THEN avg_et_per_exec ELSE NULL END) phv15 
          FROM (SELECT start_time,
                       phv,
                       AVG(et) avg_et_per_exec
                  FROM (SELECT SUBSTR(distribution,1,12) start_time,
                               bytes phv, 
                               &&sqld360_ashsample.+86400*(MAX(timestamp)-MIN(timestamp)) et,
                               NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                                NVL(partition_id,0)||'-'||NVL(distribution,'x') uniq_exec
                          FROM plan_table
                         WHERE statement_id = 'SQLD360_ASH_DATA_MEM'
                           AND position =  @instance_number@
                           AND remarks = '&&sqld360_sqlid.'
                           AND '&&diagnostics_pack.' = 'Y'
                           AND partition_id IS NOT NULL
                           AND distribution IS NOT NULL
                           AND bytes IN (&&phv_01.,&&phv_02.,&&phv_03.,&&phv_04.,&&phv_05.,&&phv_06.,
                                        &&phv_07.,&&phv_08.,&&phv_09.,&&phv_10.,&&phv_11.,&&phv_12.,
                                        &&phv_13.,&&phv_14.,&&phv_15.)
                         GROUP BY SUBSTR(distribution,1,12), bytes, 
                                  NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                                   NVL(partition_id,0)||'-'||NVL(distribution,'x'))
                 GROUP BY start_time, phv)
         GROUP BY TO_DATE(start_time,'YYYYMMDDHH24MI'))
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution per PHV for recent executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';
---------------------------
---------------------------

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Average elapsed time per execution per Plan Hash Value for historical executions in seconds, top best 5 and worst 10';
DEF foot = 'Data rounded to the 10 second';
DEF vaxis = 'Average Elapsed Time in secs, rounded to 10 sec';

COL tit_01 NEW_V tit_01 
COL tit_02 NEW_V tit_02 
COL tit_03 NEW_V tit_03 
COL tit_04 NEW_V tit_04 
COL tit_05 NEW_V tit_05 
COL tit_06 NEW_V tit_06 
COL tit_07 NEW_V tit_07 
COL tit_08 NEW_V tit_08 
COL tit_09 NEW_V tit_09 
COL tit_10 NEW_V tit_10 
COL tit_11 NEW_V tit_11 
COL tit_12 NEW_V tit_12 
COL tit_13 NEW_V tit_13 
COL tit_14 NEW_V tit_14 
COL tit_15 NEW_V tit_15 
COL phv_01 NEW_V phv_01 
COL phv_02 NEW_V phv_02 
COL phv_03 NEW_V phv_03 
COL phv_04 NEW_V phv_04 
COL phv_05 NEW_V phv_05 
COL phv_06 NEW_V phv_06 
COL phv_07 NEW_V phv_07 
COL phv_08 NEW_V phv_08 
COL phv_09 NEW_V phv_09 
COL phv_10 NEW_V phv_10 
COL phv_11 NEW_V phv_11 
COL phv_12 NEW_V phv_12 
COL phv_13 NEW_V phv_13 
COL phv_14 NEW_V phv_14 
COL phv_15 NEW_V phv_15

SELECT MAX(CASE WHEN ranking = 1  THEN TO_CHAR(phv) ELSE '' END) tit_01,
       MAX(CASE WHEN ranking = 2  THEN TO_CHAR(phv) ELSE '' END) tit_02,              
       MAX(CASE WHEN ranking = 3  THEN TO_CHAR(phv) ELSE '' END) tit_03, 
       MAX(CASE WHEN ranking = 4  THEN TO_CHAR(phv) ELSE '' END) tit_04, 
       MAX(CASE WHEN ranking = 5  THEN TO_CHAR(phv) ELSE '' END) tit_05, 
       MAX(CASE WHEN ranking = 6  THEN TO_CHAR(phv) ELSE '' END) tit_06, 
       MAX(CASE WHEN ranking = 7  THEN TO_CHAR(phv) ELSE '' END) tit_07, 
       MAX(CASE WHEN ranking = 8  THEN TO_CHAR(phv) ELSE '' END) tit_08, 
       MAX(CASE WHEN ranking = 9  THEN TO_CHAR(phv) ELSE '' END) tit_09, 
       MAX(CASE WHEN ranking = 10 THEN TO_CHAR(phv) ELSE '' END) tit_10,
       MAX(CASE WHEN ranking = 11 THEN TO_CHAR(phv) ELSE '' END) tit_11,
       MAX(CASE WHEN ranking = 12 THEN TO_CHAR(phv) ELSE '' END) tit_12,
       MAX(CASE WHEN ranking = 13 THEN TO_CHAR(phv) ELSE '' END) tit_13,
       MAX(CASE WHEN ranking = 14 THEN TO_CHAR(phv) ELSE '' END) tit_14,
       MAX(CASE WHEN ranking = 15 THEN TO_CHAR(phv) ELSE '' END) tit_15,
       MAX(CASE WHEN ranking = 1  THEN phv ELSE -1 END) phv_01,
       MAX(CASE WHEN ranking = 2  THEN phv ELSE -1 END) phv_02,              
       MAX(CASE WHEN ranking = 3  THEN phv ELSE -1 END) phv_03, 
       MAX(CASE WHEN ranking = 4  THEN phv ELSE -1 END) phv_04, 
       MAX(CASE WHEN ranking = 5  THEN phv ELSE -1 END) phv_05, 
       MAX(CASE WHEN ranking = 6  THEN phv ELSE -1 END) phv_06, 
       MAX(CASE WHEN ranking = 7  THEN phv ELSE -1 END) phv_07, 
       MAX(CASE WHEN ranking = 8  THEN phv ELSE -1 END) phv_08, 
       MAX(CASE WHEN ranking = 9  THEN phv ELSE -1 END) phv_09, 
       MAX(CASE WHEN ranking = 10 THEN phv ELSE -1 END) phv_10,
       MAX(CASE WHEN ranking = 11 THEN phv ELSE -1 END) phv_11,
       MAX(CASE WHEN ranking = 12 THEN phv ELSE -1 END) phv_12,
       MAX(CASE WHEN ranking = 13 THEN phv ELSE -1 END) phv_13,
       MAX(CASE WHEN ranking = 14 THEN phv ELSE -1 END) phv_14,
       MAX(CASE WHEN ranking = 15 THEN phv ELSE -1 END) phv_15   
  FROM (SELECT 1 fake, phv, ranking  
          FROM (SELECT phv, COUNT(*) OVER (ORDER BY avg_et) num_plans, ROW_NUMBER() OVER (ORDER BY avg_et) ranking 
                  FROM (SELECT /*cost*/ bytes phv, COUNT(*)/COUNT(DISTINCT partition_id) avg_et 
                          FROM plan_table 
                         WHERE statement_id = 'SQLD360_ASH_DATA_HIST'
                           AND remarks = '&&sqld360_sqlid.'
                           AND partition_id IS NOT NULL -- to discard samples we can't attribute to any exec (likely parse)
                         GROUP BY /*cost*/ bytes)) 
         WHERE (ranking BETWEEN 1 AND 5 -- top 5 best performing plans
             OR ranking BETWEEN num_plans-10 AND num_plans)) ash, -- top 10 worse plans
       (SELECT 1 fake FROM dual) b  -- this is in case there is no row in ASH
 WHERE ash.fake(+) = b.fake
/

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(phv1 ,0) phv1_&&tit_01.  ,
       NVL(phv2 ,0) phv2_&&tit_02.  ,
       NVL(phv3 ,0) phv3_&&tit_03.  ,
       NVL(phv4 ,0) phv4_&&tit_04.  ,
       NVL(phv5 ,0) phv5_&&tit_05.  ,
       NVL(phv6 ,0) phv6_&&tit_06.  ,
       NVL(phv7 ,0) phv7_&&tit_07.  ,
       NVL(phv8 ,0) phv8_&&tit_08.  ,
       NVL(phv9 ,0) phv9_&&tit_09.  ,
       NVL(phv10,0) phv10_&&tit_10. ,
       NVL(phv11,0) phv11_&&tit_11. ,
       NVL(phv12,0) phv12_&&tit_12. ,
       NVL(phv13,0) phv13_&&tit_13. ,
       NVL(phv14,0) phv14_&&tit_14. ,
       NVL(phv15,0) phv15_&&tit_15. 
  FROM (SELECT TO_DATE(start_time,'YYYYMMDDHH24') start_time,
               MIN(starting_snap_id) snap_id,
               MAX(CASE WHEN phv = &&phv_01. THEN avg_et_per_exec ELSE NULL END) phv1,
               MAX(CASE WHEN phv = &&phv_02. THEN avg_et_per_exec ELSE NULL END) phv2, 
               MAX(CASE WHEN phv = &&phv_03. THEN avg_et_per_exec ELSE NULL END) phv3, 
               MAX(CASE WHEN phv = &&phv_04. THEN avg_et_per_exec ELSE NULL END) phv4, 
               MAX(CASE WHEN phv = &&phv_05. THEN avg_et_per_exec ELSE NULL END) phv5, 
               MAX(CASE WHEN phv = &&phv_06. THEN avg_et_per_exec ELSE NULL END) phv6, 
               MAX(CASE WHEN phv = &&phv_07. THEN avg_et_per_exec ELSE NULL END) phv7, 
               MAX(CASE WHEN phv = &&phv_08. THEN avg_et_per_exec ELSE NULL END) phv8, 
               MAX(CASE WHEN phv = &&phv_09. THEN avg_et_per_exec ELSE NULL END) phv9, 
               MAX(CASE WHEN phv = &&phv_10. THEN avg_et_per_exec ELSE NULL END) phv10, 
               MAX(CASE WHEN phv = &&phv_11. THEN avg_et_per_exec ELSE NULL END) phv11, 
               MAX(CASE WHEN phv = &&phv_12. THEN avg_et_per_exec ELSE NULL END) phv12, 
               MAX(CASE WHEN phv = &&phv_13. THEN avg_et_per_exec ELSE NULL END) phv13, 
               MAX(CASE WHEN phv = &&phv_14. THEN avg_et_per_exec ELSE NULL END) phv14, 
               MAX(CASE WHEN phv = &&phv_15. THEN avg_et_per_exec ELSE NULL END) phv15 
          FROM (SELECT start_time,
                       phv,
                       starting_snap_id,
                       AVG(et) avg_et_per_exec
                  FROM (SELECT SUBSTR(distribution,1,10) start_time,
                               /*cost*/ bytes phv, 
                               MIN(cardinality) starting_snap_id,
                               &&sqld360_ashtimevalue.+86400*(MAX(timestamp)-MIN(timestamp)) et,
                               NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                                NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                                NVL(partition_id,0)||'-'||NVL(distribution,'x') uniq_exec
                          FROM plan_table
                         WHERE statement_id = 'SQLD360_ASH_DATA_HIST'
                           AND position =  @instance_number@
                           AND remarks = '&&sqld360_sqlid.'
                           AND '&&diagnostics_pack.' = 'Y'
                           AND partition_id IS NOT NULL
                           AND distribution IS NOT NULL
                           AND /*cost*/ bytes IN (&&phv_01.,&&phv_02.,&&phv_03.,&&phv_04.,&&phv_05.,&&phv_06.,
                                        &&phv_07.,&&phv_08.,&&phv_09.,&&phv_10.,&&phv_11.,&&phv_12.,
                                        &&phv_13.,&&phv_14.,&&phv_15.)
                         GROUP BY SUBSTR(distribution,1,10), /*cost*/ bytes, 
                                  NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,3)+1,INSTR(partition_stop,',',1,4)-INSTR(partition_stop,',',1,3)-1)),position)||'-'|| 
                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,4)+1,INSTR(partition_stop,',',1,5)-INSTR(partition_stop,',',1,4)-1)),cpu_cost)||'-'|| 
                                   NVL(TO_NUMBER(SUBSTR(partition_stop,INSTR(partition_stop,',',1,5)+1,INSTR(partition_stop,',',1,6)-INSTR(partition_stop,',',1,5)-1)),io_cost)||'-'||
                                   NVL(partition_id,0)||'-'||NVL(distribution,'x'))
                 GROUP BY start_time, phv, starting_snap_id)
         GROUP BY TO_DATE(start_time,'YYYYMMDDHH24')) ash, 
       dba_hist_snapshot b
 WHERE ash.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution per PHV for historical executions for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';

----------------------------
----------------------------


DEF main_table = 'DBA_HIST_SQLSTAT';
DEF abstract = 'Average elapsed time per execution per Plan Hash Value from AWR, top best 5 and worst 10';
DEF foot = 'Low number of executions or long executing SQL make values less accurate';
DEF vaxis = 'Average Elapsed Time in &&sqld360_awr_timescale_l.';

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

DEF tit_01 = '&&tit_01_awr.'
DEF tit_02 = '&&tit_02_awr.'
DEF tit_03 = '&&tit_03_awr.'
DEF tit_04 = '&&tit_04_awr.'
DEF tit_05 = '&&tit_05_awr.'
DEF tit_06 = '&&tit_06_awr.'
DEF tit_07 = '&&tit_07_awr.'
DEF tit_08 = '&&tit_08_awr.'
DEF tit_09 = '&&tit_09_awr.'
DEF tit_10 = '&&tit_10_awr.'
DEF tit_11 = '&&tit_11_awr.'
DEF tit_12 = '&&tit_12_awr.'
DEF tit_13 = '&&tit_13_awr.'
DEF tit_14 = '&&tit_14_awr.'
DEF tit_15 = '&&tit_15_awr.'

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(phv1 ,0) phv1_&&tit_01.  ,
       NVL(phv2 ,0) phv2_&&tit_02.  ,
       NVL(phv3 ,0) phv3_&&tit_03.  ,
       NVL(phv4 ,0) phv4_&&tit_04.  ,
       NVL(phv5 ,0) phv5_&&tit_05.  ,
       NVL(phv6 ,0) phv6_&&tit_06.  ,
       NVL(phv7 ,0) phv7_&&tit_07.  ,
       NVL(phv8 ,0) phv8_&&tit_08.  ,
       NVL(phv9 ,0) phv9_&&tit_09.  ,
       NVL(phv10,0) phv10_&&tit_10. ,
       NVL(phv11,0) phv11_&&tit_11. ,
       NVL(phv12,0) phv12_&&tit_12. ,
       NVL(phv13,0) phv13_&&tit_13. ,
       NVL(phv14,0) phv14_&&tit_14. ,
       NVL(phv15,0) phv15_&&tit_15. 
  FROM (SELECT snap_id,
               MAX(CASE WHEN phv = &&phv_01_awr. THEN avg_et_per_exec ELSE NULL END) phv1,
               MAX(CASE WHEN phv = &&phv_02_awr. THEN avg_et_per_exec ELSE NULL END) phv2, 
               MAX(CASE WHEN phv = &&phv_03_awr. THEN avg_et_per_exec ELSE NULL END) phv3, 
               MAX(CASE WHEN phv = &&phv_04_awr. THEN avg_et_per_exec ELSE NULL END) phv4, 
               MAX(CASE WHEN phv = &&phv_05_awr. THEN avg_et_per_exec ELSE NULL END) phv5, 
               MAX(CASE WHEN phv = &&phv_06_awr. THEN avg_et_per_exec ELSE NULL END) phv6, 
               MAX(CASE WHEN phv = &&phv_07_awr. THEN avg_et_per_exec ELSE NULL END) phv7, 
               MAX(CASE WHEN phv = &&phv_08_awr. THEN avg_et_per_exec ELSE NULL END) phv8, 
               MAX(CASE WHEN phv = &&phv_09_awr. THEN avg_et_per_exec ELSE NULL END) phv9, 
               MAX(CASE WHEN phv = &&phv_10_awr. THEN avg_et_per_exec ELSE NULL END) phv10, 
               MAX(CASE WHEN phv = &&phv_11_awr. THEN avg_et_per_exec ELSE NULL END) phv11, 
               MAX(CASE WHEN phv = &&phv_12_awr. THEN avg_et_per_exec ELSE NULL END) phv12, 
               MAX(CASE WHEN phv = &&phv_13_awr. THEN avg_et_per_exec ELSE NULL END) phv13, 
               MAX(CASE WHEN phv = &&phv_14_awr. THEN avg_et_per_exec ELSE NULL END) phv14, 
               MAX(CASE WHEN phv = &&phv_15_awr. THEN avg_et_per_exec ELSE NULL END) phv15 
          FROM (SELECT snap_id,
                       plan_hash_value phv, 
                       ROUND(SUM(elapsed_time_total)/SUM(NVL(NULLIF(executions_total,0),1))/&&sqld360_awr_timescale_d.,6) avg_et_per_exec
                  FROM dba_hist_sqlstat
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                   AND sql_id = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                   AND instance_number = @instance_number@
                   AND plan_hash_value IN (&&phv_01_awr.,&&phv_02_awr.,&&phv_03_awr.,&&phv_04_awr.,&&phv_05_awr.,&&phv_06_awr.,
                                           &&phv_07_awr.,&&phv_08_awr.,&&phv_09_awr.,&&phv_10_awr.,&&phv_11_awr.,&&phv_12_awr.,
                                           &&phv_13_awr.,&&phv_14_awr.,&&phv_15_awr.)
                 GROUP BY snap_id, plan_hash_value)
          GROUP BY snap_id) awr, 
         dba_hist_snapshot b
 WHERE awr.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution per PHV (total) from AWR for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';

-----------------------------
-----------------------------

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF abstract = 'Average elapsed time per execution per Plan Hash Value from AWR, top best 5 and worst 10';
DEF foot = 'Low number of executions or long executing SQL make values less accurate';
DEF vaxis = 'Average Elapsed Time in &&sqld360_awr_timescale_l.';

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

DEF tit_01 = '&&tit_01_awr.'
DEF tit_02 = '&&tit_02_awr.'
DEF tit_03 = '&&tit_03_awr.'
DEF tit_04 = '&&tit_04_awr.'
DEF tit_05 = '&&tit_05_awr.'
DEF tit_06 = '&&tit_06_awr.'
DEF tit_07 = '&&tit_07_awr.'
DEF tit_08 = '&&tit_08_awr.'
DEF tit_09 = '&&tit_09_awr.'
DEF tit_10 = '&&tit_10_awr.'
DEF tit_11 = '&&tit_11_awr.'
DEF tit_12 = '&&tit_12_awr.'
DEF tit_13 = '&&tit_13_awr.'
DEF tit_14 = '&&tit_14_awr.'
DEF tit_15 = '&&tit_15_awr.'

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(phv1 ,0) phv1_&&tit_01.  ,
       NVL(phv2 ,0) phv2_&&tit_02.  ,
       NVL(phv3 ,0) phv3_&&tit_03.  ,
       NVL(phv4 ,0) phv4_&&tit_04.  ,
       NVL(phv5 ,0) phv5_&&tit_05.  ,
       NVL(phv6 ,0) phv6_&&tit_06.  ,
       NVL(phv7 ,0) phv7_&&tit_07.  ,
       NVL(phv8 ,0) phv8_&&tit_08.  ,
       NVL(phv9 ,0) phv9_&&tit_09.  ,
       NVL(phv10,0) phv10_&&tit_10. ,
       NVL(phv11,0) phv11_&&tit_11. ,
       NVL(phv12,0) phv12_&&tit_12. ,
       NVL(phv13,0) phv13_&&tit_13. ,
       NVL(phv14,0) phv14_&&tit_14. ,
       NVL(phv15,0) phv15_&&tit_15. 
  FROM (SELECT snap_id,
               MAX(CASE WHEN phv = &&phv_01_awr. THEN avg_et_per_exec ELSE NULL END) phv1,
               MAX(CASE WHEN phv = &&phv_02_awr. THEN avg_et_per_exec ELSE NULL END) phv2, 
               MAX(CASE WHEN phv = &&phv_03_awr. THEN avg_et_per_exec ELSE NULL END) phv3, 
               MAX(CASE WHEN phv = &&phv_04_awr. THEN avg_et_per_exec ELSE NULL END) phv4, 
               MAX(CASE WHEN phv = &&phv_05_awr. THEN avg_et_per_exec ELSE NULL END) phv5, 
               MAX(CASE WHEN phv = &&phv_06_awr. THEN avg_et_per_exec ELSE NULL END) phv6, 
               MAX(CASE WHEN phv = &&phv_07_awr. THEN avg_et_per_exec ELSE NULL END) phv7, 
               MAX(CASE WHEN phv = &&phv_08_awr. THEN avg_et_per_exec ELSE NULL END) phv8, 
               MAX(CASE WHEN phv = &&phv_09_awr. THEN avg_et_per_exec ELSE NULL END) phv9, 
               MAX(CASE WHEN phv = &&phv_10_awr. THEN avg_et_per_exec ELSE NULL END) phv10, 
               MAX(CASE WHEN phv = &&phv_11_awr. THEN avg_et_per_exec ELSE NULL END) phv11, 
               MAX(CASE WHEN phv = &&phv_12_awr. THEN avg_et_per_exec ELSE NULL END) phv12, 
               MAX(CASE WHEN phv = &&phv_13_awr. THEN avg_et_per_exec ELSE NULL END) phv13, 
               MAX(CASE WHEN phv = &&phv_14_awr. THEN avg_et_per_exec ELSE NULL END) phv14, 
               MAX(CASE WHEN phv = &&phv_15_awr. THEN avg_et_per_exec ELSE NULL END) phv15 
          FROM (SELECT snap_id,
                       plan_hash_value phv, 
                       ROUND(SUM(elapsed_time_delta)/SUM(NVL(NULLIF(executions_delta,0),1))/&&sqld360_awr_timescale_d.,6) avg_et_per_exec
                  FROM dba_hist_sqlstat
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                   AND sql_id = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                   AND instance_number = @instance_number@
                   AND plan_hash_value IN (&&phv_01_awr.,&&phv_02_awr.,&&phv_03_awr.,&&phv_04_awr.,&&phv_05_awr.,&&phv_06_awr.,
                                           &&phv_07_awr.,&&phv_08_awr.,&&phv_09_awr.,&&phv_10_awr.,&&phv_11_awr.,&&phv_12_awr.,
                                           &&phv_13_awr.,&&phv_14_awr.,&&phv_15_awr.)
                 GROUP BY snap_id, plan_hash_value)
          GROUP BY snap_id) awr, 
         dba_hist_snapshot b
 WHERE awr.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution per PHV (delta) from AWR for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';

-----------------------------
-----------------------------

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF abstract = 'Average elapsed time per execution per Plan Hash Value from AWR, top best 5 and worst 10';
DEF foot = 'Low number of executions or long executing SQL make values less accurate';
DEF vaxis = 'Average Elapsed Time in &&sqld360_awr_timescale_l.';

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

DEF tit_01 = '&&tit_01_awr.'
DEF tit_02 = '&&tit_02_awr.'
DEF tit_03 = '&&tit_03_awr.'
DEF tit_04 = '&&tit_04_awr.'
DEF tit_05 = '&&tit_05_awr.'
DEF tit_06 = '&&tit_06_awr.'
DEF tit_07 = '&&tit_07_awr.'
DEF tit_08 = '&&tit_08_awr.'
DEF tit_09 = '&&tit_09_awr.'
DEF tit_10 = '&&tit_10_awr.'
DEF tit_11 = '&&tit_11_awr.'
DEF tit_12 = '&&tit_12_awr.'
DEF tit_13 = '&&tit_13_awr.'
DEF tit_14 = '&&tit_14_awr.'
DEF tit_15 = '&&tit_15_awr.'

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(ROUND(SUM(etps1 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps1 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv1_&&tit_01.  ,
       NVL(ROUND(SUM(etps2 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps2 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv2_&&tit_02.  ,
       NVL(ROUND(SUM(etps3 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps3 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv3_&&tit_03.  ,
       NVL(ROUND(SUM(etps4 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps4 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv4_&&tit_04.  ,
       NVL(ROUND(SUM(etps5 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps5 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv5_&&tit_05.  ,
       NVL(ROUND(SUM(etps6 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps6 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv6_&&tit_06.  ,
       NVL(ROUND(SUM(etps7 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps7 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv7_&&tit_07.  ,
       NVL(ROUND(SUM(etps8 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps8 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv8_&&tit_08.  ,
       NVL(ROUND(SUM(etps9 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps9 ) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv9_&&tit_09.  ,
       NVL(ROUND(SUM(etps10) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps10) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv10_&&tit_10. ,
       NVL(ROUND(SUM(etps11) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps11) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv11_&&tit_11. ,
       NVL(ROUND(SUM(etps12) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps12) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv12_&&tit_12. ,
       NVL(ROUND(SUM(etps13) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps13) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv13_&&tit_13. ,
       NVL(ROUND(SUM(etps14) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps14) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv14_&&tit_14. ,
       NVL(ROUND(SUM(etps15) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW)
         /NVL(NULLIF(SUM(eps15) OVER (ORDER BY end_interval_time RANGE BETWEEN NUMTODSINTERVAL(1,'DAY') PRECEDING AND CURRENT ROW),0),1)/&&sqld360_awr_timescale_d.,6),0) phv15_&&tit_15. 
  FROM (SELECT snap_id,
               MAX(CASE WHEN phv = &&phv_01_awr. THEN elapsed_time_per_snap ELSE NULL END) etps1,
               MAX(CASE WHEN phv = &&phv_02_awr. THEN elapsed_time_per_snap ELSE NULL END) etps2, 
               MAX(CASE WHEN phv = &&phv_03_awr. THEN elapsed_time_per_snap ELSE NULL END) etps3, 
               MAX(CASE WHEN phv = &&phv_04_awr. THEN elapsed_time_per_snap ELSE NULL END) etps4, 
               MAX(CASE WHEN phv = &&phv_05_awr. THEN elapsed_time_per_snap ELSE NULL END) etps5, 
               MAX(CASE WHEN phv = &&phv_06_awr. THEN elapsed_time_per_snap ELSE NULL END) etps6, 
               MAX(CASE WHEN phv = &&phv_07_awr. THEN elapsed_time_per_snap ELSE NULL END) etps7, 
               MAX(CASE WHEN phv = &&phv_08_awr. THEN elapsed_time_per_snap ELSE NULL END) etps8, 
               MAX(CASE WHEN phv = &&phv_09_awr. THEN elapsed_time_per_snap ELSE NULL END) etps9, 
               MAX(CASE WHEN phv = &&phv_10_awr. THEN elapsed_time_per_snap ELSE NULL END) etps10, 
               MAX(CASE WHEN phv = &&phv_11_awr. THEN elapsed_time_per_snap ELSE NULL END) etps11, 
               MAX(CASE WHEN phv = &&phv_12_awr. THEN elapsed_time_per_snap ELSE NULL END) etps12, 
               MAX(CASE WHEN phv = &&phv_13_awr. THEN elapsed_time_per_snap ELSE NULL END) etps13, 
               MAX(CASE WHEN phv = &&phv_14_awr. THEN elapsed_time_per_snap ELSE NULL END) etps14, 
               MAX(CASE WHEN phv = &&phv_15_awr. THEN elapsed_time_per_snap ELSE NULL END) etps15,
               MAX(CASE WHEN phv = &&phv_01_awr. THEN execs_per_snap ELSE NULL END) eps1,
               MAX(CASE WHEN phv = &&phv_02_awr. THEN execs_per_snap ELSE NULL END) eps2, 
               MAX(CASE WHEN phv = &&phv_03_awr. THEN execs_per_snap ELSE NULL END) eps3, 
               MAX(CASE WHEN phv = &&phv_04_awr. THEN execs_per_snap ELSE NULL END) eps4, 
               MAX(CASE WHEN phv = &&phv_05_awr. THEN execs_per_snap ELSE NULL END) eps5, 
               MAX(CASE WHEN phv = &&phv_06_awr. THEN execs_per_snap ELSE NULL END) eps6, 
               MAX(CASE WHEN phv = &&phv_07_awr. THEN execs_per_snap ELSE NULL END) eps7, 
               MAX(CASE WHEN phv = &&phv_08_awr. THEN execs_per_snap ELSE NULL END) eps8, 
               MAX(CASE WHEN phv = &&phv_09_awr. THEN execs_per_snap ELSE NULL END) eps9, 
               MAX(CASE WHEN phv = &&phv_10_awr. THEN execs_per_snap ELSE NULL END) eps10, 
               MAX(CASE WHEN phv = &&phv_11_awr. THEN execs_per_snap ELSE NULL END) eps11, 
               MAX(CASE WHEN phv = &&phv_12_awr. THEN execs_per_snap ELSE NULL END) eps12, 
               MAX(CASE WHEN phv = &&phv_13_awr. THEN execs_per_snap ELSE NULL END) eps13, 
               MAX(CASE WHEN phv = &&phv_14_awr. THEN execs_per_snap ELSE NULL END) eps14, 
               MAX(CASE WHEN phv = &&phv_15_awr. THEN execs_per_snap ELSE NULL END) eps15
          FROM (SELECT snap_id,
                       plan_hash_value phv, 
                       SUM(elapsed_time_delta) elapsed_time_per_snap,
                       SUM(executions_delta) execs_per_snap
                  FROM dba_hist_sqlstat
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                   AND sql_id = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                   AND instance_number = @instance_number@
                   AND plan_hash_value IN (&&phv_01_awr.,&&phv_02_awr.,&&phv_03_awr.,&&phv_04_awr.,&&phv_05_awr.,&&phv_06_awr.,
                                           &&phv_07_awr.,&&phv_08_awr.,&&phv_09_awr.,&&phv_10_awr.,&&phv_11_awr.,&&phv_12_awr.,
                                           &&phv_13_awr.,&&phv_14_awr.,&&phv_15_awr.)
                 GROUP BY snap_id, plan_hash_value)
          GROUP BY snap_id) awr, 
         dba_hist_snapshot b
 WHERE awr.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Elapsed Time/Execution per PHV (moving 1d) from AWR for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';

-----------------------------
-----------------------------


DEF main_table = 'DBA_HIST_SQLSTAT';
DEF abstract = 'Average buffer gets per row per execution per Plan Hash Value from AWR, top best 5 and worst 10';
DEF foot = 'Low number of executions or long executing SQL make values less accurate';
DEF vaxis = 'Buffer gets';

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

DEF tit_01 = '&&tit_01_awr.'
DEF tit_02 = '&&tit_02_awr.'
DEF tit_03 = '&&tit_03_awr.'
DEF tit_04 = '&&tit_04_awr.'
DEF tit_05 = '&&tit_05_awr.'
DEF tit_06 = '&&tit_06_awr.'
DEF tit_07 = '&&tit_07_awr.'
DEF tit_08 = '&&tit_08_awr.'
DEF tit_09 = '&&tit_09_awr.'
DEF tit_10 = '&&tit_10_awr.'
DEF tit_11 = '&&tit_11_awr.'
DEF tit_12 = '&&tit_12_awr.'
DEF tit_13 = '&&tit_13_awr.'
DEF tit_14 = '&&tit_14_awr.'
DEF tit_15 = '&&tit_15_awr.'

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(phv1 ,0) phv1_&&tit_01.  ,
       NVL(phv2 ,0) phv2_&&tit_02.  ,
       NVL(phv3 ,0) phv3_&&tit_03.  ,
       NVL(phv4 ,0) phv4_&&tit_04.  ,
       NVL(phv5 ,0) phv5_&&tit_05.  ,
       NVL(phv6 ,0) phv6_&&tit_06.  ,
       NVL(phv7 ,0) phv7_&&tit_07.  ,
       NVL(phv8 ,0) phv8_&&tit_08.  ,
       NVL(phv9 ,0) phv9_&&tit_09.  ,
       NVL(phv10,0) phv10_&&tit_10. ,
       NVL(phv11,0) phv11_&&tit_11. ,
       NVL(phv12,0) phv12_&&tit_12. ,
       NVL(phv13,0) phv13_&&tit_13. ,
       NVL(phv14,0) phv14_&&tit_14. ,
       NVL(phv15,0) phv15_&&tit_15. 
  FROM (SELECT snap_id,
               MAX(CASE WHEN phv = &&phv_01_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv1,
               MAX(CASE WHEN phv = &&phv_02_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv2, 
               MAX(CASE WHEN phv = &&phv_03_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv3, 
               MAX(CASE WHEN phv = &&phv_04_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv4, 
               MAX(CASE WHEN phv = &&phv_05_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv5, 
               MAX(CASE WHEN phv = &&phv_06_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv6, 
               MAX(CASE WHEN phv = &&phv_07_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv7, 
               MAX(CASE WHEN phv = &&phv_08_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv8, 
               MAX(CASE WHEN phv = &&phv_09_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv9, 
               MAX(CASE WHEN phv = &&phv_10_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv10, 
               MAX(CASE WHEN phv = &&phv_11_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv11, 
               MAX(CASE WHEN phv = &&phv_12_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv12, 
               MAX(CASE WHEN phv = &&phv_13_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv13, 
               MAX(CASE WHEN phv = &&phv_14_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv14, 
               MAX(CASE WHEN phv = &&phv_15_awr. THEN avg_gets_per_row_per_exec ELSE NULL END) phv15 
          FROM (SELECT snap_id,
                       plan_hash_value phv, 
                       --TRUNC(SUM(buffer_gets_total)/SUM(NVL(NULLIF(rows_processed_total,0),1))/SUM(NVL(NULLIF(executions_total,0),1)),3) avg_gets_per_row_per_exec
                       TRUNC(SUM(buffer_gets_total) / SUM(NVL(NULLIF(executions_total,0),1)) / (SUM(NVL(NULLIF(rows_processed_total,0),1))/SUM(NVL(NULLIF(executions_total,0),1))),3) avg_gets_per_row_per_exec
                  FROM dba_hist_sqlstat
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                   AND sql_id = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                   AND instance_number = @instance_number@
                   AND plan_hash_value IN (&&phv_01_awr.,&&phv_02_awr.,&&phv_03_awr.,&&phv_04_awr.,&&phv_05_awr.,&&phv_06_awr.,
                                           &&phv_07_awr.,&&phv_08_awr.,&&phv_09_awr.,&&phv_10_awr.,&&phv_11_awr.,&&phv_12_awr.,
                                           &&phv_13_awr.,&&phv_14_awr.,&&phv_15_awr.)
                 GROUP BY snap_id, plan_hash_value)
          GROUP BY snap_id) awr, 
         dba_hist_snapshot b
 WHERE awr.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Avg Buffer Gets/Row/Execution per PHV from AWR for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';

-----------------------------
-----------------------------

DEF main_table = 'DBA_HIST_SQLSTAT';
DEF abstract = 'Execution Plan Cost per Plan Hash Value from AWR, top best 5 and worst 10';
DEF foot = 'ONLY USE THIS REPORT FOR PLAN STABILITY CHECKS!!!';
DEF vaxis = 'Optimizer cost';

COL phv1_ NOPRI
COL phv2_ NOPRI
COL phv3_ NOPRI
COL phv4_ NOPRI
COL phv5_ NOPRI
COL phv6_ NOPRI
COL phv7_ NOPRI
COL phv8_ NOPRI
COL phv9_ NOPRI
COL phv10_ NOPRI
COL phv11_ NOPRI
COL phv12_ NOPRI
COL phv13_ NOPRI
COL phv14_ NOPRI
COL phv15_ NOPRI

DEF tit_01 = '&&tit_01_awr.'
DEF tit_02 = '&&tit_02_awr.'
DEF tit_03 = '&&tit_03_awr.'
DEF tit_04 = '&&tit_04_awr.'
DEF tit_05 = '&&tit_05_awr.'
DEF tit_06 = '&&tit_06_awr.'
DEF tit_07 = '&&tit_07_awr.'
DEF tit_08 = '&&tit_08_awr.'
DEF tit_09 = '&&tit_09_awr.'
DEF tit_10 = '&&tit_10_awr.'
DEF tit_11 = '&&tit_11_awr.'
DEF tit_12 = '&&tit_12_awr.'
DEF tit_13 = '&&tit_13_awr.'
DEF tit_14 = '&&tit_14_awr.'
DEF tit_15 = '&&tit_15_awr.'

BEGIN
  :sql_text_backup := q'[
SELECT b.snap_id snap_id,
       TO_CHAR(b.begin_interval_time, 'YYYY-MM-DD HH24:MI')  begin_time, 
       TO_CHAR(b.end_interval_time, 'YYYY-MM-DD HH24:MI')  end_time,
       NVL(phv1 ,0) phv1_&&tit_01.  ,
       NVL(phv2 ,0) phv2_&&tit_02.  ,
       NVL(phv3 ,0) phv3_&&tit_03.  ,
       NVL(phv4 ,0) phv4_&&tit_04.  ,
       NVL(phv5 ,0) phv5_&&tit_05.  ,
       NVL(phv6 ,0) phv6_&&tit_06.  ,
       NVL(phv7 ,0) phv7_&&tit_07.  ,
       NVL(phv8 ,0) phv8_&&tit_08.  ,
       NVL(phv9 ,0) phv9_&&tit_09.  ,
       NVL(phv10,0) phv10_&&tit_10. ,
       NVL(phv11,0) phv11_&&tit_11. ,
       NVL(phv12,0) phv12_&&tit_12. ,
       NVL(phv13,0) phv13_&&tit_13. ,
       NVL(phv14,0) phv14_&&tit_14. ,
       NVL(phv15,0) phv15_&&tit_15. 
  FROM (SELECT snap_id,
               MAX(CASE WHEN phv = &&phv_01_awr. THEN optimizer_cost ELSE NULL END) phv1,
               MAX(CASE WHEN phv = &&phv_02_awr. THEN optimizer_cost ELSE NULL END) phv2, 
               MAX(CASE WHEN phv = &&phv_03_awr. THEN optimizer_cost ELSE NULL END) phv3, 
               MAX(CASE WHEN phv = &&phv_04_awr. THEN optimizer_cost ELSE NULL END) phv4, 
               MAX(CASE WHEN phv = &&phv_05_awr. THEN optimizer_cost ELSE NULL END) phv5, 
               MAX(CASE WHEN phv = &&phv_06_awr. THEN optimizer_cost ELSE NULL END) phv6, 
               MAX(CASE WHEN phv = &&phv_07_awr. THEN optimizer_cost ELSE NULL END) phv7, 
               MAX(CASE WHEN phv = &&phv_08_awr. THEN optimizer_cost ELSE NULL END) phv8, 
               MAX(CASE WHEN phv = &&phv_09_awr. THEN optimizer_cost ELSE NULL END) phv9, 
               MAX(CASE WHEN phv = &&phv_10_awr. THEN optimizer_cost ELSE NULL END) phv10, 
               MAX(CASE WHEN phv = &&phv_11_awr. THEN optimizer_cost ELSE NULL END) phv11, 
               MAX(CASE WHEN phv = &&phv_12_awr. THEN optimizer_cost ELSE NULL END) phv12, 
               MAX(CASE WHEN phv = &&phv_13_awr. THEN optimizer_cost ELSE NULL END) phv13, 
               MAX(CASE WHEN phv = &&phv_14_awr. THEN optimizer_cost ELSE NULL END) phv14, 
               MAX(CASE WHEN phv = &&phv_15_awr. THEN optimizer_cost ELSE NULL END) phv15 
          FROM (SELECT snap_id,
                       plan_hash_value phv, 
                       MEDIAN(optimizer_cost) optimizer_cost
                  FROM dba_hist_sqlstat
                 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                   AND sql_id = '&&sqld360_sqlid.'
                   AND '&&diagnostics_pack.' = 'Y'
                   AND instance_number = @instance_number@
                   AND plan_hash_value IN (&&phv_01_awr.,&&phv_02_awr.,&&phv_03_awr.,&&phv_04_awr.,&&phv_05_awr.,&&phv_06_awr.,
                                           &&phv_07_awr.,&&phv_08_awr.,&&phv_09_awr.,&&phv_10_awr.,&&phv_11_awr.,&&phv_12_awr.,
                                           &&phv_13_awr.,&&phv_14_awr.,&&phv_15_awr.)
                 GROUP BY snap_id, plan_hash_value)
          GROUP BY snap_id) awr, 
         dba_hist_snapshot b
 WHERE awr.snap_id(+) = b.snap_id
   AND b.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
 ORDER BY 3
]';
END;
/

DEF chartype = 'LineChart';
DEF stacked = '';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Execution Plan Cost per PHV from AWR for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Execution Plan Cost per PHV from AWR for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Execution Plan Cost per PHV from AWR for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Execution Plan Cost per PHV from AWR for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Execution Plan Cost per PHV from AWR for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Execution Plan Cost per PHV from AWR for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Execution Plan Cost per PHV from AWR for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Execution Plan Cost per PHV from AWR for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Execution Plan Cost per PHV from AWR for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.sqld360_9a_pre_one.sql

COL phv1_ PRI
COL phv2_ PRI
COL phv3_ PRI
COL phv4_ PRI
COL phv5_ PRI
COL phv6_ PRI
COL phv7_ PRI
COL phv8_ PRI
COL phv9_ PRI
COL phv10_ PRI
COL phv11_ PRI
COL phv12_ PRI
COL phv13_ PRI
COL phv14_ PRI
COL phv15_ PRI

DEF skip_lch = 'Y';

---------------------------

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;
