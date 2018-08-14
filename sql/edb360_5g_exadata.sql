@@&&edb360_0g.tkprof.sql
DEF section_id = '5g';
DEF section_name = 'Exadata';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'FTS with single-block reads';
DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := q'[
WITH
ash AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       current_obj#, COUNT(*) samples
  FROM &&awr_object_prefix.active_sess_history h
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND event = 'cell single block physical read'
   AND sql_plan_operation = 'TABLE ACCESS'
   AND sql_plan_options = 'STORAGE FULL'
 GROUP BY
       current_obj#
)
SELECT a.samples,
       a.current_obj#,
       CASE a.current_obj# WHEN 0 THEN 'SYS' ELSE o.owner END owner,
       CASE a.current_obj# WHEN 0 THEN 'UNDO' ELSE o.object_name END object_name,
       CASE a.current_obj# WHEN 0 THEN NULL ELSE o.subobject_name END subobject_name
  FROM ash a,
       &&dva_object_prefix.objects o
 WHERE o.object_id(+) = a.current_obj#
 ORDER BY
       a.samples DESC,
       a.current_obj#
]';
END;
/
@@&&skip_diagnostics.&&skip_10g_script.edb360_9a_pre_one.sql

COL db_time_secs HEA "DB Time|Secs";
COL io_time_secs HEA "IO Time|Secs";
COL u_io_secs HEA "User I/O|Secs";
COL dbfsr_secs HEA "db file|scattered read|Secs";
COL dpr_secs HEA "direct path read|Secs";
COL s_io_secs HEA "System I/O|Secs";
COL commt_secs HEA "Commit|Secs";
COL lfpw_secs HEA "log file|parallel write|Secs";
COL u_io_perc_dbt HEA "User I/O|Perc of|DB Time";
COL dbfsr_perc_dbt HEA "db file|scattered read|Perc of|DB Time";
COL dpr_perc_dbt HEA "direct path read|Perc of|DB Time";
COL s_io_perc_dbt HEA "System I/O|Perc of|DB Time";
COL commt_perc_dbt HEA "Commit|Perc of|DB Time";
COL lfpw_perc_dbt HEA "log file|parallel write|Perc of|DB Time";
COL u_io_perc_iot HEA "User I/O|Perc of|IO Time";
COL dbfsr_perc_iot HEA "db file|scattered read|Perc of|IO Time";
COL dpr_perc_iot HEA "direct path read|Perc of|IO Time";
COL s_io_perc_iot HEA "System I/O|Perc of|IO Time";
COL commt_perc_iot HEA "Commit|Perc of|IO Time";
COL lfpw_perc_iot HEA "log file|parallel write|Perc of|IO Time";

DEF title = 'Relevant I/O Time Composition';
DEF main_table = '&&awr_hist_prefix.SYSTEM_EVENT';
BEGIN
  :sql_text := q'[
-- requested by Frits Hoogland
WITH 
db_time AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       stat_name,
       value - LAG(value) OVER (PARTITION BY dbid, instance_number, stat_name ORDER BY snap_id) value
  FROM &&awr_object_prefix.sys_time_model
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND stat_name = 'DB time'
),
system_event_detail AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       wait_class,
       SUM(time_waited_micro) time_waited_micro
  FROM &&awr_object_prefix.system_event
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND wait_class IN ('User I/O', 'System I/O', 'Commit')
 GROUP BY
       snap_id,
       dbid,
       instance_number,
       wait_class
),
system_event AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       wait_class,
       time_waited_micro - LAG(time_waited_micro) OVER (PARTITION BY dbid, instance_number, wait_class ORDER BY snap_id) time_waited_micro
  FROM system_event_detail
),
system_wait AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       event_name,
       time_waited_micro - LAG(time_waited_micro) OVER (PARTITION BY dbid, instance_number, event_name ORDER BY snap_id) time_waited_micro
  FROM &&awr_object_prefix.system_event
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND event_name IN ('db file scattered read', 'direct path read', 'log file parallel write')
),
time_components AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       d.snap_id,
       d.dbid,
       d.instance_number,
       d.value db_time,
       e1.time_waited_micro u_io_time,
       e2.time_waited_micro s_io_time,
       e3.time_waited_micro commt_time,
       w1.time_waited_micro dbfsr_time,
       w2.time_waited_micro dpr_time,
       w3.time_waited_micro lfpw_time
  FROM db_time d,
       system_event e1,
       system_event e2,
       system_event e3,
       system_wait w1,
       system_wait w2,
       system_wait w3
 WHERE d.value >= 0
   AND e1.snap_id = d.snap_id
   AND e1.dbid = d.dbid
   AND e1.instance_number = d.instance_number
   AND e1.wait_class = 'User I/O'
   AND e1.time_waited_micro >= 0
   AND e2.snap_id = d.snap_id
   AND e2.dbid = d.dbid
   AND e2.instance_number = d.instance_number
   AND e2.wait_class = 'System I/O'
   AND e2.time_waited_micro >= 0
   AND e3.snap_id = d.snap_id
   AND e3.dbid = d.dbid
   AND e3.instance_number = d.instance_number
   AND e3.wait_class = 'Commit'
   AND e3.time_waited_micro >= 0
   AND w1.snap_id = d.snap_id
   AND w1.dbid = d.dbid
   AND w1.instance_number = d.instance_number
   AND w1.event_name = 'db file scattered read'
   AND w1.time_waited_micro >= 0
   AND w2.snap_id = d.snap_id
   AND w2.dbid = d.dbid
   AND w2.instance_number = d.instance_number
   AND w2.event_name = 'direct path read'
   AND w2.time_waited_micro >= 0
   AND w3.snap_id = d.snap_id
   AND w3.dbid = d.dbid
   AND w3.instance_number = d.instance_number
   AND w3.event_name = 'log file parallel write'
   AND w3.time_waited_micro >= 0
),
by_inst_and_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       t.snap_id,
       t.instance_number,
       --s.begin_interval_time,
       --s.end_interval_time,
       --ROUND((CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       SUM(db_time) db_time,
       SUM(u_io_time) u_io_time,
       SUM(dbfsr_time) dbfsr_time,
       SUM(dpr_time) dpr_time,
       SUM(s_io_time) s_io_time,
       SUM(commt_time) commt_time,
       SUM(lfpw_time) lfpw_time
  FROM time_components t,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id = t.snap_id
   AND s.dbid = t.dbid
   AND s.instance_number = t.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
 GROUP BY
       t.snap_id,
       t.instance_number,
       s.begin_interval_time,
       s.end_interval_time
),
by_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       --MIN(begin_interval_time) begin_interval_time,
       --MIN(end_interval_time) end_interval_time,
       --ROUND((CAST(MIN(end_interval_time) AS DATE) - CAST(MIN(begin_interval_time) AS DATE)) * 24 * 60 * 60) interval_secs,
       NVL(SUM(db_time), 0) db_time,
       NVL(SUM(u_io_time), 0) u_io_time,
       NVL(SUM(dbfsr_time), 0) dbfsr_time,
       NVL(SUM(dpr_time), 0) dpr_time,
       NVL(SUM(s_io_time), 0) s_io_time,
       NVL(SUM(commt_time), 0) commt_time,
       NVL(SUM(lfpw_time), 0) lfpw_time,
       NVL(SUM(u_io_time), 0) +
       NVL(SUM(s_io_time), 0) +
       NVL(SUM(commt_time), 0) io_time
  FROM by_inst_and_snap
 GROUP BY
       snap_id
)
SELECT ROUND(SUM(db_time) / 1e6, 2) db_time_secs,
       ROUND(SUM(io_time) / 1e6, 2) io_time_secs,
       ROUND(SUM(u_io_time) / 1e6, 2) u_io_secs,
       ROUND(SUM(dbfsr_time) / 1e6, 2) dbfsr_secs,
       ROUND(SUM(dpr_time) / 1e6, 2) dpr_secs,
       ROUND(SUM(s_io_time) / 1e6, 2) s_io_secs,
       ROUND(SUM(lfpw_time) / 1e6, 2) lfpw_secs,
       ROUND(SUM(commt_time) / 1e6, 2) commt_secs,
       ROUND(100 * SUM(u_io_time) / SUM(db_time), 2) u_io_perc_dbt,
       ROUND(100 * SUM(dbfsr_time) / SUM(db_time), 2) dbfsr_perc_dbt,
       ROUND(100 * SUM(dpr_time) / SUM(db_time), 2) dpr_perc_dbt,
       ROUND(100 * SUM(s_io_time) / SUM(db_time), 2) s_io_perc_dbt,
       ROUND(100 * SUM(lfpw_time) / SUM(db_time), 2) lfpw_perc_dbt,
       ROUND(100 * SUM(commt_time) / SUM(db_time), 2) commt_perc_dbt,
       ROUND(100 * SUM(u_io_time) / SUM(io_time), 2) u_io_perc_iot,
       ROUND(100 * SUM(dbfsr_time) / SUM(io_time), 2) dbfsr_perc_iot,
       ROUND(100 * SUM(dpr_time) / SUM(io_time), 2) dpr_perc_iot,
       ROUND(100 * SUM(s_io_time) / SUM(io_time), 2) s_io_perc_iot,
       ROUND(100 * SUM(lfpw_time) / SUM(io_time), 2) lfpw_perc_iot,
       ROUND(100 * SUM(commt_time) / SUM(io_time), 2) commt_perc_iot
  FROM by_snap
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Relevant I/O Time Composition';
DEF main_table = '&&awr_hist_prefix.SYSTEM_EVENT';
DEF chartype = 'LineChart';
DEF skip_lch = '';
DEF stacked = '';
DEF vaxis = 'Time Component in Seconds';
DEF vbaseline = '';
DEF tit_01 = 'DB Time';
DEF tit_02 = 'I/O Time';
DEF tit_03 = 'User I/O';
DEF tit_04 = 'db file scattered read';
DEF tit_05 = 'direct path read';
DEF tit_06 = 'System I/O';
DEF tit_07 = 'Commit';
DEF tit_08 = 'log file parallel write';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
BEGIN
  :sql_text := q'[
-- requested by Frits Hoogland
WITH 
db_time AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       stat_name,
       value - LAG(value) OVER (PARTITION BY dbid, instance_number, stat_name ORDER BY snap_id) value
  FROM &&awr_object_prefix.sys_time_model
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND stat_name = 'DB time'
),
system_event_detail AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       wait_class,
       SUM(time_waited_micro) time_waited_micro
  FROM &&awr_object_prefix.system_event
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND wait_class IN ('User I/O', 'System I/O', 'Commit')
 GROUP BY
       snap_id,
       dbid,
       instance_number,
       wait_class
),
system_event AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       wait_class,
       time_waited_micro - LAG(time_waited_micro) OVER (PARTITION BY dbid, instance_number, wait_class ORDER BY snap_id) time_waited_micro
  FROM system_event_detail
),
system_wait AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       event_name,
       time_waited_micro - LAG(time_waited_micro) OVER (PARTITION BY dbid, instance_number, event_name ORDER BY snap_id) time_waited_micro
  FROM &&awr_object_prefix.system_event
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND event_name IN ('db file scattered read', 'direct path read', 'log file parallel write')
),
time_components AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       d.snap_id,
       d.dbid,
       d.instance_number,
       d.value db_time,
       e1.time_waited_micro u_io_time,
       e2.time_waited_micro s_io_time,
       e3.time_waited_micro commt_time,
       w1.time_waited_micro dbfsr_time,
       w2.time_waited_micro dpr_time,
       w3.time_waited_micro lfpw_time
  FROM db_time d,
       system_event e1,
       system_event e2,
       system_event e3,
       system_wait w1,
       system_wait w2,
       system_wait w3
 WHERE d.value >= 0
   AND e1.snap_id = d.snap_id
   AND e1.dbid = d.dbid
   AND e1.instance_number = d.instance_number
   AND e1.wait_class = 'User I/O'
   AND e1.time_waited_micro >= 0
   AND e2.snap_id = d.snap_id
   AND e2.dbid = d.dbid
   AND e2.instance_number = d.instance_number
   AND e2.wait_class = 'System I/O'
   AND e2.time_waited_micro >= 0
   AND e3.snap_id = d.snap_id
   AND e3.dbid = d.dbid
   AND e3.instance_number = d.instance_number
   AND e3.wait_class = 'Commit'
   AND e3.time_waited_micro >= 0
   AND w1.snap_id = d.snap_id
   AND w1.dbid = d.dbid
   AND w1.instance_number = d.instance_number
   AND w1.event_name = 'db file scattered read'
   AND w1.time_waited_micro >= 0
   AND w2.snap_id = d.snap_id
   AND w2.dbid = d.dbid
   AND w2.instance_number = d.instance_number
   AND w2.event_name = 'direct path read'
   AND w2.time_waited_micro >= 0
   AND w3.snap_id = d.snap_id
   AND w3.dbid = d.dbid
   AND w3.instance_number = d.instance_number
   AND w3.event_name = 'log file parallel write'
   AND w3.time_waited_micro >= 0
),
by_inst_and_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       t.snap_id,
       t.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       --ROUND((CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       SUM(db_time) db_time,
       SUM(u_io_time) u_io_time,
       SUM(dbfsr_time) dbfsr_time,
       SUM(dpr_time) dpr_time,
       SUM(s_io_time) s_io_time,
       SUM(commt_time) commt_time,
       SUM(lfpw_time) lfpw_time
  FROM time_components t,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id = t.snap_id
   AND s.dbid = t.dbid
   AND s.instance_number = t.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
 GROUP BY
       t.snap_id,
       t.instance_number,
       s.begin_interval_time,
       s.end_interval_time
),
by_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       --ROUND((CAST(MIN(end_interval_time) AS DATE) - CAST(MIN(begin_interval_time) AS DATE)) * 24 * 60 * 60) interval_secs,
       NVL(SUM(db_time), 0) db_time,
       NVL(SUM(u_io_time), 0) u_io_time,
       NVL(SUM(dbfsr_time), 0) dbfsr_time,
       NVL(SUM(dpr_time), 0) dpr_time,
       NVL(SUM(s_io_time), 0) s_io_time,
       NVL(SUM(commt_time), 0) commt_time,
       NVL(SUM(lfpw_time), 0) lfpw_time,
       NVL(SUM(u_io_time), 0) +
       NVL(SUM(s_io_time), 0) +
       NVL(SUM(commt_time), 0) io_time
  FROM by_inst_and_snap
 GROUP BY
       snap_id
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(db_time / 1e6, 2) db_time_secs,
       ROUND(io_time / 1e6, 2) io_time_secs,
       ROUND(u_io_time / 1e6, 2) u_io_secs,
       ROUND(dbfsr_time / 1e6, 2) dbfsr_secs,
       ROUND(dpr_time / 1e6, 2) dpr_secs,
       ROUND(s_io_time / 1e6, 2) s_io_secs,
       ROUND(lfpw_time / 1e6, 2) lfpw_secs,
       ROUND(commt_time / 1e6, 2) commt_secs,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM by_snap
 ORDER BY
       snap_id
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

COL cv_cellname       HEAD CELLNAME         FOR A20
COL cv_cellversion    HEAD CELLSRV_VERSION  FOR A20
COL cv_flashcachemode HEAD FLASH_CACHE_MODE FOR A20

DEF title = 'Cell IORM Status';
DEF main_table = '&&v_view_prefix.CELL_CONFIG';
BEGIN
  :sql_text := q'[
-- celliorm.sql (v1.0) 
-- Tanel Poder
-- http://blog.tanelpoder.com
WITH cell_config AS (
    ( SELECT /*+ materialize */
        cellname,
        CASE
                WHEN confval LIKE '%interdatabaseplan%' THEN replace(confval,'interdatabaseplan','iormplan')
                ELSE confval
            END
        confval
      FROM
        &&v_object_prefix.cell_config  -- gv isn't needed, all cells should be visible in all instances
      WHERE
        conftype = 'IORM'
    )
)
SELECT
    cellname cv_cellname
  , CAST(extract(xmltype(confval), '/cli-output/iormplan/objective/text()') AS VARCHAR2(20)) objective
  , CAST(extract(xmltype(confval), '/cli-output/iormplan/status/text()')    AS VARCHAR2(15)) status
  , CAST(extract(xmltype(confval), '/cli-output/iormplan/name/text()')      AS VARCHAR2(30)) interdb_plan
  , CAST(extract(xmltype(confval), '/cli-output/iormplan/catPlan/text()')   AS VARCHAR2(30)) cat_plan
  , CAST(extract(xmltype(confval), '/cli-output/iormplan/dbPlan/text()')    AS VARCHAR2(30)) db_plan
FROM 
    cell_config
ORDER BY
    cv_cellname
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

COL cv_cellname       HEAD CELLNAME         FOR A20
COL cv_cellversion    HEAD CELLSRV_VERSION  FOR A20
COL cv_flashcachemode HEAD FLASH_CACHE_MODE FOR A20

DEF title = 'Cell Physical Disk Summary';
DEF main_table = '&&v_view_prefix.CELL_CONFIG';
BEGIN
  :sql_text := q'[
-- cellpd.sql (v1.0) 
-- Tanel Poder
-- http://blog.tanelpoder.com
SELECT 
    disktype
  , cv_cellname
  , status
  , ROUND(SUM(physicalsize/POWER(10,9))) total_gb
  , ROUND(AVG(physicalsize/POWER(10,9))) avg_gb
  , COUNT(*) num_disks
  , SUM(CASE WHEN predfailStatus  = 'TRUE' THEN 1 END) predfail
  , SUM(CASE WHEN poorPerfStatus  = 'TRUE' THEN 1 END) poorperf
  , SUM(CASE WHEN wtCachingStatus = 'TRUE' THEN 1 END) wtcacheprob
  , SUM(CASE WHEN peerFailStatus  = 'TRUE' THEN 1 END) peerfail
  , SUM(CASE WHEN criticalStatus  = 'TRUE' THEN 1 END) critical
FROM (
    SELECT /*+ NO_MERGE */
        c.cellname cv_cellname
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/name/text()')                          AS VARCHAR2(20)) diskname
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/diskType/text()')                      AS VARCHAR2(20)) diskType          
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/luns/text()')                          AS VARCHAR2(20)) luns              
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/makeModel/text()')                     AS VARCHAR2(50)) makeModel         
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalFirmware/text()')              AS VARCHAR2(20)) physicalFirmware  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalInsertTime/text()')            AS VARCHAR2(30)) physicalInsertTime
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalSerial/text()')                AS VARCHAR2(20)) physicalSerial    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalSize/text()')                  AS VARCHAR2(20)) physicalSize      
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/slotNumber/text()')                    AS VARCHAR2(30)) slotNumber        
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/status/text()')                        AS VARCHAR2(20)) status            
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/id/text()')                            AS VARCHAR2(20)) id                
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/key_500/text()')                       AS VARCHAR2(20)) key_500           
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/predfailStatus/text()')                AS VARCHAR2(20)) predfailStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/poorPerfStatus/text()')                AS VARCHAR2(20)) poorPerfStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/wtCachingStatus/text()')               AS VARCHAR2(20)) wtCachingStatus   
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/peerFailStatus/text()')                AS VARCHAR2(20)) peerFailStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/criticalStatus/text()')                AS VARCHAR2(20)) criticalStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errCmdTimeoutCount/text()')            AS VARCHAR2(20)) errCmdTimeoutCount
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errHardReadCount/text()')              AS VARCHAR2(20)) errHardReadCount  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errHardWriteCount/text()')             AS VARCHAR2(20)) errHardWriteCount 
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errMediaCount/text()')                 AS VARCHAR2(20)) errMediaCount     
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errOtherCount/text()')                 AS VARCHAR2(20)) errOtherCount     
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errSeekCount/text()')                  AS VARCHAR2(20)) errSeekCount      
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/sectorRemapCount/text()')              AS VARCHAR2(20)) sectorRemapCount  
    FROM
        &&v_object_prefix.cell_config c
      , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.confval), '/cli-output/physicaldisk'))) v  -- gv isn't needed, all cells should be visible in all instances
    WHERE 
        c.conftype = 'PHYSICALDISKS'
)
GROUP BY
    cv_cellname
  , disktype
  , status
ORDER BY
    disktype
  , cv_cellname
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

COL cv_cellname       HEAD CELLNAME         FOR A20
COL cv_cellversion    HEAD CELLSRV_VERSION  FOR A20
COL cv_flashcachemode HEAD FLASH_CACHE_MODE FOR A20

DEF title = 'Cell Physical Disk Detail';
DEF main_table = '&&v_view_prefix.CELL_CONFIG';
BEGIN
  :sql_text := q'[
-- cellpdx.sql (v1.0) 
-- Tanel Poder
-- http://blog.tanelpoder.com
SELECT * FROM (
    SELECT
        c.cellname cv_cellname
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/name/text()')                          AS VARCHAR2(20)) diskname
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/diskType/text()')                      AS VARCHAR2(20)) diskType          
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/luns/text()')                          AS VARCHAR2(20)) luns              
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/makeModel/text()')                     AS VARCHAR2(40)) makeModel         
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalFirmware/text()')              AS VARCHAR2(20)) physicalFirmware  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalInsertTime/text()')            AS VARCHAR2(30)) physicalInsertTime
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalSerial/text()')                AS VARCHAR2(20)) physicalSerial    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalSize/text()')                  AS VARCHAR2(20)) physicalSize      
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/sectorRemapCount/text()')              AS VARCHAR2(20)) sectorRemapCount  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/slotNumber/text()')                    AS VARCHAR2(30)) slotNumber        
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/status/text()')                        AS VARCHAR2(20)) status            
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/id/text()')                            AS VARCHAR2(20)) id                
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/key_500/text()')                       AS VARCHAR2(20)) key_500           
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/predfailStatus/text()')                AS VARCHAR2(20)) predfailStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/poorPerfStatus/text()')                AS VARCHAR2(20)) poorPerfStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/wtCachingStatus/text()')               AS VARCHAR2(20)) wtCachingStatus   
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/peerFailStatus/text()')                AS VARCHAR2(20)) peerFailStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/criticalStatus/text()')                AS VARCHAR2(20)) criticalStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errCmdTimeoutCount/text()')            AS VARCHAR2(20)) errCmdTimeoutCount
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errHardReadCount/text()')              AS VARCHAR2(20)) errHardReadCount  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errHardWriteCount/text()')             AS VARCHAR2(20)) errHardWriteCount 
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errMediaCount/text()')                 AS VARCHAR2(20)) errMediaCount     
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errOtherCount/text()')                 AS VARCHAR2(20)) errOtherCount     
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errSeekCount/text()')                  AS VARCHAR2(20)) errSeekCount      
    FROM
        &&v_object_prefix.cell_config c
      , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.confval), '/cli-output/physicaldisk'))) v  -- gv isn't needed, all cells should be visible in all instances
    WHERE 
        c.conftype = 'PHYSICALDISKS'
)
ORDER BY
    cv_cellname
  , diskname
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

COL cv_cellname       HEAD CELL_NAME        FOR A20
COL cv_cell_path      HEAD CELL_PATH        FOR A20
COL cv_cellversion    HEAD CELLSRV_VERSION  FOR A20
COL cv_flashcachemode HEAD FLASH_CACHE_MODE FOR A20

DEF title = 'Cell Details';
DEF main_table = '&&v_view_prefix.CELL_CONFIG';
BEGIN
  :sql_text := q'[
-- cellver.sql (v1.0) 
-- Tanel Poder
-- http://blog.tanelpoder.com
SELECT
    cellname cv_cell_path
  , CAST(extract(xmltype(confval), '/cli-output/cell/name/text()') AS VARCHAR2(20))  cv_cellname
  , CAST(extract(xmltype(confval), '/cli-output/cell/releaseVersion/text()') AS VARCHAR2(20))  cv_cellVersion 
  , CAST(extract(xmltype(confval), '/cli-output/cell/flashCacheMode/text()') AS VARCHAR2(20))  cv_flashcachemode
  , CAST(extract(xmltype(confval), '/cli-output/cell/cpuCount/text()')       AS VARCHAR2(10))  cpu_count
  , CAST(extract(xmltype(confval), '/cli-output/cell/upTime/text()')         AS VARCHAR2(20))  uptime
  , CAST(extract(xmltype(confval), '/cli-output/cell/kernelVersion/text()')  AS VARCHAR2(30))  kernel_version
  , CAST(extract(xmltype(confval), '/cli-output/cell/makeModel/text()')      AS VARCHAR2(50))  make_model
FROM 
    &&v_object_prefix.cell_config  -- gv isn't needed, all cells should be visible in all instances
WHERE 
    conftype = 'CELL'
ORDER BY
    cv_cellname
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

COL cellname            HEAD CELLNAME       FOR A20
COL celldisk_name       HEAD CELLDISK       FOR A30
COL physdisk_name       HEAD PHYSDISK       FOR A30
COL griddisk_name       HEAD GRIDDISK       FOR A30
COL asmdisk_name        HEAD ASMDISK        FOR A30
BREAK ON asm_diskgroup SKIP 1 ON asm_disk

DEF title = 'Cell Disk Topology';
DEF main_table = '&&v_view_prefix.CELL_CONFIG';
BEGIN
  :sql_text := q'[
-- exadisktopo.sql (v1.0) 
-- Tanel Poder
-- http://blog.tanelpoder.com
WITH pd AS (
    SELECT /*+ MATERIALIZE */
        c.cellname,
        CAST(extractvalue(value(v),'/physicaldisk/name/text()') AS VARCHAR2(100) ) name,
        CAST(extractvalue(value(v),'/physicaldisk/diskType/text()') AS VARCHAR2(100) ) disktype,
        CAST(extractvalue(value(v),'/physicaldisk/luns/text()') AS VARCHAR2(100) ) luns,
        CAST(extractvalue(value(v),'/physicaldisk/makeModel/text()') AS VARCHAR2(100) ) makemodel,
        CAST(extractvalue(value(v),'/physicaldisk/physicalFirmware/text()') AS VARCHAR2(100) ) physicalfirmware,
        CAST(extractvalue(value(v),'/physicaldisk/physicalInsertTime/text()') AS VARCHAR2(100) ) physicalinserttime,
        CAST(extractvalue(value(v),'/physicaldisk/physicalSerial/text()') AS VARCHAR2(100) ) physicalserial,
        CAST(extractvalue(value(v),'/physicaldisk/physicalSize/text()') AS VARCHAR2(100) ) physicalsize,
        CAST(extractvalue(value(v),'/physicaldisk/slotNumber/text()') AS VARCHAR2(100) ) slotnumber,
        CAST(extractvalue(value(v),'/physicaldisk/status/text()') AS VARCHAR2(100) ) status,
        CAST(extractvalue(value(v),'/physicaldisk/id/text()') AS VARCHAR2(100) ) id,
        CAST(extractvalue(value(v),'/physicaldisk/key_500/text()') AS VARCHAR2(100) ) key_500,
        CAST(extractvalue(value(v),'/physicaldisk/predfailStatus/text()') AS VARCHAR2(100) ) predfailstatus,
        CAST(extractvalue(value(v),'/physicaldisk/poorPerfStatus/text()') AS VARCHAR2(100) ) poorperfstatus,
        CAST(extractvalue(value(v),'/physicaldisk/wtCachingStatus/text()') AS VARCHAR2(100) ) wtcachingstatus,
        CAST(extractvalue(value(v),'/physicaldisk/peerFailStatus/text()') AS VARCHAR2(100) ) peerfailstatus,
        CAST(extractvalue(value(v),'/physicaldisk/criticalStatus/text()') AS VARCHAR2(100) ) criticalstatus,
        CAST(extractvalue(value(v),'/physicaldisk/errCmdTimeoutCount/text()') AS VARCHAR2(100) ) errcmdtimeoutcount,
        CAST(extractvalue(value(v),'/physicaldisk/errHardReadCount/text()') AS VARCHAR2(100) ) errhardreadcount,
        CAST(extractvalue(value(v),'/physicaldisk/errHardWriteCount/text()') AS VARCHAR2(100) ) errhardwritecount,
        CAST(extractvalue(value(v),'/physicaldisk/errMediaCount/text()') AS VARCHAR2(100) ) errmediacount,
        CAST(extractvalue(value(v),'/physicaldisk/errOtherCount/text()') AS VARCHAR2(100) ) errothercount,
        CAST(extractvalue(value(v),'/physicaldisk/errSeekCount/text()') AS VARCHAR2(100) ) errseekcount,
        CAST(extractvalue(value(v),'/physicaldisk/sectorRemapCount/text()') AS VARCHAR2(100) ) sectorremapcount
    FROM
        &&v_object_prefix.cell_config c,
        TABLE ( xmlsequence(extract(xmltype(c.confval),'/cli-output/physicaldisk') ) ) v  -- gv isn't needed, all cells should be visible in all instances
    WHERE
        c.conftype = 'PHYSICALDISKS'
),cd AS (
    SELECT /*+ MATERIALIZE */
        c.cellname,
        CAST(extractvalue(value(v),'/celldisk/name/text()') AS VARCHAR2(100) ) name,
        CAST(extractvalue(value(v),'/celldisk/comment        /text()') AS VARCHAR2(100) ) disk_comment,
        CAST(extractvalue(value(v),'/celldisk/creationTime   /text()') AS VARCHAR2(100) ) creationtime,
        CAST(extractvalue(value(v),'/celldisk/deviceName     /text()') AS VARCHAR2(100) ) devicename,
        CAST(extractvalue(value(v),'/celldisk/devicePartition/text()') AS VARCHAR2(100) ) devicepartition,
        CAST(extractvalue(value(v),'/celldisk/diskType       /text()') AS VARCHAR2(100) ) disktype,
        CAST(extractvalue(value(v),'/celldisk/errorCount     /text()') AS VARCHAR2(100) ) errorcount,
        CAST(extractvalue(value(v),'/celldisk/freeSpace      /text()') AS VARCHAR2(100) ) freespace,
        CAST(extractvalue(value(v),'/celldisk/id             /text()') AS VARCHAR2(100) ) id,
        CAST(extractvalue(value(v),'/celldisk/interleaving   /text()') AS VARCHAR2(100) ) interleaving,
        CAST(extractvalue(value(v),'/celldisk/lun            /text()') AS VARCHAR2(100) ) lun,
        CAST(extractvalue(value(v),'/celldisk/physicalDisk   /text()') AS VARCHAR2(100) ) physicaldisk,
        CAST(extractvalue(value(v),'/celldisk/size           /text()') AS VARCHAR2(100) ) disk_size,
        CAST(extractvalue(value(v),'/celldisk/status         /text()') AS VARCHAR2(100) ) status
    FROM
        &&v_object_prefix.cell_config c,
        TABLE ( xmlsequence(extract(xmltype(c.confval),'/cli-output/celldisk') ) ) v  -- gv isn't needed, all cells should be visible in all instances
    WHERE
        c.conftype = 'CELLDISKS'
),gd AS (
    SELECT /*+ MATERIALIZE */
        c.cellname,
        CAST(extractvalue(value(v),'/griddisk/name/text()') AS VARCHAR2(100) ) name,
        CAST(extractvalue(value(v),'/griddisk/asmDiskgroupName/text()') AS VARCHAR2(100) ) asmdiskgroupname,
        CAST(extractvalue(value(v),'/griddisk/asmDiskName     /text()') AS VARCHAR2(100) ) asmdiskname,
        CAST(extractvalue(value(v),'/griddisk/asmFailGroupName/text()') AS VARCHAR2(100) ) asmfailgroupname,
        CAST(extractvalue(value(v),'/griddisk/availableTo     /text()') AS VARCHAR2(100) ) availableto,
        CAST(extractvalue(value(v),'/griddisk/cachingPolicy   /text()') AS VARCHAR2(100) ) cachingpolicy,
        CAST(extractvalue(value(v),'/griddisk/cellDisk        /text()') AS VARCHAR2(100) ) celldisk,
        CAST(extractvalue(value(v),'/griddisk/comment         /text()') AS VARCHAR2(100) ) disk_comment,
        CAST(extractvalue(value(v),'/griddisk/creationTime    /text()') AS VARCHAR2(100) ) creationtime,
        CAST(extractvalue(value(v),'/griddisk/diskType        /text()') AS VARCHAR2(100) ) disktype,
        CAST(extractvalue(value(v),'/griddisk/errorCount      /text()') AS VARCHAR2(100) ) errorcount,
        CAST(extractvalue(value(v),'/griddisk/id              /text()') AS VARCHAR2(100) ) id,
        CAST(extractvalue(value(v),'/griddisk/offset          /text()') AS VARCHAR2(100) ) offset,
        CAST(extractvalue(value(v),'/griddisk/size            /text()') AS VARCHAR2(100) ) disk_size,
        CAST(extractvalue(value(v),'/griddisk/status          /text()') AS VARCHAR2(100) ) status,
        CAST(extractvalue(value(v),'/griddisk/cachedBy        /text()') AS VARCHAR2(100) ) cachedby
    FROM
        &&v_object_prefix.cell_config c,
        TABLE ( xmlsequence(extract(xmltype(c.confval),'/cli-output/griddisk') ) ) v  -- gv isn't needed, all cells should be visible in all instances
    WHERE
        c.conftype = 'GRIDDISKS'
),lun AS (
    SELECT /*+ MATERIALIZE */
        c.cellname,
        CAST(extractvalue(value(v),'/lun/cellDisk         /text()') AS VARCHAR2(100) ) celldisk,
        CAST(extractvalue(value(v),'/lun/deviceName       /text()') AS VARCHAR2(100) ) devicename,
        CAST(extractvalue(value(v),'/lun/diskType         /text()') AS VARCHAR2(100) ) disktype,
        CAST(extractvalue(value(v),'/lun/id               /text()') AS VARCHAR2(100) ) id,
        CAST(extractvalue(value(v),'/lun/isSystemLun      /text()') AS VARCHAR2(100) ) issystemlun,
        CAST(extractvalue(value(v),'/lun/lunAutoCreate    /text()') AS VARCHAR2(100) ) lunautocreate,
        CAST(extractvalue(value(v),'/lun/lunSize          /text()') AS VARCHAR2(100) ) lunsize,
        CAST(extractvalue(value(v),'/lun/physicalDrives   /text()') AS VARCHAR2(100) ) physicaldrives,
        CAST(extractvalue(value(v),'/lun/raidLevel        /text()') AS VARCHAR2(100) ) raidlevel,
        CAST(extractvalue(value(v),'/lun/lunWriteCacheMode/text()') AS VARCHAR2(100) ) lunwritecachemode,
        CAST(extractvalue(value(v),'/lun/status           /text()') AS VARCHAR2(100) ) status
    FROM
        &&v_object_prefix.cell_config c,
        TABLE ( xmlsequence(extract(xmltype(c.confval),'/cli-output/lun') ) ) v  -- gv isn't needed, all cells should be visible in all instances
    WHERE
        c.conftype = 'LUNS'
),ad AS (
    SELECT /*+ MATERIALIZE */
        *
    FROM
        &&v_object_prefix.asm_disk
),adg AS (
    SELECT /*+ MATERIALIZE */
        dg.*,
        length(dg.name) namesize
    FROM
        &&v_object_prefix.asm_diskgroup dg
) SELECT
    adg.name asm_diskgroup,
    adg.state,
    ad.label asm_disk,
    gd.asmdiskname griddisk_name,
    cd.name celldisk_name,
    pd.cellname,
    substr(cd.devicepartition,1,20) cd_devicepart,
    pd.name physdisk_name,
    substr(pd.status,1,20) physdisk_status,
    lun.lunwritecachemode,
    gd.cachedby
-- , SUBSTR(cd.devicename,1,20)      cd_devicename
-- , SUBSTR(lun.devicename,1,20)     lun_devicename
--    disktype*/
  FROM
    adg
    LEFT OUTER JOIN ad ON ad.group_number = adg.group_number
                          AND substr(ad.label,1,adg.namesize) = adg.name
    JOIN gd ON upper(gd.asmdiskname) = upper(ad.label)
    RIGHT OUTER JOIN cd ON cd.name = gd.celldisk
    RIGHT OUTER JOIN pd ON cd.physicaldisk = pd.physicalserial
    RIGHT OUTER JOIN lun ON cd.cellname = lun.cellname
                            AND cd.devicename = lun.devicename 
ORDER BY
    asm_diskgroup,
    cellname,
    celldisk_name,
    asm_disk,
    griddisk_name,
    cellname
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql
CLEAR BREAKS

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
