-- 12c dbms_stats.report_stats_operations
-- add seq to spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&common_edb360_prefix._&&section_id._&&report_sequence._dbms_stats.report_stats_operations' one_spool_filename FROM DUAL;
SET PAGES 0;
SPO &&edb360_log..txt APP;
PRO Get DBMS_STATS.REPORT_STATS_OPERATIONS(detail_level => 'BASIC', format => 'HTML', latestN => &&def_max_rows., since => TO_TIMESTAMP('&&edb360_date_from.', '&&edb360_date_format.'), until => TO_TIMESTAMP('&&edb360_date_to.', '&&edb360_date_format.'))
SPO OFF;
SPO &&edb360_output_directory.&&one_spool_filename..html
SELECT DBMS_STATS.REPORT_STATS_OPERATIONS(detail_level => 'BASIC', format => 'HTML', latestN => &&def_max_rows., since => TO_TIMESTAMP('&&edb360_date_from.', '&&edb360_date_format.'), until => TO_TIMESTAMP('&&edb360_date_to.', '&&edb360_date_format.')) FROM DUAL
/
SPO OFF;
SET PAGES &&def_max_rows.; 
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.&&one_spool_filename..html >> &&edb360_log3..txt
-- update main report
SPO &&edb360_main_report..html APP;
PRO <li title="DBMS_STATS.REPORT_STATS_OPERATIONS">Statistics Gathering History Report
PRO <a href="&&one_spool_filename..html">html</a>
PRO </li>
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt
-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;


file:///tmp/00123_edb360_2b_3c_619615_3c_115_dbms_stats.report_stats_operations.html