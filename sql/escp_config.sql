-- range of dates below supersede history days when values are other than YYYY-MM-DD
-- When not using the Date Range leave the values 'YYYY-MM-DD' active
-- DEF escp_conf_date_from = 'YYYY-MM-DD';
-- DEF escp_conf_date_to   = 'YYYY-MM-DD';

DEF escp_conf_date_from = 'YYYY-MM-DD';
DEF escp_conf_date_to   = 'YYYY-MM-DD';

-- When using Date Range the escp_max_days will be ignored
-- Even when ESCP_MAX_DAYS=365 the collection will get from the SYSDATE - history_days
DEF ESCP_MAX_DAYS = '365';

-- use if you need tool to act on a dbid stored on AWR, but that is not the current v$database.dbid
DEF escp_conf_dbid = '';
-- 

-- Multitenant 
/* 
* escp_conf_dd_mode 
Allows to run eSP over different dictionary views depending on their prefix.
Valid values are DBA_HIST, CDB_HIST, AWR_ROOT, AWR_PDB, AWR_CDB, & AUTO
AUTO choice is: 
- AWR_ROOT on multitenant executing from CDB$ROOT in 12.2
- AWR_CDB  on multitenant executing from CDB$ROOT in 18c+
- AWR_PDB  on multitenant executing from PDB 
- DBA_HIST otherwise 

* escp_conf_con_option 
Allows to add the CON keyword to the name of the view.
Valid values are N , Y , A
Example 
edb360_conf_con_option | View name 
            N          | cdb_hist_sysstat
            Y          | cdb_hist_con_sysstat
"A"uto choice is:
- N on pre-12.2
- N on multitenant when executing from CDB$ROOT 
- N on multitenant when executing from PDB and no PDB snapshots found
- Y on multitenant when PDB snapshots found

* escp_conf_is_cdb 
- A autodetect (Y if DB is multitenant. N otheriwse)
- N Assume this is not a multitenant database
- Y Assume this is a multitenant database. 

There is no guarantee that all queries will execute successfully for all values and combinations.
*/
DEF escp_conf_dd_mode = 'AUTO'
DEF escp_conf_con_option = 'A'
DEF escp_conf_is_cdb = 'A'