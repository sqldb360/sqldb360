----------------------------------------------------------------------------------------
--
-- File name:   resources_requirements_statspack.sql (2016-09-01)
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
-- Example:     # cd esp_collect-master
--              # sqlplus / as sysdba
--              SQL> START sql/esp_master.sql
--
--  Notes:      Developed and tested on 12.1.0.2, 12.1.0.1, 11.2.0.4, 11.2.0.3, 
--				10.2.0.4, 9.2.0.8, 9.2.0.1
--             
---------------------------------------------------------------------------------------
--
SET TERM OFF ECHO OFF FEED OFF VER OFF HEA ON PAGES 100 COLSEP ' ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 10 SQLBL ON BLO . RECSEP OFF;

-- get host name (up to 30, stop before first '.', no special characters)
DEF esp_host_name_short = '';
COL esp_host_name_short NEW_V esp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(host_name, 1, decode(instr(host_name,'.'),0,31,instr(host_name,'.'))-1)) esp_host_name_short FROM v$instance;
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

COL ecr_collection_key NEW_V ecr_collection_key;
-- STATSPACK
-- removed ora_hash for Oracle 9i
SELECT 'get_collection_key', SUBSTR(name||(dbid||name||instance_name||host_name||systimestamp), 1, 13) ecr_collection_key FROM v$instance, v$database;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';

CL COL;

SPO res_requirements_stp_&&esp_host_name_short._&&esp_dbname_short._&&esp_collection_yyyymmdd_hhmi..txt;

/*****************************************************************************************/

SELECT dbid, name FROM v$database
/

/*****************************************************************************************/

COL startup_time FOR A26;
COL short_host_name FOR A30;
COL platform_name FOR A40;

PRO Database/Instance
PRO ~~~~~~~~~~~~~~~~~
SELECT st.dbid,				
       st.instance_number,	
       st.startup_time,		
       i.version,			
       d.name db_name,
       i.instance_name,
       TRANSLATE(LOWER(SUBSTR(SUBSTR(host_name, 1, decode(INSTR(i.host_name, '.'),0,30,INSTR(i.host_name, '.')) - 1), 1, 30)),
        'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
        'abcdefghijklmnopqrstuvwxyz0123456789-_')
        short_host_name,			
        pl.platform_name	
  FROM (SELECT DISTINCT dbid, instance_number, startup_time
        FROM perfstat.stats$snapshot) st,
       gv$instance i,
       gv$database d,
       (select os||' '||bit platform_name
          from (
            SELECT 1 id, substr(banner,9,instr(banner,':')-9)  os FROM v$version  where banner like 'TNS for%') a Left outer join
            (select 1 id, substr(banner,instr(banner,'bit')-2,5) bit   FROM v$version  where banner like '%bit Pro%') b 
            on a.id=b.id
            ) pl
  WHERE st.instance_number=i.inst_id
  AND   i.inst_id=d.inst_id
  ORDER BY
       dbid,				
       instance_number,	
       startup_time
/

/*****************************************************************************************/
PRO
COL order_by NOPRI;
COL metric FOR A26 HEA "Metric";
COL instance_number FOR 9999 HEA "Inst|Num";
COL on_cpu FOR 999990.0 HEA "Active|Sessions|ON CPU";
COL on_cpu_and_resmgr FOR 9999990.0 HEA "Active|Sessions|ON CPU|or RESMGR";
COL resmgr_cpu_quantum FOR 999999990.0 HEA "Active|Sessions|ON RESMGR|CPU quantum";
COL begin_interval_time FOR A18 HEA "Begin Interval";
COL end_interval_time FOR A18 HEA "End Interval";
COL snap_shots FOR 99999 HEA "Snap|Shots";
COL days FOR 990.0 HEA "Days|Hist";
COL avg_snaps_per_day FOR 990.0 HEA "Avg|Snaps|per|Day";
COL min_sample_time FOR A18 HEA "Begin Interval";
COL max_sample_time FOR A18 HEA "End Interval";
COL samples FOR 9999999 HEA "Samples";
COL hours FOR 9990.0 HEA "Hours|Hist";

PRO
PRO
PRO CPU from STATSPACK
PRO ~~~~~~~~~~~~~~~~

WITH 
  cpu_per_db_and_inst AS
  (SELECT /*+ INLINE */
    dbid,
       instance_number,
       MIN(begin_time)                                               begin_interval_time,
       MAX(end_time)                                                 end_interval_time,
       COUNT(DISTINCT snap_id)                                                snap_shots,   
    MAX(aas_on_cpu) aas_on_cpu_max,
    PERCENTILE_DISC(0.9999) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_9999,
    PERCENTILE_DISC(0.999) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_999,
    PERCENTILE_DISC(0.99) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_99,
    PERCENTILE_DISC(0.97) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_97,
    PERCENTILE_DISC(0.95) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_95,
    PERCENTILE_DISC(0.90) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_90,
    PERCENTILE_DISC(0.75) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_75,
    PERCENTILE_DISC(0.50) WITHIN GROUP (
  ORDER BY aas_on_cpu) aas_on_cpu_med,
    ROUND(AVG(aas_on_cpu), 1) aas_on_cpu_avg
  FROM (
  SELECT /*+ */
    begin_time,
    end_time,
    'ON CPU' session_state ,
    dbid,
    snap_id,
    instance_number,
    ROUND(((end_time    -begin_time)*86400)) elap_time,
    (value              -last_value)/100 cpu_used_secs,
    DECODE(ROUND((value -last_value)/100 / ((end_time-begin_time)*86400)), 0,1, ROUND((value -last_value)/100 / ((end_time-begin_time)*86400)))aas_on_cpu
  FROM (
  SELECT /*+  */ 
    s.dbid,
    s.instance_number,
    s.startup_time ,
    s.snap_time end_time ,
    LAG(s.snap_time) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS begin_time ,
    e.name stat_name ,
    s.snap_id ,
    LAG(s.snap_id) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_snap_id
    ,
    e.value ,
    LAG(e.value) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_value ,
    MIN(s.snap_time) OVER ( PARTITION BY s.dbid ) min_snap_time ,
    MAX(s.snap_time) OVER ( PARTITION BY s.dbid ) max_snap_time
  FROM perfstat.STATS$SNAPSHOT s
  INNER JOIN perfstat.STATS$SYSSTAT e --v$sysstat
  ON e.snap_id          = s.snap_id
  AND e.dbid            = s.dbid
  AND e.instance_number = s.instance_number
  AND e.name            ='CPU used by this session'
   )
  WHERE last_value IS NOT NULL
  )
  GROUP BY dbid,
  instance_number
  ),
cpu_per_inst_and_perc AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, aas_on_cpu_max  on_cpu, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 01 order_by, 'Maximum or peak - Rollup' metric, null, sum(aas_on_cpu_max)  on_cpu, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 02 order_by, '99.99th percntl' metric, instance_number, aas_on_cpu_9999 on_cpu, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 02 order_by, '99.99th percntl - Rollup' metric, null, sum(aas_on_cpu_9999)  aas_on_cpu_9999, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 03 order_by, '99.9th percentl' metric, instance_number, aas_on_cpu_999  on_cpu,  begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 03 order_by, '99.9th percentl - Rollup' metric, null, sum(aas_on_cpu_999)  aas_on_cpu_999, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 04 order_by, '99th percentile' metric, instance_number, aas_on_cpu_99   on_cpu,  begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 04 order_by, '99th percentl - Rollup' metric, null, sum(aas_on_cpu_99)  aas_on_cpu_99, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 05 order_by, '97th percentile' metric, instance_number, aas_on_cpu_97   on_cpu, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 05 order_by, '97th percentl - Rollup' metric, null, sum(aas_on_cpu_97)  aas_on_cpu_97, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 06 order_by, '95th percentile' metric, instance_number, aas_on_cpu_95   on_cpu, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 06 order_by, '95th percentl - Rollup' metric, null, sum(aas_on_cpu_95)  aas_on_cpu_95, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 07 order_by, '90th percentile' metric, instance_number, aas_on_cpu_90   on_cpu, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 07 order_by, '90th percentl - Rollup' metric, null, sum(aas_on_cpu_90)  aas_on_cpu_90, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 08 order_by, '75th percentile' metric, instance_number, aas_on_cpu_75   on_cpu, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 08 order_by, '75th percentl - Rollup' metric, null, sum(aas_on_cpu_75)  aas_on_cpu_75, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 09 order_by, 'Median'          metric, instance_number, aas_on_cpu_med  on_cpu, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 09 order_by, 'Median - Rollup' metric, null, sum(aas_on_cpu_med)  aas_on_cpu_med, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
UNION ALL
SELECT dbid, 10 order_by, 'Average'         metric, instance_number, aas_on_cpu_avg  on_cpu, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 10 order_by, 'Average - Rollup' metric, null, sum(aas_on_cpu_avg)  aas_on_cpu_avg, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots
FROM cpu_per_db_and_inst
group by dbid 
)
SELECT dbid,
       order_by,
       metric,
       instance_number,
       on_cpu,
       TO_CHAR((begin_interval_time), 'YYYY-MM-DD HH24:MI') begin_interval_time,
       TO_CHAR((end_interval_time), 'YYYY-MM-DD HH24:MI') end_interval_time,
       snap_shots,
       ROUND((end_interval_time) - (begin_interval_time), 1) days,
       ROUND(snap_shots / ((end_interval_time ) - (begin_interval_time)), 1) avg_snaps_per_day
  FROM cpu_per_inst_and_perc
/

/*****************************************************************************************/
PRO
COL mem_gb FOR 99990.0 HEA "Mem GB";
COL sga_gb FOR 99990.0 HEA "SGA GB";
COL pga_gb FOR 99990.0 HEA "PGA GB";
PRO
PRO Memory from STATSPACK
PRO ~~~~~~~~~~~~~~~
WITH mem_per_inst_and_snap AS (
SELECT /*+ INLINE */
       s.snap_id,
       s.dbid,
       s.instance_number,
       SUM(g.value) sga_bytes,
       MAX(p.value) pga_bytes,
       SUM(g.value) + MAX(p.value) mem_bytes,
       MIN(s.snap_time) begin_interval_time,
       MAX(s.snap_time) end_interval_time      
  FROM perfstat.stats$snapshot s,
       perfstat.stats$sga g,
       perfstat.STATS$PGASTAT p
 WHERE g.snap_id = s.snap_id
   AND g.dbid = s.dbid
   AND g.instance_number = s.instance_number
   AND p.snap_id = s.snap_id
   AND p.dbid = s.dbid
   AND p.instance_number = s.instance_number
   AND p.name = 'total PGA allocated'
 GROUP BY
       s.snap_id,
       s.dbid,
       s.instance_number
),
mem_per_db_and_inst AS (
SELECT dbid,
       instance_number,
       MIN(begin_interval_time)                                begin_interval_time,
       MAX(end_interval_time)                                  end_interval_time,
       COUNT(DISTINCT snap_id)                                 snap_shots,        
       MAX(mem_bytes)                                          mem_bytes_max,
       MAX(sga_bytes)                                          sga_bytes_max,
       MAX(pga_bytes)                                          pga_bytes_max,
   /*   Bug losing connection on 9i
   PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_99,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_97,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_95,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_90,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_75,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_med,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_med,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_med, 
      */ ROUND(AVG(mem_bytes), 1)                                mem_bytes_avg,
       ROUND(AVG(sga_bytes), 1)                                sga_bytes_avg,
       ROUND(AVG(pga_bytes), 1)                                pga_bytes_avg
  FROM mem_per_inst_and_snap
 GROUP BY
       dbid,
       instance_number
)
,
mem_per_inst_and_perc AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, mem_bytes_max mem_bytes, sga_bytes_max sga_bytes, pga_bytes_max pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
 SELECT dbid, 01 order_by, 'Maximum or peak - Rollup' metric, null, sum(mem_bytes_max) mem_bytes, sum(sga_bytes_max) sga_bytes, sum(pga_bytes_max) pga_bytes, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots FROM mem_per_db_and_inst
 GROUP BY dbid
 UNION ALL
/*SELECT dbid, 02 order_by, '99th percentile' metric, instance_number, mem_bytes_99  mem_bytes, sga_bytes_99  sga_bytes, pga_bytes_99  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 03 order_by, '97th percentile' metric, instance_number, mem_bytes_97  mem_bytes, sga_bytes_97  sga_bytes, pga_bytes_97  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 04 order_by, '95th percentile' metric, instance_number, mem_bytes_95  mem_bytes, sga_bytes_95  sga_bytes, pga_bytes_95  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 05 order_by, '90th percentile' metric, instance_number, mem_bytes_90  mem_bytes, sga_bytes_90  sga_bytes, pga_bytes_90  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 06 order_by, '75th percentile' metric, instance_number, mem_bytes_75  mem_bytes, sga_bytes_75  sga_bytes, pga_bytes_75  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 07 order_by, 'Median'          metric, instance_number, mem_bytes_med mem_bytes, sga_bytes_med sga_bytes, pga_bytes_med pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
*/
SELECT dbid, 08 order_by, 'Average'         metric, instance_number, mem_bytes_avg mem_bytes, sga_bytes_avg sga_bytes, pga_bytes_avg pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
 SELECT dbid, 08 order_by, 'Average - Rollup' metric, null, sum(mem_bytes_avg) mem_bytes, sum(sga_bytes_avg) sga_bytes, sum(pga_bytes_avg) pga_bytes, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time, sum(snap_shots) snap_shots FROM mem_per_db_and_inst
 GROUP BY dbid
)
SELECT dbid,
       order_by,
       metric,
       instance_number,
       ROUND(mem_bytes / POWER(2,30), 1) mem_gb,
       ROUND(sga_bytes / POWER(2,30), 1) sga_gb,
       ROUND(pga_bytes / POWER(2,30), 1) pga_gb,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM mem_per_inst_and_perc
/  
   
/*****************************************************************************************/
PRO
COL file_type FOR A10 HEA "File Type";
COL disk_tb FOR 999,990.0 HEA "Disk TB";
COL display FOR A10 HEA "Disk Space";
PRO
PRO Disk Space
PRO ~~~~~~~~~~
WITH 
sizes AS (
SELECT 'Data' file_type,
       SUM(bytes) bytes
  FROM v$datafile
 UNION ALL
SELECT 'Temp' file_type,
       SUM(bytes) bytes
  FROM v$tempfile
 UNION ALL
SELECT 'Log' file_type,
       SUM(bytes) * MAX(members) bytes
  FROM v$log
  -- Removed for Oracle 9i
-- UNION ALL
--SELECT 'Control' file_type,
--       SUM(block_size * file_size_blks) bytes
--  FROM v$controlfile
),
dbsize AS (
SELECT 'Total' file_type,
       SUM(bytes) bytes
  FROM sizes
)
SELECT s.file_type,
       ROUND(s.bytes/POWER(10,12),1) disk_tb,
       CASE 
       WHEN s.bytes > POWER(10,15) THEN ROUND(s.bytes/POWER(10,15),1)||' PB'
       WHEN s.bytes > POWER(10,12) THEN ROUND(s.bytes/POWER(10,12),1)||' TB'
       WHEN s.bytes > POWER(10,9) THEN ROUND(s.bytes/POWER(10,9),1)||' GB'
       WHEN s.bytes > POWER(10,6) THEN ROUND(s.bytes/POWER(10,6),1)||' MB'
       WHEN s.bytes > POWER(10,3) THEN ROUND(s.bytes/POWER(10,3),1)||' KB'
       WHEN s.bytes > 0 THEN s.bytes||' B' END display
  FROM sizes s
 UNION ALL
SELECT s.file_type,
       ROUND(s.bytes/POWER(10,12),1) disk_tb,
       CASE 
       WHEN s.bytes > POWER(10,15) THEN ROUND(s.bytes/POWER(10,15),1)||' PB'
       WHEN s.bytes > POWER(10,12) THEN ROUND(s.bytes/POWER(10,12),1)||' TB'
       WHEN s.bytes > POWER(10,9) THEN ROUND(s.bytes/POWER(10,9),1)||' GB'
       WHEN s.bytes > POWER(10,6) THEN ROUND(s.bytes/POWER(10,6),1)||' MB'
       WHEN s.bytes > POWER(10,3) THEN ROUND(s.bytes/POWER(10,3),1)||' KB'
       WHEN s.bytes > 0 THEN s.bytes||' B' END display
  FROM dbsize s
/

/*****************************************************************************************/
PRO
PRO
PRO IO Throughput
PRO ~~~~~~~~~~~~~
WITH
io_per_inst AS (
SELECT /*+ INLINE   */
       dbid,
       instance_number,
       MIN(begin_time) begin_interval_time,
       MAX(end_time) end_interval_time,
       COUNT(DISTINCT snap_id) snap_shots,   
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_median,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_median,
       ROUND(AVG((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_avg
  FROM (
  SELECT /*+  */
       dbid,
       instance_number,
       snap_id,
       min(snap_time) begin_time,
       max(end_time) end_time,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN ('physical writes', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value*blksize ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN ('physical writes') THEN value*blksize ELSE 0 END) 
       +
       SUM(CASE WHEN stat_name IN ('redo size') THEN value ELSE 0 END) w_bytes,
       AVG((snap_time - end_time)*86400) elapsed_sec
  FROM (
SELECT /*+   */
    s.dbid,
    s.instance_number,
    s.startup_time ,
    s.snap_time, 
    LAG(s.snap_time) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS end_time ,
    e.name stat_name ,
    s.snap_id ,
    LAG(s.snap_id) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS last_snap_id
    ,
    e.value -
    LAG(e.value) OVER ( PARTITION BY s.dbid, s.instance_number, s.startup_time, e.name ORDER BY s.snap_id) AS value ,
    MIN(s.snap_time) OVER ( PARTITION BY s.dbid ) min_snap_time ,
    MAX(s.snap_time) OVER ( PARTITION BY s.dbid ) max_snap_time
  FROM perfstat.STATS$SNAPSHOT s
  INNER JOIN perfstat.STATS$SYSSTAT e --v$sysstat
  ON e.snap_id          = s.snap_id
  AND e.dbid            = s.dbid
  AND e.instance_number = s.instance_number
  AND e.name            IN ('physical reads', 'physical writes', 'redo writes', 'redo size')
  ) sysstat_io_lag
  ,  (
        SELECT  distinct VALUE blksize
          FROM V$parameter
          WHERE name='db_block_size'
        )block_size
 WHERE LAST_SNAP_ID is not null
 GROUP BY
       dbid,
       instance_number,
       snap_id
  )
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       dbid, instance_number),
io_per_inst_or_cluster AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, rw_iops_peak rw_iops, r_iops_peak r_iops, w_iops_peak w_iops, rw_mbps_peak rw_mbps, r_mbps_peak r_mbps, w_mbps_peak w_mbps, begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 01 order_by, 'Maximum or peak - Rollup' metric, null, sum(rw_iops_peak) rw_iops, sum(r_iops_peak) r_iops, sum(w_iops_peak) w_iops, sum(rw_mbps_peak) rw_mbps, sum(r_mbps_peak) r_mbps, sum(w_mbps_peak) w_mbps, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
 UNION ALL
SELECT dbid, 02 order_by, '99.9th percentile' metric, instance_number, rw_iops_999 rw_iops,  0 r_iops,  0 w_iops,  rw_mbps_999 rw_mbps,  0 r_mbps,  0 w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 02 order_by, '99.9th percentile - Rollup' metric, null, sum(rw_iops_999) rw_iops, 0 ,  0 , sum(rw_mbps_999) rw_mbps, 0 ,  0 , min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
 UNION ALL
SELECT dbid, 03 order_by, '99th percentile' metric, instance_number, rw_iops_99 rw_iops,   0 r_iops,   0 w_iops,   rw_mbps_99 rw_mbps,   0 r_mbps,   0 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 03 order_by, '99th percentile - Rollup' metric, null, sum(rw_iops_99) rw_iops, 0 ,  0 , sum(rw_mbps_99) rw_mbps, 0 ,  0 , min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
 UNION ALL
SELECT dbid, 04 order_by, '97th percentile' metric, instance_number, rw_iops_97 rw_iops,   0 r_iops,   0 w_iops,   rw_mbps_97 rw_mbps,   0 r_mbps,   0 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 04 order_by, '97th percentile - Rollup' metric, null, sum(rw_iops_97) rw_iops, 0 ,  0 , sum(rw_mbps_97) rw_mbps, 0 ,  0 , min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
 UNION ALL
SELECT dbid, 05 order_by, '95th percentile' metric, instance_number, rw_iops_95 rw_iops,   0 r_iops,   0 w_iops,   rw_mbps_95 rw_mbps,   0 r_mbps,   0 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 05 order_by, '95th percentile - Rollup' metric, null, sum(rw_iops_95) rw_iops, 0 ,  0 , sum(rw_mbps_95) rw_mbps, 0 ,  0 , min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
 UNION ALL
SELECT dbid, 06 order_by, '90th percentile' metric, instance_number, rw_iops_90 rw_iops,   0 r_iops,   0 w_iops,   rw_mbps_90 rw_mbps,   0 r_mbps,   0 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 06 order_by, '90th percentile - Rollup' metric, null, sum(rw_iops_90) rw_iops, 0 ,  0 , sum(rw_mbps_90) rw_mbps, 0 ,  0 , min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
 UNION ALL
SELECT dbid, 07 order_by, '75th percentile' metric, instance_number, rw_iops_75 rw_iops,   0 r_iops,   0 w_iops,   rw_mbps_75 rw_mbps,   0 r_mbps,   0 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 07 order_by, '75th percentile - Rollup' metric, null, sum(rw_iops_75) rw_iops, 0 ,  0 , sum(rw_mbps_75) rw_mbps, 0 ,  0 , min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
 UNION ALL
SELECT dbid, 08 order_by, 'Median'          metric, instance_number, rw_iops_median rw_iops,  0 r_iops,  0 w_iops,  rw_mbps_median rw_mbps,  0 r_mbps,  0 w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 08 order_by, 'Median - Rollup' metric, null, sum(rw_iops_median) rw_iops, 0 ,  0 , sum(rw_mbps_median) rw_mbps, 0 ,  0 , min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
 UNION ALL
SELECT dbid, 09 order_by, 'Average'         metric, instance_number, rw_iops_avg rw_iops,  r_iops_avg r_iops,  w_iops_avg w_iops,  rw_mbps_avg rw_mbps,  r_mbps_avg r_mbps,  w_mbps_avg w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 09 order_by, 'Average - Rollup' metric, null, sum(rw_iops_avg) rw_iops, sum(r_iops_avg) r_iops, sum(w_iops_avg) w_iops, sum(rw_mbps_avg) rw_mbps, sum(r_mbps_avg) r_mbps, sum(w_mbps_avg) w_mbps, min(begin_interval_time) begin_interval_time, max(end_interval_time) end_interval_time , sum(snap_shots) snap_shots FROM io_per_inst
GROUP BY dbid 
) 
SELECT dbid,
       metric,
       instance_number,
       rw_iops,
       r_iops,
       w_iops,
       rw_mbps,
       r_mbps,
       w_mbps,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM io_per_inst_or_cluster
 ORDER BY
       dbid,
       order_by,
       instance_number NULLS LAST
/


/*****************************************************************************************/

SPO OFF;
SET TERM ON ECHO OFF FEED ON VER ON HEA ON PAGES 14 COLSEP ' ' LIN 80 TRIMS OFF TRIM ON TI OFF TIMI OFF ARRAY 15 NUM 10 SQLBL OFF BLO ON RECSEP WR;










