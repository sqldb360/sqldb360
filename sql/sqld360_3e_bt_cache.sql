DEF section_id = '3e';
DEF section_name = 'Big Table Caching';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'BT Scan Cache';
DEF main_table = 'GV$BT_SCAN_CACHE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$bt_scan_cache
 ORDER BY inst_id 
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'BT Scan Objects Temps';
DEF main_table = 'GV$BT_SCAN_OBJ_TEMPS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       o.owner, o.object_name, o.subobject_name,
       bsc.*
  FROM gv$bt_scan_obj_temps bsc,
       dba_objects o
 WHERE bsc.dataobj# = o.data_object_id 
   AND (o.owner, o.object_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
 ORDER BY bsc.inst_id, o.owner, o.object_name, o.subobject_name
]';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;