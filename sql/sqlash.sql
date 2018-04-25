----------------------------------------------------------------------------------------
--
-- File name:   sqlash.sql
--
-- Purpose:     ASH Reports for one SQL_ID
--
-- Author:      Carlos Sierra
--
-- Version:     2013/12/18
--
-- Usage:       This script inputs two parameters. Parameter 1 is a flag to specify if
--              your database is licensed to use the Oracle Diagnostics Pack or not.
--              Parameter 2 specifies the SQL_ID for which you want to generate ASH
--              instance reports from memory and AWR.
--              If you don't have Oracle Diagnostics Pack license do not use this script.
--
-- Example:     @sqlash.sql Y f995z9antmhxn
--
--  Notes:      Developed and tested on 11.2.0.3 and 12.0.1.0
--              Generates both TEXT and HTML reports from both memory and AWR
--              For a more robust tool use SQLTXPLAIN(SQLT) from MOS
--             
---------------------------------------------------------------------------------------
-- text and or html formats? change these flags if you want to eliminate a format
DEF text = 'Y';
DEF html = 'Y';
-- memory or awr sources? change these flags if you want to eliminate a source
DEF mem = 'Y';
DEF awr = 'Y';
-- max awr reports to produce
DEF max_reports = '12';
--
SET FEED OFF VER OFF LIN 2000 PAGES 0 TIMI OFF LONG 4000000 LONGC 400 TRIMS ON AUTOT OFF;
SET SERVEROUT ON;
PRO
PRO 1. Enter Oracle Diagnostics Pack License Flag [ Y | N ] (required)
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
-- get dbid
VAR dbid NUMBER;
BEGIN
  SELECT dbid INTO :dbid FROM v$database;
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
ALTER SESSION SET nls_comp='BINARY';
ALTER SESSION SET nls_sort='BINARY';
-- driver
SPO sqlash_&&sql_id._driver.sql
DECLARE
  rep_count INTEGER := 0;
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN
  -- mem
  FOR i IN (SELECT inst_id,
                   TO_CHAR(MIN(sample_time), '&&date_mask.') btime, 
                   TO_CHAR(MAX(sample_time), '&&date_mask.') etime
              FROM gv$active_session_history
             WHERE :license = 'Y' 
               AND '&&mem.' = 'Y'
               AND sql_id = '&&sql_id.'
             GROUP BY
                   inst_id
            HAVING MIN(sample_time) != MAX(sample_time)
             ORDER BY
                   inst_id)
  LOOP
    -- text
    IF '&&text.' = 'Y' THEN
      put('SPO sqlash_&&sql_id._'||i.inst_id||'_'||SUBSTR(i.btime, 1, 8)||'_'||SUBSTR(i.btime, 9)||'_'||SUBSTR(i.etime, 1, 8)||'_'||SUBSTR(i.etime, 9)||'_mem.txt;');
      put('SELECT output FROM TABLE(SYS.DBMS_WORKLOAD_REPOSITORY.ash_report_text(:dbid, '||i.inst_id||', TO_DATE('''||i.btime||''', ''&&date_mask.''), TO_DATE('''||i.etime||''', ''&&date_mask.''), 0, 0, TO_NUMBER(NULL), :sql_id));');
      put('SPO OFF;');
    END IF;
    -- html
    IF '&&html.' = 'Y' THEN
      put('SPO sqlash_&&sql_id._'||i.inst_id||'_'||SUBSTR(i.btime, 1, 8)||'_'||SUBSTR(i.btime, 9)||'_'||SUBSTR(i.etime, 1, 8)||'_'||SUBSTR(i.etime, 9)||'_mem.html;');
      put('SELECT output FROM TABLE(SYS.DBMS_WORKLOAD_REPOSITORY.ash_report_html(:dbid, '||i.inst_id||', TO_DATE('''||i.btime||''', ''&&date_mask.''), TO_DATE('''||i.etime||''', ''&&date_mask.''), 0, 0, TO_NUMBER(NULL), :sql_id));');
      put('SPO OFF;');
    END IF;
  END LOOP;
  -- awr
  FOR i IN (SELECT s.instance_number,
                   TO_CHAR(s.startup_time, '&&date_mask.') stime,
                   TO_CHAR(MIN(h.sample_time), '&&date_mask.') btime,
                   TO_CHAR(MAX(h.sample_time), '&&date_mask.') etime
              FROM dba_hist_active_sess_history h,
                   dba_hist_snapshot s
             WHERE :license = 'Y' 
               AND '&&awr.' = 'Y'
               AND h.dbid = :dbid
               AND h.sql_id = '&&sql_id.'
               AND s.snap_id = h.snap_id
               AND s.dbid = h.dbid
               AND s.instance_number = h.instance_number
             GROUP BY
                   s.startup_time,
                   s.instance_number    
            HAVING MIN(h.sample_time) != MAX(h.sample_time)
             ORDER BY
                   s.startup_time DESC,
                   s.instance_number)
  LOOP
    rep_count := rep_count + 1;
    IF rep_count > TO_NUMBER('&&max_reports.') THEN
      EXIT;
    END IF;
    -- text
    IF '&&text.' = 'Y' THEN
      put('SPO sqlash_&&sql_id._'||i.instance_number||'_'||SUBSTR(i.btime, 1, 8)||'_'||SUBSTR(i.btime, 9)||'_'||SUBSTR(i.etime, 1, 8)||'_'||SUBSTR(i.etime, 9)||'_awr.txt;');
      put('SELECT output FROM TABLE(SYS.DBMS_WORKLOAD_REPOSITORY.ash_report_text(:dbid, '||i.instance_number||', TO_DATE('''||i.btime||''', ''&&date_mask.''), TO_DATE('''||i.etime||''', ''&&date_mask.''), 0, 0, TO_NUMBER(NULL), :sql_id));');
      put('SPO OFF;');
    END IF;
    -- html
    IF '&&html.' = 'Y' THEN
      put('SPO sqlash_&&sql_id._'||i.instance_number||'_'||SUBSTR(i.btime, 1, 8)||'_'||SUBSTR(i.btime, 9)||'_'||SUBSTR(i.etime, 1, 8)||'_'||SUBSTR(i.etime, 9)||'_awr.html;');
      put('SELECT output FROM TABLE(SYS.DBMS_WORKLOAD_REPOSITORY.ash_report_html(:dbid, '||i.instance_number||', TO_DATE('''||i.btime||''', ''&&date_mask.''), TO_DATE('''||i.etime||''', ''&&date_mask.''), 0, 0, TO_NUMBER(NULL), :sql_id));');
      put('SPO OFF;');
    END IF;
  END LOOP;
END;
/
SPO OFF;
@sqlash_&&sql_id._driver.sql
-- cleanup
HOS zip -m sqlash_&&sql_id. sqlash_&&sql_id._*.html
HOS zip -m sqlash_&&sql_id. sqlash_&&sql_id._*.txt
HOS zip -m sqlash_&&sql_id. sqlash_&&sql_id._driver.sql
HOS zip -d sqlash_&&sql_id. sqlash_&&sql_id._driver.sql
PRO sqlash_&&sql_id..zip contains text and html reports
SET FEED ON VER ON LIN 80 PAGES 14 LONG 80 LONGC 80 TRIMS OFF;
SET SERVEROUT OFF;
UNDEF 1 2
-- end



