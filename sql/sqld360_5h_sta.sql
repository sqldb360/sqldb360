DEF section_id = '5h';
DEF section_name = 'SQL Tuning Advisor';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'STA report';
DEF main_table = 'DBA_ADVISOR_TASK';

@@sqld360_0s_pre_nondef

SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SET TERM OFF
SPO sqld360_sta_&&sqld360_sqlid._driver.sql
BEGIN
  FOR i IN (SELECT DISTINCT task_name, execution_name 
              FROM dba_advisor_objects
             WHERE attr1 = '&&sqld360_sqlid.'
               AND type = 'SQL'
               AND task_name NOT LIKE 'ADDM%') LOOP  -- might need to restrict this condition
    DBMS_OUTPUT.PUT_LINE('SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('''||i.task_name||''','''||i.execution_name||''') FROM dual;');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------'); 
  END LOOP;
END;
/
SPO OFF

SPO &&one_spool_filename..txt
@sqld360_sta_&&sqld360_sqlid._driver.sql
SPO OFF

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SPO OFF;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..txt">txt</a>
PRO </li>
PRO </ol>
SPO OFF;
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_sta_&&sqld360_sqlid._driver.sql
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..txt
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
