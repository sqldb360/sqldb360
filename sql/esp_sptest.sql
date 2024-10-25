-------------------------------------------------------------------
-- Checking the statspack is installed. Abort if it does not exist.

DEF sptest_result ='Failed to collect from Statspack'
COL sptest_result NEW_V sptest_result
host touch statspack_installation_test.txt
HOS zip -qj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip statspack_installation_test.txt
SPOOL statspack_installation_test.txt APP
SELECT 'Statspack has '||COUNT(*)||' snapshots' sptest_result FROM stats$snapshot WHERE rownum=1;
PROMPT &&sptest_result.
SPOOL OFF
HOS zip -qmj escp_output_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..zip statspack_installation_test.txt

-------------------------------------------------------------------