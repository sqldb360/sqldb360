@@&&edb360_0g.tkprof.sql
DEF section_id = '4j';
DEF section_name = 'Parallel Execution';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'DOP Limit Method';
DEF main_table = '&&v_view_prefix.PARALLEL_DEGREE_LIMIT_MTH';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
    FROM &&v_object_prefix.parallel_degree_limit_mth
]';
END;
/
@@edb360_9a_pre_one.sql

&&gv_object_prefix.px_buffer_advice

DEF title = 'PX Buffer Advice';
DEF main_table = '&&gv_view_prefix.PX_BUFFER_ADVICE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.px_buffer_advice
 ORDER BY 1, 2
]';
END;
/
@@&&edb360_skip_px_mem.edb360_9a_pre_one.sql

DEF title = 'PQ System Stats';
DEF main_table = '&&gv_view_prefix.PQ_SYSSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.pq_sysstat
 ORDER BY 1, 2
]';
END;
/
@@&&edb360_skip_px_mem.edb360_9a_pre_one.sql

DEF title = 'PX Process System Stats';
DEF main_table = '&&gv_view_prefix.PX_PROCESS_SYSSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.px_process_sysstat
 ORDER BY 1, 2
]';
END;
/
@@&&edb360_skip_px_mem.edb360_9a_pre_one.sql

DEF title = 'System Stats';
DEF main_table = '&&gv_view_prefix.&&CDB_AWR_CON_OPTION.SYSSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.&&cdb_awr_con_option.sysstat
 ORDER BY 1, UPPER(name)
]';
END;
/
@@&&edb360_skip_stat_mem.edb360_9a_pre_one.sql

DEF title = 'PQ Slave';
DEF main_table = '&&gv_view_prefix.PQ_SLAVE';
BEGIN
  :sql_text := q'[
SELECT * FROM &&gv_object_prefix.pq_slave ORDER BY 1, 2
]';
END;
/
@@&&edb360_skip_px_mem.edb360_9a_pre_one.sql

DEF title = 'PX Sessions';
DEF main_table = '&&gv_view_prefix.PX_SESSION';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       pxs.inst_id,
       pxs.qcsid,
       NVL(pxp.server_name, 'QC') server_name,
       pxs.sid,
       pxs.serial#,
       NVL(pxp.pid, pro.pid) pid,
       NVL(pxp.spid, pro.spid) spid,
       pxs.server_group,
       pxs.server_set,
       pxs.server#,
       pxs.degree,
       pxs.req_degree,
       swt.event,
       ses.sql_id,
       ses.sql_child_number,
       ses.resource_consumer_group,
       ses.module,
       ses.action
  FROM &&gv_object_prefix.px_session pxs,
       &&gv_object_prefix.px_process pxp,
       &&gv_object_prefix.session ses,
       &&gv_object_prefix.process pro,
       &&gv_object_prefix.session_wait swt
 WHERE pxp.inst_id(+) = pxs.inst_id
   AND pxp.sid(+) = pxs.sid
   AND pxp.serial#(+) = pxs.serial#
   AND ses.inst_id(+) = pxs.inst_id
   AND ses.sid(+) = pxs.sid
   AND ses.serial#(+) = pxs.serial#
   AND ses.saddr(+) = pxs.saddr
   AND pro.inst_id(+) = ses.inst_id
   AND pro.addr(+) = ses.paddr
   AND swt.inst_id(+) = ses.inst_id
   AND swt.sid(+) = ses.sid
 ORDER BY
       pxs.inst_id,
       pxs.qcsid,
       pxs.qcserial# NULLS FIRST,
       pxp.server_name NULLS FIRST
]';
END;
/
@@&&edb360_skip_px_mem.edb360_9a_pre_one.sql

DEF title = 'PX Sessions Stats';
DEF main_table = '&&gv_view_prefix.PX_SESSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.*,
       n.name
  FROM &&gv_object_prefix.px_sesstat s,
       &&gv_object_prefix.&&cdb_awr_con_option.sysstat n
 WHERE s.value > 0
   AND n.inst_id = s.inst_id
   AND n.statistic# = s.statistic#
 ORDER BY s.inst_id, s.qcsid NULLS FIRST, s.sid
]';
END;
/
@@&&edb360_skip_px_mem.edb360_9a_pre_one.sql

DEF title = 'PX Processes';
DEF main_table = '&&gv_view_prefix.PX_PROCESS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.px_process
 ORDER BY 1, 2
]';
END;
/
@@&&edb360_skip_px_mem.edb360_9a_pre_one.sql

DEF title = 'Services';
DEF main_table = '&&gv_view_prefix.SERVICES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.services
 ORDER BY 1, 2
]';
END;
/
@@edb360_9a_pre_one.sql
DEF title = 'IO Last Calibration Results';
DEF main_table = '&&cdb_view_prefix.RSRC_IO_CALIBRATE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&cdb_object_prefix.rsrc_io_calibrate
 ORDER BY
       1, 2
]';
END;
/
@@&&skip_ver_le_10.edb360_9a_pre_one.sql

DEF title = 'Parallel Parameters';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
-- inspired on parmsd.sql (Kerry Osborne)
select name, description, value, isdefault, ismodified, isset
from
(
select flag,name,value,isdefault,ismodified,
case when isdefault||ismodified = 'TRUEFALSE' then 'FALSE' else 'TRUE' end isset ,
description
from
   (
       select
            decode(substr(i.ksppinm,1,1),'_',2,1) flag
            , i.ksppinm name
            , sv.ksppstvl value
            , sv.ksppstdf  isdefault
--            , decode(bitand(sv.ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE') ismodified
            , decode(bitand(sv.ksppstvf,7),1,'TRUE',4,'TRUE','FALSE') ismodified
, i.KSPPDESC description
         from sys.x$ksppi  i
            , sys.x$ksppsv sv
        where i.indx = sv.indx
   )
)
where name like nvl('%parallel%',name)
and flag != 3
order by flag,replace(name,'_','')
]';
END;
/
@@edb360_9a_pre_one.sql


DEF main_table = '&&cdb_awr_hist_prefix.&&CDB_AWR_CON_OPTION.SYSSTAT';
DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';

BEGIN
  :sql_text_backup := q'[
WITH
selected_stat_name AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       (s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) startup_time_interval,
       h.stat_name,
       (h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) value
       --h.value
  FROM &&cdb_awr_hist_prefix.&&cdb_awr_con_option.sysstat h,
       &&cdb_awr_hist_prefix.snapshot s
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN ('@stat_name_01@', '@stat_name_02@', '@stat_name_03@', '@stat_name_04@', '@stat_name_05@', '@stat_name_06@', '@stat_name_07@', '@stat_name_08@', '@stat_name_09@', '@stat_name_10@', '@stat_name_11@', '@stat_name_12@', '@stat_name_13@', '@stat_name_14@', '@stat_name_15@')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
stat_name_per_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       stat_name,
       SUM(value) value
  FROM selected_stat_name
 WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
   AND value >= 0
 GROUP BY
       snap_id,
       stat_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE stat_name WHEN '@stat_name_01@' THEN value ELSE 0 END) dummy_01,
       SUM(CASE stat_name WHEN '@stat_name_02@' THEN value ELSE 0 END) dummy_02,
       SUM(CASE stat_name WHEN '@stat_name_03@' THEN value ELSE 0 END) dummy_03,
       SUM(CASE stat_name WHEN '@stat_name_04@' THEN value ELSE 0 END) dummy_04,
       SUM(CASE stat_name WHEN '@stat_name_05@' THEN value ELSE 0 END) dummy_05,
       SUM(CASE stat_name WHEN '@stat_name_06@' THEN value ELSE 0 END) dummy_06,
       SUM(CASE stat_name WHEN '@stat_name_07@' THEN value ELSE 0 END) dummy_07,
       SUM(CASE stat_name WHEN '@stat_name_08@' THEN value ELSE 0 END) dummy_08,
       SUM(CASE stat_name WHEN '@stat_name_09@' THEN value ELSE 0 END) dummy_09,
       SUM(CASE stat_name WHEN '@stat_name_10@' THEN value ELSE 0 END) dummy_10,
       SUM(CASE stat_name WHEN '@stat_name_11@' THEN value ELSE 0 END) dummy_11,
       SUM(CASE stat_name WHEN '@stat_name_12@' THEN value ELSE 0 END) dummy_12,
       SUM(CASE stat_name WHEN '@stat_name_13@' THEN value ELSE 0 END) dummy_13,
       SUM(CASE stat_name WHEN '@stat_name_14@' THEN value ELSE 0 END) dummy_14,
       SUM(CASE stat_name WHEN '@stat_name_15@' THEN value ELSE 0 END) dummy_15
  FROM stat_name_per_snap
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'Parallel Operations';
DEF vaxis = 'Statements';
DEF tit_01 = 'queries parallelized';
DEF tit_02 = 'DML statements parallelized';
DEF tit_03 = 'DDL statements parallelized';
DEF tit_04 = 'Parallel operations not downgraded';
DEF tit_05 = 'Parallel operations downgraded to serial';
DEF tit_06 = 'Parallel operations downgraded 1 to 25 pct';
DEF tit_07 = 'Parallel operations downgraded 25 to 50 pct';
DEF tit_08 = 'Parallel operations downgraded 50 to 75 pct';
DEF tit_09 = 'Parallel operations downgraded 75 to 99 pct';
DEF tit_10 = 'DFO trees parallelized';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
EXEC :sql_text := REPLACE(:sql_text_backup, '@stat_name_01@', '&&tit_01.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_02@', '&&tit_02.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_03@', '&&tit_03.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_04@', '&&tit_04.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_05@', '&&tit_05.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_06@', '&&tit_06.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_07@', '&&tit_07.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_08@', '&&tit_08.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_09@', '&&tit_09.');
EXEC :sql_text := REPLACE(:sql_text, '@stat_name_10@', '&&tit_10.');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_04', '"'||SUBSTR('&&tit_04.',20,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_05', '"'||SUBSTR('&&tit_05.',20,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_06', '"'||SUBSTR('&&tit_06.',20,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_07', '"'||SUBSTR('&&tit_07.',20,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_08', '"'||SUBSTR('&&tit_08.',20,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_09', '"'||SUBSTR('&&tit_09.',20,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_10', '"'||SUBSTR('&&tit_10.',1,30)||'"');
@@edb360_9a_pre_one.sql


DEF main_table = '&&cdb_awr_hist_prefix.&&CDB_AWR_CON_OPTION.SYSSTAT';
DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';

BEGIN
  :sql_text_backup := q'[
WITH
selected_stat_name AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       (s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) startup_time_interval,
       h.stat_name,
       (h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id)) value
       --h.value
  FROM &&cdb_awr_hist_prefix.&&cdb_awr_con_option.sysstat h,
       &&cdb_awr_hist_prefix.snapshot s
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN ('queries parallelized','DML statements parallelized','DDL statements parallelized',
                        'Parallel operations not downgraded','Parallel operations downgraded to serial',
                        'Parallel operations downgraded 1 to 25 pct','Parallel operations downgraded 25 to 50 pct',
                        'Parallel operations downgraded 50 to 75 pct','Parallel operations downgraded 75 to 99 pct'
                        ,'DFO trees parallelized')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
),
stat_name_per_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       stat_name,
       SUM(value) value
  FROM selected_stat_name
 WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
   AND value >= 0
 GROUP BY
       snap_id,
       stat_name
), pxstats as (
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE stat_name WHEN 'queries parallelized' THEN value ELSE 0 END) queries_px,
       SUM(CASE stat_name WHEN 'DML statements parallelized' THEN value ELSE 0 END) dml_px,
       SUM(CASE stat_name WHEN 'DDL statements parallelized' THEN value ELSE 0 END) ddl_px,
       SUM(CASE  WHEN stat_name in  ('queries parallelized','DML statements parallelized','DDL statements parallelized') THEN value ELSE 0 END) sql_px_total,
       SUM(CASE stat_name WHEN 'Parallel operations not downgraded' THEN value ELSE 0 END) no_downgrade,
       SUM(CASE stat_name WHEN 'Parallel operations downgraded to serial' THEN value ELSE 0 END) PX_SERIAL,
       SUM(CASE stat_name WHEN 'Parallel operations downgraded 1 to 25 pct' THEN value ELSE 0 END) PX1_25,
       SUM(CASE stat_name WHEN 'Parallel operations downgraded 25 to 50 pct' THEN value ELSE 0 END) PX25_50,
       SUM(CASE stat_name WHEN 'Parallel operations downgraded 50 to 75 pct' THEN value ELSE 0 END) PX50_75,
       SUM(CASE stat_name WHEN 'Parallel operations downgraded 75 to 99 pct' THEN value ELSE 0 END) PX77_99,
        SUM(CASE stat_name WHEN 'DFO trees parallelized' THEN value ELSE 0 END) DFO,
       SUM(CASE  WHEN stat_name like 'Parallel operations downgraded %' THEN value ELSE 0 END) total_downgrade,
       SUM(CASE  WHEN stat_name like 'Parallel operations downgraded % pct' THEN value ELSE 0 END) parcial_downgrade,
       SUM(CASE  WHEN stat_name in  ('queries parallelized','DML statements parallelized','DDL statements parallelized')
                 OR stat_name = 'Parallel operations downgraded to serial'
                        THEN value ELSE 0 END) TOTAL_SQL
  FROM stat_name_per_snap
 GROUP BY
       snap_id)
SELECT  snap_id
        ,begin_time
        ,end_time
        ,100*round(parcial_downgrade/decode(total_sql,0,1,total_sql),2) dummy_01
        ,100*round(no_downgrade/decode(total_sql,0,1,total_sql),2) dummy_02
        ,100*round(px_serial/decode(total_sql,0,1,total_sql),2) dummy_03
       ,0 dummy_04
       ,0 dummy_05
       ,0 dummy_06
       ,0 dummy_07
       ,0 dummy_08
       ,0 dummy_09
       ,0 dummy_10
       ,0 dummy_11
       ,0 dummy_12
       ,0 dummy_13
       ,0 dummy_14
       ,0 dummy_15
from pxstats
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'Parallel Downgrade Perc';
DEF vaxis = 'Statements';
DEF tit_01 = 'Perc PX Partial Downgrade';
DEF tit_02 = 'Perc PX No Downgrade';
DEF tit_03 = 'Perc Serial';
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
EXEC :sql_text := REPLACE(:sql_text_backup, 'dummy_01', '"'||SUBSTR('&&tit_01.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_02', '"'||SUBSTR('&&tit_02.',1,30)||'"');
EXEC :sql_text := REPLACE(:sql_text, 'dummy_03', '"'||SUBSTR('&&tit_03.',1,30)||'"');
@@edb360_9a_pre_one.sql

DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Parallel Max Servers Time Series';
DEF main_table = '&&cdb_awr_hist_prefix.RESOURCE_LIMIT';
DEF vaxis = 'Parallel max servers';
DEF tit_01 = 'Current Utilization';
DEF tit_02 = 'Max Utilization';
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

EXEC :sql_text := REPLACE(:sql_text_backup, '@resource_name@', 'parallel_max_servers');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

BEGIN
 :sql_text := q'[
WITH
max_resource_limit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name,
       MAX(r.current_utilization) current_utilization
  FROM &&cdb_awr_hist_prefix.resource_limit r,
       &&cdb_awr_hist_prefix.snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name IN ('sessions', 'processes', 'parallel_max_servers')
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE resource_name WHEN 'sessions'             THEN current_utilization ELSE 0 END) sessions,
       SUM(CASE resource_name WHEN 'processes'            THEN current_utilization ELSE 0 END) processes,
       SUM(CASE resource_name WHEN 'parallel_max_servers' THEN current_utilization ELSE 0 END) parallel_max_servers,
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
  FROM max_resource_limit
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions, Processes and Parallel Servers - Time Series1';
DEF main_table = '&&cdb_awr_hist_prefix.RESOURCE_LIMIT';
DEF vaxis = 'Count';
DEF tit_01 = 'Sessions';
DEF tit_02 = 'Processes';
DEF tit_03 = 'Parallel Max Servers';
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

@@&&skip_diagnostics.edb360_9a_pre_one.sql

BEGIN
 :sql_text := q'[
WITH
max_resource_limit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.instance_number,
       CAST(s.begin_interval_time AS DATE) begin_time,
       CAST(s.end_interval_time AS DATE) end_time,
       r.resource_name metric_name,
       MAX(r.current_utilization) value
  FROM &&cdb_awr_hist_prefix.resource_limit r,
       &&cdb_awr_hist_prefix.snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name IN ('sessions', 'processes', 'parallel_max_servers')
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name
),
max_sysmetric_summary AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       begin_time,
       end_time,
       metric_name,
       ROUND(maxval, 3) value
  FROM &&edb360_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = &&edb360_sysmetric_group. /* 1 minute intervals */
   AND metric_name IN ('Active Serial Sessions', 'Active Parallel Sessions')
   AND maxval >= 0
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE metric_name WHEN 'sessions'                 THEN value ELSE 0 END) sessions,
       SUM(CASE metric_name WHEN 'processes'                THEN value ELSE 0 END) processes,
       SUM(CASE metric_name WHEN 'parallel_max_servers'     THEN value ELSE 0 END) max_parallel_servers,
       SUM(CASE metric_name WHEN 'Active Serial Sessions'   THEN value ELSE 0 END) max_active_serial_sessions,
       SUM(CASE metric_name WHEN 'Active Parallel Sessions' THEN value ELSE 0 END) max_active_parallel_sessions,
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
  FROM (SELECT * FROM max_resource_limit UNION ALL SELECT * FROM max_sysmetric_summary)
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions, Processes and Parallel Servers - Time Series2';
DEF main_table = '&&cdb_awr_hist_prefix.RESOURCE_LIMIT';
DEF vaxis = 'Count';
DEF tit_01 = 'Sessions';
DEF tit_02 = 'Processes';
DEF tit_03 = 'Max Parallel Servers';
DEF tit_04 = 'Max Active Serial Sessions';
DEF tit_05 = 'Max Active Parallel Sessions';
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

@@&&skip_diagnostics.edb360_9a_pre_one.sql

BEGIN
 :sql_text := q'[
WITH
max_resource_limit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.instance_number,
       CAST(s.begin_interval_time AS DATE) begin_time,
       CAST(s.end_interval_time AS DATE) end_time,
       r.resource_name metric_name,
       MAX(r.current_utilization) value
  FROM &&cdb_awr_hist_prefix.resource_limit r,
       &&cdb_awr_hist_prefix.snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name IN ('sessions', 'processes', 'parallel_max_servers')
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name
),
max_sysmetric_summary AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       begin_time,
       end_time,
       metric_name,
       ROUND(maxval, 3) value
  FROM &&edb360_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = &&edb360_sysmetric_group. /* 1 minute intervals */
   AND metric_name IN ('Active Serial Sessions',
                       'Active Parallel Sessions',
                       'PQ QC Session Count',
                       'PQ Slave Session Count',
                       'Average Active Sessions',
                       'Session Count')
   AND maxval >= 0
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE metric_name WHEN 'sessions'                 THEN value ELSE 0 END) sessions,
       SUM(CASE metric_name WHEN 'processes'                THEN value ELSE 0 END) processes,
       SUM(CASE metric_name WHEN 'parallel_max_servers'     THEN value ELSE 0 END) max_parallel_servers,
       SUM(CASE metric_name WHEN 'Active Serial Sessions'   THEN value ELSE 0 END) max_active_serial_sessions,
       SUM(CASE metric_name WHEN 'Active Parallel Sessions' THEN value ELSE 0 END) max_active_parallel_sessions,
       SUM(CASE metric_name WHEN 'PQ QC Session Count'      THEN value ELSE 0 END) max_pq_qc_session_count,
       SUM(CASE metric_name WHEN 'PQ Slave Session Count'   THEN value ELSE 0 END) max_pq_slave_session_count,
       SUM(CASE metric_name WHEN 'Average Active Sessions'  THEN value ELSE 0 END) max_average_active_sessions,
       SUM(CASE metric_name WHEN 'Session Count'            THEN value ELSE 0 END) max_session_count,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT * FROM max_resource_limit UNION ALL SELECT * FROM max_sysmetric_summary)
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions, Processes and Parallel Servers - Time Series3';
DEF main_table = '&&cdb_awr_hist_prefix.RESOURCE_LIMIT';
DEF vaxis = 'Count';
DEF tit_01 = 'Sessions';
DEF tit_02 = 'Processes';
DEF tit_03 = 'Max Parallel Servers';
DEF tit_04 = 'Max Active Serial Sessions';
DEF tit_05 = 'Max Active Parallel Sessions';
DEF tit_06 = 'Max PQ QC Session Count';
DEF tit_07 = 'Max PQ Slave Session Count';
DEF tit_08 = 'Max Average Active Sessions';
DEF tit_09 = 'Max Session Count';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

@@&&skip_diagnostics.edb360_9a_pre_one.sql

BEGIN
 :sql_text := q'[
WITH
max_resource_limit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       1 branch,
       r.snap_id,
       r.instance_number,
       CAST(s.begin_interval_time AS DATE) begin_time,
       CAST(s.end_interval_time AS DATE) end_time,
       r.resource_name metric_name,
       MAX(r.current_utilization) value
  FROM &&cdb_awr_hist_prefix.resource_limit r,
       &&cdb_awr_hist_prefix.snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name IN ('sessions', 'processes', 'parallel_max_servers')
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name
),
max_sysmetric_summary AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       2 branch,
       snap_id,
       instance_number,
       begin_time,
       end_time,
       metric_name,
       ROUND(maxval, 3) value
  FROM &&edb360_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = &&edb360_sysmetric_group. /* 1 minute intervals */
   AND metric_name IN ('Active Serial Sessions',
                       'Active Parallel Sessions',
                       'PQ QC Session Count',
                       'PQ Slave Session Count',
                       'Average Active Sessions',
                       'Session Count')
   AND maxval >= 0
),
avg_sysmetric_summary AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       3 branch,
       snap_id,
       instance_number,
       begin_time,
       end_time,
       metric_name,
       ROUND(average, 3) value
  FROM &&edb360_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = &&edb360_sysmetric_group. /* 1 minute intervals */
   AND metric_name IN ('Active Serial Sessions',
                       'Active Parallel Sessions',
                       'PQ QC Session Count',
                       'PQ Slave Session Count',
                       'Average Active Sessions',
                       'Session Count')
   AND average >= 0
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(CASE branch WHEN 1 THEN (CASE metric_name WHEN 'sessions'                 THEN value ELSE 0 END) ELSE 0 END) sessions,
       SUM(CASE branch WHEN 1 THEN (CASE metric_name WHEN 'processes'                THEN value ELSE 0 END) ELSE 0 END) processes,
       SUM(CASE branch WHEN 1 THEN (CASE metric_name WHEN 'parallel_max_servers'     THEN value ELSE 0 END) ELSE 0 END) max_parallel_servers,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN 'Active Serial Sessions'   THEN value ELSE 0 END) ELSE 0 END) max_active_serial_sessions,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN 'Active Parallel Sessions' THEN value ELSE 0 END) ELSE 0 END) max_active_parallel_sessions,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN 'PQ QC Session Count'      THEN value ELSE 0 END) ELSE 0 END) max_pq_qc_session_count,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN 'PQ Slave Session Count'   THEN value ELSE 0 END) ELSE 0 END) max_pq_slave_session_count,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN 'Average Active Sessions'  THEN value ELSE 0 END) ELSE 0 END) max_average_active_sessions,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN 'Session Count'            THEN value ELSE 0 END) ELSE 0 END) max_session_count,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN 'Active Serial Sessions'   THEN value ELSE 0 END) ELSE 0 END) avg_active_serial_sessions,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN 'Active Parallel Sessions' THEN value ELSE 0 END) ELSE 0 END) avg_active_parallel_sessions,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN 'PQ QC Session Count'      THEN value ELSE 0 END) ELSE 0 END) avg_pq_qc_session_count,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN 'PQ Slave Session Count'   THEN value ELSE 0 END) ELSE 0 END) avg_pq_slave_session_count,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN 'Average Active Sessions'  THEN value ELSE 0 END) ELSE 0 END) avg_average_active_sessions,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN 'Session Count'            THEN value ELSE 0 END) ELSE 0 END) avg_session_count
  FROM (SELECT * FROM max_resource_limit UNION ALL SELECT * FROM max_sysmetric_summary UNION ALL SELECT * FROM avg_sysmetric_summary)
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions, Processes and Parallel Servers - Time Series4';
DEF main_table = '&&cdb_awr_hist_prefix.RESOURCE_LIMIT';
DEF vaxis = 'Count';
DEF tit_01 = 'Sessions';
DEF tit_02 = 'Processes';
DEF tit_03 = 'Max Parallel Servers';
DEF tit_04 = 'Max Active Serial Sessions';
DEF tit_05 = 'Max Active Parallel Sessions';
DEF tit_06 = 'Max PQ QC Session Count';
DEF tit_07 = 'Max PQ Slave Session Count';
DEF tit_08 = 'Max Average Active Sessions';
DEF tit_09 = 'Max Session Count';
DEF tit_10 = 'Avg Active Serial Sessions';
DEF tit_11 = 'Avg Active Parallel Sessions';
DEF tit_12 = 'Avg PQ QC Session Count';
DEF tit_13 = 'Avg PQ Slave Session Count';
DEF tit_14 = 'Avg Average Active Sessions';
DEF tit_15 = 'Avg Session Count';

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF main_table = '&&edb360_SYSMETRIC_SUMMARY';
DEF chartype = 'LineChart';
DEF vbaseline = '';
DEF stacked = '';
DEF tit_01 = 'Max Value';
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

BEGIN
  :sql_text_backup := q'[
WITH
per_instance AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       begin_time,
       end_time,
       maxval
  FROM &&edb360_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = &&edb360_sysmetric_group. /* 1 minute intervals */
   AND metric_name = '@metric_name@'
   AND maxval >= 0
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(maxval), 1) "Max Value",
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
  FROM per_instance
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF title = 'Active Parallel Sessions';
DEF vaxis = 'Sessions';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'PX downgraded 1 to 25% Per Sec';
DEF vaxis = 'PX Operations Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'PX downgraded 25 to 50% Per Sec';
DEF vaxis = 'PX Operations Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'PX downgraded 50 to 75% Per Sec';
DEF vaxis = 'PX Operations Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'PX downgraded 75 to 99% Per Sec';
DEF vaxis = 'PX Operations Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'PX downgraded to serial Per Sec';
DEF vaxis = 'PX Operations Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'PX operations not downgraded Per Sec';
DEF vaxis = 'PX Operations Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'Queries parallelized Per Sec';
DEF vaxis = 'Queries Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'DML statements parallelized Per Sec';
DEF vaxis = 'DML Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'DDL statements parallelized Per Sec';
DEF vaxis = 'DDL Per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max value is within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
