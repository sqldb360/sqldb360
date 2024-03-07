----------------------------------------------------------------------------------------
--
-- File name:   esp_statspack.sql (2024-01-03)
--
-- Purpose:     Collect Database Requirements (CPU, Memory, Disk and IO Perf)
--
-- Author:      Carlos Sierra, Rodrigo Righetti , Abel Macias, Jorge Barba
--
-- Usage:       Collects Requirements from Statspack on databases.
--
--              The output of this script can be used to feed a Sizing and Provisioning
--              application.
--
-- Example:     # cd esp_collect-master
--              # sqlplus / as sysdba
--              SQL> START sql/esp_statspack.sql
--
--  Notes:      Developed and tested on 12.1.0.2, 12.1.0.1, 11.2.0.4, 11.2.0.3,
--        10.2.0.4, 9.2.0.8, 9.2.0.1
--
-- Modified January 2024 to redefine esp_host_name_short
---------------------------------------------------------------------------------------
--
SET TERM ON;
PRO Executing esp_collect_requirements and resources_requirements
PRO Please wait ...

SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;

DEF skip_escp_v1 = '--skip--'

-- get host name (up to 30, stop before first '.', no special characters)
DEF esp_host_name_short = '';
COL esp_host_name_short NEW_V esp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) esp_host_name_short FROM DUAL;
SELECT SUBSTR('&&esp_host_name_short.', 1, INSTR('&&esp_host_name_short..', '.') - 1) esp_host_name_short FROM DUAL;
SELECT TRANSLATE('&&esp_host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') esp_host_name_short FROM DUAL;

-- get database name (up to 10, stop before first '.', no special characters)
COL esp_dbname_short NEW_V esp_dbname_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) esp_dbname_short FROM DUAL;
SELECT SUBSTR('&&esp_dbname_short.', 1, INSTR('&&esp_dbname_short..', '.') - 1) esp_dbname_short FROM DUAL;
SELECT TRANSLATE('&&esp_dbname_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') esp_dbname_short FROM DUAL;

-- get collection date
DEF esp_collection_yyyymmdd = '';
COL esp_collection_yyyymmdd NEW_V esp_collection_yyyymmdd FOR A8;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') esp_collection_yyyymmdd FROM DUAL;

-- DB Features
@@sql/features_use.sql

/*
use escp_host_name_short instead of the calculated esp_host_name_short by esp_master
This is to use the name of the primary server stored in historic tables than the script executing server
The name of the script executing server is collected in the END category.
*/
DEF esp_host_name_short=&&escp_host_name_short.

WHENEVER SQLERROR EXIT
-- Checking the statspack is installed. Abort if it does not exist.
host touch statspack_installation_test.txt
HOS zip -qj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip statspack_installation_test.txt
SPOOL statspack_installation_test.txt APP
SELECT COUNT(*) FROM stats$snapshot WHERE rownum=1;
PROMPT success.
SPOOL OFF
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip statspack_installation_test.txt
WHENEVER SQLERROR CONTINUE

-- STATSPACK collector
@@sql/escp_collect_statspack.sql 
@@&&skip_escp_v1.sql/esp_collect_requirements_statspack.sql
@@&&skip_escp_v1.sql/resources_requirements_statspack.sql


SET TERM ON;

-- cpu info for linux, aix and solaris. expect some errors
SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;
SPO hostcommands_driver.sql
SELECT decode(  platform_id,
                13,'HOS cat /proc/cpuinfo | grep -i name | sort | uniq | cat - /sys/devices/virtual/dmi/id/product_name >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt', -- Linux x86 64-bit
                6,'HOS lsconf | grep Processor >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt', -- AIX-Based Systems (64-bit)
                2,'HOS psrinfo -v >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt ; isalist >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt ; prtconf -b >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt',  -- Solaris[tm] OE (64-bit)
                4,'HOS machinfo >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt' -- HP-UX IA (64-bit)
        ) from v$database, product_component_version
where 1=1
and to_number(substr(product_component_version.version,1,2)) > 9
and lower(product_component_version.product) like 'oracle%';
SPO OFF
SET DEF ON
@hostcommands_driver.sql
set feed on echo on

HOS awk -f sql/escpver escp_sp_&&escp_host_name_short._&&escp_dbname_short._&&esp_collection_yyyymmdd._*.csv >> escp_&&escp_host_name_short._&&escp_dbname_short._&&esp_collection_yyyymmdd..rpt

-- zip esp
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip hostcommands_driver.sql escp_&&escp_host_name_short._&&escp_dbname_short._&&esp_collection_yyyymmdd..rpt
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd._*.txt
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip escp_sp_&&escp_host_name_short._&&escp_dbname_short._&&esp_collection_yyyymmdd._*.csv
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip esp_requirements_*_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd._*.csv
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip res_requirements_*_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd._*.txt
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip features_use_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd._*.txt
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_collection_yyyymmdd..zip                          escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip 

SET TERM ON ECHO OFF FEED ON VER ON HEA ON PAGES 14 COLSEP ' ' LIN 80 TRIMS OFF TRIM ON TI OFF TIMI OFF ARRAY 15 NUM 10 SQLBL OFF BLO ON RECSEP WR;
PRO
PRO Generated escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd..zip
PRO

