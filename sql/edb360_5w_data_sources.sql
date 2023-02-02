@@&&edb360_0g.tkprof.sql
DEF section_id = '5w';
DEF section_name = 'Data Sources';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = 'DBA_HIST_SNAPSHOT';
DEF title = '&&main_table.';
BEGIN
  :sql_text_backup := q'[
SELECT *
  FROM (SELECT t.*
              ,t.snap_id-lag(t.snap_id) over (partition by con_id,dbid,instance_number@partcol@ order by snap_id) gap
              ,lead(t.snap_id) over (partition by con_id,dbid,instance_number@partcol@ order by snap_id)-t.snap_id ngap
          FROM @main_table@ t
       )
 where nvl(gap,-1)<>1 or nvl(ngap,-1)<>1
 order by con_id,dbid,instance_number@partcol@,snap_id
]';
 :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
END;
/
@@edb360_9a_pre_one.sql

DEF main_table = 'CDB_HIST_SNAPSHOT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_ROOT_SNAPSHOT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_CDB_SNAPSHOT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_PDB_SNAPSHOT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
@@edb360_9a_pre_one.sql

DEF main_table = 'DBA_HIST_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'CDB_HIST_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_ROOT_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_CDB_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_PDB_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'DBA_HIST_CON_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'CDB_HIST_CON_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_ROOT_CON_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_CDB_CON_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_PDB_CON_SYSSTAT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@',',stat_id');
@@edb360_9a_pre_one.sql

DEF main_table = 'DBA_HIST_ASH_SNAPSHOT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
@@edb360_9a_pre_one.sql

DEF main_table = 'CDB_HIST_ASH_SNAPSHOT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_ROOT_ASH_SNAPSHOT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
@@edb360_9a_pre_one.sql

DEF main_table = 'AWR_PDB_ASH_SNAPSHOT';
DEF title = '&&main_table.';
exec :sql_text := replace(replace(:sql_text_backup,'@main_table@','&&main_table.'),'@partcol@','');
@@edb360_9a_pre_one.sql
