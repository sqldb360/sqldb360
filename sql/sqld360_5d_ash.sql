DEF section_id = '5d';
DEF section_name = 'ASH';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'ASH Reports';
DEF main_table = 'V$ACTIVE_SESSION_HISTORY';

@@sqld360_0s_pre_nondef


ALTER SESSION SET nls_comp='BINARY';
ALTER SESSION SET nls_sort='BINARY';
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SET TERM OFF
-- driver
SPO sqld360_ash_&&sqld360_sqlid._driver.sql
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
                   TO_CHAR(MIN(sample_time), '&&ash_date_mask.') btime, 
                   TO_CHAR(MAX(sample_time), '&&ash_date_mask.') etime
              FROM gv$active_session_history
             WHERE '&&diagnostics_pack.' = 'Y' 
               AND '&&ash_mem.' = 'Y'
               AND sql_id = '&&sqld360_sqlid.'
             GROUP BY
                   inst_id
            HAVING MIN(sample_time) != MAX(sample_time)
             ORDER BY
                   inst_id)
  LOOP
    -- text
    IF '&&ash_text.' = 'Y' THEN
      put('SPO sqld360_ash_&&sqld360_sqlid._'||i.inst_id||'_'||SUBSTR(i.btime, 1, 8)||'_'||SUBSTR(i.btime, 9)||'_'||SUBSTR(i.etime, 1, 8)||'_'||SUBSTR(i.etime, 9)||'_mem.txt;');
      put('SELECT output FROM TABLE(SYS.DBMS_WORKLOAD_REPOSITORY.ash_report_text(&&sqld360_dbid., '||i.inst_id||', TO_DATE('''||i.btime||''', ''&&ash_date_mask.''), TO_DATE('''||i.etime||''', ''&&ash_date_mask.''), 0, 0, TO_NUMBER(NULL), :sqld360_sqlid));');
      put('SPO OFF;');
    END IF;
    -- html
    IF '&&ash_html.' = 'Y' THEN
      put('SPO sqld360_ash_&&sqld360_sqlid._'||i.inst_id||'_'||SUBSTR(i.btime, 1, 8)||'_'||SUBSTR(i.btime, 9)||'_'||SUBSTR(i.etime, 1, 8)||'_'||SUBSTR(i.etime, 9)||'_mem.html;');
      put('SELECT output FROM TABLE(SYS.DBMS_WORKLOAD_REPOSITORY.ash_report_html(&&sqld360_dbid., '||i.inst_id||', TO_DATE('''||i.btime||''', ''&&ash_date_mask.''), TO_DATE('''||i.etime||''', ''&&ash_date_mask.''), 0, 0, TO_NUMBER(NULL), :sqld360_sqlid));');
      put('SPO OFF;');
    END IF;
  END LOOP;
  -- awr
  FOR i IN (SELECT s.instance_number,
                   TO_CHAR(s.startup_time, '&&ash_date_mask.') stime,
                   TO_CHAR(MIN(h.sample_time), '&&ash_date_mask.') btime,
                   TO_CHAR(MAX(h.sample_time), '&&ash_date_mask.') etime
              FROM dba_hist_active_sess_history h,
                   dba_hist_snapshot s
             WHERE '&&diagnostics_pack.' = 'Y' 
               AND '&&ash_awr.' = 'Y'
               AND h.dbid = '&&sqld360_dbid.'
               AND h.sql_id = '&&sqld360_sqlid.'
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
    IF rep_count > TO_NUMBER('&&ash_max_reports.') THEN
      EXIT;
    END IF;
    -- text
    IF '&&ash_text.' = 'Y' THEN
      put('SPO sqld360_ash_&&sqld360_sqlid._'||i.instance_number||'_'||SUBSTR(i.btime, 1, 8)||'_'||SUBSTR(i.btime, 9)||'_'||SUBSTR(i.etime, 1, 8)||'_'||SUBSTR(i.etime, 9)||'_awr.txt;');
      put('SELECT output FROM TABLE(SYS.DBMS_WORKLOAD_REPOSITORY.ash_report_text(&&sqld360_dbid., '||i.instance_number||', TO_DATE('''||i.btime||''', ''&&ash_date_mask.''), TO_DATE('''||i.etime||''', ''&&ash_date_mask.''), 0, 0, TO_NUMBER(NULL), ''&&sqld360_sqlid.''));');
      put('SPO OFF;');
    END IF;
    -- html
    IF '&&ash_html.' = 'Y' THEN
      put('SPO sqld360_ash_&&sqld360_sqlid._'||i.instance_number||'_'||SUBSTR(i.btime, 1, 8)||'_'||SUBSTR(i.btime, 9)||'_'||SUBSTR(i.etime, 1, 8)||'_'||SUBSTR(i.etime, 9)||'_awr.html;');
      put('SELECT output FROM TABLE(SYS.DBMS_WORKLOAD_REPOSITORY.ash_report_html(&&sqld360_dbid., '||i.instance_number||', TO_DATE('''||i.btime||''', ''&&ash_date_mask.''), TO_DATE('''||i.etime||''', ''&&ash_date_mask.''), 0, 0, TO_NUMBER(NULL), ''&&sqld360_sqlid.''));');
      put('SPO OFF;');
    END IF;
  END LOOP;
END;
/
SPO OFF;
@sqld360_ash_&&sqld360_sqlid._driver.sql

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

SET PAGES 50000

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename._ash.zip">zip</a>
PRO </li>
PRO </ol>
SPO OFF;
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_ash_&&sqld360_sqlid._driver.sql
HOS zip -jmq &&one_spool_filename._ash sqld360_ash_&&sqld360_sqlid.*
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename._ash.zip
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt
