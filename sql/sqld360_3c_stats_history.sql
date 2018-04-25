DEF section_id = '3c';
DEF section_name = 'Statistics History';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'System Statistics History';
DEF main_table = 'WRI$_OPTSTAT_AUX_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       h.*
  FROM sys.wri$_optstat_aux_history h
 ORDER BY h.savtime desc, sname
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Tables Statistics History';
DEF main_table = 'WRI$_OPTSTAT_TAB_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       o.owner owner,
       o.object_name table_name,
       TRUNC((h.rowcnt - LAG(h.rowcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime)) / NULLIF(LAG(h.rowcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime),0),2)*100 rowcnt_change_perc,
       TRUNC((h.blkcnt - LAG(h.blkcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime)) / NULLIF(LAG(h.blkcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime),0),2)*100 blkcnt_change_perc,
       h.*
  FROM sys.wri$_optstat_tab_history h,
       dba_objects o
 WHERE (o.owner, o.object_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
   AND o.object_type = 'TABLE'
   AND o.object_id = h.obj#
   AND '&&diagnostics_pack.' = 'Y'
 ORDER BY o.owner, o.object_name, h.savtime desc
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Indexes Statistics History';
DEF main_table = 'WRI$_OPTSTAT_IND_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       i.owner,
       i.table_name,
       i.index_name, 
       TRUNC((h.blevel - LAG(h.blevel,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime)) / NULLIF(LAG(h.blevel,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime),0),2)*100 blevel_change_perc,
       TRUNC((h.leafcnt - LAG(h.leafcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime)) / NULLIF(LAG(h.leafcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime),0),2)*100 leafcnt_change_perc,
       TRUNC((h.clufac - LAG(h.clufac,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime)) / NULLIF(LAG(h.clufac,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime),0),2)*100 clufac_change_perc,    
       h.*
  FROM sys.wri$_optstat_ind_history h,
       dba_objects o,
       dba_indexes i
 WHERE (i.table_owner, i.table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
   AND i.index_name = o.object_name
   AND i.owner = o.owner
   AND o.object_type = 'INDEX'
   AND o.object_id = h.obj#
   AND '&&diagnostics_pack.' = 'Y'
 ORDER BY i.table_owner, i.table_name, i.index_name, h.savtime desc
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Columns Statistics History';
DEF main_table = 'WRI$_OPTSTAT_HISTHEAD_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       c.owner,
       c.table_name,
       c.column_name, 
       TRUNC((h.null_cnt - LAG(h.null_cnt,1,NULL) OVER (PARTITION BY h.obj#, c.column_name ORDER BY h.savtime)) / NULLIF(LAG(h.null_cnt,1,NULL) OVER (PARTITION BY h.obj#, c.column_name  ORDER BY h.savtime),0),2)*100 nullcnt_change_perc,
       TRUNC((h.distcnt - LAG(h.distcnt,1,NULL) OVER (PARTITION BY h.obj#, c.column_name ORDER BY h.savtime)) / NULLIF(LAG(h.distcnt,1,NULL) OVER (PARTITION BY h.obj#, c.column_name  ORDER BY h.savtime),0),2)*100 distcnt_change_perc,
       CASE WHEN h.flags > 64 THEN 'YES' ELSE 'NO' END had_histogram,
       h.*
  FROM sys.wri$_optstat_histhead_history h,
       dba_objects o,
       dba_tab_cols c
 WHERE (c.owner, c.table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
   AND c.table_name = o.object_name
   AND c.owner = o.owner
   AND o.object_type = 'TABLE'
   AND o.object_id = h.obj#
   AND c.column_id = h.intcol#
   AND '&&diagnostics_pack.' = 'Y'
 ORDER BY c.owner, c.table_name, c.column_id, h.savtime desc
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Partitions Statistics History';
DEF main_table = 'WRI$_OPTSTAT_TAB_HISTORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
        p.table_owner, 
        p.table_name,
        p.partition_name,
        p.partition_position, 
        TRUNC((h.rowcnt - LAG(h.rowcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime)) / NULLIF(LAG(h.rowcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime),0),2)*100 rowcnt_change_perc,
        TRUNC((h.blkcnt - LAG(h.blkcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime)) / NULLIF(LAG(h.blkcnt,1,NULL) OVER (PARTITION BY h.obj# ORDER BY h.savtime),0),2)*100 blkcnt_change_perc,
        h.*
  FROM (SELECT table_owner, table_name, partition_name, partition_position,
               ROW_NUMBER() OVER (ORDER BY partition_position) rn, COUNT(*) OVER () num_part
          FROM dba_tab_partitions 
         WHERE (table_owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
       ) p,
       dba_objects o,
       sys.wri$_optstat_tab_history h
 WHERE (p.rn <= &&sqld360_conf_first_part OR p.rn >= num_part-&&sqld360_conf_last_part)
   AND o.object_type = 'TABLE PARTITION'
   AND p.table_owner = o.owner
   AND p.table_name = o.object_name
   AND p.partition_name = o.subobject_name
   AND o.object_id = h.obj#
   AND '&&diagnostics_pack.' = 'Y'
 ORDER BY p.table_owner, p.table_name, p.partition_name, p.partition_position DESC, h.savtime desc 
]';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;