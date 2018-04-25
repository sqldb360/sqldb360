/* 
   Extracted from eAdam
*/

DEF section_id = '5g';
DEF section_name = 'eAdam';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'eAdam ASH';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';

@@sqld360_0s_pre_nondef

/* ------------------------------------------------------------------------- */

SET TERM ON ECHO OFF ARRAY 1000;
CL COL;
SET TERM OFF;

DEF date_mask = 'YYYY-MM-DD/HH24:MI:SS';
DEF timestamp_mask = 'YYYY-MM-DD/HH24:MI:SS.FF6';
DEF fields_delimiter = '<,>';

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = '&&date_mask.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&timestamp_mask.';

-- timestamp for record keeping control
COL current_time NEW_V current_time;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') current_time FROM DUAL;

/* ------------------------------------------------------------------------- */

SET TERM OFF ECHO OFF DEF ON FEED OFF FLU OFF HEA OFF NUM 30 LIN 32767 LONG 4000000 LONGC 4000 NEWP NONE PAGES 0 SHOW OFF SQLC MIX TAB OFF TRIMS ON VER OFF TIM OFF TIMI OFF ARRAY 1000 SQLP SQL> BLO . RECSEP OFF COLSEP '&&fields_delimiter.';

SPO dba_hist_xtr_control.txt;
SELECT d.dbid, d.name dbname, d.db_unique_name, d.platform_name,
       i.instance_number, i.instance_name, i.host_name, i.version,
       '&&current_time.' current_sysdate
  FROM v$database d,
       v$instance i;
SPO OFF;
HOS gzip dba_hist_xtr_control.txt
HOS tar -cf &&one_spool_filename..tar dba_hist_xtr_control.txt.gz
HOS rm dba_hist_xtr_control.txt.gz

/* ------------------------------------------------------------------------- */

SPO dba_tab_columns.txt;
SELECT table_name,
       column_id,
       column_name,
       data_type,
       data_length,
       data_precision,
       data_scale
  FROM dba_tab_columns
 WHERE (owner, table_name) IN 
(('SYS', 'DBA_HIST_ACTIVE_SESS_HISTORY')
,('SYS', 'GV_$ACTIVE_SESSION_HISTORY')
)
ORDER BY CASE owner WHEN 'SYS' THEN 1 ELSE 2 END, table_name, column_id;
SPO OFF;
HOS gzip dba_tab_columns.txt
HOS tar -rf &&one_spool_filename..tar dba_tab_columns.txt.gz
HOS rm dba_tab_columns.txt.gz

/* ------------------------------------------------------------------------- */

SPO dba_hist_active_sess_history.txt;
SELECT * FROM dba_hist_active_sess_history WHERE dbid = &&sqld360_dbid. AND (snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.) AND sql_id = '&&sqld360_sqlid.';
SPO OFF;
HOS gzip dba_hist_active_sess_history.txt
HOS tar -rf &&one_spool_filename..tar dba_hist_active_sess_history.txt.gz
HOS rm dba_hist_active_sess_history.txt.gz

/* ------------------------------------------------------------------------- */

SPO gv_active_session_history.txt;
SELECT * FROM gv$active_session_history WHERE sql_id = '&&sqld360_sqlid.';
SPO OFF;
HOS gzip gv_active_session_history.txt
HOS tar -rf &&one_spool_filename..tar gv_active_session_history.txt.gz
HOS rm gv_active_session_history.txt.gz

/* -------------------------------------------------------------------------- */

SET TERM ON COLSEP '';
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..tar">tar</a>
PRO </li>
PRO </ol>
SPO OFF;

HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..tar
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
