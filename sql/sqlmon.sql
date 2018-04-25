----------------------------------------------------------------------------------------
--
-- File name:   sqlmon.sql
--
-- Purpose:     SQL Monitor Reports for one SQL_ID
--
-- Author:      Carlos Sierra
--
-- Version:     2014/03/11
--
-- Usage:       This script inputs two parameters. Parameter 1 is a flag to specify if
--              your database is licensed to use the Oracle Tuning Pack or not.
--              Parameter 2 specifies the SQL_ID for which you want to generate all
--              SQL Monitor reports from all RAC nodes.
--              If you don't have the Oracle Tuning Pack license do not use this script.
--
-- Example:     @sqlmon.sql Y f995z9antmhxn
--
--  Notes:      Developed and tested on 11.2.0.3 and 12.0.1.0
--              Generates both TEXT and ACTIVE reports
--              For a more robust tool use SQLHC or SQLTXPLAIN(SQLT) from MOS
--             
---------------------------------------------------------------------------------------
-- text and or active formats? change these flags if you want to eliminate a format
DEF text = 'Y';
DEF active = 'Y';
DEF max_reports = '12';
--
SET FEED OFF VER OFF LIN 32767 PAGES 0 TIMI OFF LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET SERVEROUT ON;
PRO
PRO 1. Enter Oracle Tuning Pack License Flag [ Y | N ] (required)
DEF input_license = '&1';
PRO
PRO 2. Enter SQL_ID (required)
DEF sql_id = '&2';
-- set license
VAR license CHAR(1);
BEGIN
  SELECT UPPER(SUBSTR(TRIM('&input_license.'), 1, 1)) INTO :license FROM DUAL;
END;
/
-- set sql_id
VAR sql_id VARCHAR2(13);
BEGIN 
  :sql_id := '&&sql_id.';
END;
/
-- global setup
DEF date_mask = 'YYYYMMDDHH24MISS';
VAR r CLOB;
-- get current time
COL current_time NEW_V current_time FOR A15;
SELECT 'current_time: ' x, TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') current_time FROM DUAL;
-- text
SPO sqlmon_&&sql_id._driver.sql
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
             WHERE :license = 'Y' 
               AND '&&text.' = 'Y'
               AND sql_id = '&&sql_id.' 
               AND sql_text IS NOT NULL
               AND process_name = 'ora'
             ORDER BY
                   sql_exec_start DESC)
             WHERE ROWNUM <= &&max_reports.)
  LOOP
    put('BEGIN');
    put(':r :=');
    put('DBMS_SQLTUNE.report_sql_monitor');
    put('( sql_id => ''&&sql_id.''');
    put(', session_id => '||i.sid);
    put(', session_serial => '||i.session_serial#);
    put(', sql_exec_start => TO_DATE('''||TO_CHAR(i.sql_exec_start, '&&date_mask.')||''', ''&&date_mask.'')');
    put(', sql_exec_id => '||i.sql_exec_id);
    put(', inst_id => '||i.inst_id);
    put(', report_level => ''ALL''');
    put(', type => ''TEXT'' );');
    put('END;');
    put('/');
    put('PRINT :r;');
  END LOOP;
END;
/
SPO OFF;
SPO sqlmon_&&sql_id..txt;
SELECT DBMS_SQLTUNE.report_sql_monitor_list(sql_id => '&&sql_id.', type => 'TEXT') 
  FROM DUAL 
 WHERE :license = 'Y' 
   AND '&&text.' = 'Y';
@sqlmon_&&sql_id._driver.sql
SPO OFF;
-- active
SPO sqlmon_&&sql_id._driver.sql
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
             WHERE :license = 'Y' 
               AND '&&active.' = 'Y'
               AND sql_id = '&&sql_id.' 
               AND sql_text IS NOT NULL
               AND process_name = 'ora'
             ORDER BY
                   sql_exec_start DESC)
             WHERE ROWNUM <= &&max_reports.)
  LOOP
    put('BEGIN');
    put(':r :=');
    put('DBMS_SQLTUNE.report_sql_monitor');
    put('( sql_id => ''&&sql_id.''');
    put(', session_id => '||i.sid);
    put(', session_serial => '||i.session_serial#);
    put(', sql_exec_start => TO_DATE('''||TO_CHAR(i.sql_exec_start, '&&date_mask.')||''', ''&&date_mask.'')');
    put(', sql_exec_id => '||i.sql_exec_id);
    put(', inst_id => '||i.inst_id);
    put(', report_level => ''ALL''');
    put(', type => ''ACTIVE'' );');
    put('END;');
    put('/');
    put('SPO sqlmon_&&sql_id._'||i.sql_exec_id||'_'||LPAD(TO_CHAR(i.sql_exec_start, 'HH24MISS'), 6, '0')||'.html;');
    put('PRINT :r;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SPO sqlmon_&&sql_id._list.html;
SELECT DBMS_SQLTUNE.report_sql_monitor_list(sql_id => '&&sql_id.', type => 'HTML') 
  FROM DUAL 
 WHERE :license = 'Y' 
   AND '&&active.' = 'Y';
SPO OFF;
@sqlmon_&&sql_id._driver.sql
SPO sqlmon_&&sql_id._detail.html;
SELECT DBMS_SQLTUNE.report_sql_detail(sql_id => '&&sql_id.', report_level => 'ALL', type => 'ACTIVE') 
  FROM DUAL 
 WHERE :license = 'Y' 
   AND '&&active.' = 'Y';
SPO OFF;
-- cleanup
HOS zip -m sqlmon_&&sql_id._&&current_time. sqlmon_&&sql_id.*.*
HOS zip -m sqlmon_&&sql_id._&&current_time. sqlmon_&&sql_id._driver.sql
HOS zip -d sqlmon_&&sql_id._&&current_time. sqlmon_&&sql_id._driver.sql
PRO sqlmon_&&sql_id._&&current_time..zip contains text and active reports
SET FEED ON VER ON LIN 80 PAGES 14 LONG 80 LONGC 80 TRIMS OFF;
SET SERVEROUT OFF;
UNDEF 1 2
-- end



