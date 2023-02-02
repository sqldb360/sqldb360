/* -------------------------------------------------
Environemnt Detection

* env_diagnostics_pack 
Valid values are N , Y

* env_conf_date_from = 'YYYY-MM-DD'; 
* env_conf_date_to ='YYYY-MM-DD';
* env_conf_days = '31';
Note:env_conf_date_from/to has precedence over env_conf_days

* env_conf_dbid
define a specific DBID
Valid values are NULL and DBID from v$database or CON_DBID

* env_conf_dd_mode 
Allows to specify the group of which dictionary views to scan.
Valid values are DBA_HIST, CDB_HIST, AWR_ROOT, AWR_PDB, AWR_CDB, & AUTO
AUTO choice is: 
- AWR_ROOT on multitenant executing from CDB$ROOT in 12.2
- AWR_CDB  on multitenant executing from CDB$ROOT in 18c+
- AWR_PDB  on multitenant executing from PDB 
- DBA_HIST otherwise

* env_conf_con_option
Allows to add the CON keyword to the name of the view.
Valid values are N , Y , A
Example 
env_conf_con_option | View name 
            N       | cdb_hist_sysstat
            Y       | cdb_hist_con_sysstat
"A"uto choice is:
- N on pre-12.2
- N on multitenant when executing from CDB$ROOT 
- N on multitenant when executing from PDB and no PDB snapshots found
- Y on multitenant when PDB snapshots found

* env_conf_is_cdb 
- A autodetect (Y if DB is multitenant. N otheriwse)
- N Assume this is not a multitenant database
- Y Assume this is a multitenant database. 
Note: env_is_cdb setting is independent of env_conf_dd_mode

---------------------------------------------

This script defines variables:

* env_is_cdb 
  N for non-multitenant
  Y for multitenant

* env_dd_mode
  DBA_HIST, CDB_HIST, AWR_ROOT, AWR_PDB, AWR_CDB

* env_awr_hist_prefix   
  AWR historical group prefix

* env_awr_object_prefix 
  Data Dictionay group prefix

* env_con_id
  -1 executing from non-multitenant
  0-1:CDB$ROOT 2:PDB$SEED >2:PDB

* env_pdb_name
  NONE For non-multitenant  
  CDB$ROOT For multitenant or user defined depeding the connection.

* env_dbid         
  For multitenant executing from PDB and if there are PDB specific snapshots then returns PDB in v$database.CON_DBID
  Otherwise (For non-multitenant and multitenant executing from CDB$ROOT) returns V$database.DBID

* env_awr_con_option 
  CON on multitenant when PDB snapshots found
  NULL otherwise

* env_minimum_snap_id
* env_maximum_snap_id
Range of snap_ids of snapshots for the env_dbid

* env_date_from
* env_date_to 
Range of dates belonging to env_minimum_snap_id and env_maximum_snap_id

* skip_cdb    '--' when executing in a multitenant DB (as indicated by env_is_cdb)
* skip_noncdb '--' when executing in a non-multitenant DB (as indicated by env_is_cdb)

*/

-- get container info
DEF env_is_cdb = 'N'
COL env_is_cdb NEW_V env_is_cdb;

DEF env_con_id = '-1';
COL env_con_id NEW_V env_con_id;

DEF env_pdb_name = 'NONE'
COL env_pdb_name NEW_V env_pdb_name;

SELECT /* ignore if it fails to parse */ 
       'Y' env_is_cdb
      ,SYS_CONTEXT('USERENV','CON_ID') env_con_id 
      ,SYS_CONTEXT('USERENV', 'CON_NAME') env_pdb_name 
  FROM v$pdbs 
fetch first row only;

SELECT DECODE(UPPER('&&env_conf_is_cdb'),'Y','Y','N','N','&&env_is_cdb.') env_is_cdb
FROM DUAL;

COL env_con_id CLEAR
COL env_pdb_name CLEAR
COL env_is_cdb CLEAR

col env_dd_mode NEW_V env_dd_mode
col env_awr_con_option new_v env_awr_con_option
select 
 (CASE WHEN upper('&&env_conf_dd_mode.')  IN ('DBA_HIST','CDB_HIST','AWR_ROOT','AWR_CDB','AWR_PDB')
       THEN upper('&&env_conf_dd_mode.')  
  ELSE -- AUTO or typo
   (CASE '&&env_pdb_name.'
    WHEN 'NONE'     THEN 'DBA_HIST' 
    WHEN 'CDB$ROOT' THEN 'AWR_ROOT'
    ELSE                 'AWR_PDB'
    END) 
  END) env_dd_mode
 ,decode(upper('&&env_conf_con_option.'),'Y','CON_','') env_awr_con_option
FROM DUAL;

/*
This query only serves to verify the existance of AWR_CDB and snapshots in it.
*/
SELECT /* ignore if it fails to parse */
       'AWR_CDB' env_dd_mode
  FROM awr_cdb_snapshot
 WHERE '&&env_dd_mode'='AWR_ROOT'
   and '&&env_diagnostics_pack.' = 'Y'
fetch first row only;

/*
FailSafe - there should be at least the snapshot table of the view group otherwise choose DBA_HIST
*/
SELECT 'DBA_HIST' env_dd_mode
  FROM DUAL
 WHERE NOT EXISTS (SELECT 1 FROM dba_catalog where table_name='&&env_dd_mode._SNAPSHOT');

-- Auto if A or typo
SELECT /* ignore if it fails to parse */
      'CON_' env_awr_con_option
FROM awr_pdb_con_sysstat
where con_id>2
  and '&&env_diagnostics_pack.' = 'Y'
  and '&&env_pdb_name.'<>'CDB$ROOT'
  and upper('&&env_conf_con_option.') not in ('Y','N')
fetch first row only;

COL env_dd_mode CLEAR
COL env_awr_con_option CLEAR

-------------------------------

COL skip_cdb     new_v skip_cdb     nopri
COL skip_noncdb  new_v skip_noncdb  nopri

select
decode('&&env_is_cdb.','Y','','N','--') skip_noncdb,
decode('&&env_is_cdb.','Y','--','N','') skip_cdb
from dual;

COL skip_cdb    clear
COL skip_noncdb clear

-------------------------------

/* This objects adapt their prefix depending on circumstances  */

COL env_awr_hist_prefix   NEW_V env_awr_hist_prefix
COL env_awr_object_prefix NEW_V env_awr_object_prefix

SELECT 'DBA_HIST_'   env_awr_hist_prefix
      ,'dba_' env_awr_object_prefix    
FROM DUAL WHERE '&&env_dd_mode.'='DBA_HIST'
UNION 
SELECT 'CDB_HIST_' env_awr_hist_prefix
      ,'cdb_'      env_awr_object_prefix
FROM DUAL WHERE '&&env_dd_mode.'='CDB_HIST'
UNION 
SELECT 'AWR_ROOT_' env_awr_hist_prefix
      ,'awr_root_' env_awr_object_prefix
FROM DUAL WHERE '&&env_dd_mode.'='AWR_ROOT'
UNION 
SELECT 'AWR_CDB_' env_awr_hist_prefix
      ,'awr_cdb_' env_awr_object_prefix
FROM DUAL WHERE '&&env_dd_mode.'='AWR_CDB'
UNION 
SELECT 'AWR_PDB_' env_awr_hist_prefix
      ,'awr_PDB_' env_awr_object_prefix
FROM DUAL WHERE '&&env_dd_mode.'='AWR_PDB';

COL env_awr_hist_prefix   CLEAR
COL env_awr_object_prefix CLEAR

-- get dbid 
-- By default in a CDB or PDB this will be the DBID of the container
COL env_dbid NEW_V env_dbid;
SELECT TRIM(TO_CHAR(NVL(TO_NUMBER('&&env_conf_dbid.'), dbid))) env_dbid FROM v$database;

/*
--amc 01.1.2023 the snapshots of the pdb are not in dba_hist. making it adaptable to env_dd_mode.
--dmk 31.1.2019 if in PDB work with DBID of PDB in v$database.CON_DBID if there are PDB specific snapshots
*/
SELECT /* ignore if it fails to parse in pre-12.1 */
     TRIM(TO_CHAR(NVL(TO_NUMBER('&&env_conf_dbid.'), v.con_dbid))) env_dbid 
FROM v$database v, &&env_awr_hist_prefix.snapshot s 
WHERE s.dbid = v.con_dbid 
  AND '&&env_is_cdb.'='Y' 
  and '&&env_diagnostics_pack.' = 'Y' 
fetch first row only;

COL env_dbid CLEAR

DEF env_history_days = 0
COL env_history_days NEW_V env_history_days;
-- range: takes at least 31 days and at most as many as actual history, with a default of 31. parameter restricts within that range.
SELECT NVL(TO_CHAR(LEAST(CEIL(SYSDATE - CAST(MIN(begin_interval_time) AS DATE)), GREATEST(31, TO_NUMBER(NVL(TRIM('&&env_conf_days.'), '31'))))),'31') env_history_days 
  FROM &&env_awr_hist_prefix.snapshot 
 WHERE '&&env_diagnostics_pack.' = 'Y' 
   AND '&&env_conf_date_from.' = 'YYYY-MM-DD' AND '&&env_conf_date_to.' = 'YYYY-MM-DD'
   AND dbid = &&env_dbid.;
   
SELECT TO_CHAR(TO_DATE('&&env_conf_date_to.', 'YYYY-MM-DD') - TO_DATE('&&env_conf_date_from.', 'YYYY-MM-DD') + 1) env_history_days 
  FROM DUAL 
 WHERE '&&env_conf_date_from.' != 'YYYY-MM-DD' AND '&&env_conf_date_to.' != 'YYYY-MM-DD';

-- Dates format
DEF env_date_format = 'YYYY-MM-DD"T"HH24:MI:SS';

COL env_date_from NEW_V env_date_from;
COL env_date_to NEW_V env_date_to;
SELECT CASE '&&env_conf_date_from.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE - &&env_history_days., '&&env_date_format.') ELSE '&&env_conf_date_from.T00:00:00' END env_date_from
      ,CASE '&&env_conf_date_to.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE, '&&env_date_format.') ELSE '&&env_conf_date_to.T23:59:59' END env_date_to 
 FROM DUAL;

-- snapshot ranges

DEF env_minimum_snap_id=''
COL env_minimum_snap_id NEW_V env_minimum_snap_id;

DEF env_maximum_snap_id=''
COL env_maximum_snap_id NEW_V env_maximum_snap_id;

SELECT NVL(TO_CHAR(MAX(snap_id)), 1) env_maximum_snap_id
      ,NVL(TO_CHAR(MAX(end_interval_time),'&&env_date_format.'),'&&env_date_to.') env_date_to
  FROM &&env_awr_hist_prefix.snapshot 
 WHERE '&&env_diagnostics_pack.' = 'Y' 
   AND dbid = &&env_dbid. 
   AND end_interval_time <= TO_DATE('&&env_date_to.', '&&env_date_format.');
SELECT '-1' env_maximum_snap_id FROM DUAL WHERE TRIM('&&env_maximum_snap_id.') IS NULL;

SELECT NVL(TO_CHAR(MIN(snap_id)), '0') env_minimum_snap_id 
      ,NVL(TO_CHAR(MIN(begin_interval_time),'&&env_date_format.'),'&&env_date_from.') env_date_from
  FROM &&env_awr_hist_prefix.snapshot 
 WHERE '&&env_diagnostics_pack.' = 'Y' 
   AND dbid = &&env_dbid. 
   AND begin_interval_time >=TO_DATE('&&env_date_to.', '&&env_date_format.')-&&env_history_days.
   AND begin_interval_time < TO_DATE('&&env_date_to.', '&&env_date_format.');
SELECT '-1' env_minimum_snap_id FROM DUAL WHERE TRIM('&&env_minimum_snap_id.') IS NULL;

SELECT TO_CHAR(TRIM(GREATEST(ROUND(TO_DATE('&&env_date_to.', '&&env_date_format.') - TO_DATE('&&env_date_from.', '&&env_date_format.')),1))) env_history_days 
  FROM DUAL;

COL env_history_days CLEAR
COL env_date_from CLEAR
COL env_date_to CLEAR
COL env_minimum_snap_id CLEAR
COL env_maximum_snap_id CLEAR
