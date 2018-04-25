-- setup
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SELECT TO_CHAR(SYSDATE, '&&edb360_date_format.') edb360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SELECT REPLACE(TRANSLATE('&&title.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789_'), '__', '_') title_no_spaces FROM DUAL;
SELECT '&&common_edb360_prefix._&&section_id._&&report_sequence._&&title_no_spaces.' spool_filename FROM DUAL;
SET HEA OFF;
SET TERM ON;

-- cleanup
SELECT '0' row_num FROM DUAL;

-- log and watchdog
SPO &&edb360_log..txt APP;
COL edb360_bypass NEW_V edb360_bypass;
SELECT ' echo timeout ' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds
/
--SELECT 'Elapsed Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3) FROM DUAL
SELECT 'Elapsed Hours so far: '||TO_CHAR(ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3), '990.000') FROM DUAL
/
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&hh_mm_ss. &&section_id. "&&section_name."
PRO &&hh_mm_ss. &&title.&&title_suffix.

-- count
PRINT sql_text;
--SELECT '0' row_num FROM DUAL;
PRO &&hh_mm_ss. &&section_id..&&report_sequence.
SELECT 'Elapsed Hours so far: '||TO_CHAR(ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3), '990.000') FROM DUAL
/
EXEC :sql_text_display := REPLACE(REPLACE(TRIM(CHR(10) FROM :sql_text)||';', '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;');
SET TIMI ON;
SET SERVEROUT ON;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Elapsed Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3)||CHR(10));
END;
/
SET TIMI OFF;
SET SERVEROUT OFF;
PRO
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt

-- spools query
SPO &&common_edb360_prefix._query.sql;
SELECT 'SELECT TO_CHAR(ROWNUM) row_num, v0.* FROM /* &&section_id..&&report_sequence. */ ('||CHR(10)||TRIM(CHR(10) FROM :sql_text)||CHR(10)||') v0 WHERE ROWNUM <= &&max_rows.' FROM DUAL;
SPO OFF;
SET HEA ON;
GET &&common_edb360_prefix._query.sql

-- update main report
SET TERM OFF;
SPO &&edb360_main_report..html APP;
PRO <li title="&&main_table.">&&edb360_bypass.&&title.
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt

-- dummy call
COL edb360_prev_sql_id NEW_V edb360_prev_sql_id NOPRI;
COL edb360_prev_child_number NEW_V edb360_prev_child_number NOPRI;
SELECT prev_sql_id edb360_prev_sql_id, TO_CHAR(prev_child_number) edb360_prev_child_number FROM &&v_dollar.session WHERE sid = SYS_CONTEXT('USERENV', 'SID')
/

-- execute one sql
@@&&edb360_bypass.&&skip_html.&&edb360_skip_html.edb360_9b_one_html.sql
@@&&edb360_bypass.&&skip_html.&&edb360_skip_xml.edb360_9g_one_xml.sql
@@&&edb360_bypass.&&skip_text.&&edb360_skip_text.edb360_9c_one_text.sql
@@&&edb360_bypass.&&skip_csv.&&edb360_skip_csv.edb360_9d_one_csv.sql
@@&&edb360_bypass.&&skip_lch.&&edb360_skip_line.edb360_9e_one_line_chart.sql
@@&&edb360_bypass.&&skip_lch2.&&edb360_skip_line.edb360_9e_two_line_chart.sql
@@&&edb360_bypass.&&skip_pch.&&edb360_skip_pie.edb360_9f_one_pie_chart.sql
@@&&edb360_bypass.&&skip_bch.&&edb360_skip_bar.edb360_9h_one_bar_chart.sql
HOS zip -j &&edb360_zip_filename. &&edb360_log2..txt >> &&edb360_log3..txt
HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt

-- sql monitor long executions of sql from edb360
SELECT 'N' edb360_tuning_pack_for_sqlmon, ' echo skip sqlmon' skip_sqlmon_exec FROM DUAL
/
SELECT '&&tuning_pack.' edb360_tuning_pack_for_sqlmon, NULL skip_sqlmon_exec, SUBSTR(sql_text, 1, 100) edb360_sql_text_100, elapsed_time FROM &&v_dollar.sql 
WHERE sql_id = '&&edb360_prev_sql_id.' AND elapsed_time / 1e6 > 60 /* seconds */
/
@@&&skip_tuning.&&skip_sqlmon_exec.sqlmon.sql &&edb360_tuning_pack_for_sqlmon. &&edb360_prev_sql_id.
HOS zip -mj &&edb360_zip_filename. sqlmon_&&edb360_prev_sql_id._&&current_time..zip >> &&edb360_log3..txt

-- needed reset after eventual sqlmon above
SET TERM OFF; 
SET HEA ON; 
SET LIN 32767; 
SET NEWP NONE; 
SET PAGES &&def_max_rows.; 
SET LONG 32000000; 
SET LONGC 2000; 
SET WRA ON; 
SET TRIMS ON; 
SET TRIM ON; 
SET TI OFF; 
SET TIMI OFF; 
SET NUM 20; 
SET SQLBL ON; 
SET BLO .; 
SET RECSEP OFF;

-- cleanup
EXEC :sql_text := NULL;
--COL row_num NEW_V row_num HEA '#' PRI;
DEF abstract = '';
DEF abstract2 = '';
DEF foot = '';
DEF max_rows = '&&def_max_rows.';
DEF skip_html = '';
DEF skip_text = '';
DEF skip_csv = '';
DEF skip_lch = '--skip--';
DEF skip_lch2 = '--skip--';
DEF skip_pch = '--skip--';
DEF skip_bch = '--skip--';
DEF title_suffix = '';
DEF haxis = '&&host_name_suffix. &&db_version. &&cores_threads_hosts.';

-- update main report
SPO &&edb360_main_report..html APP;
PRO <small><em> (&&row_num.) </em></small>
PRO </li>
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

