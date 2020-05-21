@@&&edb360_0g.tkprof.sql
DEF section_id = '3i';
DEF section_name = 'JDBC Sessions';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'JDBC Connection usage per Module';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
WITH x AS (
SELECT COUNT(*) sessions, /* &&section_id..&&report_sequence. */
&&skip_noncdb.con_id,
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
where program like '%JDBC%' 
GROUP BY &&skip_noncdb.con_id,
module 
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY x.sessions DESC, &&skip_noncdb.x.con_id,
         x.module
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Connection usage per Process and Module';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
WITH x AS (
SELECT COUNT(*) sessions, /* &&section_id..&&report_sequence. */
&&skip_noncdb.con_id,
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
FROM  &&gv_object_prefix.session 
WHERE program LIKE '%JDBC%' 
GROUP BY &&skip_noncdb.con_id,
         process, module 
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY x.sessions DESC, &&skip_noncdb.x.con_id,
         x.process, x.module
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Connection usage per JVM';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
WITH x AS (
SELECT COUNT(*) sessions, /* &&section_id..&&report_sequence. */
&&skip_noncdb.con_id,
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
where program like '%JDBC%' 
GROUP BY &&skip_noncdb.con_id,
         machine 
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY x.sessions DESC, &&skip_noncdb.x.con_id,
         x.machine
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Connection usage per JVM Process';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
WITH x AS (
SELECT COUNT(*) sessions, /* &&section_id..&&report_sequence. */
&&skip_noncdb.con_id,
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
where program like '%JDBC%' 
GROUP BY &&skip_noncdb.con_id,
         machine, process 
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY x.sessions DESC, &&skip_noncdb.x.con_id,
         x.machine, x.process
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Idle connections for more than N hours';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
WITH x AS (
SELECT &&skip_noncdb.con_id,
TRUNC(last_call_et/3600) hours_idle,status, /* &&section_id..&&report_sequence. */
COUNT(*) sessions,
CASE TRUNC(last_call_et/3600) WHEN 0 THEN ROUND(AVG(last_call_et)) END avg_secs,
CASE TRUNC(last_call_et/3600) WHEN 0 THEN MEDIAN(last_call_et) END med_secs
FROM     &&gv_object_prefix.session 
where    program like '%JDBC%'
AND      status <> 'ACTIVE' 
GROUP BY &&skip_noncdb.con_id,
         status,TRUNC(last_call_et/3600) 
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY x.hours_idle, x.status
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Idle connections per Status, JVM and Program';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
WITH x AS (
SELECT TRUNC(last_call_et/3600) hours_idle, /* &&section_id..&&report_sequence. */
status,
&&skip_noncdb.con_id,
machine, 
program,
COUNT(*) sessions, 
CASE TRUNC(last_call_et/3600) WHEN 0 THEN ROUND(AVG(last_call_et)) END avg_secs,
CASE TRUNC(last_call_et/3600) WHEN 0 THEN MEDIAN(last_call_et) END med_secs
FROM &&gv_object_prefix.session 
where program like '%JDBC%'
--and  last_call_et > 3600
and status <> 'ACTIVE' 
GROUP BY TRUNC(last_call_et/3600), status, 
         &&skip_noncdb.con_id,
		 machine, program 
)
SELECT x.*
       &&skip_noncdb.,c.name con_name
  FROM x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
ORDER BY x.hours_idle, x.status, 
       &&skip_noncdb.x.con_id,
	   x.machine, x.program
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Active connections';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
SELECT s.last_call_et last_call_et_secs,  /* &&section_id..&&report_sequence. */
s.*,  t.sql_text current_sql, t2.sql_text prev_sql 
     &&skip_noncdb.,c.name con_name
FROM &&gv_object_prefix.session s
     &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
     LEFT OUTER JOIN &&gv_object_prefix.sql t
     ON s.inst_id =t.inst_id
     and s.sql_address =t.address
     and s.sql_hash_value =t.hash_value
     and s.sql_id = t.sql_id
     and s.sql_child_number = t.child_number
     &&skip_noncdb.and s.con_id = t.con_id
	 LEFT OUTER JOIN &&gv_object_prefix.sql t2
     ON s.inst_id =t2.inst_id
     and s.prev_sql_addr =t2.address
     and s.prev_hash_value =t2.hash_value
     and s.prev_sql_id = t2.sql_id
     and s.prev_child_number = t2.child_number
     &&skip_noncdb.and s.con_id = t2.con_id
WHERE s.program like '%JDBC%' 
AND   s.status = 'ACTIVE' 
ORDER BY last_call_et
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Idle connections';
DEF main_table = '&&gv_view_prefix.SESSION';
BEGIN
  :sql_text := q'[
-- from monitor_jdbc_conn.sql 
SELECT s.last_call_et last_call_et_secs,  /* &&section_id..&&report_sequence. */
s.*,  t.sql_text current_sql, t2.sql_text prev_sql 
     &&skip_noncdb.,c.name con_name
FROM &&gv_object_prefix.session s
     &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = s.con_id
     LEFT OUTER JOIN &&gv_object_prefix.sql t
     ON s.inst_id =t.inst_id
     and s.sql_address =t.address
     and s.sql_hash_value =t.hash_value
     and s.sql_id = t.sql_id
     and s.sql_child_number = t.child_number
     &&skip_noncdb.and s.con_id = t.con_id
	 LEFT OUTER JOIN &&gv_object_prefix.sql t2
     ON s.inst_id =t2.inst_id
     and s.prev_sql_addr =t2.address
     and s.prev_hash_value =t2.hash_value
     and s.prev_sql_id = t2.sql_id
     and s.prev_child_number = t2.child_number
     &&skip_noncdb.and s.con_id = t2.con_id
WHERE s.program like '%JDBC%' 
and s.status <> 'ACTIVE' 
ORDER BY last_call_et
]';
END;
/
@@edb360_9a_pre_one.sql       

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

