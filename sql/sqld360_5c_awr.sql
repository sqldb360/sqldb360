DEF section_id = '5c';
DEF section_name = 'AWR';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'AWR Reports';
DEF main_table = 'DBA_HIST_SQLSTAT';

@@sqld360_0s_pre_nondef


SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SET TERM OFF
-- driver
SPO sqld360_awr_&&sqld360_sqlid._driver.sql
DECLARE
  rep_count INTEGER := 0;
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN

  -- awr
  FOR i IN (SELECT dbid, instance_number, eid, bid
              FROM(SELECT s.dbid, s.instance_number, s.eid, s.bid,
                          SUM(elapsed_time_delta) elap_time
                     FROM dba_hist_sqlstat ss,
                          (SELECT s.dbid, s.instance_number, s.snap_id eid,
                                  LAG(s.snap_id) OVER (PARTITION BY s.dbid, s.instance_number ORDER BY s.snap_id) bid
                             FROM dba_hist_snapshot s) s 
                    WHERE '&&diagnostics_pack.' = 'Y' 
                      AND ss.dbid = '&&sqld360_dbid.'
                      AND ss.sql_id = '&&sqld360_sqlid.'
                      AND s.eid = ss.snap_id
                      AND s.dbid = ss.dbid
                      AND s.instance_number = ss.instance_number
                    GROUP BY s.dbid, s.instance_number, s.eid, s.bid   
                    ORDER BY s.instance_number, SUM(elapsed_time_delta) DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_awrrpt.)
  LOOP

      put('SPO sqld360_awr_&&sqld360_sqlid._'||i.instance_number||'_'||i.bid||'_'||i.eid||'_awr.html;');
      put('SELECT output FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_report_html(&&sqld360_dbid., '||i.instance_number||','||i.bid||','||i.eid||',9));');
      put('SPO OFF;');

      put('SPO sqld360_awr_&&sqld360_sqlid._'||i.instance_number||'_'||i.bid||'_'||i.eid||'_awr_global.html;');
      put('SELECT output FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_global_report_html('||i.dbid||','''','||i.bid||','||i.eid||',9));');
      put('SPO OFF;');      

  END LOOP;
END;
/
SPO OFF;
@sqld360_awr_&&sqld360_sqlid._driver.sql

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
PRO <a href="&&one_spool_filename._awr.zip">zip</a>
PRO </li>
PRO </ol>
SPO OFF;
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_awr_&&sqld360_sqlid._driver.sql
HOS zip -jmq &&one_spool_filename._awr sqld360_awr_&&sqld360_sqlid.*
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename._awr.zip
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt
