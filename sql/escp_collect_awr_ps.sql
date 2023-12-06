----------------------------------------------------------------------------------------
--
-- File name:   escp_collect_awr_ps.sql (2023-11-02)
--
--              Enkitec Sizing and Capacity Planing eSCP 
--
-- Purpose:     Collect Resources Metrics of a parsing schema on an Oracle Database
-- 
--
-- Author:      Carlos Sierra, Abel Macias
--
-- Usage:       Extract from AWR a subset of:
--
--                  view                         resource(s)
--                  ---------------------------- -----------------
--                  DBA_HIST_ACTIVE_SESS_HISTORY CPU
--                  DBA_HIST_SGA                 MEM
--                  DBA_HIST_PGASTAT             MEM
--                  DBA_HIST_TBSPC_SPACE_USAGE   DISK
--                  DBA_HIST_LOG                 DISK
--                  DBA_HIST_SYSSTAT             IOPS MBPS PHYR PHYW NETW IC
--                  DBA_HIST_DLM_MISC            IC
--                  DBA_HIST_OSSTAT              OS
--
--              Collections from this script are consumed by the ESCP tool.
--              Warning: Stats may not be available because its collection is not implemented yet or lack of granularity.
--              Warning: The parsing schema name replaces the database name to consider it as a "PDB"
--
-- Example:     # cd escp_collect
--              # sqlplus / as sysdba
--              SQL> DEF escp_parsing_schema ='SCOTT'  -- case sensitive
--              SQL> START sql/escp_collect_awr_ps.sql
--
-- Notes:       Developed and tested on 19.16
--
-- Warning:     Requires a license for the Oracle Diagnostics Pack
--
-- Modified on November 2023 to collect info at parsing schema level
-- Modified on Feburary 2023 to redefine min_instance_host_id
-- Modified on January 2023 to adapt to multitenat
-- Modified on April 12th, 2021 to Add Date Range
---------------------------------------------------------------------------------------


SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;

@@escp_config.sql
@@escp_edb360_config.sql

-- Parameters for detect_environment.sql 

def env_diagnostics_pack = 'Y'
def env_conf_dbid='&&escp_conf_dbid.'
def env_conf_date_from = '&&escp_conf_date_from.'; 
def env_conf_date_to ='&&escp_conf_date_to.';
def env_conf_days = '&&ESCP_MAX_DAYS.';
def env_conf_dd_mode = '&&escp_conf_dd_mode.'
def env_conf_con_option ='&&escp_conf_con_option.'
def env_conf_is_cdb = '&&escp_conf_is_cdb.'

@@detect_environment.sql

-- Output of detect_environment.sql 
DEFINE is_cdb = '&&ENV_IS_CDB.'
DEFINE escp_con_id = '&&ENV_CON_ID.'
DEFINE escp_pdb_name = '&&ENV_PDB_NAME.'
DEFINE escp_awr_con_option = '&&ENV_AWR_CON_OPTION.'
DEFINE escp_awr_hist_prefix = '&&ENV_AWR_HIST_PREFIX.'
DEFINE escp_awr_object_prefix = '&&ENV_AWR_OBJECT_PREFIX.'
DEFINE escp_this_dbid = '&&ENV_DBID.'
DEFINE escp_history_days = '&&ENV_HISTORY_DAYS.'
DEFINE ESCP_DATE_FORMAT = '&&ENV_DATE_FORMAT.'
DEFINE escp_timestamp_format = '&&ENV_DATE_FORMAT.'
DEFINE escp_date_from = '&&ENV_DATE_FROM.'
DEFINE escp_date_to = '&&ENV_DATE_TO.' 
DEFINE escp_minimum_snap_id = '&&ENV_MINIMUM_SNAP_ID.'
DEFINE escp_maximum_snap_id = '&&ENV_MAXIMUM_SNAP_ID.'
-- skip_noncdb and skip_cdb are also defined
-- end of Output of detect_environment.sql 

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
ALTER SESSION SET NLS_DATE_FORMAT = '&&ESCP_DATE_FORMAT.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&ESCP_DATE_FORMAT.';


-- get host name (up to 30, stop before first '.', no special characters)
DEF escp_host_name_short = '';
COL escp_host_name_short NEW_V escp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) escp_host_name_short FROM DUAL;
SELECT SUBSTR('&&escp_host_name_short.', 1, INSTR('&&escp_host_name_short..', '.') - 1) escp_host_name_short FROM DUAL;
SELECT TRANSLATE('&&escp_host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') escp_host_name_short FROM DUAL;

-- get database name (up to 10, stop before first '.', no special characters)
COL escp_dbname_short NEW_V escp_dbname_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) escp_dbname_short FROM DUAL;
SELECT SUBSTR('&&escp_dbname_short.', 1, INSTR('&&escp_dbname_short..', '.') - 1) escp_dbname_short FROM DUAL;
SELECT TRANSLATE('&&escp_dbname_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') escp_dbname_short FROM DUAL;

-- get collection date
DEF escp_collection_yyyymmdd_hhmi = '';
COL escp_collection_yyyymmdd_hhmi NEW_V escp_collection_yyyymmdd_hhmi FOR A13;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') escp_collection_yyyymmdd_hhmi FROM DUAL;

COL escp_this_inst_num NEW_V escp_this_inst_num;
SELECT 'get_instance_number', TO_CHAR(instance_number) escp_this_inst_num FROM v$instance
/

DEF escp_dd_prefix = 'DBA_'
COL escp_dd_prefix NEW_V escp_dd_prefix
SELECT DECODE('&&is_cdb.','Y','CDB_','DBA_') env_conf_is_cdb from DUAL;
DEF escp_user_id = 0
COL escp_user_id NEW_V escp_user_id
SELECT user_id escp_user_id FROM &&escp_dd_prefix.USERS WHERE username='&&escp_parsing_schema.';

DEF;

---------------------------------------------------------------------------------------

SPO escp_&&escp_host_name_short._&&escp_dbname_short._&&escp_parsing_schema._&&escp_collection_yyyymmdd_hhmi..csv;

COL escp_metric_group    FOR A8;
COL escp_metric_acronym  FOR A16;
COL escp_instance_number FOR A4;
COL escp_end_date        FOR A20;
COL escp_value           FOR A128;

-- header
SELECT 'METGROUP'       escp_metric_group,
       'METRIC_ACRONYM' escp_metric_acronym,
       'INST'           escp_instance_number,
       'END_DATE'       escp_end_date,
       'VALUE'          escp_value 
  FROM DUAL
/

SELECT 'BEGIN'                    escp_metric_group,
       d.name                     escp_metric_acronym,
       TO_CHAR(i.instance_number) escp_instance_number,
       SYSDATE                    escp_end_date,
       i.host_name                escp_value 
  FROM v$instance i, 
       v$database d
/

-- collection user
SELECT 'COLLECT' escp_metric_group,
       'USER'    escp_metric_acronym,
       NULL      escp_instance_number,
       NULL      escp_end_date,
       USER      escp_value 
  FROM v$instance
/

/*
-- collection days
SELECT 'COLLECT'                                  escp_metric_group,
       'DAYS'                                     escp_metric_acronym,
       NULL                                       escp_instance_number,
       TO_CHAR(SYSDATE - &&escp_collection_days.) escp_end_date,
       '&&escp_collection_days.'                  escp_value 
  FROM v$instance
/
*/
-- To support Date Range
-- collection days
SELECT 'COLLECT'                                  escp_metric_group,
       'DAYS'                                     escp_metric_acronym,
       NULL                                       escp_instance_number,
       '&&escp_date_to.'                          escp_end_date,
       '&&escp_history_days.'                          escp_value 
  FROM v$instance
/

---------------------------------------------------------------------------------------

-- database dbid
SELECT 'DATABASE'       escp_metric_group,
       'DBID'           escp_metric_acronym,
       NULL             escp_instance_number,
       NULL             escp_end_date,
       TO_CHAR('&&escp_this_dbid.')    escp_value 
  FROM DUAL
/

-- database name
SELECT 'DATABASE'       escp_metric_group,
       'NAME'           escp_metric_acronym,
       NULL             escp_instance_number,
       NULL             escp_end_date,
       substr('&&escp_parsing_schema.',1,30)             escp_value -- the parsing schema is treated as a PDB
  FROM v$database
/

-- database created
SELECT 'DATABASE'       escp_metric_group,
       'CREATED'        escp_metric_acronym,
       NULL             escp_instance_number,
       NULL             escp_end_date,
       TO_CHAR(created) escp_value 
  FROM v$database
/

-- database db_unique_name
SELECT 'DATABASE'       escp_metric_group,
       'DB_UNIQUE_NAME' escp_metric_acronym,
       NULL             escp_instance_number,
       NULL             escp_end_date,
       db_unique_name   escp_value 
  FROM v$database
/

-- database instance_name_min
SELECT 'DATABASE'         escp_metric_group,
       'INST_NAME_MIN'    escp_metric_acronym,
       NULL               escp_instance_number,
       NULL               escp_end_date,
       MIN(instance_name) escp_value 
  FROM &&escp_awr_hist_prefix.database_instance
 WHERE dbid = &&escp_this_dbid.
/

-- database instance_name_max
SELECT 'DATABASE'         escp_metric_group,
       'INST_NAME_MAX'    escp_metric_acronym,
       NULL               escp_instance_number,
       NULL               escp_end_date,
       MAX(instance_name) escp_value 
  FROM &&escp_awr_hist_prefix.database_instance
 WHERE dbid = &&escp_this_dbid.
/

-- database host_name_min
SELECT 'DATABASE'      escp_metric_group,
       'HOST_NAME_MIN' escp_metric_acronym,
       NULL            escp_instance_number,
       NULL            escp_end_date,
       MIN(host_name)  escp_value 
  FROM &&escp_awr_hist_prefix.database_instance
 WHERE dbid = &&escp_this_dbid.
/

-- database host_name_max
SELECT 'DATABASE'      escp_metric_group,
       'HOST_NAME_MAX' escp_metric_acronym,
       NULL            escp_instance_number,
       NULL            escp_end_date,
       MAX(host_name)  escp_value 
  FROM &&escp_awr_hist_prefix.database_instance
 WHERE dbid = &&escp_this_dbid.
/

-- database version
SELECT 'DATABASE' escp_metric_group,
       'VERSION'  escp_metric_acronym,
       NULL       escp_instance_number,
       NULL       escp_end_date,
       version    escp_value 
  FROM v$instance
/

-- database platform_name
SELECT 'DATABASE'    escp_metric_group,
       'PLATFORM'    escp_metric_acronym,
       NULL          escp_instance_number,
       NULL          escp_end_date,
       platform_name escp_value 
  FROM v$database
/

-- database db_block_size
SELECT 'DATABASE'           escp_metric_group,
       'DB_BLOCK_SIZE'      escp_metric_acronym,
       NULL                 escp_instance_number,
       NULL                 escp_end_date,
       SUBSTR(value, 1, 10) escp_value 
  FROM v$system_parameter2
 WHERE name = 'db_block_size'
/

-- database min_instance_host_id
WITH
all_instances AS (
SELECT instance_number, MAX(startup_time) max_startup_time
  FROM &&escp_awr_hist_prefix.database_instance
 WHERE dbid = &&escp_this_dbid.
 GROUP BY 
       instance_number
)
SELECT 'DATABASE'                      escp_metric_group,
       'MIN_INST_HOST'                 escp_metric_acronym,
       TO_CHAR(MIN(h.instance_number)) escp_instance_number,
       NULL                            escp_end_date,
       MIN(h.host_name)                escp_value 
  FROM &&escp_awr_hist_prefix.database_instance h
      ,all_instances i
 WHERE dbid = &&escp_this_dbid.
   AND h.instance_number = i.instance_number
   and h.startup_time=i.max_startup_time
/


---------------------------------------------------------------------------------------

-- instance instance_name
WITH
all_instances AS (
SELECT instance_number, MAX(startup_time) max_startup_time
  FROM &&escp_awr_hist_prefix.database_instance
 WHERE dbid = &&escp_this_dbid.
 GROUP BY 
       instance_number
)
SELECT 'INSTANCE'                 escp_metric_group,
       'INSTANCE_NAME'            escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.startup_time             escp_end_date,
       h.instance_name            escp_value
  FROM all_instances a,
       &&escp_awr_hist_prefix.database_instance h
 WHERE h.dbid = &&escp_this_dbid.
   AND h.instance_number = a.instance_number
   AND h.startup_time = a.max_startup_time
 ORDER BY
       h.instance_number
/

-- instance host_name
WITH
all_instances AS (
SELECT instance_number, MAX(startup_time) max_startup_time
  FROM &&escp_awr_hist_prefix.database_instance
 WHERE dbid = &&escp_this_dbid.
 GROUP BY 
       instance_number
)
SELECT 'INSTANCE'                 escp_metric_group,
       'HOST_NAME'                escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.startup_time             escp_end_date,
       h.host_name                escp_value
  FROM all_instances a,
       &&escp_awr_hist_prefix.database_instance h
 WHERE h.dbid = &&escp_this_dbid.
   AND h.instance_number = a.instance_number
   AND h.startup_time = a.max_startup_time
 ORDER BY
       h.instance_number
/

---------------------------------------------------------------------------------------

-- DBA_HIST_ACTIVE_SESS_HISTORY CPU
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       'CPU'                      escp_metric_group,
       CASE h.session_state 
       WHEN 'ON CPU' THEN 'CPU' 
       ELSE 'RMCPUQ' 
       END                        escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.sample_time              escp_end_date,
       TO_CHAR(COUNT(*))          escp_value
  FROM &&escp_awr_hist_prefix.active_sess_history h
 WHERE h.snap_id BETWEEN &&escp_minimum_snap_id. AND &&escp_maximum_snap_id.
   AND h.dbid = &&escp_this_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
   AND h.sample_time BETWEEN TO_TIMESTAMP('&&escp_date_from.','&&escp_timestamp_format.') 
              AND TO_TIMESTAMP('&&escp_date_to.','&&escp_timestamp_format.')
   AND h.user_id=&&escp_user_id.
 GROUP BY
       h.session_state,
       h.instance_number,
       h.sample_time
 ORDER BY
       h.session_state,
       h.instance_number,
       h.sample_time
/

-- DBA_HIST_SGA MEM
-- Not available.


-- DBA_HIST_PGASTAT MEM
-- Not available


-- DBA_HIST_TBSPC_SPACE_USAGE DISK
-- Not available


-- DBA_HIST_LOG DISK
-- Not available


-- DBA_HIST_SYSSTAT IOPS MBPS 
-- Not available NETW IC
WITH
dba_hist_sysstat_sqf AS (
select /*+ MATERIALIZE */ d.* ,SUM(delta) OVER (partition by stat_name,instance_number order by SNAP_ID) value
from (
select snap_id,instance_number
      ,SUM(PHYSICAL_READ_REQUESTS_TOTAL)  "physical read total IO requests"
      ,SUM(PHYSICAL_WRITE_REQUESTS_TOTAL) "physical write total IO requests"
      ,SUM(PHYSICAL_READ_BYTES_TOTAL)     "physical read total bytes"
      ,SUM(PHYSICAL_WRITE_BYTES_TOTAL)    "physical write total bytes"
      ,SUM(DISK_READS_TOTAL)              "physical reads"
      ,SUM(DIRECT_WRITES_TOTAL)           "physical writes"
      ,SUM(0)                             "redo writes" -- not available but necessary value
      ,SUM(0)                             "redo size"   -- not available but necessary value      
  from dba_hist_sqlstat h
 WHERE h.snap_id BETWEEN &&escp_minimum_snap_id. AND &&escp_maximum_snap_id.
   AND h.dbid = &&escp_this_dbid.
   and h.PARSING_SCHEMA_ID = &&escp_user_id.
 GROUP BY snap_id,instance_number
)
UNPIVOT(
 delta
 for stat_name 
 in (
     "physical read total IO requests"  as 'physical read total IO requests'
    ,"physical write total IO requests" as 'physical write total IO requests'
    ,"physical read total bytes"        as 'physical read total bytes'
    ,"physical write total bytes"       as 'physical write total bytes'
    ,"physical reads"                   as 'physical reads'
    ,"physical writes"                  as 'physical writes'
    ,"redo writes"                      as 'redo writes'
    ,"redo size"                        as 'redo size'
 )
) d
),
dba_hist_snapshot_sqf AS (
SELECT /*+ 
       MATERIALIZE 
       NO_MERGE 
       FULL(s.INT$DBA_HIST_SNAPSHOT.WRM$_SNAPSHOT)
       FULL(s.WRM$_SNAPSHOT)
       */
       s.snap_id,
       s.instance_number,
       s.end_interval_time
  FROM &&escp_awr_hist_prefix.snapshot s
 WHERE s.snap_id BETWEEN &&escp_minimum_snap_id. AND &&escp_maximum_snap_id.
   AND s.dbid = &&escp_this_dbid.
   AND s.end_interval_time BETWEEN TO_TIMESTAMP('&&escp_date_from.','&&escp_timestamp_format.') 
              AND TO_TIMESTAMP('&&escp_date_to.','&&escp_timestamp_format.')
)
SELECT /*+ USE_HASH(h s) */
       CASE h.stat_name
       WHEN 'physical read total IO requests'        THEN 'IOPS'
       WHEN 'physical write total IO requests'       THEN 'IOPS'
       WHEN 'redo writes'                            THEN 'IOPS'
       WHEN 'physical read total bytes'              THEN 'MBPS'
       WHEN 'physical write total bytes'             THEN 'MBPS'
       WHEN 'redo size'                              THEN 'MBPS'
       WHEN 'physical reads'                         THEN 'PHYR'
       WHEN 'physical reads direct'                  THEN 'PHYR'
       WHEN 'physical reads cache'                   THEN 'PHYR'
       WHEN 'physical writes'                        THEN 'PHYW'
       WHEN 'physical writes direct'                 THEN 'PHYW'
       WHEN 'physical writes from cache'             THEN 'PHYW'
       WHEN 'bytes sent via SQL*Net to client'       THEN 'NETW'
       WHEN 'bytes received via SQL*Net from client' THEN 'NETW'
       WHEN 'bytes sent via SQL*Net to dblink'       THEN 'NETW'
       WHEN 'bytes received via SQL*Net from dblink' THEN 'NETW'
       WHEN 'gc cr blocks received'                  THEN 'IC'
       WHEN 'gc current blocks received'             THEN 'IC'
       WHEN 'gc cr blocks served'                    THEN 'IC'
       WHEN 'gc current blocks served'               THEN 'IC'
       WHEN 'gcs messages sent'                      THEN 'IC'
       WHEN 'ges messages sent'                      THEN 'IC'
       END                                           escp_metric_group,
       CASE h.stat_name
       WHEN 'physical read total IO requests'        THEN 'RREQS'
       WHEN 'physical write total IO requests'       THEN 'WREQS'
       WHEN 'redo writes'                            THEN 'WREDO'
       WHEN 'physical read total bytes'              THEN 'RBYTES'
       WHEN 'physical write total bytes'             THEN 'WBYTES'
       WHEN 'redo size'                              THEN 'WREDOBYTES'
       WHEN 'physical reads'                         THEN 'PHYR'
       WHEN 'physical reads direct'                  THEN 'PHYRD'
       WHEN 'physical reads cache'                   THEN 'PHYRC'
       WHEN 'physical writes'                        THEN 'PHYW'
       WHEN 'physical writes direct'                 THEN 'PHYWD'
       WHEN 'physical writes from cache'             THEN 'PHYWC'
       WHEN 'bytes sent via SQL*Net to client'       THEN 'TOCLIENT'
       WHEN 'bytes received via SQL*Net from client' THEN 'FROMCLIENT'
       WHEN 'bytes sent via SQL*Net to dblink'       THEN 'TODBLINK'
       WHEN 'bytes received via SQL*Net from dblink' THEN 'FROMDBLINK'
       WHEN 'gc cr blocks received'                  THEN 'GCCRBR'
       WHEN 'gc current blocks received'             THEN 'GCCBLR'
       WHEN 'gc cr blocks served'                    THEN 'GCCRBS'
       WHEN 'gc current blocks served'               THEN 'GCCBLS'
       WHEN 'gcs messages sent'                      THEN 'GCSMS'
       WHEN 'ges messages sent'                      THEN 'GESMS'
       END                                           escp_metric_acronym,
       TO_CHAR(h.instance_number)                    escp_instance_number,
       s.end_interval_time                           escp_end_date,
       TO_CHAR(h.value)                              escp_value
  FROM dba_hist_sysstat_sqf  h,
       dba_hist_snapshot_sqf s
 WHERE s.snap_id         = h.snap_id
   AND s.instance_number = h.instance_number
 ORDER BY
       CASE h.stat_name
       WHEN 'physical read total IO requests'        THEN 1.1
       WHEN 'physical write total IO requests'       THEN 1.2
       WHEN 'redo writes'                            THEN 1.3
       WHEN 'physical read total bytes'              THEN 2.1
       WHEN 'physical write total bytes'             THEN 2.2
       WHEN 'redo size'                              THEN 2.3
       WHEN 'physical reads'                         THEN 3.1
       WHEN 'physical reads direct'                  THEN 3.2
       WHEN 'physical reads cache'                   THEN 3.3
       WHEN 'physical writes'                        THEN 4.1
       WHEN 'physical writes direct'                 THEN 4.2
       WHEN 'physical writes from cache'             THEN 4.3
       WHEN 'bytes sent via SQL*Net to client'       THEN 5.1
       WHEN 'bytes received via SQL*Net from client' THEN 5.2
       WHEN 'bytes sent via SQL*Net to dblink'       THEN 5.3
       WHEN 'bytes received via SQL*Net from dblink' THEN 5.4
       WHEN 'gc cr blocks received'                  THEN 6.1
       WHEN 'gc current blocks received'             THEN 6.2
       WHEN 'gc cr blocks served'                    THEN 6.3
       WHEN 'gc current blocks served'               THEN 6.4
       WHEN 'gcs messages sent'                      THEN 6.5
       WHEN 'ges messages sent'                      THEN 6.6
       ELSE 9.9 
       END,
       h.instance_number,
       s.end_interval_time
/

-- DBA_HIST_DLM_MISC IC
-- Not available

-- DBA_HIST_OSSTAT OS
-- Not available

---------------------------------------------------------------------------------------

-- collection end
SELECT 'END'                      escp_metric_group,
       d.name                     escp_metric_acronym,
       TO_CHAR(i.instance_number) escp_instance_number,
       SYSDATE                    escp_end_date,
       i.host_name                escp_value 
  FROM v$instance i, 
       v$database d
/

SPO OFF;
SET TERM ON ECHO OFF FEED ON VER ON HEA ON PAGES 14 COLSEP ' ' LIN 80 TRIMS OFF TRIM ON TI OFF TIMI OFF ARRAY 15 NUM 10 SQLBL OFF BLO ON RECSEP WR;
