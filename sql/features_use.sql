----------------------------------------------------------------------------------------
--
-- File name:   features_use.sql (2016-09-01)
--
-- Purpose:     Collect Database Features Use
--
-- Author:      Carlos Sierra
--
-- Usage:       Collects V$OPTION and DBA_FEATURE_USAGE_STATISTICS
--				 
--              The output of this script can be used to determine which database
--              features the application requires.
--
-- Example:     # cd esp_collect-master
--              # sqlplus / as sysdba
--              SQL> START sql/esp_master.sql
--
--  Notes:      Developed and tested on 12.1.0.2, 11.2.0.4, 11.2.0.3, 10.2.0.4
--             
---------------------------------------------------------------------------------------
--
SET TERM OFF ECHO OFF FEED OFF VER OFF HEA ON PAGES 100 COLSEP ' ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 10 SQLBL ON BLO . RECSEP OFF LONG 8000 LONGC 80;

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
DEF esp_collection_yyyymmdd_hhmi = '';
COL esp_collection_yyyymmdd_hhmi NEW_V esp_collection_yyyymmdd_hhmi FOR A13;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') esp_collection_yyyymmdd_hhmi FROM DUAL;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';

CL COL;

SPO features_use_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt;

/*****************************************************************************************/

PRO
PRO V$OPTION
PRO ~~~~~~~~
SELECT * FROM v$option
/

/*****************************************************************************************/

PRO
PRO DBA_FEATURE_USAGE_STATISTICS
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT * FROM dba_feature_usage_statistics
/

/*****************************************************************************************/

SPO OFF;
SET TERM ON ECHO OFF FEED ON VER ON HEA ON PAGES 14 COLSEP ' ' LIN 80 TRIMS OFF TRIM ON TI OFF TIMI OFF ARRAY 15 NUM 10 SQLBL OFF BLO ON RECSEP WR;

