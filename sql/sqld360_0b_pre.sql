--WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET TERM ON; 
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SET TIM OFF;
SET TIMI OFF;
CL COL;
COL row_num FOR 9999999 HEA '#' PRI;

-- version
DEF sqld360_vYYNN = 'v1801';
DEF sqld360_vrsn = '&&sqld360_vYYNN. (2018-01-13)';
DEF sqld360_prefix = 'sqld360';

-- parameters
PRO
PRO Parameter 1: 
PRO SQL_ID of the SQL to be extracted (required)
PRO
COL sqld360_sqlid new_V sqld360_sqlid FOR A15;
SELECT TRIM('&1.') sqld360_sqlid FROM DUAL;

WHENEVER SQLERROR EXIT;
DECLARE
  sqlid_length NUMBER;
BEGIN
  SELECT LENGTH(TRANSLATE('&&sqld360_sqlid.',
                   'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHJKLMNOPQRSTUVWXYZ-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?',
                   'abcdefghijklmnopqrstuvwxyz0123456789')) 
    INTO sqlid_length
    FROM DUAL;

  -- SQLID should be 13 chars, at least today in 2016 :-)
  IF sqlid_length <> 13 THEN
    RAISE_APPLICATION_ERROR(-20100, 'SQL ID provided looks incorrect!!!');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;

--set a bind too
VAR sqld360_sqlid VARCHAR2(13);
BEGIN 
  :sqld360_sqlid := '&&sqld360_sqlid.';
END;
/


BEGIN  
  -- if standalone execution then need to insert metadata   
  IF '&&from_edb360.' = '' THEN
    -- no need to clean, it's a GTT 
       -- false, user might execute twice in a row in the same session
    DELETE plan_table WHERE remarks = '&&sqld360_sqlid.' AND statement_id IN ('SQLD360_SQLID', 'SQLD360_ASH_LOAD');
    -- column options set to 1 is safe here, if no diagnostics then ASH is not extracted at all anyway
    INSERT INTO plan_table (statement_id, timestamp, operation, options) VALUES ('SQLD360_SQLID',sysdate,'&&sqld360_sqlid.','1');
    --INSERT INTO plan_table (statement_id, timestamp, operation) VALUES ('SQLD360_ASH_LOAD',sysdate, NULL);
    INSERT INTO plan_table (statement_id, timestamp, operation, options) VALUES ('SQLD360_ASH_LOAD',sysdate, NULL, '&&sqld360_sqlid.');
  END IF;
END;
/  
  

PRO
PRO Parameter 2: 
PRO If your Database is licensed to use the Oracle Tuning pack please enter T.
PRO If you have a license for Diagnostics pack but not for Tuning pack, enter D.
PRO Be aware value N reduces the output content substantially. Avoid N if possible.
PRO
PRO Oracle Pack License? (Tuning, Diagnostics or None) [ T | D | N ] (required)
COL license_pack NEW_V license_pack FOR A1;
SELECT NVL(UPPER(SUBSTR(TRIM('&2.'), 1, 1)), '?') license_pack FROM DUAL;
WHENEVER SQLERROR EXIT SQL.SQLCODE;
BEGIN
  IF NOT '&&license_pack.' IN ('T', 'D', 'N') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Invalid Oracle Pack License "&&license_pack.". Valid values are T, D and N.');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;

PRO
SET TERM OFF;
COL diagnostics_pack NEW_V diagnostics_pack FOR A1;
SELECT CASE WHEN '&&license_pack.' IN ('T', 'D') THEN 'Y' ELSE 'N' END diagnostics_pack FROM DUAL;
COL skip_diagnostics NEW_V skip_diagnostics FOR A1;
SELECT CASE WHEN '&&license_pack.' IN ('T', 'D') THEN NULL ELSE 'Y' END skip_diagnostics FROM DUAL;
COL tuning_pack NEW_V tuning_pack FOR A1;
SELECT CASE WHEN '&&license_pack.' = 'T' THEN 'Y' ELSE 'N' END tuning_pack FROM DUAL;
COL skip_tuning NEW_V skip_tuning FOR A1;
SELECT CASE WHEN '&&license_pack.' = 'T' THEN NULL ELSE 'Y' END skip_tuning FROM DUAL;
SET TERM ON;
SELECT 'Be aware value "N" reduces output content substantially. Avoid "N" if possible.' warning FROM dual WHERE '&&license_pack.' = 'N';
BEGIN
  IF '&&license_pack.' = 'N' THEN
    DBMS_LOCK.SLEEP(10); -- sleep few seconds
  END IF;
END;
/


PRO
PRO Parameter 3:
PRO Name of an optional custom configuration file executed right after 
PRO sql/sqld360_00_config.sql. If such file name is provided, then corresponding file
PRO should exist under sqld360-master/sql. Filename is case sensitivive and its existence
PRO is not validated. Example: custom_config_01.sql
PRO If no custom configuration file is needed, simply hit the "return" key.
PRO
PRO Custom configuration filename? (optional)
COL custom_config_filename NEW_V custom_config_filename NOPRI;
SELECT NVL(TRIM('&3.'), 'null') custom_config_filename FROM DUAL;

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO custom configuration filename: "&&custom_config_filename."
PRO
SET SUF '';
@@&&custom_config_filename.
SET SUF sql;
@@&&custom_config_filename.

-- suppressing some unnecessary output
--SET TERM OFF;

-- get dbid
COL sqld360_dbid NEW_V sqld360_dbid;
SELECT TRIM(NVL('&&sqld360_conf_dbid.',TO_CHAR(dbid))) sqld360_dbid FROM v$database;

-- get dbmod
COL sqld360_dbmod NEW_V sqld360_dbmod;
SELECT LPAD(MOD(dbid,1e6),6,'6') sqld360_dbmod FROM v$database;

-- get host hash
COL host_hash NEW_V host_hash;
SELECT LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_hash FROM DUAL;

-- get instance number
COL connect_instance_number NEW_V connect_instance_number;
SELECT TO_CHAR(instance_number) connect_instance_number FROM v$instance;

-- get instance name 
COL connect_instance_name NEW_V connect_instance_name;
SELECT TO_CHAR(instance_name) connect_instance_name FROM v$instance;

-- get database name (up to 10, stop before first '.', no special characters)
COL database_name_short NEW_V database_name_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) database_name_short FROM DUAL;
SELECT SUBSTR('&&database_name_short.', 1, INSTR('&&database_name_short..', '.') - 1) database_name_short FROM DUAL;
SELECT TRANSLATE('&&database_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') database_name_short FROM DUAL;

-- get host name (up to 30, stop before first '.', no special characters)
COL host_name_short NEW_V host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) host_name_short FROM DUAL;
SELECT SUBSTR('&&host_name_short.', 1, INSTR('&&host_name_short..', '.') - 1) host_name_short FROM DUAL;
SELECT TRANSLATE('&&host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') host_name_short FROM DUAL;

-- get block_size
COL sqld360_db_block_size NEW_V sqld360_db_block_size;
SELECT TRIM(TO_NUMBER(value)) sqld360_db_block_size FROM v$system_parameter2 WHERE name = 'db_block_size';

COL history_days NEW_V history_days;
-- range: takes at least 31 days and at most as many as actual history, with a default of 31. parameter restricts within that range. 
SELECT TO_CHAR(LEAST(CEIL(SYSDATE - CAST(MIN(begin_interval_time) AS DATE)),  TO_NUMBER(NVL('&&sqld360_fromedb360_days.', '&&sqld360_conf_days.')))) history_days FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&sqld360_dbid.;
SELECT TO_CHAR(TO_DATE('&&sqld360_conf_date_to.', 'YYYY-MM-DD') - TO_DATE('&&sqld360_conf_date_from.', 'YYYY-MM-DD') + 1) history_days FROM DUAL WHERE '&&sqld360_conf_date_from.' != 'YYYY-MM-DD' AND '&&sqld360_conf_date_to.' != 'YYYY-MM-DD';
SELECT '0' history_days FROM DUAL WHERE NVL(TRIM('&&diagnostics_pack.'), 'N') = 'N';

-- get average number of Cores
COL avg_core_count NEW_V avg_core_count FOR A5;
SELECT TO_CHAR(ROUND(AVG(TO_NUMBER(value)),1)) avg_core_count FROM gv$osstat WHERE stat_name = 'NUM_CPU_CORES';

-- get average number of Threads
COL avg_thread_count NEW_V avg_thread_count FOR A6;
SELECT TO_CHAR(ROUND(AVG(TO_NUMBER(value)),1)) avg_thread_count FROM gv$osstat WHERE stat_name = 'NUM_CPUS';

-- get number of Hosts
COL hosts_count NEW_V hosts_count FOR A2;
SELECT TO_CHAR(COUNT(DISTINCT inst_id)) hosts_count FROM gv$osstat WHERE stat_name = 'NUM_CPU_CORES';

-- get cores_threads_hosts
COL cores_threads_hosts NEW_V cores_threads_hosts;
SELECT CASE TO_NUMBER('&&hosts_count.') WHEN 1 THEN 'cores:&&avg_core_count. threads:&&avg_thread_count.' ELSE 'cores:&&avg_core_count.(avg) threads:&&avg_thread_count.(avg) hosts:&&hosts_count.' END cores_threads_hosts FROM DUAL;

--SET TERM OFF;

-- Dates format
DEF sqld360_date_format = 'YYYY-MM-DD"T"HH24:MI:SS';
DEF sqld360_timestamp_format = 'YYYY-MM-DD"T"HH24:MI:SS.FF';
DEF sqld360_timestamp_tz_format = 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM';

COL sqld360_date_from NEW_V sqld360_date_from;
COL sqld360_date_to NEW_V sqld360_date_to;
SELECT CASE '&&sqld360_conf_date_from.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE - &&history_days., '&&sqld360_date_format.') ELSE '&&sqld360_conf_date_from.T00:00:00' END sqld360_date_from FROM DUAL;
SELECT CASE '&&sqld360_conf_date_to.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE, '&&sqld360_date_format.') ELSE '&&sqld360_conf_date_to.T23:59:59' END sqld360_date_to FROM DUAL;


--DEF skip_script = 'sql/sqld360_0f_skip_script.sql ';

-- number fo rows per report
COL row_num NEW_V row_num HEA '#' PRI;

-- get rdbms version
COL db_version NEW_V db_version;
SELECT version db_version FROM v$instance;
DEF skip_10g = '';
COL skip_10g NEW_V skip_10g;
SELECT '--' skip_10g FROM v$instance WHERE version LIKE '10%';
COL skip_11g NEW_V skip_11g;
SELECT '--' skip_11g FROM v$instance WHERE version LIKE '11%';
DEF skip_11r1 = '';
COL skip_11r1 NEW_V skip_11r1;
SELECT '--' skip_11r1 FROM v$instance WHERE version LIKE '11.1%';
DEF skip_11r201 = '';
COL skip_11r201 NEW_V skip_11r201;
SELECT '--' skip_11r201 FROM v$instance WHERE version LIKE '11.2.0.1%';
-- this is to bypass some bugs in 11.2.0.3 that can cause slowdown
DEF skip_11r203 = '';
COL skip_11r203 NEW_V skip_11r203;
SELECT '--' skip_11r203 FROM v$instance WHERE version LIKE '11.2.0.3%';
DEF skip_12c = '';
COL skip_12c NEW_V skip_12c;
SELECT '--' skip_12c FROM v$instance WHERE version LIKE '12.%';
DEF skip_12r101 = '';
COL skip_12r101 NEW_V skip_12r101;
SELECT '--' skip_12r101 FROM v$instance WHERE version LIKE '12.1.0.1%';
DEF skip_12r1 = '';
COL skip_12r1 NEW_V skip_12r1;
SELECT '--' skip_12r1 FROM v$instance WHERE version LIKE '12.1.%';

-- get average number of CPUs
COL avg_cpu_count NEW_V avg_cpu_count FOR A3;
SELECT ROUND(AVG(TO_NUMBER(value))) avg_cpu_count FROM gv$system_parameter2 WHERE name = 'cpu_count';

-- get total number of CPUs
COL sum_cpu_count NEW_V sum_cpu_count FOR A3;
SELECT SUM(TO_NUMBER(value)) sum_cpu_count FROM gv$system_parameter2 WHERE name = 'cpu_count';

-- determine if rac or single instance (null means rac)
COL is_single_instance NEW_V is_single_instance FOR A1;
SELECT CASE COUNT(*) WHEN 1 THEN 'Y' END is_single_instance FROM gv$instance;

-- timestamp on filename
COL sqld360_file_time NEW_V sqld360_file_time FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') sqld360_file_time FROM DUAL;

-- snapshot ranges
SELECT '0' history_days FROM DUAL WHERE TRIM('&&history_days.') IS NULL;
COL tool_sysdate NEW_V tool_sysdate;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') tool_sysdate FROM DUAL;
COL as_of_date NEW_V as_of_date;
SELECT ', as of '||TO_CHAR(SYSDATE, 'Dy Mon DD @HH12:MIAM') as_of_date FROM DUAL;
COL between_times NEW_V between_times;
COL between_dates NEW_V between_dates;
SELECT ', between &&sqld360_date_from. and &&sqld360_date_to.' between_dates FROM DUAL;

COL minimum_snap_id NEW_V minimum_snap_id;
SELECT NVL(TO_CHAR(MIN(snap_id)), '0') minimum_snap_id FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&sqld360_dbid. AND begin_interval_time > TO_DATE('&&sqld360_date_from.', '&&sqld360_date_format.');
SELECT '-1' minimum_snap_id FROM DUAL WHERE TRIM('&&minimum_snap_id.') IS NULL;
COL maximum_snap_id NEW_V maximum_snap_id;
SELECT NVL(TO_CHAR(MAX(snap_id)), '&&minimum_snap_id.') maximum_snap_id FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&sqld360_dbid. AND end_interval_time < TO_DATE('&&sqld360_date_to.', '&&sqld360_date_format.');
SELECT '-1' maximum_snap_id FROM DUAL WHERE TRIM('&&maximum_snap_id.') IS NULL;

-- Next two parameters are used for ASH calculations
COL sqld360_ashdiskfilter NEW_V sqld360_ashdiskfilter
SELECT 10 sqld360_ashdiskfilter FROM dual;
SELECT VALUE sqld360_ashdiskfilter FROM v$parameter2 WHERE name = '_ash_disk_filter_ratio';
COL sqld360_ashsample NEW_V sqld360_ashsample
SELECT 1 sqld360_ashsample FROM dual;
SELECT TO_NUMBER(TRUNC(VALUE/1000,3)) sqld360_ashsample FROM v$parameter2 WHERE name = '_ash_sampling_interval';
-- Formula is really simple, adjust the _ash_sampling_interval to seconds and multiply by _ash_disk_filter_ratio
COL sqld360_ashtimevalue NEW_V sqld360_ashtimevalue
SELECT TO_NUMBER(TRUNC(&&sqld360_ashsample.*&&sqld360_ashdiskfilter.,3)) sqld360_ashtimevalue FROM DUAL;

-- ebs
DEF ebs_release = '';
DEF ebs_system_name = '';
COL ebs_release NEW_V ebs_release;
COL ebs_system_name NEW_V ebs_system_name;
SELECT release_name ebs_release, applications_system_name ebs_system_name FROM applsys.fnd_product_groups WHERE ROWNUM = 1;

-- siebel
DEF siebel_schema = '';
DEF siebel_app_ver = '';
COL siebel_schema NEW_V siebel_schema;
COL siebel_app_ver NEW_V siebel_app_ver;
--SELECT owner siebel_schema FROM sys.dba_tab_columns WHERE table_name = 'S_REPOSITORY' AND column_name = 'ROW_ID' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT owner siebel_schema FROM dba_tab_columns WHERE table_name = 'S_REPOSITORY' AND column_name = 'ROW_ID' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT app_ver siebel_app_ver FROM &&siebel_schema..s_app_ver WHERE ROWNUM = 1;

-- psft
DEF psft_schema = '';
DEF psft_tools_rel = '';
COL psft_schema NEW_V psft_schema;
COL psft_tools_rel NEW_V psft_tools_rel;
--SELECT owner psft_schema FROM sys.dba_tab_columns WHERE table_name = 'PSSTATUS' AND column_name = 'TOOLSREL' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT owner psft_schema FROM dba_tab_columns WHERE table_name = 'PSSTATUS' AND column_name = 'TOOLSREL' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT toolsrel psft_tools_rel FROM &&psft_schema..psstatus WHERE ROWNUM = 1;

-- local or remote exec (local will be --) 
COL sqld360_remote_exec NEW_V sqld360_remote_exec FOR A20;
COL sqld360_local_exec NEW_V sqld360_local_exec FOR A20;
SELECT '--' sqld360_remote_exec FROM dual;
SELECT NULL sqld360_local_exec FROM dual;
-- this SQL errors out in 11.1.0.6 and < 10.2.0.5, this is expected, the value is used only >= 11.2
SELECT CASE WHEN a.port <> 0 AND a.machine <> b.host_name THEN NULL ELSE '--' END sqld360_remote_exec FROM v$session a, v$instance b WHERE sid = USERENV('SID');
SELECT CASE WHEN a.port <> 0 AND a.machine <> b.host_name THEN '--' ELSE NULL END sqld360_local_exec FROM v$session a, v$instance b WHERE sid = USERENV('SID');

-- udump mnd pid, oved here from 0c_post
-- get udump directory path
COL sqld360_udump_path NEW_V sqld360_udump_path FOR A500;
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') sqld360_udump_path FROM v$parameter2 WHERE name = 'user_dump_dest';

-- get diag_trace path (first SQL below is for 10g)
COL sqld360_diagtrace_path NEW_V sqld360_diagtrace_path FOR A500;
SELECT NULL sqld360_diagtrace_path FROM dual;
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') sqld360_diagtrace_path FROM v$diag_info WHERE name = 'Diag Trace';

-- get pid
COL sqld360_spid NEW_V sqld360_spid FOR A5;
SELECT TO_CHAR(spid) sqld360_spid FROM v$session s, v$process p WHERE s.sid = SYS_CONTEXT('USERENV', 'SID') AND p.addr = s.paddr;

-- get sqltxt and command_type
COL sqld360_sqltxt NEW_V sqld360_sqltxt
-- COMMAND_TYPE = 2 is INSERT, likely to never change (eventually will use X$KEACMDN / WRH$_SQLCOMMAND_NAME)
COL sqld360_is_insert NEW_V sqld360_is_insert
SELECT SUBSTR(sql_text,1,100) sqld360_sqltxt FROM v$sqltext_with_newlines WHERE sql_id = '&&sqld360_sqlid.' AND piece = 0 AND rownum = 1;
SELECT CASE WHEN command_type = 2 THEN 'Y' ELSE 'N' END sqld360_is_insert FROM v$sql WHERE sql_id = '&&sqld360_sqlid.' AND rownum = 1;
SELECT SUBSTR(sql_text,1,100) sqld360_sqltxt, CASE WHEN command_type = 2 THEN 'Y' ELSE 'N' END sqld360_is_insert FROM dba_hist_sqltext WHERE sql_id = '&&sqld360_sqlid.' AND rownum = 1;

-- get sql full text
VAR sqld360_fullsql CLOB;
EXEC :sqld360_fullsql := NULL;

BEGIN
 -- if available from AWR then grab it from there
 BEGIN
   SELECT sql_text
     INTO :sqld360_fullsql
     FROM dba_hist_sqltext
    WHERE sql_id = '&&sqld360_sqlid.';
 EXCEPTION WHEN NO_DATA_FOUND THEN NULL; -- this is intentional, will try next block
 END;

  IF :sqld360_fullsql IS NULL THEN
   SELECT sql_fulltext
     INTO :sqld360_fullsql
     FROM gv$sql
    WHERE sql_id = '&&sqld360_sqlid.'
      AND sql_fulltext IS NOT NULL
      AND ROWNUM = 1;
  END IF;

END;
/

VAR xplan_user VARCHAR2(30)
BEGIN

  SELECT parsing_schema_name
    INTO :xplan_user
    FROM gv$sql
   WHERE sql_id = '&&sqld360_sqlid.'
     AND rownum = 1;

EXCEPTION WHEN NO_DATA_FOUND THEN
  -- pick up one user that executed the SQL
  -- might give strange results for SQLs that run in
  -- different schemas where underlying objects are different
  SELECT parsing_schema_name
    INTO :xplan_user
    FROM dba_hist_sqlstat
   WHERE sql_id =  '&&sqld360_sqlid.'
     AND ROWNUM = 1;

END;
/
COL xplan_user NEW_V xplan_user
COL current_user NEW_V current_user
SELECT :xplan_user xplan_user FROM DUAL;
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') current_user FROM DUAL;

-- getting EXPLAIN PLAN FOR hoping to capture "warmer" dependencies
COL xplan_sql NEW_V xplan_sql
SELECT :sqld360_fullsql xplan_sql FROM DUAL;
ALTER SESSION SET CURRENT_SCHEMA = &&xplan_user.;
EXPLAIN PLAN FOR &&xplan_sql.
/
COL sqld360_xplan_sqlid NEW_V sqld360_xplan_sqlid
SELECT '' sqld360_xplan_sqlid FROM DUAL;
SELECT prev_sql_id sqld360_xplan_sqlid FROM v$session WHERE sid = USERENV('sid');
ALTER SESSION SET CURRENT_SCHEMA = &&current_user.;


-- get exact_matching_signature, force_matching_signature
COL exact_matching_signature NEW_V exact_matching_signature FOR 99999999999999999999999
COL force_matching_signature NEW_V force_matching_signature FOR 99999999999999999999999

-- this is to set a fake value in case SQL is not in memory and AWR
SELECT 0 exact_matching_signature, 0 force_matching_signature
  FROM DUAL
/

SELECT DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(:sqld360_fullsql,0) exact_matching_signature,
       DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(:sqld360_fullsql,1) force_matching_signature
  FROM dual
/

COL skip_force_match NEW_V skip_force_match
SELECT CASE WHEN '&&exact_matching_signature.' = '&&force_matching_signature.' THEN '--' END skip_force_match 
  FROM DUAL
/

-- inclusion config determine skip flags
COL sqld360_skip_html   NEW_V sqld360_skip_html;
COL sqld360_skip_xml    NEW_V sqld360_skip_xml;
COL sqld360_skip_text   NEW_V sqld360_skip_text;
COL sqld360_skip_csv    NEW_V sqld360_skip_csv;
COL sqld360_skip_line   NEW_V sqld360_skip_line;
COL sqld360_skip_pie    NEW_V sqld360_skip_pie;
COL sqld360_skip_bar    NEW_V sqld360_skip_bar;
COL sqld360_skip_tree   NEW_V sqld360_skip_tree;
COL sqld360_skip_bubble NEW_V sqld360_skip_bubble;
COL sqld360_skip_scatt  NEW_V sqld360_skip_scatt;

SELECT CASE '&&sqld360_conf_incl_html.'   WHEN 'N' THEN '--' END sqld360_skip_html   FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_xml.'    WHEN 'N' THEN '--' END sqld360_skip_xml    FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_text.'   WHEN 'N' THEN '--' END sqld360_skip_text   FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_csv.'    WHEN 'N' THEN '--' END sqld360_skip_csv    FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_line.'   WHEN 'N' THEN '--' END sqld360_skip_line   FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_pie.'    WHEN 'N' THEN '--' END sqld360_skip_pie    FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_bar.'    WHEN 'N' THEN '--' END sqld360_skip_bar    FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_tree.'   WHEN 'N' THEN '--' END sqld360_skip_tree   FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_bubble.' WHEN 'N' THEN '--' END sqld360_skip_bubble FROM DUAL;
SELECT CASE '&&sqld360_conf_incl_scatt.'  WHEN 'N' THEN '--' END sqld360_skip_scatt  FROM DUAL;

COL sqld360_skip_awrrpt NEW_V sqld360_skip_awrrpt;
SELECT CASE '&&sqld360_conf_incl_awrrpt.' WHEN 'N' THEN '--' END sqld360_skip_awrrpt FROM DUAL;

COL sqld360_skip_ashrpt NEW_V sqld360_skip_ashrpt;
SELECT CASE '&&sqld360_conf_incl_ashrpt.' WHEN 'N' THEN '--' END sqld360_skip_ashrpt FROM DUAL;

COL sqld360_skip_sqlmon NEW_V sqld360_skip_sqlmon;
SELECT CASE '&&sqld360_conf_incl_sqlmon.' WHEN 'N' THEN '--' END sqld360_skip_sqlmon FROM DUAL;

COL sqld360_skip_sta NEW_V sqld360_skip_sta;
SELECT CASE '&&sqld360_conf_incl_sta.' WHEN 'N' THEN '--' END sqld360_skip_sta FROM DUAL;

COL sqld360_skip_eadam NEW_V sqld360_skip_eadam;
SELECT CASE '&&sqld360_conf_incl_eadam.' WHEN 'N' THEN '--' END sqld360_skip_eadam FROM DUAL;

COL sqld360_skip_rawash NEW_V sqld360_skip_rawash;
SELECT CASE '&&sqld360_conf_incl_rawash.' WHEN 'N' THEN '--' END sqld360_skip_rawash FROM DUAL;

COL sqld360_skip_stats_h NEW_V sqld360_skip_stats_h;
SELECT CASE '&&sqld360_conf_incl_stats_h.' WHEN 'N' THEN '--' END sqld360_skip_stats_h FROM DUAL;

COL sqld360_skip_fmatch NEW_V sqld360_skip_fmatch;
SELECT CASE '&&sqld360_conf_incl_fmatch.' WHEN 'N' THEN '--' END sqld360_skip_fmatch FROM DUAL;

COL sqld360_skip_metadata NEW_V sqld360_skip_metadata;
SELECT CASE '&&sqld360_conf_incl_metadata.' WHEN 'N' THEN '--' END sqld360_skip_metadata FROM DUAL;

COL sqld360_skip_stats NEW_V sqld360_skip_stats;
SELECT CASE '&&sqld360_conf_incl_stats.' WHEN 'N' THEN '--' END sqld360_skip_stats FROM DUAL;

COL sqld360_skip_tcb NEW_V sqld360_skip_tcb;
SELECT CASE '&&sqld360_conf_incl_tcb.' WHEN 'N' THEN '--' END sqld360_skip_tcb FROM DUAL;

COL sqld360_skip_cboenv NEW_V sqld360_skip_cboenv;
SELECT CASE '&&sqld360_conf_incl_cboenv.' WHEN 'N' THEN '--' END sqld360_skip_cboenv FROM DUAL;

COL sqld360_tcb_exp_data NEW_V sqld360_tcb_exp_data;
COL sqld360_tcb_exp_sample NEW_V sqld360_tcb_exp_sample;
SELECT CASE WHEN '&&sqld360_conf_tcb_sample.' BETWEEN '1' AND '100' THEN 'TRUE' ELSE 'FALSE' END sqld360_tcb_exp_data, LEAST(TO_NUMBER('&&sqld360_conf_tcb_sample.'),100) sqld360_tcb_exp_sample FROM dual;

COL sqld360_skip_objd NEW_V sqld360_skip_objd;
SELECT CASE '&&sqld360_conf_incl_obj_dept.' WHEN 'N' THEN '--' END sqld360_skip_objd FROM DUAL;

COL sqld360_skip_obj_ashbased NEW_V sqld360_skip_obj_ashbased;
SELECT CASE '&&sqld360_conf_incl_obj_ashbased.' WHEN 'N' THEN '--' END sqld360_skip_obj_ashbased FROM DUAL;

COL sqld360_skip_lowhigh NEW_V sqld360_skip_lowhigh;
SELECT CASE '&&sqld360_conf_translate_lowhigh.' WHEN 'N' THEN '--' END sqld360_skip_lowhigh FROM DUAL;

COL sqld360_has_plsql NEW_V sqld360_has_plsql;
SELECT CASE WHEN SUM(has_plsql) = 0 THEN '--' ELSE NULL END sqld360_has_plsql 
  FROM (SELECT COUNT(*) has_plsql
          FROM gv$sql
         WHERE sql_id = '&&sqld360_sqlid.' 
           AND plsql_exec_time <> 0 
        UNION ALL 
        SELECT COUNT(*) 
          FROM dba_hist_sqlstat
         WHERE sql_id = '&&sqld360_sqlid.' 
           AND plsexec_time_delta <> 0);

-- this is to avoid the whole observation block to error if the user can't just read stats_h because of grants
COL sqld360_no_read_stats_h new_V sqld360_no_read_stats_h
SELECT '--' sqld360_no_read_stats_h FROM DUAL;
SELECT NULL sqld360_no_read_stats_h FROM sys.wri$_optstat_tab_history WHERE rownum <= 1;

--this is the divisor variable, will be used in the formula
COL sqld360_awr_timescale_d NEW_V sqld360_awr_timescale_d
--this is the label variable, will be used in the Y-axis label
COL sqld360_awr_timescale_l NEW_V sqld360_awr_timescale_l
-- Consider "ms" the exception, everything else goes to default
SELECT CASE WHEN '&&sqld360_conf_awr_timescale.' = 'ms' THEN '1e3' ELSE '1e6'  END sqld360_awr_timescale_d, CASE WHEN '&&sqld360_conf_awr_timescale.' = 'ms' THEN 'ms'  ELSE 'secs' END sqld360_awr_timescale_l FROM DUAL;



-- setup
DEF main_table = '';
DEF title = '';
DEF title_no_spaces = '';
DEF title_suffix = '';
DEF common_sqld360_prefix = '&&sqld360_prefix._&&sqld360_dbmod._&&sqld360_sqlid.';
DEF sqld360_main_report = '00001_&&common_sqld360_prefix._index';
DEF sqld360_log = '00002_&&common_sqld360_prefix._log';
-- this is for eDB360 to pull the log in case the execution fails
UPDATE plan_table SET remarks = '&&sqld360_log..txt'  WHERE statement_id = 'SQLD360_SQLID' and operation = '&&sqld360_sqlid.';
DEF sqld360_tkprof = '00003_&&common_sqld360_prefix._tkprof';
DEF sqld360_main_filename = '&&common_sqld360_prefix._&&host_hash.';  -- need to change this
DEF sqld360_log2 = '00004_&&common_sqld360_prefix._log2';
DEF sqld360_tracefile_identifier = '&&common_sqld360_prefix.';
DEF sqld360_copyright = ' (c) 2015';
DEF top_level_hints = 'NO_MERGE';
DEF sq_fact_hints = 'MATERIALIZE NO_MERGE';
DEF ds_hint = 'DYNAMIC_SAMPLING(4)';
DEF def_max_rows = '50000';
DEF max_rows = '5e4';
DEF num_parts = '100';
--DEF translate_lowhigh = 'Y';
DEF default_dir = 'SQLD360_DIR'
DEF sqlmon_date_mask = 'YYYYMMDDHH24MISS';
DEF sqlmon_text = 'Y';
DEF sqlmon_active = 'Y';
DEF sqlmon_hist = 'Y';
--DEF sqlmon_max_reports = '12';
DEF ash_date_mask = 'YYYYMMDDHH24MISS';
DEF ash_text = 'Y';
DEF ash_html = 'Y';
DEF ash_mem = 'Y';
DEF ash_awr = 'Y';
DEF ash_max_reports = '12';
--DEF skip_tcb = '';
--DEF skip_ash_rpt = '--';
-- I really don't like this, I would rather insert some metadata into the plan table and join back (keep an eye on it, 2016/09/27)
DEF wait_class_colors = 'CASE wait_class WHEN ''''CPU'''' THEN ''''34CF27'''' WHEN ''''Scheduler'''' THEN ''''9FFA9D'''' WHEN ''''User I/O'''' THEN ''''0252D7'''' WHEN ''''System I/O'''' THEN ''''1E96DD'''' ';
DEF wait_class_colors2 = ' WHEN ''''Concurrency'''' THEN ''''871C12'''' WHEN ''''Application'''' THEN ''''C42A05'''' WHEN ''''Commit'''' THEN ''''EA6A05'''' WHEN ''''Configuration'''' THEN ''''594611''''  ';
DEF wait_class_colors3 = ' WHEN ''''Administrative'''' THEN ''''75763E''''  WHEN ''''Network'''' THEN ''''989779'''' WHEN ''''Other'''' THEN ''''F571A0'''' ';
DEF wait_class_colors4 = ' WHEN ''''Cluster'''' THEN ''''CEC3B5'''' WHEN ''''Queueing'''' THEN ''''C6BAA5'''' END';
--DEF wait_class_colors =  "CASE wait_class WHEN 'CPU' THEN '34CF27' WHEN 'Scheduler' THEN '9FFA9D' WHEN 'User I/O' THEN '0252D7' WHEN 'System I/O' THEN '1E96DD' ";
--DEF wait_class_colors2 = " WHEN 'Concurrency' THEN '871C12' WHEN 'Application' THEN 'C42A05' WHEN 'Commit' THEN 'EA6A05' WHEN 'Configuration' THEN '594611'  ";
--DEF wait_class_colors3 = " WHEN 'Administrative' THEN '75763E'  WHEN 'Network' THEN '989779' WHEN 'Other' THEN 'F571A0' ";
--DEF wait_class_colors4 = " WHEN 'Cluster' THEN 'CEC3B5' WHEN 'Queueing' THEN 'C6BAA5' END";
DEF wait_class_colors_s = 'CASE wait_class WHEN ''''CPU'''' THEN ''''color: ''''''''#34CF27'''''''''''' WHEN ''''Scheduler'''' THEN ''''color: ''''''''#9FFA9D'''''''''''' WHEN ''''User I/O'''' THEN ''''color: ''''''''#0252D7'''''''''''' WHEN ''''System I/O'''' THEN ''''color: ''''''''#1E96DD'''''''''''' ';
DEF wait_class_colors2_s = ' WHEN ''''Concurrency'''' THEN ''''color: ''''''''#871C12'''''''''''' WHEN ''''Application'''' THEN ''''color: ''''''''#C42A05'''''''''''' WHEN ''''Commit'''' THEN ''''color: ''''''''#EA6A05'''''''''''' WHEN ''''Configuration'''' THEN ''''color: ''''''''#594611''''''''''''  ';
DEF wait_class_colors3_s = ' WHEN ''''Administrative'''' THEN ''''color: ''''''''#75763E''''''''''''  WHEN ''''Network'''' THEN ''''color: ''''''''#989779'''''''''''' WHEN ''''Other'''' THEN ''''color: ''''''''#F571A0'''''''''''' ';
DEF wait_class_colors4_s = ' WHEN ''''Cluster'''' THEN ''''color: ''''''''#CEC3B5'''''''''''' WHEN ''''Queueing'''' THEN ''''color: ''''''''#C6BAA5'''''''''''' END';

--
DEF series_01 = ''
DEF series_02 = ''
DEF series_03 = ''
DEF series_04 = ''
DEF series_05 = ''
DEF series_06 = ''
DEF series_07 = ''
DEF series_08 = ''
DEF series_09 = ''
DEF series_10 = ''
DEF series_11 = ''
DEF series_12 = ''
DEF series_13 = ''
DEF series_14 = ''
DEF series_15 = ''
---
DEF skip_html = '';
DEF skip_xml = '';
DEF skip_text = '';
DEF skip_csv = '';
DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
DEF skip_bch = 'Y';
DEF skip_tch = 'Y';
DEF skip_uch = 'Y';
DEF skip_sch = 'Y';
DEF skip_all = '';

DEF abstract = '';
DEF abstract2 = '';
DEF foot = '';
DEF treeColor = '';
DEF bubbleMaxValue = '';
DEF bubbleSeries = 'series: {''CPU'': {color: ''#34CF27''}, ''I/O'': {color: ''#0252D7''}, ''Concurrency'': {color: ''#871C12''}, ''Cluster'': {color: ''#CEC3B5''}, ''Other'': {color: ''#C6BAA5''}, ''Multiple'': {color: ''#CCFFFF''}},';
DEF bubblesDetails = '';
DEF sql_text = '';
DEF chartype = '';
DEF stacked = '';
DEF haxis = '&&sqld360_sqlid. &&db_version. &&cores_threads_hosts.';
DEF vaxis = '';
DEF vaxis2 = '';
DEF vbaseline = '';
DEF tit_01 = '';
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
DEF exadata = '';
DEF max_col_number = '1';
DEF column_number = '1';
COL skip_html NEW_V skip_html;
COL skip_text NEW_V skip_text;
COL skip_csv NEW_V skip_csv;
COL skip_lch NEW_V skip_lch;
COL skip_pch NEW_V skip_pch;
COL skip_bch NEW_V skip_bch;
COL skip_all NEW_V skip_all;
COL dummy_01 NOPRI;
COL dummy_02 NOPRI;
COL dummy_03 NOPRI;
COL dummy_04 NOPRI;
COL dummy_05 NOPRI;
COL dummy_06 NOPRI;
COL dummy_07 NOPRI;
COL dummy_08 NOPRI;
COL dummy_09 NOPRI;
COL dummy_10 NOPRI;
COL dummy_11 NOPRI;
COL dummy_12 NOPRI;
COL dummy_13 NOPRI;
COL dummy_14 NOPRI;
COL dummy_15 NOPRI;
COL sqld360_time_stamp NEW_V sqld360_time_stamp FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') sqld360_time_stamp FROM DUAL;
COL hh_mm_ss NEW_V hh_mm_ss FOR A8;
COL title_no_spaces NEW_V title_no_spaces;
COL spool_filename NEW_V spool_filename;
COL one_spool_filename NEW_V one_spool_filename;
COL report_sequence NEW_V report_sequence;
VAR row_count NUMBER;
-- next two are using to hold the reports SQL
VAR sql_text CLOB;
VAR sql_text_backup CLOB;
--VAR sql_text_backup2 CLOB;
VAR sql_text_display CLOB;
VAR file_seq NUMBER;
VAR repo_seq NUMBER;
-- the next one is used to store the report sequence before moving to a second-layer page
VAR repo_seq_bck NUMBER;
EXEC :repo_seq := 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;
EXEC :repo_seq_bck := 0;
EXEC :file_seq := 5;
VAR get_time_t0 NUMBER;
VAR get_time_t1 NUMBER;
-- Exadata
ALTER SESSION SET "_serial_direct_read" = ALWAYS;
ALTER SESSION SET "_small_table_threshold" = 1001;
-- nls
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD/HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD/HH24:MI:SS.FF';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'YYYY-MM-DD/HH24:MI:SS.FF TZH:TZM';
-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
-- to work around bug 12672969
ALTER SESSION SET "_optimizer_order_by_elimination_enabled"=false; 
-- to work around bug 19567916
ALTER SESSION SET "_optimizer_aggr_groupby_elim"=false; 
-- workaround bug 21150273
ALTER SESSION SET "_optimizer_dsdir_usage_control"=0;
ALTER SESSION SET "_sql_plan_directive_mgmt_control" = 0;
ALTER SESSION SET optimizer_dynamic_sampling = 0;
-- workaround nigeria
ALTER SESSION SET "_gby_hash_aggregation_enabled" = TRUE;
ALTER SESSION SET "_hash_join_enabled" = TRUE;
ALTER SESSION SET "_optim_peek_user_binds" = TRUE;
ALTER SESSION SET "_optimizer_skip_scan_enabled" = TRUE;
ALTER SESSION SET "_optimizer_sortmerge_join_enabled" = TRUE;
ALTER SESSION SET cursor_sharing = EXACT;
ALTER SESSION SET db_file_multiblock_read_count = 128;
ALTER SESSION SET optimizer_index_caching = 0;
-- to work around Siebel
ALTER SESSION SET optimizer_index_cost_adj = 100;
-- leaving the next one here to remember we used to set it
--ALTER SESSION SET optimizer_dynamic_sampling = 2;
ALTER SESSION SET "_always_semi_join" = CHOOSE;
ALTER SESSION SET "_and_pruning_enabled" = TRUE;
ALTER SESSION SET "_subquery_pruning_enabled" = TRUE;
-- workaround fairpoint
COL db_vers_ofe NEW_V db_vers_ofe;
SELECT TRIM('.' FROM TRIM('0' FROM version)) db_vers_ofe FROM v$instance;
ALTER SESSION SET optimizer_features_enable = '&&db_vers_ofe.';
-- tracing script in case it takes long to execute so we can diagnose it
ALTER SESSION SET MAX_DUMP_FILE_SIZE = '1G';
ALTER SESSION SET TRACEFILE_IDENTIFIER = "&&sqld360_tracefile_identifier.";
--ALTER SESSION SET STATISTICS_LEVEL = 'ALL';

-- keep tracing level as-is in eDB360 in case this is a "nested" execution 
BEGIN
 IF TO_NUMBER('&&sqld360_sqltrace_level.') > 0 AND '&&from_edb360.' IS NULL THEN
   EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT FOREVER, LEVEL &&sqld360_sqltrace_level.''';
 END IF;
END;
/

SET TERM OFF; 
SET HEA ON; 
SET LIN 32767; 
SET NEWP NONE; 
SET PAGES &&def_max_rows.; 
SET LONG 32000; 
SET LONGC 2000; 
SET WRA ON; 
SET TRIMS ON; 
SET TRIM ON; 
SET TI OFF; 
SET TIMI OFF; 
-- because of bug 26163790
--SET ARRAY 999; 
SET NUM 20; 
SET SQLBL ON; 
SET BLO .; 
SET RECSEP OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- log header
SPO &&sqld360_log..txt;
PRO begin log
PRO
host env
DEF;
SPO OFF;

-- main header
SPO &&sqld360_main_report..html;
@@sqld360_0d_html_header.sql
PRO </head>
PRO <body>
PRO <h1><em>&&sqld360_conf_tool_page.SQLd360</a></em> &&sqld360_vYYNN.: SQL 360-degree view &&sqld360_conf_all_pages_logo.</h1>
PRO
PRO <pre>
PRO sqlid:<a title="&&sqld360_sqltxt.">&&sqld360_sqlid.</a> dbname:&&sqld360_dbmod. version:&&db_version. host:&&host_hash. license:&&license_pack. days:&&history_days. today:&&sqld360_time_stamp.
PRO </pre>
PRO
SPO OFF;

-- zip
HOS zip -jq &&sqld360_main_filename._&&sqld360_file_time. js/sorttable.js
HOS zip -jq &&sqld360_main_filename._&&sqld360_file_time. js/SQLd360_img.jpg
HOS zip -jq &&sqld360_main_filename._&&sqld360_file_time. js/SQLd360_favicon.ico
HOS zip -jq &&sqld360_main_filename._&&sqld360_file_time. js/sql-formatter.js
HOS zip -jq &&sqld360_main_filename._&&sqld360_file_time. js/googlecode.css
HOS zip -jq &&sqld360_main_filename._&&sqld360_file_time. js/vs.css
HOS zip -jq &&sqld360_main_filename._&&sqld360_file_time. js/highlight.pack.js

--WHENEVER SQLERROR CONTINUE;
