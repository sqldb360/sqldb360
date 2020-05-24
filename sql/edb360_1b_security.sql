@@&&edb360_0g.tkprof.sql
DEF section_id = '1b';
DEF section_name = 'Security';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

COL default_tablespace    heading 'Default|Tablespace'
COL temporary_tablespace  heading 'Temporary|Tablespace'
COL local_temp_tablespace heading 'Local Temp|Tablespace'
col external_name         heading 'External|Name'

DEF title = 'Users';
DEF main_table = '&&cdb_view_prefix.USERS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.users x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY x.username
          &&skip_noncdb.,x.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Profiles';
DEF main_table = '&&cdb_view_prefix.PROFILES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       x.*
       &&skip_noncdb.,c.name con_name
  FROM &&cdb_object_prefix.profiles x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 ORDER BY x.profile, x.resource_type, x.resource_name
          &&skip_noncdb.,x.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Users With Sensitive Roles Granted';
DEF main_table = '&&cdb_view_prefix.ROLE_PRIVS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.*
       &&skip_noncdb.,c.name con_name 
  FROM &&cdb_object_prefix.role_privs x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE (x.granted_role in 
('AQ_ADMINISTRATOR_ROLE','DELETE_CATALOG_ROLE','DBA','DM_CATALOG_ROLE','EXECUTE_CATALOG_ROLE',
'EXP_FULL_DATABASE','GATHER_SYSTEM_STATISTICS','HS_ADMIN_ROLE','IMP_FULL_DATABASE',
   'JAVASYSPRIV','JAVA_ADMIN','JAVA_DEPLOY','LOGSTDBY_ADMINISTRATOR',
   'OEM_MONITOR','OLAP_DBA','RECOVERY_CATALOG_OWNER','SCHEDULER_ADMIN',
   'SELECT_CATALOG_ROLE','WM_ADMIN_ROLE','XDBADMIN','RESOURCE')
    or x.granted_role like '%ANY%')
   and x.grantee not in &&exclusion_list.
   and x.grantee not in &&exclusion_list2.
   and (x.grantee
       &&skip_noncdb.,x.con_id
	   ) IN (SELECT u.username
	              &&skip_noncdb., u.con_id 
		     FROM &&cdb_object_prefix.users u)
order by x.grantee, x.granted_role
&&skip_noncdb.,x.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Users With Inappropriate Tablespaces Granted';
DEF main_table = '&&cdb_view_prefix.USERS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
&&skip_noncdb.WITH c AS (SELECT value FROM &&v_view_prefix.system_parameter2 WHERE name = 'common_user_prefix')
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       x.* 
       &&skip_noncdb.,c.name con_name
FROM   &&cdb_object_prefix.users x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id, c
WHERE  (x.default_tablespace in ('SYSAUX','SYSTEM') 
or (x.temporary_tablespace
   &&skip_noncdb.,x.con_id
   ) not in
   (select t.tablespace_name
          &&skip_noncdb.,t.con_id
   from &&cdb_object_prefix.tablespaces t
   where t.contents = 'TEMPORARY'
   and t.status = 'ONLINE'))
and NVL((SELECT COUNT(*) 
         FROM &&cdb_object_prefix.tablespace_groups g, &&cdb_object_prefix.tablespaces t 
         WHERE g.group_name = x.temporary_tablespace 
		 &&skip_noncdb.AND g.con_id = x.con_id
		 &&skip_noncdb.AND t.con_id = g.con_id 
         AND t.tablespace_name = g.tablespace_name 
         AND t.contents IN ('PERMANENT', 'UNDO')), 0) != 0
and x.username not in &&exclusion_list.
and x.username not in &&exclusion_list2.
 order by x.username
         &&skip_noncdb.,x.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Proxy Users';
DEF main_table = 'PROXY_USERS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ *
  FROM proxy_users
 ORDER BY client
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Profile Password Verification Functions';
DEF main_table = '&&cdb_view_prefix.PROFILES';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
WITH p AS (
SELECT * FROM &&cdb_view_prefix.profiles 
WHERE  resource_name = 'PASSWORD_VERIFY_FUNCTION'
), expanded_profiles AS (
SELECT /*+  NO_MERGE  */
       &&skip_noncdb.con_id,
       profile,
       limit,
       CONNECT_BY_ROOT limit top_limit,
       level nest_level
  FROM p
CONNECT BY PRIOR profile = limit
&&skip_noncdb.AND PRIOR con_id = con_id
),
users_with_profile AS (
SELECT /*+  NO_MERGE  */
       &&skip_noncdb.con_id,
       profile,
       count(*) cnt
  FROM &&cdb_view_prefix.users
 GROUP BY 
       &&skip_noncdb.con_id,
       profile
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       &&skip_noncdb.x.con_id,
       x.profile,
       DECODE(x.nest_level,2,'DEFAULT ('||x.top_limit||')',x.top_limit) profile_limit_setting,
       DECODE(x.top_limit,'NULL',' ',NVL2(o.object_name,o.owner||'.'||o.object_name,'** FUNCTION NOT FOUND **')) verification_function,
       o.last_ddl_time,
       o.status,
       NVL(TO_CHAR(u.cnt),'<NONE>') assigned_users
       &&skip_noncdb.,c.name con_name
  FROM 
       expanded_profiles x
	   LEFT OUTER JOIN &&cdb_view_prefix.objects o ON x.top_limit = o.object_name &&skip_noncdb.AND x.con_id = o.con_id 
	   LEFT OUTER JOIN users_with_profile u ON x.profile = u.profile &&skip_noncdb.AND x.con_id = u.con_id
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
 WHERE NOT (x.limit = 'DEFAULT' AND x.top_limit = 'DEFAULT')
 ORDER BY 1,2,3
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Users with CREATE SESSION privilege';
DEF main_table = '&&cdb_view_prefix.USERS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ DISTINCT 
       &&skip_noncdb.d.con_id, 
       d.username "SCHEMA", d.account_status
       &&skip_noncdb.,c.name con_name
  FROM SYS.user$ u
     , &&cdb_object_prefix.users d
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = d.con_id
 WHERE u.NAME = d.username
   AND d.account_status NOT LIKE '%LOCKED%'
   AND u.type# = 1
   AND u.NAME != 'SYS'
   AND u.NAME != 'SYSTEM'
   AND u.user# IN (
              SELECT     grantee#
                    FROM SYS.sysauth$
              CONNECT BY PRIOR grantee# = privilege#
              START WITH privilege# =
                                     (SELECT PRIVILEGE
                                        FROM SYS.system_privilege_map
                                       WHERE NAME = 'CREATE SESSION'))
   AND (d.username
       &&skip_noncdb.,d.con_id
       ) IN (SELECT DISTINCT owner
                           &&skip_noncdb., con_id
                        FROM   &&cdb_object_prefix.objects
                        WHERE  object_type != 'SYNONYM')
ORDER BY d.username
       &&skip_noncdb., d.con_id
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Roles (not default)';
DEF main_table ='&&cdb_view_prefix.ROLES';
BEGIN
  :sql_text := q'[
-- by berx
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
x.* 
&&skip_noncdb.,c.name con_name
FROM   &&cdb_object_prefix.roles x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
WHERE  (x.role
       &&skip_noncdb.,x.con_id
       ) not in (SELECT ROLE
                       &&skip_noncdb., con_id 
                   FROM &&cdb_object_prefix.roles WHERE ORACLE_MAINTAINED='Y') 
ORDER BY 1
       &&skip_noncdb., x.con_id
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'Role Privileges (not default)';
DEF main_table ='&&cdb_view_prefix.ROLE_PRIVS';
BEGIN
  :sql_text := q'[
-- by berx
select  /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
x.*  
&&skip_noncdb.,c.name con_name
from   &&cdb_object_prefix.role_privs x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
where  1=1
  AND (x.GRANTED_ROLE
      &&skip_noncdb.,x.con_id
      ) not in (SELECT ROLE
                       &&skip_noncdb., con_id 
                  FROM &&cdb_object_prefix.roles WHERE ORACLE_MAINTAINED='Y') 
ORDER BY 1,2
       &&skip_noncdb., x.con_id
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

DEF title = 'System Grants (not default)';
DEF main_table='&&cdb_view_prefix.SYS_PRIVS';
BEGIN
  :sql_text := q'[
-- by berx
select  /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
x.*  
&&skip_noncdb.,c.name con_name
FROM   &&cdb_object_prefix.sys_privs x
       &&skip_noncdb.LEFT OUTER JOIN &&v_object_prefix.containers c ON c.con_id = x.con_id
WHERE  1=1
  AND (x.GRANTEE
      &&skip_noncdb.,x.con_id
      ) not in (SELECT ROLE 
                      &&skip_noncdb., con_id 
                FROM   &&cdb_object_prefix.roles WHERE ORACLE_MAINTAINED='Y')
  AND (x.GRANTEE
      &&skip_noncdb.,x.con_id
      ) not in (SELECT USERNAME 
                      &&skip_noncdb., con_id 
                FROM   &&cdb_object_prefix.users WHERE ORACLE_MAINTAINED='Y')
]';
END;
/
@@&&skip_ver_le_11.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

COL default_tablespace    clear
COL temporary_tablespace  clear
COL local_temp_tablespace clear
col external_name         clear
