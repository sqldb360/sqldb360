@@&&edb360_0g.tkprof.sql
DEF section_id = '1b';
DEF section_name = 'Security';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Users';
DEF main_table = '&&dva_view_prefix.USERS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM &&dva_object_prefix.users
 ORDER BY username
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Profiles';
DEF main_table = '&&dva_view_prefix.PROFILES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
  FROM &&dva_object_prefix.profiles
 ORDER BY profile
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Users With Sensitive Roles Granted';
DEF main_table = '&&dva_view_prefix.ROLE_PRIVS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       p.* from &&dva_object_prefix.role_privs p
where (p.granted_role in 
('AQ_ADMINISTRATOR_ROLE','DELETE_CATALOG_ROLE','DBA','DM_CATALOG_ROLE','EXECUTE_CATALOG_ROLE',
'EXP_FULL_DATABASE','GATHER_SYSTEM_STATISTICS','HS_ADMIN_ROLE','IMP_FULL_DATABASE',
   'JAVASYSPRIV','JAVA_ADMIN','JAVA_DEPLOY','LOGSTDBY_ADMINISTRATOR',
   'OEM_MONITOR','OLAP_DBA','RECOVERY_CATALOG_OWNER','SCHEDULER_ADMIN',
   'SELECT_CATALOG_ROLE','WM_ADMIN_ROLE','XDBADMIN','RESOURCE')
    or p.granted_role like '%ANY%')
   and p.grantee not in &&exclusion_list.
   and p.grantee not in &&exclusion_list2.
   and p.grantee in (select username from &&dva_object_prefix.users)
order by p.grantee, p.granted_role
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Users With Inappropriate Tablespaces Granted';
DEF main_table = '&&dva_view_prefix.USERS';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       * from &&dva_object_prefix.users u
where (default_tablespace in ('SYSAUX','SYSTEM') or
temporary_tablespace not in
   (select tablespace_name
   from &&dva_object_prefix.tablespaces
   where contents = 'TEMPORARY'
   and status = 'ONLINE'))
and NVL((SELECT COUNT(*) 
         FROM &&dva_object_prefix.tablespace_groups g, &&dva_object_prefix.tablespaces t 
         WHERE g.group_name = u.temporary_tablespace 
         AND t.tablespace_name = g.tablespace_name 
         AND t.contents IN ('PERMANENT', 'UNDO')), 0) != 0
and username not in &&exclusion_list.
and username not in &&exclusion_list2.
order by username
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
DEF main_table = '&&dva_view_prefix.PROFILES';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
WITH
expanded_profiles AS (
SELECT /*+  NO_MERGE  */
       profile,
       limit,
       CONNECT_BY_ROOT limit top_limit,
       level nest_level
  FROM (SELECT profile, limit FROM dba_profiles WHERE resource_name = 'PASSWORD_VERIFY_FUNCTION')
CONNECT BY PRIOR profile = limit
),
users_with_profile AS (
SELECT /*+  NO_MERGE  */
       profile,
       count(*) cnt
  FROM dba_users
 GROUP BY profile
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       p.profile,
       DECODE(nest_level,2,'DEFAULT ('||top_limit||')',top_limit) profile_limit_setting,
       DECODE(top_limit,'NULL',' ',NVL2(object_name,owner||'.'||object_name,'** FUNCTION NOT FOUND **')) verification_function,
       last_ddl_time,
       status,
       NVL(TO_CHAR(u.cnt),'<NONE>') assigned_users
  FROM dba_objects o,
       expanded_profiles p,
       users_with_profile u
 WHERE p.top_limit = o.object_name (+)
   AND p.profile = u.profile (+)
   AND NOT (limit = 'DEFAULT' AND top_limit = 'DEFAULT')
 ORDER BY 1,2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Users with CREATE SESSION privilege';
DEF main_table = '&&dva_view_prefix.USERS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ DISTINCT 
       u.NAME "SCHEMA", d.account_status
  FROM SYS.user$ u, &&dva_object_prefix.users d
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
   AND u.NAME IN (SELECT DISTINCT owner
                    FROM &&dva_object_prefix.objects
                   WHERE object_type != 'SYNONYM')
ORDER BY 1
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Roles (not default)';
DEF main_table ='&&dva_view_prefix.ROLES';
BEGIN
  :sql_text := q'[
-- by berx
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
* from   &&dva_object_prefix.roles
where  role not in (SELECT ROLE FROM &&dva_object_prefix.roles WHERE ORACLE_MAINTAINED='Y')
]';
END;
/
&&skip_ver_le_11.@@edb360_9a_pre_one.sql

DEF title = 'Role Privileges (not default)';
DEF main_table ='&&dva_view_prefix.ROLE_PRIVS';
BEGIN
  :sql_text := q'[
-- by berx
select  /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
*  from   &&dva_object_prefix.role_privs
where  1=1
  AND GRANTED_ROLE not in (SELECT ROLE FROM &&dva_object_prefix.roles WHERE ORACLE_MAINTAINED='Y')
]';
END;
/
&&skip_ver_le_11.@@edb360_9a_pre_one.sql

DEF title = 'System Grants (not default)';
DEF main_table='&&dva_view_prefix.SYS_PRIVS';
BEGIN
  :sql_text := q'[
-- by berx
select  /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
*  from   &&dva_object_prefix.sys_privs
where  1=1
  AND GRANTEE not in (SELECT ROLE FROM &&dva_object_prefix.roles WHERE ORACLE_MAINTAINED='Y')
  AND GRANTEE not in (SELECT USERNAME FROM &&dva_object_prefix.users WHERE ORACLE_MAINTAINED='Y')
]';
END;
/
&&skip_ver_le_11.@@edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
