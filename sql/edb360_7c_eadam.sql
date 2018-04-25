/* 
   Extracted from eAdam
*/

/* ------------------------------------------------------------------------- */
DEF section_id = '7c';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');

SET TERM OFF ECHO OFF;

DEF date_mask = 'YYYY-MM-DD/HH24:MI:SS';
DEF timestamp_mask = 'YYYY-MM-DD/HH24:MI:SS.FF6';
DEF fields_delimiter = '<,>';

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = '&&date_mask.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&timestamp_mask.';

-- timestamp for record keeping control
COL eadam_current_time NEW_V eadam_current_time;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') eadam_current_time FROM DUAL;

/* ------------------------------------------------------------------------- */

SET TERM OFF ECHO OFF DEF ON FEED OFF FLU OFF HEA OFF NUM 30 LIN 32767 LONG 4000000 LONGC 4000 NEWP NONE PAGES 0 SHOW OFF SQLC MIX TAB OFF TRIMS ON VER OFF TIM OFF TIMI OFF SQLP SQL> BLO . RECSEP OFF COLSEP '&&fields_delimiter.';

SPO &&awr_object_prefix.xtr_control.txt;
SELECT d.dbid, d.name dbname, d.db_unique_name, d.platform_name,
       i.instance_number, i.instance_name, i.host_name, i.version,
       '&&eadam_current_time.' current_sysdate
  FROM &&v_object_prefix.database d,
       &&v_object_prefix.instance i;
SPO OFF;
HOS gzip &&awr_object_prefix.xtr_control.txt
HOS tar -cf &&edb360_tar_filename..tar &&awr_object_prefix.xtr_control.txt.gz
HOS rm &&awr_object_prefix.xtr_control.txt.gz

/* ------------------------------------------------------------------------- */

SPO &&dva_object_prefix.tab_columns.txt;
SELECT table_name,
       column_id,
       column_name,
       data_type,
       data_length,
       data_precision,
       data_scale
  FROM &&dva_object_prefix.tab_columns
 WHERE (owner, table_name) IN 
((UPPER('&&tool_repo_user.'), '&&awr_hist_prefix.ACTIVE_SESS_HISTORY')
)
ORDER BY CASE owner WHEN UPPER('&&tool_repo_user.') THEN 1 ELSE 2 END, table_name, column_id;
SPO OFF;
HOS gzip &&dva_object_prefix.tab_columns.txt
HOS tar -rf &&edb360_tar_filename..tar &&dva_object_prefix.tab_columns.txt.gz
HOS rm &&dva_object_prefix.tab_columns.txt.gz

/* ------------------------------------------------------------------------- */

SPO &&awr_object_prefix.active_sess_history.txt;
SELECT /*+ &&ds_hint.
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
    * FROM &&awr_object_prefix.active_sess_history h
WHERE h.dbid = &&edb360_dbid. 
AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
AND (h.sql_id IN (SELECT operation FROM plan_table WHERE statement_id = 'SQLD360_SQLID') OR h.snap_id IN (&&edb360_eadam_snaps.))
AND ROWNUM <= &&edb360_eadam_row_limit.;
SPO OFF;
HOS gzip &&awr_object_prefix.active_sess_history.txt
HOS tar -rf &&edb360_tar_filename..tar &&awr_object_prefix.active_sess_history.txt.gz
HOS rm &&awr_object_prefix.active_sess_history.txt.gz

/* ------------------------------------------------------------------------- */

SET TERM ON COLSEP '';

HOS zip -mj &&edb360_zip_filename. &&edb360_tar_filename..tar >> &&edb360_log3..txt
