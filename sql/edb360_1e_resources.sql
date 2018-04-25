@@&&edb360_0g.tkprof.sql
DEF section_id = '1e';
DEF section_name = 'Resources (as per AWR and MEM)';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

COL order_by NOPRI;
COL metric FOR A16 HEA "Metric";
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
COL samples FOR 9999999999 HEA "Samples";
COL hours FOR 9990.0 HEA "Hours|Hist";

DEF title = 'CPU Demand Percentiles (MEM)';
DEF main_table = '&&gv_view_prefix.ACTIVE_SESSION_HISTORY';
DEF abstract = 'Number of Sessions on CPU or RESMGR. Includes Max (Peak), Percentiles, Median and Average.<br />'
BEGIN
  :sql_text := q'[
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       inst_id,
       sample_id,
       COUNT(*) aas_on_cpu_and_resmgr,
       SUM(CASE session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE event WHEN 'resmgr:cpu quantum' THEN 1 ELSE 0 END) aas_resmgr_cpu_quantum,
       MIN(sample_time) min_sample_time,
       MAX(sample_time) max_sample_time           
  FROM &&gv_object_prefix.active_session_history
 WHERE (session_state = 'ON CPU' OR event = 'resmgr:cpu quantum')
 GROUP BY
       inst_id,
       sample_id
),
cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       MIN(min_sample_time)                                                   min_sample_time,
       MAX(max_sample_time)                                                   max_sample_time,
       COUNT(DISTINCT sample_id)                                              samples,        
       MAX(aas_on_cpu_and_resmgr)                                             aas_on_cpu_and_resmgr_max,
       MAX(aas_on_cpu)                                                        aas_on_cpu_max,
       MAX(aas_resmgr_cpu_quantum)                                            aas_resmgr_cpu_quantum_max,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_9999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)   aas_on_cpu_and_resmgr_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_on_cpu)              aas_on_cpu_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)  aas_resmgr_cpu_quantum_999,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_99,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_97,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_95,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_90,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_75,
       MEDIAN(aas_on_cpu_and_resmgr)                                          aas_on_cpu_and_resmgr_med,
       MEDIAN(aas_on_cpu)                                                     aas_on_cpu_med,
       MEDIAN(aas_resmgr_cpu_quantum)                                         aas_resmgr_cpu_quantum_med,
       ROUND(AVG(aas_on_cpu_and_resmgr), 1)                                   aas_on_cpu_and_resmgr_avg,
       ROUND(AVG(aas_on_cpu), 1)                                              aas_on_cpu_avg,
       ROUND(AVG(aas_resmgr_cpu_quantum), 1)                                  aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       inst_id
),
cpu_per_inst_and_perc AS (
SELECT 01 order_by, 'Maximum or peak' metric, inst_id, aas_on_cpu_max  on_cpu, aas_on_cpu_and_resmgr_max  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_max  resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 02 order_by, '99.99th percntl' metric, inst_id, aas_on_cpu_9999 on_cpu, aas_on_cpu_and_resmgr_9999 on_cpu_and_resmgr, aas_resmgr_cpu_quantum_9999 resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 03 order_by, '99.9th percentl' metric, inst_id, aas_on_cpu_999  on_cpu, aas_on_cpu_and_resmgr_999  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_999  resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 04 order_by, '99th percentile' metric, inst_id, aas_on_cpu_99   on_cpu, aas_on_cpu_and_resmgr_99   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_99   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 05 order_by, '97th percentile' metric, inst_id, aas_on_cpu_97   on_cpu, aas_on_cpu_and_resmgr_97   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_97   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 06 order_by, '95th percentile' metric, inst_id, aas_on_cpu_95   on_cpu, aas_on_cpu_and_resmgr_95   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_95   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 07 order_by, '90th percentile' metric, inst_id, aas_on_cpu_90   on_cpu, aas_on_cpu_and_resmgr_90   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_90   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 08 order_by, '75th percentile' metric, inst_id, aas_on_cpu_75   on_cpu, aas_on_cpu_and_resmgr_75   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_75   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 09 order_by, 'Median'          metric, inst_id, aas_on_cpu_med  on_cpu, aas_on_cpu_and_resmgr_med  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_med  resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 10 order_by, 'Average'         metric, inst_id, aas_on_cpu_avg  on_cpu, aas_on_cpu_and_resmgr_avg  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_avg  resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
),
cpu_per_db_and_perc AS (
SELECT order_by,
       metric,
       TO_NUMBER(NULL) inst_id,
       SUM(on_cpu) on_cpu,
       SUM(on_cpu_and_resmgr) on_cpu_and_resmgr,
       SUM(resmgr_cpu_quantum) resmgr_cpu_quantum,
       MIN(min_sample_time) min_sample_time,
       MAX(max_sample_time) max_sample_time,
       SUM(samples) samples
  FROM cpu_per_inst_and_perc
 GROUP BY
       order_by,
       metric
)
SELECT order_by,
       metric,
       inst_id,
       on_cpu,
       on_cpu_and_resmgr,
       resmgr_cpu_quantum,
       TO_CHAR(CAST(min_sample_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') min_sample_time,
       TO_CHAR(CAST(max_sample_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') max_sample_time,
       samples,
       ROUND((CAST(max_sample_time AS DATE) - CAST(min_sample_time AS DATE)) * 24, 1) hours
  FROM cpu_per_inst_and_perc
 UNION ALL
SELECT order_by,
       metric,
       inst_id,
       on_cpu,
       on_cpu_and_resmgr,
       resmgr_cpu_quantum,
       TO_CHAR(CAST(min_sample_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') min_sample_time,
       TO_CHAR(CAST(max_sample_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') max_sample_time,
       samples,
       ROUND((CAST(max_sample_time AS DATE) - CAST(min_sample_time AS DATE)) * 24, 1) hours
  FROM cpu_per_db_and_perc
 ORDER BY
       order_by,
       inst_id NULLS LAST
]';
END;
/
@@&&skip_diagnostics.&&edb360_skip_ash_mem.edb360_9a_pre_one.sql

DEF title = 'CPU Demand Percentiles (AWR)';
DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF abstract = 'Number of Sessions on CPU or RESMGR. Includes Max (Peak), Percentiles, Median and Average.<br />'
BEGIN
  :sql_text := q'[
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.dbid,
       h.instance_number,
       h.sample_id,
       COUNT(*) aas_on_cpu_and_resmgr,
       SUM(CASE h.session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE h.event WHEN 'resmgr:cpu quantum' THEN 1 ELSE 0 END) aas_resmgr_cpu_quantum,
       MIN(s.begin_interval_time) begin_interval_time,
       MAX(s.end_interval_time) end_interval_time      
  FROM &&awr_object_prefix.active_sess_history h, 
       &&awr_object_prefix.snapshot s
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 GROUP BY
       h.snap_id,
       h.dbid,
       h.instance_number,
       h.sample_id
),
cpu_per_db_and_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       instance_number,
       MIN(begin_interval_time)                                               begin_interval_time,
       MAX(end_interval_time)                                                 end_interval_time,
       COUNT(DISTINCT snap_id)                                                snap_shots,        
       MAX(aas_on_cpu_and_resmgr)                                             aas_on_cpu_and_resmgr_max,
       MAX(aas_on_cpu)                                                        aas_on_cpu_max,
       MAX(aas_resmgr_cpu_quantum)                                            aas_resmgr_cpu_quantum_max,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_9999,
       PERCENTILE_DISC(0.9990) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_999,
       PERCENTILE_DISC(0.9990) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_999,
       PERCENTILE_DISC(0.9990) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_999,
       PERCENTILE_DISC(0.9900) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_99,
       PERCENTILE_DISC(0.9900) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_99,
       PERCENTILE_DISC(0.9900) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_99,
       PERCENTILE_DISC(0.9700) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_97,
       PERCENTILE_DISC(0.9700) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_97,
       PERCENTILE_DISC(0.9700) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_97,
       PERCENTILE_DISC(0.9500) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_95,
       PERCENTILE_DISC(0.9500) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_95,
       PERCENTILE_DISC(0.9500) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_95,
       PERCENTILE_DISC(0.9000) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_90,
       PERCENTILE_DISC(0.9000) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_90,
       PERCENTILE_DISC(0.9000) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_90,
       PERCENTILE_DISC(0.7500) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_75,
       PERCENTILE_DISC(0.7500) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_75,
       PERCENTILE_DISC(0.7500) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_75,
       MEDIAN(aas_on_cpu_and_resmgr)                                          aas_on_cpu_and_resmgr_med,
       MEDIAN(aas_on_cpu)                                                     aas_on_cpu_med,
       MEDIAN(aas_resmgr_cpu_quantum)                                         aas_resmgr_cpu_quantum_med,
       ROUND(AVG(aas_on_cpu_and_resmgr), 1)                                   aas_on_cpu_and_resmgr_avg,
       ROUND(AVG(aas_on_cpu), 1)                                              aas_on_cpu_avg,
       ROUND(AVG(aas_resmgr_cpu_quantum), 1)                                  aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       dbid,
       instance_number
),
cpu_per_inst_and_perc AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, aas_on_cpu_max  on_cpu, aas_on_cpu_and_resmgr_max  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_max  resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 02 order_by, '99.99th percntl' metric, instance_number, aas_on_cpu_9999 on_cpu, aas_on_cpu_and_resmgr_9999 on_cpu_and_resmgr, aas_resmgr_cpu_quantum_9999 resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 03 order_by, '99.9th percentl' metric, instance_number, aas_on_cpu_999  on_cpu, aas_on_cpu_and_resmgr_999  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_999  resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 04 order_by, '99th percentile' metric, instance_number, aas_on_cpu_99   on_cpu, aas_on_cpu_and_resmgr_99   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_99   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 05 order_by, '97th percentile' metric, instance_number, aas_on_cpu_97   on_cpu, aas_on_cpu_and_resmgr_97   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_97   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 06 order_by, '95th percentile' metric, instance_number, aas_on_cpu_95   on_cpu, aas_on_cpu_and_resmgr_95   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_95   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 07 order_by, '90th percentile' metric, instance_number, aas_on_cpu_90   on_cpu, aas_on_cpu_and_resmgr_90   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_90   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 08 order_by, '75th percentile' metric, instance_number, aas_on_cpu_75   on_cpu, aas_on_cpu_and_resmgr_75   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_75   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 09 order_by, 'Median'          metric, instance_number, aas_on_cpu_med  on_cpu, aas_on_cpu_and_resmgr_med  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_med  resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 10 order_by, 'Average'         metric, instance_number, aas_on_cpu_avg  on_cpu, aas_on_cpu_and_resmgr_avg  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_avg  resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
),
cpu_per_db_and_perc AS (
SELECT dbid,
       order_by,
       metric,
       TO_NUMBER(NULL) instance_number,
       SUM(on_cpu) on_cpu,
       SUM(on_cpu_and_resmgr) on_cpu_and_resmgr,
       SUM(resmgr_cpu_quantum) resmgr_cpu_quantum,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time,
       SUM(snap_shots) snap_shots
  FROM cpu_per_inst_and_perc
 GROUP BY
       dbid,
       order_by,
       metric
)
SELECT dbid,
       order_by,
       metric,
       instance_number,
       on_cpu,
       on_cpu_and_resmgr,
       resmgr_cpu_quantum,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM cpu_per_inst_and_perc
 UNION ALL
SELECT dbid,
       order_by,
       metric,
       instance_number,
       on_cpu,
       on_cpu_and_resmgr,
       resmgr_cpu_quantum,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM cpu_per_db_and_perc
 ORDER BY
       dbid,
       order_by,
       instance_number NULLS LAST
]';
END;
/

@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions on CPU or RESMGR';
DEF tit_01 = 'ON CPU + resmgr:cpu quantum';
DEF tit_02 = 'ON CPU';
DEF tit_03 = 'resmgr:cpu quantum';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text_backup := q'[
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       MIN(sample_time) sample_time,
       SUM(CASE session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) on_cpu,
       SUM(CASE event WHEN 'resmgr:cpu quantum' THEN 1 ELSE 0 END) resmgr,
       COUNT(*) on_cpu_and_resmgr
  FROM &&awr_object_prefix.active_sess_history h
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND (session_state = 'ON CPU' OR event = 'resmgr:cpu quantum')
 GROUP BY
       snap_id,
       instance_number,
       sample_id
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number, 
       MIN(sample_time) min_sample_time, 
       MAX(sample_time) max_sample_time, 
       MAX(on_cpu) on_cpu,
       MAX(resmgr) resmgr,
       MAX(on_cpu_and_resmgr) on_cpu_and_resmgr
  FROM cpu_per_inst_and_sample
 GROUP BY
       snap_id,
       instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(min_sample_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MAX(max_sample_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(on_cpu_and_resmgr) on_cpu_and_resmgr,
       SUM(on_cpu) on_cpu,
       SUM(resmgr) resmgr,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM cpu_per_inst_and_hour
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/
--DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 
DEF vbaseline = ''; 

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'CPU Demand Series (Peak) for Cluster';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

--DEF vbaseline = 'baseline:&&avg_cpu_count.,';
DEF vbaseline = '';

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'CPU Demand Series (Peak) for Instance 1';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'CPU Demand Series (Peak) for Instance 2';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'CPU Demand Series (Peak) for Instance 3';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'CPU Demand Series (Peak) for Instance 4';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'CPU Demand Series (Peak) for Instance 5';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'CPU Demand Series (Peak) for Instance 6';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'CPU Demand Series (Peak) for Instance 7';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'CPU Demand Series (Peak) for Instance 8';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.<br />'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions on CPU';
DEF tit_01 = 'Maximum (Peak)';
DEF tit_02 = '99th Percentile';
DEF tit_03 = '97th Percentile';
DEF tit_04 = '95th Percentile';
DEF tit_05 = '90th Percentile';
DEF tit_06 = '75th Percentile';
DEF tit_07 = 'Median';
DEF tit_08 = 'Average';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text_backup := q'[
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       MIN(sample_time) sample_time,
       COUNT(*) on_cpu
  FROM &&awr_object_prefix.active_sess_history h
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND session_state = 'ON CPU'
 GROUP BY
       snap_id,
       instance_number,
       sample_id
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number, 
       MIN(sample_time) min_sample_time, 
       MAX(sample_time) max_sample_time, 
       MAX(on_cpu)                                          on_cpu_max,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY on_cpu) on_cpu_99p,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY on_cpu) on_cpu_97p,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY on_cpu) on_cpu_95p,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY on_cpu) on_cpu_90p,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY on_cpu) on_cpu_75p,
       ROUND(MEDIAN(on_cpu), 1)                             on_cpu_med,
       ROUND(AVG(on_cpu), 1)                                on_cpu_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       snap_id,
       instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(min_sample_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MAX(max_sample_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(on_cpu_max) on_cpu_max,
       SUM(on_cpu_99p) on_cpu_99p,
       SUM(on_cpu_97p) on_cpu_97p,
       SUM(on_cpu_95p) on_cpu_95p,
       SUM(on_cpu_90p) on_cpu_90p,
       SUM(on_cpu_75p) on_cpu_75p,
       SUM(on_cpu_med) on_cpu_med,
       SUM(on_cpu_avg) on_cpu_avg,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM cpu_per_inst_and_hour
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/
--DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 
DEF vbaseline = ''; 

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'CPU Demand Series (Percentile) for Cluster';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

--DEF vbaseline = 'baseline:&&avg_cpu_count.,';
DEF vbaseline = '';

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'CPU Demand Series (Percentile) for Instance 1';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'CPU Demand Series (Percentile) for Instance 2';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'CPU Demand Series (Percentile) for Instance 3';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'CPU Demand Series (Percentile) for Instance 4';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'CPU Demand Series (Percentile) for Instance 5';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'CPU Demand Series (Percentile) for Instance 6';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'CPU Demand Series (Percentile) for Instance 7';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'CPU Demand Series (Percentile) for Instance 8';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).<br />'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

--DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 
DEF vbaseline = ''; 

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

COL mem_gb FOR 99990.0 HEA "Mem GB";
COL sga_gb FOR 99990.0 HEA "SGA GB";
COL pga_gb FOR 99990.0 HEA "PGA GB";

DEF title = 'Memory Size Percentiles (AWR)';
DEF main_table = '&&awr_hist_prefix.SGA';
DEF abstract = '&&abstract_uom.';
BEGIN
  :sql_text := q'[
WITH mem_per_inst_and_snap AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       s.snap_id,
       s.dbid,
       s.instance_number,
       SUM(g.value) sga_bytes,
       MAX(p.value) pga_bytes,
       SUM(g.value) + MAX(p.value) mem_bytes,
       MIN(s.begin_interval_time) begin_interval_time,
       MAX(s.end_interval_time) end_interval_time      
  FROM &&awr_object_prefix.snapshot s,
       &&awr_object_prefix.sga g,
       &&awr_object_prefix.pgastat p
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND g.snap_id = s.snap_id
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
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       instance_number,
       MIN(begin_interval_time)                                begin_interval_time,
       MAX(end_interval_time)                                  end_interval_time,
       COUNT(DISTINCT snap_id)                                 snap_shots,        
       MAX(mem_bytes)                                          mem_bytes_max,
       MAX(sga_bytes)                                          sga_bytes_max,
       MAX(pga_bytes)                                          pga_bytes_max,
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
       MEDIAN(mem_bytes)                                       mem_bytes_med,
       MEDIAN(sga_bytes)                                       sga_bytes_med,
       MEDIAN(pga_bytes)                                       pga_bytes_med,
       ROUND(AVG(mem_bytes), 1)                                mem_bytes_avg,
       ROUND(AVG(sga_bytes), 1)                                sga_bytes_avg,
       ROUND(AVG(pga_bytes), 1)                                pga_bytes_avg
  FROM mem_per_inst_and_snap
 GROUP BY
       dbid,
       instance_number
),
mem_per_inst_and_perc AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, mem_bytes_max mem_bytes, sga_bytes_max sga_bytes, pga_bytes_max pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 02 order_by, '99th percentile' metric, instance_number, mem_bytes_99  mem_bytes, sga_bytes_99  sga_bytes, pga_bytes_99  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
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
 UNION ALL
SELECT dbid, 08 order_by, 'Average'         metric, instance_number, mem_bytes_avg mem_bytes, sga_bytes_avg sga_bytes, pga_bytes_avg pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
),
mem_per_db_and_perc AS (
SELECT dbid,
       order_by,
       metric,
       TO_NUMBER(NULL) instance_number,
       SUM(mem_bytes) mem_bytes,
       SUM(sga_bytes) sga_bytes,
       SUM(pga_bytes) pga_bytes,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time,
       SUM(snap_shots) snap_shots
  FROM mem_per_inst_and_perc
 GROUP BY
       dbid,
       order_by,
       metric
)
SELECT dbid,
       order_by,
       metric,
       instance_number,
       ROUND(mem_bytes / POWER(2,30), 1) mem_gb,
       ROUND(sga_bytes / POWER(2,30), 1) sga_gb,
       ROUND(pga_bytes / POWER(2,30), 1) pga_gb,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM mem_per_inst_and_perc
 UNION ALL
SELECT dbid,
       order_by,
       metric,
       instance_number,
       ROUND(mem_bytes / POWER(2,30), 1) mem_gb,
       ROUND(sga_bytes / POWER(2,30), 1) sga_gb,
       ROUND(pga_bytes / POWER(2,30), 1) pga_gb,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM mem_per_db_and_perc
 ORDER BY
       dbid,
       order_by,
       instance_number NULLS LAST
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Memory Size (MEM)';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
DEF abstract = 'Consolidated view of Memory requirements.'
DEF abstract2 = 'It considers AMM if setup, else ASMM if setup, else no memory management settings (individual pools size).<br />'
DEF foot = 'Consider "Giga Bytes (GB)" column for sizing. Instance Number -1 means aggregated values (SUM) while -2 means over all instances (combined).<br />'
BEGIN
  :sql_text := q'[
WITH
par AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       d.dbid,
       d.name db_name,
       i.inst_id,
       /* LOWER(SUBSTR(i.host_name||'.', 1, INSTR(i.host_name||'.', '.') - 1)) */
       LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_name,
       i.instance_number,
       i.instance_name,
       SUM(CASE p.name WHEN 'memory_target' THEN TO_NUMBER(value) END) memory_target,
       SUM(CASE p.name WHEN 'memory_max_target' THEN TO_NUMBER(value) END) memory_max_target,
       SUM(CASE p.name WHEN 'sga_target' THEN TO_NUMBER(value) END) sga_target,
       SUM(CASE p.name WHEN 'sga_max_size' THEN TO_NUMBER(value) END) sga_max_size,
       SUM(CASE p.name WHEN 'pga_aggregate_target' THEN TO_NUMBER(value) END) pga_aggregate_target
  FROM &&gv_object_prefix.instance i,
       &&gv_object_prefix.database d,
       &&gv_object_prefix.system_parameter2 p
 WHERE d.inst_id = i.inst_id
   AND p.inst_id = i.inst_id
   AND p.name IN ('memory_target', 'memory_max_target', 'sga_target', 'sga_max_size', 'pga_aggregate_target')
 GROUP BY
       d.dbid,
       d.name,
       i.inst_id,
       i.host_name,
       i.instance_number,
       i.instance_name
),
sga_max AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       bytes
  FROM &&gv_object_prefix.sgainfo
 WHERE name = 'Maximum SGA Size'
),
pga_max AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       value bytes
  FROM &&gv_object_prefix.pgastat
 WHERE name = 'maximum PGA allocated'
),
pga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.pga_aggregate_target,
       pga_max.bytes max_bytes,
       GREATEST(NVL(par.pga_aggregate_target, 0), NVL(pga_max.bytes, 0)) bytes
  FROM par,
       pga_max
 WHERE par.inst_id = pga_max.inst_id
),
amm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.memory_target,
       par.memory_max_target,
       GREATEST(NVL(par.memory_target, 0), NVL(par.memory_max_target, 0)) + (6 * POWER(2,20)) bytes
  FROM par
),
asmm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.sga_target,
       par.sga_max_size,
       pga.bytes pga_bytes,
       GREATEST(NVL(sga_target, 0), NVL(sga_max_size, 0)) + NVL(pga.bytes, 0) + (6 * POWER(2,20)) bytes
  FROM par,
       pga
 WHERE par.inst_id = pga.inst_id
),
no_mm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       pga.dbid,
       pga.db_name,
       pga.inst_id,
       pga.host_name,
       pga.instance_number,
       pga.instance_name,
       sga_max.bytes max_sga,
       pga.bytes max_pga,
       pga.pga_aggregate_target,
       sga_max.bytes + pga.bytes + (5 * POWER(2,20)) bytes
  FROM sga_max,
       pga
 WHERE sga_max.inst_id = pga.inst_id
),
them_all AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       amm.dbid,
       amm.db_name,
       amm.inst_id,
       amm.host_name,
       amm.instance_number,
       amm.instance_name,
       GREATEST(NVL(amm.bytes, 0), NVL(asmm.bytes, 0), NVL(no_mm.bytes, 0)) bytes,
       amm.memory_target,
       amm.memory_max_target,
       asmm.sga_target,
       asmm.sga_max_size,
       no_mm.max_sga,
       no_mm.pga_aggregate_target,
       no_mm.max_pga
  FROM amm,
       asmm,
       no_mm
 WHERE asmm.inst_id = amm.inst_id
   AND no_mm.inst_id = amm.inst_id
 ORDER BY
       amm.inst_id
)
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       bytes total_required,
       ROUND(bytes/POWER(2,30),3) total_required_gb,
       memory_target,
       ROUND(memory_target/POWER(2,30),3) memory_target_gb,
       memory_max_target,
       ROUND(memory_max_target/POWER(2,30),3) memory_max_target_gb,
       sga_target,
       ROUND(sga_target/POWER(2,30),3) sga_target_gb,
       sga_max_size,
       ROUND(sga_max_size/POWER(2,30),3) sga_max_size_gb,
       max_sga max_sga_alloc,
       ROUND(max_sga/POWER(2,30),3) max_sga_alloc_gb,
       pga_aggregate_target,
       ROUND(pga_aggregate_target/POWER(2,30),3) pga_aggregate_target_gb,
       max_pga max_pga_alloc,
       ROUND(max_pga/POWER(2,30),3) max_pga_alloc_gb
  FROM them_all
 UNION ALL
SELECT TO_NUMBER(NULL) dbid,
       NULL db_name,
       NULL host_name,
       -1 instance_number,
       NULL instance_name,
       SUM(bytes) total_required,
       ROUND(SUM(bytes)/POWER(2,30),3) total_required_gb,
       SUM(memory_target) memory_target,
       ROUND(SUM(memory_target)/POWER(2,30),3) memory_target_gb,
       SUM(memory_max_target) memory_max_target,
       ROUND(SUM(memory_max_target)/POWER(2,30),3) memory_max_target_gb,
       SUM(sga_target) sga_target,
       ROUND(SUM(sga_target)/POWER(2,30),3) sga_target_gb,
       SUM(sga_max_size) sga_max_size,
       ROUND(SUM(sga_max_size)/POWER(2,30),3) sga_max_size_gb,
       SUM(max_sga) max_sga_alloc,
       ROUND(SUM(max_sga)/POWER(2,30),3) max_sga_alloc_gb,
       SUM(pga_aggregate_target) pga_aggregate_target,
       ROUND(SUM(pga_aggregate_target)/POWER(2,30),3) pga_aggregate_target_gb,
       SUM(max_pga) max_pga_alloc,
       ROUND(SUM(max_pga)/POWER(2,30),3) max_pga_alloc_gb
  FROM them_all
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Size (AWR)';
DEF main_table = '&&awr_hist_prefix.PARAMETER';
DEF abstract = 'Consolidated view of Memory requirements.<br />'
DEF abstract2 = 'It considers AMM if setup, else ASMM if setup, else no memory management settings (individual pools size).<br />'
DEF foot = 'Consider "Giga Bytes (GB)" column for sizing. Instance Number -1 means aggregated values (SUM) while -2 means over all instances (combined).'
BEGIN
  :sql_text := q'[
WITH
max_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       MAX(snap_id) snap_id,
       dbid,
       instance_number,
       parameter_name
  FROM &&awr_object_prefix.parameter
 WHERE parameter_name IN ('memory_target', 'memory_max_target', 'sga_target', 'sga_max_size', 'pga_aggregate_target')
   AND (snap_id, dbid, instance_number) IN (SELECT s.snap_id, s.dbid, s.instance_number FROM &&awr_object_prefix.snapshot s)
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       dbid,
       instance_number,
       parameter_name
),
last_value AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       s.snap_id,
       s.dbid,
       s.instance_number,
       s.parameter_name,
       p.value
  FROM max_snap s,
       &&awr_object_prefix.parameter p
 WHERE p.snap_id = s.snap_id
   AND p.dbid = s.dbid
   AND p.instance_number = s.instance_number
   AND p.parameter_name = s.parameter_name
   AND p.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND p.dbid = &&edb360_dbid.
),
last_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       p.snap_id,
       p.dbid,
       p.instance_number,
       p.parameter_name,
       p.value,
       s.startup_time
  FROM last_value p,
       &&awr_object_prefix.snapshot s
 WHERE s.snap_id = p.snap_id
   AND s.dbid = p.dbid
   AND s.instance_number = p.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
),
par AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       p.dbid,
       di.db_name,
       /* LOWER(SUBSTR(di.host_name||'.', 1, INSTR(di.host_name||'.', '.') - 1)) */
       LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_name,
       p.instance_number,
       di.instance_name,
       SUM(CASE p.parameter_name WHEN 'memory_target' THEN TO_NUMBER(p.value) ELSE 0 END) memory_target,
       SUM(CASE p.parameter_name WHEN 'memory_max_target' THEN TO_NUMBER(p.value) ELSE 0 END) memory_max_target,
       SUM(CASE p.parameter_name WHEN 'sga_target' THEN TO_NUMBER(p.value) ELSE 0 END) sga_target,
       SUM(CASE p.parameter_name WHEN 'sga_max_size' THEN TO_NUMBER(p.value) ELSE 0 END) sga_max_size,
       SUM(CASE p.parameter_name WHEN 'pga_aggregate_target' THEN TO_NUMBER(p.value) ELSE 0 END) pga_aggregate_target
  FROM last_snap p,
       &&awr_object_prefix.database_instance di
 WHERE di.dbid = p.dbid
   AND di.instance_number = p.instance_number
   AND di.startup_time = p.startup_time
   AND di.dbid = &&edb360_dbid.
 GROUP BY
       p.dbid,
       di.db_name,
       di.host_name,
       p.instance_number,
       di.instance_name
),
sgainfo AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(value) sga_size
  FROM &&awr_object_prefix.sga
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
sga_max AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       instance_number,
       MAX(sga_size) bytes
  FROM sgainfo
 GROUP BY
       dbid,
       instance_number
),
pga_max AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       instance_number,
       MAX(value) bytes
  FROM &&awr_object_prefix.pgastat
 WHERE name = 'maximum PGA allocated'
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       dbid,
       instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.pga_aggregate_target,
       pga_max.bytes max_bytes,
       GREATEST(NVL(par.pga_aggregate_target, 0), NVL(pga_max.bytes, 0)) bytes
  FROM pga_max,
       par
 WHERE par.dbid = pga_max.dbid
   AND par.instance_number = pga_max.instance_number
),
amm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.memory_target,
       par.memory_max_target,
       GREATEST(NVL(par.memory_target, 0), NVL(par.memory_max_target, 0)) + (6 * POWER(2,20)) bytes
  FROM par
),
asmm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.sga_target,
       par.sga_max_size,
       pga.bytes pga_bytes,
       GREATEST(NVL(sga_target, 0), NVL(sga_max_size, 0)) + NVL(pga.bytes, 0) + (6 * POWER(2,20)) bytes
  FROM pga,
       par
 WHERE par.dbid = pga.dbid
   AND par.instance_number = pga.instance_number
),
no_mm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       pga.dbid,
       pga.db_name,
       /* LOWER(SUBSTR(pga.host_name||'.', 1, INSTR(pga.host_name||'.', '.') - 1)) */
       LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_name,
       pga.instance_number,
       pga.instance_name,
       sga_max.bytes max_sga,
       pga.bytes max_pga,
       pga.pga_aggregate_target,
       sga_max.bytes + pga.bytes + (5 * POWER(2,20)) bytes
  FROM pga,
       sga_max
 WHERE sga_max.dbid = pga.dbid
   AND sga_max.instance_number = pga.instance_number
),
them_all AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       amm.dbid,
       amm.db_name,
       amm.host_name,
       amm.instance_number,
       amm.instance_name,
       GREATEST(NVL(amm.bytes, 0), NVL(asmm.bytes, 0), NVL(no_mm.bytes, 0)) bytes,
       amm.memory_target,
       amm.memory_max_target,
       asmm.sga_target,
       asmm.sga_max_size,
       no_mm.max_sga,
       no_mm.pga_aggregate_target,
       no_mm.max_pga
  FROM amm,
       asmm,
       no_mm
 WHERE asmm.instance_number = amm.instance_number
   AND asmm.dbid = amm.dbid
   AND no_mm.instance_number = amm.instance_number
   AND no_mm.dbid = amm.dbid
 ORDER BY
       amm.dbid,
       amm.instance_number
)
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       bytes total_required,
       ROUND(bytes/POWER(2,30),3) total_required_gb,
       memory_target,
       ROUND(memory_target/POWER(2,30),3) memory_target_gb,
       memory_max_target,
       ROUND(memory_max_target/POWER(2,30),3) memory_max_target_gb,
       sga_target,
       ROUND(sga_target/POWER(2,30),3) sga_target_gb,
       sga_max_size,
       ROUND(sga_max_size/POWER(2,30),3) sga_max_size_gb,
       max_sga max_sga_alloc,
       ROUND(max_sga/POWER(2,30),3) max_sga_alloc_gb,
       pga_aggregate_target,
       ROUND(pga_aggregate_target/POWER(2,30),3) pga_aggregate_target_gb,
       max_pga max_pga_alloc,
       ROUND(max_pga/POWER(2,30),3) max_pga_alloc_gb
  FROM them_all
 UNION ALL
SELECT TO_NUMBER(NULL) dbid,
       NULL db_name,
       NULL host_name,
       -1 instance_number,
       NULL instance_name,
       SUM(bytes) total_required,
       ROUND(SUM(bytes)/POWER(2,30),3) total_required_gb,
       SUM(memory_target) memory_target,
       ROUND(SUM(memory_target)/POWER(2,30),3) memory_target_gb,
       SUM(memory_max_target) memory_max_target,
       ROUND(SUM(memory_max_target)/POWER(2,30),3) memory_max_target_gb,
       SUM(sga_target) sga_target,
       ROUND(SUM(sga_target)/POWER(2,30),3) sga_target_gb,
       SUM(sga_max_size) sga_max_size,
       ROUND(SUM(sga_max_size)/POWER(2,30),3) sga_max_size_gb,
       SUM(max_sga) max_sga_alloc,
       ROUND(SUM(max_sga)/POWER(2,30),3) max_sga_alloc_gb,
       SUM(pga_aggregate_target) pga_aggregate_target,
       ROUND(SUM(pga_aggregate_target)/POWER(2,30),3) pga_aggregate_target_gb,
       SUM(max_pga) max_pga_alloc,
       ROUND(SUM(max_pga)/POWER(2,30),3) max_pga_alloc_gb
  FROM them_all
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF main_table = '&&awr_hist_prefix.SGA';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
DEF vaxis = 'Memory in Giga Bytes (GB)';
DEF tit_01 = 'Total (SGA + PGA)';
DEF tit_02 = 'SGA';
DEF tit_03 = 'PGA';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF abstract = '&&abstract_uom.';

BEGIN
  :sql_text_backup := q'[
WITH
sga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       SUM(value) bytes
  FROM &&awr_object_prefix.sga
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       dbid,
       instance_number,
       value bytes
  FROM &&awr_object_prefix.pgastat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND name = 'total PGA allocated'
),
mem AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snp.snap_id,
       snp.dbid,
       snp.instance_number,
       snp.begin_interval_time,
       snp.end_interval_time,
       sga.bytes sga_bytes,
       pga.bytes pga_bytes,
       (sga.bytes + pga.bytes) mem_bytes
  FROM sga, pga, &&awr_object_prefix.snapshot snp
 WHERE pga.snap_id = sga.snap_id
   AND pga.dbid = sga.dbid
   AND pga.instance_number = sga.instance_number
   AND snp.snap_id = sga.snap_id
   AND snp.dbid = sga.dbid
   AND snp.instance_number = sga.instance_number
   AND snp.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND snp.dbid = &&edb360_dbid.
),
hourly_inst AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       begin_interval_time,
       end_interval_time,
       MAX(sga_bytes) sga_bytes,
       MAX(pga_bytes) pga_bytes,
       MAX(mem_bytes) mem_bytes
  FROM mem
 GROUP BY
       snap_id,
       instance_number,
       begin_interval_time,
       end_interval_time
),
hourly AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(sga_bytes) / POWER(2,30), 3) sga_gb,
       ROUND(SUM(pga_bytes) / POWER(2,30), 3) pga_gb,
       ROUND(SUM(mem_bytes) / POWER(2,30), 3) mem_gb,
       SUM(sga_bytes) sga_bytes,
       SUM(pga_bytes) pga_bytes,
       SUM(mem_bytes) mem_bytes
  FROM hourly_inst
 GROUP BY
       snap_id
)
SELECT snap_id,
       begin_time,
       end_time,
       mem_gb,
       sga_gb,
       pga_gb,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM hourly
 ORDER BY
       snap_id
]';
END;
/
DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Memory Size Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'Memory Size Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'Memory Size Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'Memory Size Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'Memory Size Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'Memory Size Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'Memory Size Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'Memory Size Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'Memory Size Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF title = 'Database Size on Disk';
DEF main_table = '&&gv_view_prefix.DATABASE';
DEF abstract = 'Displays Space on Disk including datafiles, tempfiles, log and control files.'
DEF abstract2 = '&&abstract_uom.';
DEF foot = 'Consider "Tera Bytes (TB)" column for sizing.'
COL gb FOR 999990.000;
BEGIN
  :sql_text := q'[
WITH 
sizes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       'Data' file_type,
       SUM(bytes) bytes
  FROM &&v_object_prefix.datafile
 UNION ALL
SELECT 'Temp' file_type,
       SUM(bytes) bytes
  FROM &&v_object_prefix.tempfile
 UNION ALL
SELECT 'Log' file_type,
       SUM(bytes) * MAX(members) bytes
  FROM &&v_object_prefix.log
 UNION ALL
SELECT 'Control' file_type,
       SUM(block_size * file_size_blks) bytes
  FROM &&v_object_prefix.controlfile
),
dbsize AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       'Total' file_type,
       SUM(bytes) bytes
  FROM sizes
)
SELECT d.dbid,
       d.name db_name,
       s.file_type,
       s.bytes,
       ROUND(s.bytes/POWER(10,9),3) gb,
       CASE 
       WHEN s.bytes > POWER(10,15) THEN ROUND(s.bytes/POWER(10,15),3)||' P'
       WHEN s.bytes > POWER(10,12) THEN ROUND(s.bytes/POWER(10,12),3)||' T'
       WHEN s.bytes > POWER(10,9) THEN ROUND(s.bytes/POWER(10,9),3)||' G'
       WHEN s.bytes > POWER(10,6) THEN ROUND(s.bytes/POWER(10,6),3)||' M'
       WHEN s.bytes > POWER(10,3) THEN ROUND(s.bytes/POWER(10,3),3)||' K'
       WHEN s.bytes > 0 THEN s.bytes||' B' END display
  FROM &&v_object_prefix.database d,
       sizes s
 UNION ALL
SELECT d.dbid,
       d.name db_name,
       s.file_type,
       s.bytes,
       ROUND(s.bytes/POWER(10,9),3) gb,
       CASE 
       WHEN s.bytes > POWER(10,15) THEN ROUND(s.bytes/POWER(10,15),3)||' P'
       WHEN s.bytes > POWER(10,12) THEN ROUND(s.bytes/POWER(10,12),3)||' T'
       WHEN s.bytes > POWER(10,9) THEN ROUND(s.bytes/POWER(10,9),3)||' G'
       WHEN s.bytes > POWER(10,6) THEN ROUND(s.bytes/POWER(10,6),3)||' M'
       WHEN s.bytes > POWER(10,3) THEN ROUND(s.bytes/POWER(10,3),3)||' K'
       WHEN s.bytes > 0 THEN s.bytes||' B' END display
  FROM &&v_object_prefix.database d,
       dbsize s
]';
END;
/
@@edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF main_table = '&&awr_hist_prefix.TBSPC_SPACE_USAGE';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
DEF vaxis = 'Tablespace Size in Giga Bytes (GB)';
DEF tit_01 = 'Total (Perm + Undo + Temp)';
DEF tit_02 = 'Permanent';
DEF tit_03 = 'Undo';
DEF tit_04 = 'Temporary';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF abstract = '&&abstract_uom.';

BEGIN
  :sql_text := q'[
WITH
ts_per_snap_id AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       us.snap_id,
       MIN(sn.begin_interval_time) begin_interval_time,
       MIN(sn.end_interval_time) end_interval_time,
       SUM(us.tablespace_size * ts.block_size) all_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'PERMANENT' THEN us.tablespace_size * ts.block_size ELSE 0 END) perm_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'UNDO'      THEN us.tablespace_size * ts.block_size ELSE 0 END) undo_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'TEMPORARY' THEN us.tablespace_size * ts.block_size ELSE 0 END) temp_tablespaces_bytes
  FROM &&awr_object_prefix.tbspc_space_usage us,
       &&awr_object_prefix.snapshot sn,
       &&v_object_prefix.tablespace vt,
       &&dva_object_prefix.tablespaces ts
 WHERE us.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND us.dbid = &&edb360_dbid.
   AND sn.snap_id = us.snap_id
   AND sn.dbid = us.dbid
   AND sn.instance_number = &&connect_instance_number.
   AND vt.ts# = us.tablespace_id
   AND ts.tablespace_name = vt.name
 GROUP BY
       us.snap_id
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(MAX(all_tablespaces_bytes) / POWER(10,9), 3),
       ROUND(MAX(perm_tablespaces_bytes) / POWER(10,9), 3),
       ROUND(MAX(undo_tablespaces_bytes) / POWER(10,9), 3),
       ROUND(MAX(temp_tablespaces_bytes) / POWER(10,9), 3),
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM ts_per_snap_id
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Tablespace Size Series';
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF title = 'IOPS and MBPS Percentiles';
DEF main_table = '&&awr_hist_prefix.SYSSTAT';
DEF abstract = 'I/O Operations per Second (IOPS) and I/O Mega Bytes per Second (MBPS). Includes Peak (max), percentiles and average for read (R), write (W) and read+write (RW) operations.'
DEF abstract2 = '&&abstract_uom.'
DEF foot = 'Consider Peak or high Percentile for sizing. Instance Number -1 means aggregated values (SUM) while -2 means over all instances (combined).'
BEGIN
  :sql_text := q'[
WITH
sysstat_io AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h.snap_id,
       h.dbid,
       h.instance_number,
       SUM(CASE WHEN h.stat_name = 'physical read total IO requests' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN h.stat_name IN ('physical write total IO requests', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN h.stat_name = 'physical read total bytes' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN h.stat_name IN ('physical write total bytes', 'redo size') THEN value ELSE 0 END) w_bytes
  FROM &&awr_object_prefix.sysstat h
 WHERE h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN ('physical read total IO requests', 'physical write total IO requests', 'redo writes', 'physical read total bytes', 'physical write total bytes', 'redo size')
 GROUP BY
       h.snap_id,
       h.dbid,
       h.instance_number
),
io_per_inst_and_snap_id AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.dbid,
       h1.instance_number,
       h1.snap_id,
       (h1.r_reqs - h0.r_reqs) r_reqs,
       (h1.w_reqs - h0.w_reqs) w_reqs,
       (h1.r_bytes - h0.r_bytes) r_bytes,
       (h1.w_bytes - h0.w_bytes) w_bytes,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec,
       CAST(s1.begin_interval_time AS DATE) begin_interval_time,
       CAST(s1.end_interval_time AS DATE) end_interval_time        
  FROM sysstat_io h0,
       &&awr_object_prefix.snapshot s0,
       sysstat_io h1,
       &&awr_object_prefix.snapshot s1
 WHERE s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.dbid = s0.dbid
   AND s1.instance_number = s0.instance_number
   AND s1.startup_time = s0.startup_time
),
io_per_snap_id AS (
SELECT dbid,
       snap_id,
       SUM(r_reqs) r_reqs,
       SUM(w_reqs) w_reqs,
       SUM(r_bytes) r_bytes,
       SUM(w_bytes) w_bytes,
       AVG(elapsed_sec) elapsed_sec,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time
  FROM io_per_inst_and_snap_id
 GROUP BY
       dbid,
       snap_id
),
io_per_inst AS (
SELECT dbid,
       instance_number,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time,
       COUNT(DISTINCT snap_id) snap_shots,        
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_75,
       ROUND(MEDIAN((r_reqs + w_reqs) / elapsed_sec)) rw_iops_med,
       ROUND(MEDIAN(r_reqs / elapsed_sec)) r_iops_med,
       ROUND(MEDIAN(w_reqs / elapsed_sec)) w_iops_med,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_75,
       ROUND(MEDIAN((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_med,
       ROUND(MEDIAN(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_med,
       ROUND(MEDIAN(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_med,
       ROUND(AVG((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_avg
  FROM io_per_inst_and_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       dbid,
       instance_number
),
io_per_cluster AS ( -- combined
SELECT dbid,
       TO_NUMBER(NULL) instance_number,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time,
       COUNT(DISTINCT snap_id) snap_shots,        
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_75,
       ROUND(MEDIAN((r_reqs + w_reqs) / elapsed_sec)) rw_iops_med,
       ROUND(MEDIAN(r_reqs / elapsed_sec)) r_iops_med,
       ROUND(MEDIAN(w_reqs / elapsed_sec)) w_iops_med,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_75,
       ROUND(MEDIAN((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_med,
       ROUND(MEDIAN(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_med,
       ROUND(MEDIAN(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_med,
       ROUND(AVG((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(10,6) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(10,6) / elapsed_sec)) w_mbps_avg
  FROM io_per_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       dbid
),
io_per_inst_or_cluster AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, rw_iops_peak rw_iops, r_iops_peak r_iops, w_iops_peak w_iops, rw_mbps_peak rw_mbps, r_mbps_peak r_mbps, w_mbps_peak w_mbps, begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 02 order_by, '99.9th percentl' metric, instance_number, rw_iops_999 rw_iops,  r_iops_999 r_iops,  w_iops_999 w_iops,  rw_mbps_999 rw_mbps,  r_mbps_999 r_mbps,  w_mbps_999 w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 03 order_by, '99th percentile' metric, instance_number, rw_iops_99 rw_iops,   r_iops_99 r_iops,   w_iops_99 w_iops,   rw_mbps_99 rw_mbps,   r_mbps_99 r_mbps,   w_mbps_99 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 04 order_by, '97th percentile' metric, instance_number, rw_iops_97 rw_iops,   r_iops_97 r_iops,   w_iops_97 w_iops,   rw_mbps_97 rw_mbps,   r_mbps_97 r_mbps,   w_mbps_97 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 05 order_by, '95th percentile' metric, instance_number, rw_iops_95 rw_iops,   r_iops_95 r_iops,   w_iops_95 w_iops,   rw_mbps_95 rw_mbps,   r_mbps_95 r_mbps,   w_mbps_95 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 06 order_by, '90th percentile' metric, instance_number, rw_iops_90 rw_iops,   r_iops_90 r_iops,   w_iops_90 w_iops,   rw_mbps_90 rw_mbps,   r_mbps_90 r_mbps,   w_mbps_90 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 07 order_by, '75th percentile' metric, instance_number, rw_iops_75 rw_iops,   r_iops_75 r_iops,   w_iops_75 w_iops,   rw_mbps_75 rw_mbps,   r_mbps_75 r_mbps,   w_mbps_75 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 08 order_by, 'Median'          metric, instance_number, rw_iops_med rw_iops,  r_iops_med r_iops,  w_iops_med w_iops,  rw_mbps_med rw_mbps,  r_mbps_med r_mbps,  w_mbps_med w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 09 order_by, 'Average'         metric, instance_number, rw_iops_avg rw_iops,  r_iops_avg r_iops,  w_iops_avg w_iops,  rw_mbps_avg rw_mbps,  r_mbps_avg r_mbps,  w_mbps_avg w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, rw_iops_peak rw_iops, r_iops_peak r_iops, w_iops_peak w_iops, rw_mbps_peak rw_mbps, r_mbps_peak r_mbps, w_mbps_peak w_mbps, begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 02 order_by, '99.9th percentl' metric, instance_number, rw_iops_999 rw_iops,  r_iops_999 r_iops,  w_iops_999 w_iops,  rw_mbps_999 rw_mbps,  r_mbps_999 r_mbps,  w_mbps_999 w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 03 order_by, '99th percentile' metric, instance_number, rw_iops_99 rw_iops,   r_iops_99 r_iops,   w_iops_99 w_iops,   rw_mbps_99 rw_mbps,   r_mbps_99 r_mbps,   w_mbps_99 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 04 order_by, '97th percentile' metric, instance_number, rw_iops_97 rw_iops,   r_iops_97 r_iops,   w_iops_97 w_iops,   rw_mbps_97 rw_mbps,   r_mbps_97 r_mbps,   w_mbps_97 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 05 order_by, '95th percentile' metric, instance_number, rw_iops_95 rw_iops,   r_iops_95 r_iops,   w_iops_95 w_iops,   rw_mbps_95 rw_mbps,   r_mbps_95 r_mbps,   w_mbps_95 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 06 order_by, '90th percentile' metric, instance_number, rw_iops_90 rw_iops,   r_iops_90 r_iops,   w_iops_90 w_iops,   rw_mbps_90 rw_mbps,   r_mbps_90 r_mbps,   w_mbps_90 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 07 order_by, '75th percentile' metric, instance_number, rw_iops_75 rw_iops,   r_iops_75 r_iops,   w_iops_75 w_iops,   rw_mbps_75 rw_mbps,   r_mbps_75 r_mbps,   w_mbps_75 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 08 order_by, 'Median'          metric, instance_number, rw_iops_med rw_iops,  r_iops_med r_iops,  w_iops_med w_iops,  rw_mbps_med rw_mbps,  r_mbps_med r_mbps,  w_mbps_med w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 09 order_by, 'Average'         metric, instance_number, rw_iops_avg rw_iops,  r_iops_avg r_iops,  w_iops_avg w_iops,  rw_mbps_avg rw_mbps,  r_mbps_avg r_mbps,  w_mbps_avg w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
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
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM io_per_inst_or_cluster
 ORDER BY
       dbid,
       order_by,
       instance_number NULLS LAST
]';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF main_table = '&&awr_hist_prefix.SYSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text_backup := q'[
WITH
sysstat_io AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = 'physical read total IO requests' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN ('physical write total IO requests', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = 'physical read total bytes' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN ('physical write total bytes', 'redo size') THEN value ELSE 0 END) w_bytes
  FROM &&awr_object_prefix.sysstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND stat_name IN ('physical read total IO requests', 'physical write total IO requests', 'redo writes', 'physical read total bytes', 'physical write total bytes', 'redo size')
 GROUP BY
       instance_number,
       snap_id
),
io_per_inst_and_snap_id AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       s1.snap_id,
       h1.instance_number,
       s1.begin_interval_time,
       s1.end_interval_time,
       (h1.r_reqs - h0.r_reqs) r_reqs,
       (h1.w_reqs - h0.w_reqs) w_reqs,
       (h1.r_bytes - h0.r_bytes) r_bytes,
       (h1.w_bytes - h0.w_bytes) w_bytes,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_io h0,
       &&awr_object_prefix.snapshot s0,
       sysstat_io h1,
       &&awr_object_prefix.snapshot s1
 WHERE s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 > 60 -- ignore snaps too close
),
io_per_inst_and_hr AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec), 3) rw_mbps,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec), 3) r_mbps,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec), 3) w_mbps
  FROM io_per_inst_and_snap_id
 GROUP BY
       snap_id,
       instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       SUM(@column1@) @column1@,
       SUM(@column2@) @column2@,
       SUM(@column3@) @column3@,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM io_per_inst_and_hr
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF tit_01 = 'RW IOPS';
DEF tit_02 = 'R IOPS';
DEF tit_03 = 'W IOPS';
DEF vaxis = 'IOPS (RW, R and W)';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
DEF title = 'IOPS Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'IOPS Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'IOPS Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'IOPS Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'IOPS Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'IOPS Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'IOPS Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'IOPS Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'IOPS Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'RW MBPS';
DEF tit_02 = 'R MBPS';
DEF tit_03 = 'W MBPS';
DEF vaxis = 'MBPS (RW, R and W)';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
DEF title = 'MBPS Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'MBPS Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'MBPS Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'MBPS Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'MBPS Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'MBPS Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'MBPS Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'MBPS Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'MBPS Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF main_table = '&&awr_hist_prefix.SYSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';

BEGIN
  :sql_text_backup := q'[
WITH
sysstat_io AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = 'physical read bytes' THEN value ELSE 0 END) r_appl_bytes,
       SUM(CASE WHEN stat_name = 'physical read flash cache hits' THEN value ELSE 0 END) r_flash_cache_hits,
       SUM(CASE WHEN stat_name = 'physical read IO requests' THEN value ELSE 0 END) r_IO_requests,
       SUM(CASE WHEN stat_name = 'physical read requests optimized' THEN value ELSE 0 END) r_requests_optimized,
       SUM(CASE WHEN stat_name = 'physical read total bytes' THEN value ELSE 0 END) r_total_bytes,
       SUM(CASE WHEN stat_name = 'physical read total IO requests' THEN value ELSE 0 END) r_total_IO_requests,
       SUM(CASE WHEN stat_name = 'physical read total multi block requests' THEN value ELSE 0 END) r_total_multi_block_requests,
       SUM(CASE WHEN stat_name = 'physical reads' THEN value ELSE 0 END) reads,
       SUM(CASE WHEN stat_name = 'physical reads cache' THEN value ELSE 0 END) r_cache,
       SUM(CASE WHEN stat_name = 'physical reads cache prefetch' THEN value ELSE 0 END) r_cache_prefetch,
       SUM(CASE WHEN stat_name = 'physical reads direct' THEN value ELSE 0 END) r_direct,
       SUM(CASE WHEN stat_name = 'physical reads direct (lob)' THEN value ELSE 0 END) r_direct_lob,
       SUM(CASE WHEN stat_name = 'physical reads direct temporary tablespace' THEN value ELSE 0 END) r_direct_temporary_tablespace,
       SUM(CASE WHEN stat_name = 'physical reads for flashback new' THEN value ELSE 0 END) r_for_flashback_new,
       SUM(CASE WHEN stat_name = 'physical reads prefetch warmup' THEN value ELSE 0 END) r_prefetch_warmup,
       SUM(CASE WHEN stat_name = 'physical write bytes' THEN value ELSE 0 END) w_appl_bytes,
       SUM(CASE WHEN stat_name = 'physical write IO requests' THEN value ELSE 0 END) w_IO_requests,
       SUM(CASE WHEN stat_name = 'physical write total bytes' THEN value ELSE 0 END) w_total_bytes,
       SUM(CASE WHEN stat_name = 'physical write total IO requests' THEN value ELSE 0 END) w_total_IO_requests,
       SUM(CASE WHEN stat_name = 'physical write total multi block requests' THEN value ELSE 0 END) w_total_multi_block_requests,
       SUM(CASE WHEN stat_name = 'physical writes' THEN value ELSE 0 END) writes,
       SUM(CASE WHEN stat_name = 'physical writes direct' THEN value ELSE 0 END) w_direct,
       SUM(CASE WHEN stat_name = 'physical writes direct (lob)' THEN value ELSE 0 END) w_direct_lob,
       SUM(CASE WHEN stat_name = 'physical writes direct temporary tablespace' THEN value ELSE 0 END) w_direct_temporary_tablespace,
       SUM(CASE WHEN stat_name = 'physical writes from cache' THEN value ELSE 0 END) w_from_cache,
       SUM(CASE WHEN stat_name = 'physical writes non checkpoint' THEN value ELSE 0 END) w_non_checkpoint,
       SUM(CASE WHEN stat_name = 'redo size' THEN value ELSE 0 END) redo_size,
       SUM(CASE WHEN stat_name = 'redo writes' THEN value ELSE 0 END) redo_writes,
       SUM(CASE WHEN stat_name = 'physical read total IO requests' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN ('physical write total IO requests', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = 'physical read total bytes' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN ('physical write total bytes', 'redo size') THEN value ELSE 0 END) w_bytes
  FROM &&awr_object_prefix.sysstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND stat_name IN (
   'physical read bytes',
   'physical read flash cache hits',
   'physical read IO requests',
   'physical read requests optimized',
   'physical read total bytes', /* r_bytes */
   'physical read total IO requests', /* r_reqs */
   'physical read total multi block requests',
   'physical reads',
   'physical reads cache',
   'physical reads cache prefetch',
   'physical reads direct',
   'physical reads direct (lob)',
   'physical reads direct temporary tablespace',
   'physical reads for flashback new',
   'physical reads prefetch warmup',
   'physical write bytes',
   'physical write IO requests',
   'physical write total bytes', /* w_bytes */
   'physical write total IO requests', /* w_reqs */
   'physical write total multi block requests',
   'physical writes',
   'physical writes direct',
   'physical writes direct (lob)',
   'physical writes direct temporary tablespace',
   'physical writes from cache',
   'physical writes non checkpoint',
   'redo size', /* w_bytes */
   'redo writes') /* w_reqs */
 GROUP BY
       instance_number,
       snap_id
),
io_per_inst_and_snap_id AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       s1.snap_id,
       h1.instance_number,
       s1.begin_interval_time,
       s1.end_interval_time,
       (h1.r_appl_bytes - h0.r_appl_bytes) r_appl_bytes,
       (h1.r_flash_cache_hits - h0.r_flash_cache_hits) r_flash_cache_hits,
       (h1.r_IO_requests - h0.r_IO_requests) r_IO_requests,
       (h1.r_requests_optimized - h0.r_requests_optimized) r_requests_optimized,
       (h1.r_total_bytes - h0.r_total_bytes) r_total_bytes,
       (h1.r_total_IO_requests - h0.r_total_IO_requests) r_total_IO_requests,
       (h1.r_total_multi_block_requests - h0.r_total_multi_block_requests) r_total_multi_block_requests,
       (h1.reads - h0.reads) reads,
       (h1.r_cache - h0.r_cache) r_cache,
       (h1.r_cache_prefetch - h0.r_cache_prefetch) r_cache_prefetch,
       (h1.r_direct - h0.r_direct) r_direct,
       (h1.r_direct_lob - h0.r_direct_lob) r_direct_lob,
       (h1.r_direct_temporary_tablespace - h0.r_direct_temporary_tablespace) r_direct_temporary_tablespace,
       (h1.r_for_flashback_new - h0.r_for_flashback_new) r_for_flashback_new,
       (h1.r_prefetch_warmup - h0.r_prefetch_warmup) r_prefetch_warmup,
       (h1.w_appl_bytes - h0.w_appl_bytes) w_appl_bytes,
       (h1.w_IO_requests - h0.w_IO_requests) w_IO_requests,
       (h1.w_total_bytes - h0.w_total_bytes) w_total_bytes,
       (h1.w_total_IO_requests - h0.w_total_IO_requests) w_total_IO_requests,
       (h1.w_total_multi_block_requests - h0.w_total_multi_block_requests) w_total_multi_block_requests,
       (h1.writes - h0.writes) writes,
       (h1.w_direct - h0.w_direct) w_direct,
       (h1.w_direct_lob - h0.w_direct_lob) w_direct_lob,
       (h1.w_direct_temporary_tablespace - h0.w_direct_temporary_tablespace) w_direct_temporary_tablespace,
       (h1.w_from_cache - h0.w_from_cache) w_from_cache,
       (h1.w_non_checkpoint - h0.w_non_checkpoint) w_non_checkpoint,
       (h1.redo_size - h0.redo_size) redo_size,
       (h1.redo_writes - h0.redo_writes) redo_writes,
       (h1.r_reqs - h0.r_reqs) r_reqs,
       (h1.w_reqs - h0.w_reqs) w_reqs,
       (h1.r_bytes - h0.r_bytes) r_bytes,
       (h1.w_bytes - h0.w_bytes) w_bytes,
       (h1.r_total_IO_requests - h0.r_total_IO_requests) - (h1.r_total_multi_block_requests - h0.r_total_multi_block_requests) r_total_single_block_requests,
       (h1.w_total_IO_requests - h0.w_total_IO_requests) - (h1.w_total_multi_block_requests - h0.w_total_multi_block_requests) w_total_single_block_requests,
       --(h1.reads - h0.reads) - (h1.r_direct - h0.r_direct) - (h1.r_cache - h0.r_cache) r_buffered_multi_block_req,
       (&&database_block_size. * ((h1.r_total_IO_requests - h0.r_total_IO_requests) - (h1.r_total_multi_block_requests - h0.r_total_multi_block_requests))) r_total_bytes_single_block_req,
       (h1.r_total_bytes - h0.r_total_bytes) - (&&database_block_size. * ((h1.r_total_IO_requests - h0.r_total_IO_requests) - (h1.r_total_multi_block_requests - h0.r_total_multi_block_requests))) r_total_bytes_multi_block_req,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_io h0,
       &&awr_object_prefix.snapshot s0,
       sysstat_io h1,
       &&awr_object_prefix.snapshot s1
 WHERE s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 > 60 -- ignore snaps too close
),
io_per_inst_and_hr AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       MIN(begin_interval_time) begin_interval_time,
       MIN(end_interval_time) end_interval_time,
       ROUND(MAX(reads / elapsed_sec)) reads_ps,
       ROUND(MAX(writes / elapsed_sec)) writes_ps,
       ROUND(MAX(r_flash_cache_hits / elapsed_sec)) r_flash_cache_hits_ps,
       ROUND(MAX(r_IO_requests / elapsed_sec)) r_appl_iops,
       ROUND(MAX(r_requests_optimized / elapsed_sec)) r_requests_optimized_iops,
       ROUND(MAX(r_total_IO_requests / elapsed_sec)) r_total_iops,
       ROUND(MAX(r_total_multi_block_requests / elapsed_sec)) r_total_multi_block_iops,
       ROUND(MAX(r_cache / elapsed_sec)) r_cache_ps,
       ROUND(MAX(r_cache_prefetch / elapsed_sec)) r_cache_prefetch_ps,
       ROUND(MAX(r_direct / elapsed_sec)) r_direct_ps,
       ROUND(MAX(r_direct_lob / elapsed_sec)) r_direct_lob_ps,
       ROUND(MAX(r_direct_temporary_tablespace / elapsed_sec)) r_direct_temp_tablespace_ps,
       ROUND(MAX(r_for_flashback_new / elapsed_sec)) r_for_flashback_new_ps,
       ROUND(MAX(r_prefetch_warmup / elapsed_sec)) r_prefetch_warmup_ps,
       ROUND(MAX(w_IO_requests / elapsed_sec)) w_appl_iops,
       ROUND(MAX(w_total_IO_requests / elapsed_sec)) w_total_iops,
       ROUND(MAX(w_total_multi_block_requests / elapsed_sec)) w_total_multi_block_iops,
       ROUND(MAX(w_direct / elapsed_sec)) w_direct_ps,
       ROUND(MAX(w_direct_lob / elapsed_sec)) w_direct_lob_ps,
       ROUND(MAX(w_direct_temporary_tablespace / elapsed_sec)) w_direct_temp_tablespace_ps,
       ROUND(MAX(w_from_cache / elapsed_sec)) w_from_cache_ps,
       ROUND(MAX(w_non_checkpoint / elapsed_sec)) w_non_checkpoint_ps,
       ROUND(MAX(redo_writes / elapsed_sec)) w_redo_iops,
       ROUND(MAX(r_total_single_block_requests / elapsed_sec)) r_total_single_block_iops,
       ROUND(MAX(w_total_single_block_requests / elapsed_sec)) w_total_single_block_iops,
       --ROUND(MAX(r_buffered_multi_block_req / elapsed_sec)) r_buffered_multi_block_iops,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops,
       ROUND(MAX(r_total_bytes / POWER(10,6) / elapsed_sec), 3) r_total_mbps,
       ROUND(MAX(r_appl_bytes / POWER(10,6) / elapsed_sec), 3) r_appl_mbps,
       ROUND(MAX(w_total_bytes / POWER(10,6) / elapsed_sec), 3) w_total_mbps,
       ROUND(MAX(w_appl_bytes / POWER(10,6) / elapsed_sec), 3) w_appl_mbps,
       ROUND(MAX(redo_size / POWER(10,6) / elapsed_sec), 3) redo_size_mbps,
       ROUND(MAX(r_total_bytes_single_block_req / POWER(10,6) / elapsed_sec), 3) r_total_single_block_mbps,
       ROUND(MAX(r_total_bytes_multi_block_req / POWER(10,6) / elapsed_sec), 3) r_total_multi_block_mbps,
       --ROUND(MAX(r_total_bytes_multi_block_req * (r_buffered_multi_block_req / GREATEST(r_total_multi_block_requests, 1)) / POWER(10,6) / elapsed_sec), 3) r_buffered_multi_block_mbps,
       --ROUND(MAX(r_total_bytes_multi_block_req * (r_direct / GREATEST(r_total_multi_block_requests, 1)) / POWER(10,6) / elapsed_sec), 3) r_direct_multi_block_mbps,
       ROUND(MAX((r_bytes + w_bytes) / POWER(10,6) / elapsed_sec), 3) rw_mbps,
       ROUND(MAX(r_bytes / POWER(10,6) / elapsed_sec), 3) r_mbps,
       ROUND(MAX(w_bytes / POWER(10,6) / elapsed_sec), 3) w_mbps
  FROM io_per_inst_and_snap_id
 GROUP BY
       snap_id,
       instance_number
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_interval_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       #column01#
       #column02#
       #column03#
       #column04#
       #column05#
       #column06#
       #column07#
       #column08#
       #column09#
       #column10#
       #column11#
       #column12#
       #column13#
       #column14#
       #column15#
  FROM io_per_inst_and_hr
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

DEF tit_01 = 'R-IOPS';
DEF tit_02 = 'Total IO Requests';
DEF tit_03 = 'Total single-block Requests';
DEF tit_04 = 'Total multi-block Requests';
DEF tit_05 = 'Requests Optimized';
DEF tit_06 = 'Application IO Requests';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF vaxis = 'Read I/O Operations per Second (R-IOPS)';

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', 'SUM(r_iops) r_iops,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', 'SUM(r_total_iops) total_IO_requests,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', 'SUM(r_total_single_block_iops) total_single_block_requests,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', 'SUM(r_total_multi_block_iops) total_multi_block_requests,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', 'SUM(r_requests_optimized_iops) requests_optimized,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', 'SUM(r_appl_iops) appl_IO_requests,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', '0 dummy_07,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', '0 dummy_08,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', '0 dummy_09,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', '0 dummy_10,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column11#', '0 dummy_11,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column12#', '0 dummy_12,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column13#', '0 dummy_13,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column14#', '0 dummy_14,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column15#', '0 dummy_15');

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
DEF title = 'R-IOPS Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'R-IOPS Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'R-IOPS Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'R-IOPS Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'R-IOPS Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'R-IOPS Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'R-IOPS Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'R-IOPS Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read I/O Operations per Second (R-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'R-IOPS Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'Reads';
DEF tit_02 = 'Direct';
DEF tit_03 = 'Direct LOB';
DEF tit_04 = 'Direct Temporary Tablespace';
DEF tit_05 = 'Cache';
DEF tit_06 = 'Cache pre-fetch';
DEF tit_07 = 'Flash Cache Hits';
DEF tit_08 = 'For Flashback New';
DEF tit_09 = 'Pre-fetch warmup';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF vaxis = 'Reads per Second';

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', 'SUM(reads_ps) reads,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', 'SUM(r_direct_ps) direct,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', 'SUM(r_direct_lob_ps) direct_lob,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', 'SUM(r_direct_temp_tablespace_ps) direct_temporary_tablespace,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', 'SUM(r_cache_ps) cache,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', 'SUM(r_cache_prefetch_ps) cache_prefetch,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', 'SUM(r_flash_cache_hits_ps) flash_cache_hits,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', 'SUM(r_for_flashback_new_ps) for_flashback_new,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', 'SUM(r_prefetch_warmup_ps) prefetch_warmup,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', '0 dummy_10,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column11#', '0 dummy_11,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column12#', '0 dummy_12,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column13#', '0 dummy_13,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column14#', '0 dummy_14,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column15#', '0 dummy_15');

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Reads per Second.<br />'
DEF title = 'Reads (per second) Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Reads per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'Reads (per second) Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Reads per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'Reads (per second) Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Reads per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'Reads (per second) Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Reads per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'Reads (per second) Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Reads per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'Reads (per second) Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Reads per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'Reads (per second) Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Reads per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'Reads (per second) Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Reads per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'Reads (per second) Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'R-MBPS';
DEF tit_02 = 'Total MBPS';
DEF tit_03 = 'Total single-block MBPS';
DEF tit_04 = 'Total multi-block MBPS';
DEF tit_05 = 'Application MBPS';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF vaxis = 'Read Megabytes per Second (R-MBPS)';

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', 'SUM(r_mbps) r_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', 'SUM(r_total_mbps) total_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', 'SUM(r_total_single_block_mbps) total_single_block_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', 'SUM(r_total_multi_block_mbps) total_multi_block_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', 'SUM(r_appl_mbps) appl_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', '0 dummy_06,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', '0 dummy_07,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', '0 dummy_08,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', '0 dummy_09,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', '0 dummy_10,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column11#', '0 dummy_11,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column12#', '0 dummy_12,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column13#', '0 dummy_13,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column14#', '0 dummy_14,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column15#', '0 dummy_15');

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
DEF title = 'R-MBPS Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'R-MBPS Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'R-MBPS Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'R-MBPS Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'R-MBPS Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'R-MBPS Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'R-MBPS Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'R-MBPS Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read Megabytes per Second (R-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'R-MBPS Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'W-IOPS';
DEF tit_02 = 'Total IO Requests';
DEF tit_03 = 'Redo Writes';
DEF tit_04 = 'Total single-block Requests';
DEF tit_05 = 'Total multi-block Requests';
DEF tit_06 = 'Application IO Requests';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF vaxis = 'Write I/O Operations per Second (W-IOPS)';

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', 'SUM(w_iops) w_iops,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', 'SUM(w_total_iops) total_IO_requests,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', 'SUM(w_redo_iops) redo_writes,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', 'SUM(w_total_single_block_iops) total_single_block_requests,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', 'SUM(w_total_multi_block_iops) total_multi_block_requests,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', 'SUM(w_appl_iops) appl_IO_requests,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', '0 dummy_07,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', '0 dummy_08,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', '0 dummy_09,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', '0 dummy_10,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column11#', '0 dummy_11,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column12#', '0 dummy_12,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column13#', '0 dummy_13,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column14#', '0 dummy_14,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column15#', '0 dummy_15');

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
DEF title = 'W-IOPS Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'W-IOPS Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'W-IOPS Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'W-IOPS Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'W-IOPS Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'W-IOPS Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'W-IOPS Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'W-IOPS Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write I/O Operations per Second (W-IOPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'W-IOPS Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'Writes';
DEF tit_02 = 'Direct';
DEF tit_03 = 'Direct LOB';
DEF tit_04 = 'Direct Temporary Tablespace';
DEF tit_05 = 'From Cache';
DEF tit_06 = 'Non Checkpoint';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF vaxis = 'Writes per Second';

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', 'SUM(writes_ps) writes,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', 'SUM(w_direct_ps) direct,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', 'SUM(w_direct_lob_ps) direct_lob,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', 'SUM(w_direct_temp_tablespace_ps) direct_temporary_tablespace,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', 'SUM(w_from_cache_ps) from_cache,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', 'SUM(w_non_checkpoint_ps) non_checkpoint,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', '0 dummy_07,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', '0 dummy_08,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', '0 dummy_09,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', '0 dummy_10,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column11#', '0 dummy_11,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column12#', '0 dummy_12,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column13#', '0 dummy_13,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column14#', '0 dummy_14,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column15#', '0 dummy_15');

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Writes per Second.<br />'
DEF title = 'Writes (per second) Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Writes per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'Writes (per second) Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Writes per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'Writes (per second) Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Writes per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'Writes (per second) Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Writes per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'Writes (per second) Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Writes per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'Writes (per second) Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Writes per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'Writes (per second) Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Writes per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'Writes (per second) Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Writes per Second.<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'Writes (per second) Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'W-MBPS';
DEF tit_02 = 'Total MBPS';
DEF tit_03 = 'Redo Size MBPS';
DEF tit_04 = 'Application MBPS';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF vaxis = 'Write Megabytes per Second (W-MBPS)';

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', 'SUM(w_mbps) w_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', 'SUM(w_total_mbps) total_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', 'SUM(redo_size_mbps) redo_size_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', 'SUM(w_appl_mbps) appl_mbps,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', '0 dummy_05,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', '0 dummy_06,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', '0 dummy_07,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', '0 dummy_08,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', '0 dummy_09,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', '0 dummy_10,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column11#', '0 dummy_11,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column12#', '0 dummy_12,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column13#', '0 dummy_13,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column14#', '0 dummy_14,');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column15#', '0 dummy_15');

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
DEF title = 'W-MBPS Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'W-MBPS Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'W-MBPS Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'W-MBPS Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'W-MBPS Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'W-MBPS Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'W-MBPS Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'W-MBPS Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Write Megabytes per Second (W-MBPS).<br />'
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'W-MBPS Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
