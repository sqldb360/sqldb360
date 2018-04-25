-- setup
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') sqld360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SELECT REPLACE(TRANSLATE('&&title.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789_'), '__', '_') title_no_spaces FROM DUAL;
--SELECT '&&common_sqld360_prefix._&&column_number._&&title_no_spaces.' spool_filename FROM DUAL;
SELECT '&&common_sqld360_prefix._&&section_id._&&report_sequence._&&title_no_spaces.' spool_filename FROM DUAL;
SET HEA OFF;
SET TERM ON;

-- log
SELECT '0' row_num FROM DUAL;
SPO &&sqld360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number. "&&section_name."
PRO &&hh_mm_ss. &&title.&&title_suffix.

-- count
PRINT sql_text;

SET TERM OFF;
PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number..
EXEC :sql_text_display := TRIM(CHR(10) FROM :sql_text)||';';
PRO
SPO OFF;
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- spools query
SPO &&common_sqld360_prefix._query.sql;
SELECT 'SELECT TO_CHAR(ROWNUM) row_num, v0.* /* &&section_id..&&report_sequence. */ FROM ('||CHR(10)||TRIM(CHR(10) FROM :sql_text)||CHR(10)||') v0 WHERE ROWNUM <= &&max_rows.' FROM DUAL;
SPO OFF;
SET HEA ON;
GET &&common_sqld360_prefix._query.sql

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
SPO OFF;
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

-- execute one sql
@@&&skip_html.&&sqld360_skip_html.sqld360_9b_one_html.sql
@@&&skip_xml.&&sqld360_skip_xml.sqld360_9i_one_xml.sql
@@&&skip_text.&&sqld360_skip_text.sqld360_9c_one_text.sql
@@&&skip_csv.&&sqld360_skip_csv.sqld360_9d_one_csv.sql
@@&&skip_lch.&&sqld360_skip_line.sqld360_9e_one_line_chart.sql
@@&&skip_pch.&&sqld360_skip_pie.sqld360_9f_one_pie_chart.sql
@@&&skip_bch.&&sqld360_skip_bar.sqld360_9g_one_bar_chart.sql
@@&&skip_tch.&&sqld360_skip_tree.sqld360_9h_one_org_chart.sql
@@&&skip_uch.&&sqld360_skip_bubble.sqld360_9j_one_bubble_chart.sql
@@&&skip_sch.&&sqld360_skip_scatt.sqld360_9k_one_scatter_chart.sql
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt
EXEC :sql_text := NULL;
COL row_num FOR 9999999 HEA '#' PRI;
DEF abstract = '';
DEF abstract2 = '';
DEF foot = '';
DEF treeColor = '';
DEF bubblesDetails = '';
DEF max_rows = '&&def_max_rows.';
DEF skip_html = '';
DEF skip_xml  = '';
DEF skip_text = '';
DEF skip_csv = '';
DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
DEF skip_bch = 'Y';
DEF skip_tch = 'Y';
DEF skip_uch = 'Y';
DEF skip_sch = 'Y';
DEF title_suffix = '';
DEF haxis = '&&sqld360_sqlid. &&db_version. &&cores_threads_hosts.';

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

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
-- bug 26163790
--SET ARRAY 999; 
SET NUM 20; 
SET SQLBL ON; 
SET BLO .; 
SET RECSEP OFF;

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <small><em>(&&row_num.)</em></small>
PRO </li>
SPO OFF;
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

