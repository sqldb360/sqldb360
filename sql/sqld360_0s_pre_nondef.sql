SET LIN 32767 PAGES 0 LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SET TERM OFF;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') sqld360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SELECT REPLACE(TRANSLATE('&&title.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789_'), '__', '_') title_no_spaces FROM DUAL;
SELECT '&&common_sqld360_prefix._&&section_id._&&report_sequence._&&title_no_spaces.' spool_filename FROM DUAL;
SET HEA OFF;

-- add seq to spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

SET TERM ON; 

-- log
SPO &&sqld360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number. "&&section_name."
PRO &&hh_mm_ss. &&title.&&title_suffix.
