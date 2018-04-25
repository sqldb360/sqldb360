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
DEF main_table = '&&gv_view_prefix.SYSSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       * 
  FROM &&gv_object_prefix.sysstat 
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
       &&gv_object_prefix.sysstat n
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
DEF main_table = '&&dva_view_prefix.RSRC_IO_CALIBRATE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.rsrc_io_calibrate
 ORDER BY
       1, 2
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

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

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
