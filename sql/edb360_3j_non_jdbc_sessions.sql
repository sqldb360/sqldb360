@@&&edb360_0g.tkprof.sql
DEF section_id = '3j';
DEF section_name = 'Non-JDBC Sessions';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Non-JDBC Connection usage per Module';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
select count(*) sessions, /* &&section_id..&&report_sequence. */
type,
module,
SUM(CASE status WHEN 'ACTIVE' THEN 1 ELSE 0 END) active, 
SUM(CASE status WHEN 'INACTIVE' THEN 1 ELSE 0 END) inactive, 
SUM(CASE status WHEN 'KILLED' THEN 1 ELSE 0 END) killed, 
SUM(CASE status WHEN 'CACHED' THEN 1 ELSE 0 END) cached, 
SUM(CASE status WHEN 'SNIPED' THEN 1 ELSE 0 END) sniped, 
MIN(last_call_et) min_last_call_secs,
MAX(last_call_et) max_last_call_secs,
MEDIAN(last_call_et) med_last_call_secs
FROM &&gv_object_prefix.session 
where (program IS NULL OR program not like '%JDBC%')
group by type,module 
order by 1 DESC, 2,3
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Non-JDBC Connection usage per Process and Module';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
select count(*) sessions, /* &&section_id..&&report_sequence. */
type,
process, 
module,  
SUM(CASE status WHEN 'ACTIVE' THEN 1 ELSE 0 END) active, 
SUM(CASE status WHEN 'INACTIVE' THEN 1 ELSE 0 END) inactive, 
SUM(CASE status WHEN 'KILLED' THEN 1 ELSE 0 END) killed, 
SUM(CASE status WHEN 'CACHED' THEN 1 ELSE 0 END) cached, 
SUM(CASE status WHEN 'SNIPED' THEN 1 ELSE 0 END) sniped, 
MIN(last_call_et) min_last_call_secs,
MAX(last_call_et) max_last_call_secs,
MEDIAN(last_call_et) med_last_call_secs
FROM &&gv_object_prefix.session 
where (program IS NULL OR program not like '%JDBC%')
group by type,process, module 
order by 1 DESC, 2, 3, 4
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Non-JDBC Connection usage per JVM';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
select count(*) sessions, /* &&section_id..&&report_sequence. */
type,
machine,  
SUM(CASE status WHEN 'ACTIVE' THEN 1 ELSE 0 END) active, 
SUM(CASE status WHEN 'INACTIVE' THEN 1 ELSE 0 END) inactive, 
SUM(CASE status WHEN 'KILLED' THEN 1 ELSE 0 END) killed, 
SUM(CASE status WHEN 'CACHED' THEN 1 ELSE 0 END) cached, 
SUM(CASE status WHEN 'SNIPED' THEN 1 ELSE 0 END) sniped, 
MIN(last_call_et) min_last_call_secs,
MAX(last_call_et) max_last_call_secs,
MEDIAN(last_call_et) med_last_call_secs
FROM &&gv_object_prefix.session 
where (program IS NULL OR program not like '%JDBC%')
group by type,machine 
order by 1 DESC, 2, 3
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Non-JDBC Connection usage per JVM Process';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
select count(*) sessions, /* &&section_id..&&report_sequence. */
type,
machine, 
process, 
SUM(CASE status WHEN 'ACTIVE' THEN 1 ELSE 0 END) active, 
SUM(CASE status WHEN 'INACTIVE' THEN 1 ELSE 0 END) inactive, 
SUM(CASE status WHEN 'KILLED' THEN 1 ELSE 0 END) killed, 
SUM(CASE status WHEN 'CACHED' THEN 1 ELSE 0 END) cached, 
SUM(CASE status WHEN 'SNIPED' THEN 1 ELSE 0 END) sniped, 
MIN(last_call_et) min_last_call_secs,
MAX(last_call_et) max_last_call_secs,
MEDIAN(last_call_et) med_last_call_secs
FROM &&gv_object_prefix.session 
where (program IS NULL OR program not like '%JDBC%')
group by type,machine, process 
order by 1 DESC, 2, 3, 4
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Non-JDBC Idle connections for more than N hours';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
select TRUNC(last_call_et/3600) hours_idle, /* &&section_id..&&report_sequence. */
type,
status, 
count(*) sessions,
CASE TRUNC(last_call_et/3600) WHEN 0 THEN ROUND(AVG(last_call_et)) END avg_secs,
CASE TRUNC(last_call_et/3600) WHEN 0 THEN MEDIAN(last_call_et) END med_secs
FROM &&gv_object_prefix.session 
where (program IS NULL OR program not like '%JDBC%')
and status <> 'ACTIVE' 
group by type,status,TRUNC(last_call_et/3600) 
order by 1,2,3
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Non-JDBC Idle connections per Status, JVM and Program';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
select TRUNC(last_call_et/3600) hours_idle, /* &&section_id..&&report_sequence. */
type,
status,
machine, 
program,
count(*) sessions, 
CASE TRUNC(last_call_et/3600) WHEN 0 THEN ROUND(AVG(last_call_et)) END avg_secs,
CASE TRUNC(last_call_et/3600) WHEN 0 THEN MEDIAN(last_call_et) END med_secs
FROM &&gv_object_prefix.session 
where (program IS NULL OR program not like '%JDBC%')
--and  last_call_et > 3600
and status <> 'ACTIVE' 
group by TRUNC(last_call_et/3600),type,status,machine, program 
order by 1,2,3,4,5
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Non-JDBC Active connections';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
select s.last_call_et last_call_et_secs,  /* &&section_id..&&report_sequence. */
s.*,  t.sql_text current_sql, t2.sql_text prev_sql 
FROM &&gv_object_prefix.session s, &&gv_object_prefix.sql t, &&gv_object_prefix.sql t2
where s.inst_id =t.inst_id(+)
and s.sql_address =t.address(+)  
and s.sql_hash_value =t.hash_value(+)
and s.sql_id = t.sql_id(+)
and s.sql_child_number = t.child_number(+)
&&skip_11g_column.&&skip_10g_column.and s.con_id = t.con_id(+)
and s.inst_id =t2.inst_id(+)
and s.prev_sql_addr =t2.address(+)  
and s.prev_hash_value =t2.hash_value(+)
and s.prev_sql_id = t2.sql_id(+)
and s.prev_child_number = t2.child_number(+)
&&skip_11g_column.&&skip_10g_column.and s.con_id = t2.con_id(+)
and (s.program IS NULL OR s.program not like '%JDBC%')
and s.status = 'ACTIVE' 
order by last_call_et
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Non-JDBC Idle connections';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
select s.last_call_et last_call_et_secs,  /* &&section_id..&&report_sequence. */
s.*,  t.sql_text current_sql, t2.sql_text prev_sql 
FROM &&gv_object_prefix.session s, &&gv_object_prefix.sql t, &&gv_object_prefix.sql t2
where s.inst_id =t.inst_id(+)
and s.sql_address =t.address(+)  
and s.sql_hash_value =t.hash_value(+)
and s.sql_id = t.sql_id(+)
and s.sql_child_number = t.child_number(+)
&&skip_11g_column.&&skip_10g_column.and s.con_id = t.con_id(+)
and s.inst_id =t2.inst_id(+)
and s.prev_sql_addr =t2.address(+)  
and s.prev_hash_value =t2.hash_value(+)
and s.prev_sql_id = t2.sql_id(+)
and s.prev_child_number = t2.child_number(+)
&&skip_11g_column.&&skip_10g_column.and s.con_id = t2.con_id(+)
and (s.program IS NULL OR s.program not like '%JDBC%')
and s.status <> 'ACTIVE' 
order by last_call_et
]';
END;
/
@@edb360_9a_pre_one.sql       

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

