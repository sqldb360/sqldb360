COL edb360_bypass NEW_V edb360_bypass;
SELECT ' echo timeout ' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds
/
SELECT TO_CHAR(SYSDATE, '&&edb360_date_format.') edb360_time_stamp FROM DUAL
/
COL total_hours NEW_V total_hours;
SELECT 'Tool execution hours: '||TO_CHAR(ROUND((:edb360_main_time1 - :edb360_main_time0) / 100 / 3600, 3), '990.000')||'.' total_hours FROM DUAL
/
SPO &&edb360_main_report..html APP;
@@edb360_0e_html_footer.sql
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- turing trace off
ALTER SESSION SET SQL_TRACE = FALSE;
@@&&edb360_0g.tkprof.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Collect chart setup driver
HOS zip -mj &&edb360_zip_filename. &&chart_setup_driver. >> &&edb360_log3..txt

-- cleanup
SET HEA ON; 
SET LIN 80; 
SET NEWP 1; 
SET PAGES 14; 
SET LONG 80; 
SET LONGC 80; 
SET WRA ON; 
SET TRIMS OFF; 
SET TRIM OFF; 
SET TI OFF; 
SET TIMI OFF; 
SET NUM 10; 
SET NUMF ""; 
SET SQLBL OFF; 
SET BLO ON; 
SET RECSEP WR;
UNDEF 1

-- alert log (few methods) note: prefix of &&skip_extras. is to bypass copy when requesting only some section(s)
COL db_name_upper NEW_V db_name_upper;
COL db_name_lower NEW_V db_name_lower;
COL db_unique_name_upper NEW_V db_unique_name_upper;
COL db_unique_name_lower NEW_V db_unique_name_lower;
COL instance_name_upper NEW_V instance_name_upper;
COL instance_name_lower NEW_V instance_name_lower;
COL background_dump_dest NEW_V background_dump_dest;
COL diagnostic_dest NEW_V diagnostic_dest;
SELECT UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_upper FROM DUAL;
SELECT LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_lower FROM DUAL;
SELECT UPPER(SYS_CONTEXT('USERENV', 'DB_UNIQUE_NAME')) db_unique_name_upper FROM DUAL;
SELECT LOWER(SYS_CONTEXT('USERENV', 'DB_UNIQUE_NAME')) db_unique_name_lower FROM DUAL;
SELECT UPPER(SYS_CONTEXT('USERENV', 'INSTANCE_NAME')) instance_name_upper FROM DUAL;
SELECT LOWER(SYS_CONTEXT('USERENV', 'INSTANCE_NAME')) instance_name_lower FROM DUAL;
SELECT value background_dump_dest FROM &&v_dollar.parameter WHERE name = 'background_dump_dest';
SELECT value diagnostic_dest FROM &&v_dollar.parameter WHERE name = 'diagnostic_dest';
-- pre 12c 
HOS &&skip_extras. cp &&background_dump_dest./alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&background_dump_dest./alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&background_dump_dest./alert_&&db_unique_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&background_dump_dest./alert_&&db_unique_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&background_dump_dest./alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&background_dump_dest./alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&background_dump_dest./alert_&&_connect_identifier..log . >> &&edb360_log3..txt
--12c db_name
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_upper./trace/alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_upper./trace/alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_upper./trace/alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_upper./trace/alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_upper./trace/alert_&&_connect_identifier.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_lower./trace/alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_lower./trace/alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_lower./trace/alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_lower./trace/alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_upper.*/&&instance_name_lower./trace/alert_&&_connect_identifier.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_upper./trace/alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_upper./trace/alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_upper./trace/alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_upper./trace/alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_upper./trace/alert_&&_connect_identifier.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_lower./trace/alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_lower./trace/alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_lower./trace/alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_lower./trace/alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_name_lower.*/&&instance_name_lower./trace/alert_&&_connect_identifier.*.log . >> &&edb360_log3..txt
---12c db_unique_name
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_upper./trace/alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_upper./trace/alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_upper./trace/alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_upper./trace/alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_upper./trace/alert_&&_connect_identifier.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_lower./trace/alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_lower./trace/alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_lower./trace/alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_lower./trace/alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_upper.*/&&instance_name_lower./trace/alert_&&_connect_identifier.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_upper./trace/alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_upper./trace/alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_upper./trace/alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_upper./trace/alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_upper./trace/alert_&&_connect_identifier.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_lower./trace/alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_lower./trace/alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_lower./trace/alert_&&instance_name_upper.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_lower./trace/alert_&&instance_name_lower.*.log . >> &&edb360_log3..txt
HOS &&skip_extras. cp &&diagnostic_dest./diag/rdbms/&&db_unique_name_lower.*/&&instance_name_lower./trace/alert_&&_connect_identifier.*.log . >> &&edb360_log3..txt
-- rename
HOS &&skip_extras. rename alert_ 00006_&&common_edb360_prefix._alert_ alert_*.log >> &&edb360_log3..txt

-- listener log (last 100K + counts per hour) note: prefix of &&skip_extras. is to bypass lsnr when requesting only some section(s)
HOS &&skip_extras. lsnrctl show trc_directory | grep trc_directory | awk '{print "HOS cat "$6"/listener.log | fgrep \"establish\" | awk '\''{ print $1\",\"$2 }'\'' | awk -F: '\''{ print \",\"$1 }'\'' | uniq -c > listener_logons.csv"} END {print "HOS sed -i '\''1s/^/COUNT ,DATE,HOUR\\n/'\'' listener_logons.csv"}' > listener_log_driver.sql
HOS &&skip_extras. lsnrctl show trc_directory | grep trc_directory | awk 'BEGIN {b = "HOS tail -100000000c "; e = " > listener_tail.log"} {print b, $6"/listener.log", e } END {print "HOS zip -m listener_log.zip listener_logons.csv listener_tail.log listener_log_driver.sql"}' >> listener_log_driver.sql
@&&skip_extras.listener_log_driver.sql
HOS &&skip_extras. zip -mj &&edb360_zip_filename. listener_log.zip >> &&edb360_log3..txt
HOS rm listener_log_driver.sql

-- zip 
HOS zip -mj &&edb360_zip_filename. &&common_edb360_prefix._query.sql >> &&edb360_log3..txt
HOS zip -d &&edb360_zip_filename. &&common_edb360_prefix._query.sql >> &&edb360_log3..txt
-- prefix &&skip_extras. is to bypass alert and opatch when a section is requested
HOS &&skip_extras. zip -mj &&edb360_zip_filename. 00006_&&common_edb360_prefix._alert_*.log >> &&edb360_log3..txt
HOS &&skip_extras. zip -j 00007_&&common_edb360_prefix._opatch $ORACLE_HOME/cfgtoollogs/opatch/opatch* >> &&edb360_log3..txt
HOS &&skip_extras. zip -mj &&edb360_zip_filename. 00007_&&common_edb360_prefix._opatch.zip >> &&edb360_log3..txt
HOS zip -mj &&edb360_zip_filename. &&edb360_log2..txt >> &&edb360_log3..txt
--HOS zip -mj &&edb360_zip_filename. awrinfo.txt >> &&edb360_log3..txt
HOS zip -mj &&edb360_zip_filename. &&edb360_tkprof._sort.txt >> &&edb360_log3..txt
HOS zip -mj &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt
HOS zip -mj &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt
HOS unzip -l &&edb360_zip_filename. >> &&edb360_log3..txt
HOS zip -mj &&edb360_zip_filename. &&edb360_log3..txt
SET TERM ON;

/*
-- meta360
-- prefix &&skip_extras. is to bypass meta360 when a section is requested
DEF _md_top_schemas = '';
DEF _md_tool = '';
@@&&skip_extras.&&edb360_skip_metadata. get_top_N_schemas.sql
HOS &&skip_extras. &&edb360_skip_metadata. zip -mj &&edb360_zip_filename. TOP_&&_md_top_schemas._&&_md_tool..zip
*/

-- optional move of zip file
COL edb360_mv_host_command NEW_V edb360_mv_host_command
SELECT CASE WHEN '&&edb360_move_directory.' IS NULL 
       THEN 'ls -lat &&edb360_zip_filename..zip' 
       ELSE 'mv &&edb360_zip_filename..zip &&edb360_move_directory. ; ls -lat &&edb360_move_directory.&&edb360_zip_filename..zip' 
       END edb360_mv_host_command FROM DUAL
/
HOS &&edb360_mv_host_command.
