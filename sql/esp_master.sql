----------------------------------------------------------------------------------------
--
-- File name:   esp_master.sql (2016-09-01)
--
-- Purpose:     Collect Database Requirements (CPU, Memory, Disk and IO Perf)
--
-- Author:      Carlos Sierra, Rodrigo Righetti
--
-- Usage:       Collects Requirements from AWR and ASH views on databases with the
--				Oracle Diagnostics Pack license, it also collect from Statspack starting
--				9i databases up to 12c.
--
--              The output of this script can be used to feed a Sizing and Provisioning
--              application.
--
-- Example:     # cd esp_collect
--              # sqlplus / as sysdba
--              SQL> START sql/esp_master.sql
--
--  Notes:      Developed and tested on 12.1.0.2, 12.1.0.1, 11.2.0.4, 11.2.0.3,
--				10.2.0.4, 9.2.0.8, 9.2.0.1
--
---------------------------------------------------------------------------------------
--
SET TERM ON;
PRO Executing esp_collect_requirements and resources_requirements
PRO Please wait ...

SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;

VARIABLE vskip_awr varchar2(20)
VARIABLE vskip_statspack varchar2(20)

-- IF AWR has snapshots for the last 2 hours use it and skip Statspack scripts
-- IF BOTH AWR AND SNAPSHOT HAVE NO DATA IN THE LAST 2 HOURS, IT WILL RUN BOTH.
BEGIN
    :vskip_statspack := NULL;
    :vskip_awr := NULL;
	BEGIN
		EXECUTE IMMEDIATE 'SELECT ''--skip--''  FROM DBA_HIST_SNAPSHOT WHERE begin_interval_time >= systimestamp-2/24 AND rownum < 2'
		INTO :vskip_statspack;
	EXCEPTION
		WHEN OTHERS THEN
 		NULL;
	END;
	IF :vskip_statspack IS NULL THEN
    	BEGIN
    		EXECUTE IMMEDIATE 'SELECT ''--skip--'' FROM perfstat.stats$snapshot WHERE snap_time >= sysdate-2/24 AND rownum < 2'
    		INTO :vskip_awr ;
    	EXCEPTION
    		WHEN OTHERS THEN
     		NULL;
    	END;
	END IF;
END;
/

DEF skip_awr = '';
COL skip_awr NEW_V skip_awr;
SELECT :vskip_awr skip_awr FROM dual;

DEF skip_statspack = '';
COL skip_statspack NEW_V skip_statspack;
SELECT :vskip_statspack skip_statspack FROM dual;

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

-- AWR collector
@@&&skip_awr.sql/escp_collect_awr.sql
@@&&skip_awr.sql/esp_collect_requirements_awr.sql
@@&&skip_awr.sql/resources_requirements_awr.sql

-- STATSPACK collector
@@&&skip_statspack.sql/esp_collect_requirements_statspack.sql
@@&&skip_statspack.sql/resources_requirements_statspack.sql

-- DB Features
@@sql/features_use.sql

SET TERM ON;

-- cpu info for linux, aix and solaris. expect some errors
SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;
SPO hostcommands_driver.sql
SELECT decode(  platform_id,
                13,'HOS cat /proc/cpuinfo | grep -i name | sort | uniq | cat - /sys/devices/virtual/dmi/id/product_name >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt', -- Linux x86 64-bit
                6,'HOS lsconf | grep Processor >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt', -- AIX-Based Systems (64-bit)
                2,'HOS psrinfo -v >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt', -- Solaris[tm] OE (64-bit)
                4,'HOS machinfo >> cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt' -- HP-UX IA (64-bit)
        ) from v$database, product_component_version
where 1=1
and to_number(substr(product_component_version.version,1,2)) > 9
and lower(product_component_version.product) like 'oracle%';
SPO OFF
SET DEF ON
@hostcommands_driver.sql
set feed on echo on

-- zip esp
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip hostcommands_driver.sql
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip cpuinfo_model_name_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd._*.txt
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip escp_&&escp_host_name_short._&&escp_dbname_short._&&esp_collection_yyyymmdd._*.csv
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip esp_requirements_*_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd._*.csv
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip res_requirements_*_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd._*.txt
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip features_use_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd._*.txt
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_collection_yyyymmdd..zip                          escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip 

SET TERM ON ECHO OFF FEED ON VER ON HEA ON PAGES 14 COLSEP ' ' LIN 80 TRIMS OFF TRIM ON TI OFF TIMI OFF ARRAY 15 NUM 10 SQLBL OFF BLO ON RECSEP WR;
PRO
PRO Generated escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd..zip
PRO
