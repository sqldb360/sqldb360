DEF section_id = '5b';
DEF section_name = 'SQL Monitor Reports';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'SQL Monitor Reports';
DEF main_table = 'GV$SQL_MONITOR';

@@sqld360_0s_pre_nondef

VAR myreport CLOB

-- text
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SET TERM OFF
SPO sqld360_sqlmon_&&sqld360_sqlid._driver_txt.sql
DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN
  FOR i IN (SELECT * FROM 
           (SELECT sid,
                   session_serial#,
                   sql_exec_start,
                   sql_exec_id,
                   inst_id
              FROM gv$sql_monitor 
             WHERE '&&tuning_pack.' = 'Y' 
               AND '&&sqlmon_text.' = 'Y'
               AND sql_id = '&&sqld360_sqlid.' 
               AND sql_text IS NOT NULL
               AND process_name = 'ora'
             ORDER BY
                   sql_exec_start DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_SQLTUNE.report_sql_monitor');
    put('( sql_id => ''&&sqld360_sqlid.''');
    put(', session_id => '||i.sid);
    put(', session_serial => '||i.session_serial#);
    put(', sql_exec_start => TO_DATE('''||TO_CHAR(i.sql_exec_start, '&&sqlmon_date_mask.')||''', ''&&sqlmon_date_mask.'')');
    put(', sql_exec_id => '||i.sql_exec_id);
    put(', inst_id => '||i.inst_id);
    put(', report_level => ''ALL''');
    put(', type => ''TEXT'' );');
    put('END;');
    put('/');
    put('PRINT :myreport;');
    put('SPO sqld360_sqlmon_&&sqld360_sqlid._'||i.sql_exec_id||'_'||LPAD(TO_CHAR(i.sql_exec_start, 'YYYYMMDDHH24MISS'), 14, '0')||'.txt;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
SPO sqld360_sqlmon_&&sqld360_sqlid..txt;
SELECT DBMS_SQLTUNE.report_sql_monitor_list(sql_id => '&&sqld360_sqlid.', type => 'TEXT') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_text.' = 'Y';
@sqld360_sqlmon_&&sqld360_sqlid._driver_txt.sql
SPO OFF;

-- active
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SPO sqld360_sqlmon_&&sqld360_sqlid._driver_active.sql
DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN
  FOR i IN (SELECT * FROM 
           (SELECT sid,
                   session_serial#,
                   sql_exec_start,
                   sql_exec_id,
                   inst_id
              FROM gv$sql_monitor 
             WHERE '&&tuning_pack.' = 'Y' 
               AND '&&sqlmon_active.' = 'Y'
               AND sql_id = '&&sqld360_sqlid.' 
               AND sql_text IS NOT NULL
               AND process_name = 'ora'
             ORDER BY
                   sql_exec_start DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_SQLTUNE.report_sql_monitor');
    put('( sql_id => ''&&sqld360_sqlid.''');
    put(', session_id => '||i.sid);
    put(', session_serial => '||i.session_serial#);
    put(', sql_exec_start => TO_DATE('''||TO_CHAR(i.sql_exec_start, '&&sqlmon_date_mask.')||''', ''&&sqlmon_date_mask.'')');
    put(', sql_exec_id => '||i.sql_exec_id);
    put(', inst_id => '||i.inst_id);
    put(', report_level => ''ALL''');
    put(', type => ''ACTIVE'' );');
    put('END;');
    put('/');
    put('SPO sqld360_sqlmon_&&sqld360_sqlid._'||i.sql_exec_id||'_'||LPAD(TO_CHAR(i.sql_exec_start, 'YYYYMMDDHH24MISS'), 14, '0')||'.html;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
SPO sqld360_sqlmon_&&sqld360_sqlid._list.html;
SELECT DBMS_SQLTUNE.report_sql_monitor_list(sql_id => '&&sqld360_sqlid.', type => 'HTML') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_active.' = 'Y';
SPO OFF;
@sqld360_sqlmon_&&sqld360_sqlid._driver_active.sql
SPO sqld360_sqlmon_&&sqld360_sqlid._detail.html;
SELECT DBMS_SQLTUNE.report_sql_detail(sql_id => '&&sqld360_sqlid.', report_level => 'ALL', type => 'ACTIVE') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_active.' = 'Y';
SPO OFF;


-- historical, based on elapsed, worst &&sqld360_conf_num_sqlmon_rep.
-- it errors out in < 12c but the error is not reported to screen/main files
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SPO sqld360_sqlmon_&&sqld360_sqlid._driver_hist.sql
DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN
  FOR i IN (SELECT * 
              FROM (SELECT report_id,
                           --TO_NUMBER(EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/stats/stat[@name="elapsed_time"]')) 
                           substr(key4,instr(key4,'#')+1, instr(key4,'#',1,2)-instr(key4,'#',1)-1) elapsed,  
                           --EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_exec_id') 
                           key2 sql_exec_id,
                           --EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_exec_start') 
                           key3 sql_exec_start
                      FROM dba_hist_reports
                     WHERE component_name = 'sqlmonitor'
                       --AND EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_id') = '&&sqld360_sqlid.' 
                       AND key1 = '&&sqld360_sqlid.'
                       AND '&&tuning_pack.' = 'Y' 
                       AND '&&sqlmon_hist.' = 'Y'
                     ORDER BY 2 DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL');
    put('( rid => '||i.report_id);
    put(', type => ''ACTIVE'' );');
    put('END;');
    put('/');
    put('SPO sqld360_sqlmon_&&sqld360_sqlid._'||i.sql_exec_id||'_'||REPLACE(REPLACE(i.sql_exec_start,':',''),' ','')||'_hist.html;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
@sqld360_sqlmon_&&sqld360_sqlid._driver_hist.sql

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename._sqlmon.zip">zip</a>
PRO </li>
PRO </ol>
SPO OFF;
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_sqlmon_&&sqld360_sqlid._driver*
HOS zip -jmq &&one_spool_filename._sqlmon sqld360_sqlmon_&&sqld360_sqlid.*
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename._sqlmon.zip
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt
