SPO &&sqld360_main_report..html APP;
@@sqld360_0e_html_footer.sql
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- turing trace off
ALTER SESSION SET SQL_TRACE = FALSE;

-- tkprof for trace from execution of tool in case someone reports slow performance in tool, one of the two execs will fail
HOS tkprof &&sqld360_udump_path.*ora_&&sqld360_spid._&&sqld360_tracefile_identifier..trc &&sqld360_tkprof._sort.txt sort=prsela exeela fchela
HOS tkprof &&sqld360_diagtrace_path.*ora_&&sqld360_spid._&&sqld360_tracefile_identifier..trc &&sqld360_tkprof._sort.txt sort=prsela exeela fchela

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- readme
SPO 00000_readme_first.txt
PRO 1. Unzip &&sqld360_main_filename._&&sqld360_file_time..zip into a directory
PRO 2. Review &&sqld360_main_report..html
SPO OFF;

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
SET ARRAY 15; 
SET NUM 10; 
SET NUMF ""; 
SET SQLBL OFF; 
SET BLO ON; 
SET RECSEP WR;
UNDEF 1 2 3 4 5 6

-- alert log (3 methods)
--COL db_name_upper NEW_V db_name_upper;
--COL db_name_lower NEW_V db_name_lower;
--COL background_dump_dest NEW_V background_dump_dest;
--SELECT UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_upper FROM DUAL;
--SELECT LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_lower FROM DUAL;
--SELECT value background_dump_dest FROM v$parameter WHERE name = 'background_dump_dest';
--HOS cp &&background_dump_dest./alert_&&db_name_upper.*.log .
--HOS cp &&background_dump_dest./alert_&&db_name_lower.*.log .
--HOS cp &&background_dump_dest./alert_&&_connect_identifier..log .
--HOS rename alert_ 00005_&&common_sqld360_prefix._alert_ alert_*.log

-- zip 
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. 99999_sqld360_&&sqld360_sqlid._drivers*
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&common_sqld360_prefix._query.sql
HOS zip -dq &&sqld360_main_filename._&&sqld360_file_time. &&common_sqld360_prefix._query.sql
--HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. 00005_&&common_sqld360_prefix._alert_*.log
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_tkprof._sort.txt
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. 00000_readme_first.txt 
--HOS unzip -l &&sqld360_main_filename._&&sqld360_file_time.


-- This commit is to end the transaction we initiated in this execution
-- The main goal is to avoid ORA-65023 when switching to another PDB
COMMIT;

-- here we need to switch back to caller CONTAINER (CDB/PDB)
-- It will error out in versions before 12c, safe to ignore
ALTER SESSION SET CONTAINER=&&sqld360_container.;


--update plan table with zip file for eDB360 to pull
UPDATE plan_table SET remarks = '&&sqld360_main_filename._&&sqld360_file_time..zip'  WHERE statement_id = 'SQLD360_SQLID' and operation = '&&sqld360_sqlid.';
COMMIT;

SET TERM ON;
