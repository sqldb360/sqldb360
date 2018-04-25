@@&&edb360_0g.tkprof.sql
DEF section_id = '4d';
DEF section_name = 'System Time Model';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&awr_hist_prefix.SYS_TIME_MODEL';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Average Active Sessions (AAS)';
--DEF vbaseline = 'baseline:&&avg_cpu_count.,';
DEF vbaseline = '';
DEF tit_01 = 'background elapsed time';
DEF tit_02 = 'background cpu time';
DEF tit_03 = 'RMAN cpu time (backup/restore)';
DEF tit_04 = 'DB time';
DEF tit_05 = 'DB CPU';
DEF tit_06 = 'connection management call elapsed time';
DEF tit_07 = 'sequence load elapsed time';
DEF tit_08 = 'sql execute elapsed time';
DEF tit_09 = 'parse time elapsed';
DEF tit_10 = 'hard parse elapsed time';
DEF tit_11 = 'PL/SQL execution elapsed time';
DEF tit_12 = 'inbound PL/SQL rpc elapsed time';
DEF tit_13 = 'PL/SQL compilation elapsed time';
DEF tit_14 = 'Java execution elapsed time';
DEF tit_15 = 'repeated bind elapsed time';
COL background_time FOR 999990.0;
COL background_cpu FOR 999990.0;
COL rman_cpu FOR 999990.0;
COL db_time FOR 999990.0;
COL db_cpu FOR 999990.0;
COL connection_management_call FOR 999990.0;
COL sequence_load FOR 999990.0;
COL sql_execute FOR 999990.0;
COL parse_time FOR 999990.0;
COL hard_parse FOR 999990.0;
COL plsql_execution FOR 999990.0;
COL inbound_plsql_rpc FOR 999990.0;
COL plsql_compilation FOR 999990.0;
COL java_execution FOR 999990.0;
COL repeated_bind FOR 999990.0;
BEGIN
  :sql_text_backup := q'[
WITH
sys_time_model_denorm_2 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE stat_name WHEN 'background elapsed time' THEN value / 1e6 ELSE 0 END) background_time,
       SUM(CASE stat_name WHEN 'background cpu time'  THEN value / 1e6 ELSE 0 END) background_cpu,       
       SUM(CASE stat_name WHEN 'RMAN cpu time (backup/restore)' THEN value / 1e6 ELSE 0 END) rman_cpu,
       SUM(CASE stat_name WHEN 'DB time' THEN value / 1e6 ELSE 0 END) db_time,
       SUM(CASE stat_name WHEN 'DB CPU' THEN value / 1e6 ELSE 0 END) db_cpu,
       SUM(CASE stat_name WHEN 'connection management call elapsed time' THEN value / 1e6 ELSE 0 END) connection_management_call,
       SUM(CASE stat_name WHEN 'sequence load elapsed time' THEN value / 1e6 ELSE 0 END) sequence_load,
       SUM(CASE stat_name WHEN 'sql execute elapsed time' THEN value / 1e6 ELSE 0 END) sql_execute,
       SUM(CASE stat_name WHEN 'parse time elapsed' THEN value / 1e6 ELSE 0 END) parse_time,
       SUM(CASE stat_name WHEN 'hard parse elapsed time' THEN value / 1e6 ELSE 0 END) hard_parse,
       SUM(CASE stat_name WHEN 'PL/SQL execution elapsed time' THEN value / 1e6 ELSE 0 END) plsql_execution,
       SUM(CASE stat_name WHEN 'inbound PL/SQL rpc elapsed time' THEN value / 1e6 ELSE 0 END) inbound_plsql_rpc,
       SUM(CASE stat_name WHEN 'PL/SQL compilation elapsed time' THEN value / 1e6 ELSE 0 END) plsql_compilation,
       SUM(CASE stat_name WHEN 'Java execution elapsed time' THEN value / 1e6 ELSE 0 END) java_execution,
       SUM(CASE stat_name WHEN 'repeated bind elapsed time' THEN value / 1e6 ELSE 0 END) repeated_bind
  FROM &&awr_object_prefix.sys_time_model
 WHERE stat_name IN (
'background elapsed time',
'background cpu time',
'RMAN cpu time (backup/restore)',
'DB time',
'DB CPU',
'connection management call elapsed time',
'sequence load elapsed time',
'sql execute elapsed time',
'parse time elapsed',
'hard parse elapsed time',
'PL/SQL execution elapsed time',
'inbound PL/SQL rpc elapsed time',
'PL/SQL compilation elapsed time',
'Java execution elapsed time',
'repeated bind elapsed time'
)
   AND '&&diagnostics_pack.' = 'Y'
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
sys_time_model_denorm_3 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       s1.begin_interval_time,
       s1.end_interval_time,
       ROUND((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       (h1.background_time - h0.background_time) background_time,
       (h1.background_cpu - h0.background_cpu) background_cpu,
       (h1.rman_cpu - h0.rman_cpu) rman_cpu,
       (h1.db_time - h0.db_time) db_time,
       (h1.db_cpu - h0.db_cpu) db_cpu,
       (h1.connection_management_call - h0.connection_management_call) connection_management_call,
       (h1.sequence_load - h0.sequence_load) sequence_load,
       (h1.sql_execute - h0.sql_execute) sql_execute,
       (h1.parse_time - h0.parse_time) parse_time,
       (h1.hard_parse - h0.hard_parse) hard_parse,
       (h1.plsql_execution - h0.plsql_execution) plsql_execution,
       (h1.inbound_plsql_rpc - h0.inbound_plsql_rpc) inbound_plsql_rpc,
       (h1.plsql_compilation - h0.plsql_compilation) plsql_compilation,
       (h1.java_execution - h0.java_execution) java_execution,
       (h1.repeated_bind - h0.repeated_bind) repeated_bind
  FROM sys_time_model_denorm_2 h0,
       sys_time_model_denorm_2 h1,
       &&awr_object_prefix.snapshot s0,
       &&awr_object_prefix.snapshot s1
 WHERE h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.dbid = s0.dbid
   AND s1.instance_number = s0.instance_number
   AND s1.startup_time = s0.startup_time
   AND s1.begin_interval_time > (s0.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
   AND (h1.db_time - h0.db_time) > 0 /* eliminates occasional negative spikes */
),
sys_time_model_denorm_4 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(background_time / interval_secs), 3) background_time,
       ROUND(SUM(background_cpu / interval_secs), 3) background_cpu,
       ROUND(SUM(rman_cpu / interval_secs), 3) rman_cpu,
       ROUND(SUM(db_time / interval_secs), 3) db_time,
       ROUND(SUM(db_cpu / interval_secs), 3) db_cpu,
       ROUND(SUM(connection_management_call / interval_secs), 3) connection_management_call,
       ROUND(SUM(sequence_load / interval_secs), 3) sequence_load,
       ROUND(SUM(sql_execute / interval_secs), 3) sql_execute,
       ROUND(SUM(parse_time / interval_secs), 3) parse_time,
       ROUND(SUM(hard_parse / interval_secs), 3) hard_parse,
       ROUND(SUM(plsql_execution / interval_secs), 3) plsql_execution,
       ROUND(SUM(inbound_plsql_rpc / interval_secs), 3) inbound_plsql_rpc,
       ROUND(SUM(plsql_compilation / interval_secs), 3) plsql_compilation,
       ROUND(SUM(java_execution / interval_secs), 3) java_execution,
       ROUND(SUM(repeated_bind / interval_secs), 3) repeated_bind
  FROM sys_time_model_denorm_3
 GROUP BY
       snap_id
)
SELECT snap_id,
       begin_time,
       end_time,
       background_time,
       background_cpu,
       rman_cpu,
       db_time,
       db_cpu,
       connection_management_call,
       sequence_load,
       sql_execute,
       parse_time,
       hard_parse,
       plsql_execution,
       inbound_plsql_rpc,
       plsql_compilation,
       java_execution,
       repeated_bind
  FROM sys_time_model_denorm_4
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'System Time Model (STM) per Cluster';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'System Time Model (STM) for Instance 1';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'System Time Model (STM) for Instance 2';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'System Time Model (STM) for Instance 3';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'System Time Model (STM) for Instance 4';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'System Time Model (STM) for Instance 5';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'System Time Model (STM) for Instance 6';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'System Time Model (STM) for Instance 7';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'System Time Model (STM) for Instance 8';
DEF abstract = 'Average Active Sessions (AAS).<br />'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
