@@&&edb360_0g.tkprof.sql
DEF section_id = '7a';
DEF section_name = 'AWR/ADDM/ASH Reports';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SET VER OFF FEED OFF SERVEROUT ON HEAD OFF PAGES 50000 LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;
SET TERM ON;
CL SCR;
PRO Searching for snaps of interest ...
PRO Please wait ...
SET TERM OFF; 
-- watchdog
COL edb360_bypass NEW_V edb360_bypass;
SELECT ' echo timeout ' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds
/
COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;
SPO &&edb360_output_directory.99910_&&common_edb360_prefix._rpt_driver.sql;
PRO PRO
PRO VAR lv_inst_num      VARCHAR2(1023);;
PRO VAR lv_dbid          NUMBER;; 
PRO VAR lv_bid           NUMBER;; 
PRO VAR lv_eid           NUMBER;; 
PRO VAR lv_begin_date    VARCHAR2(14);; 
PRO VAR lv_end_date      VARCHAR2(14);;
PRO VAR lv_rep           VARCHAR2(14);;
PRO PRO
PRO VAR lv_m1_inst_num   VARCHAR2(1023);;
PRO VAR lv_m1_dbid       NUMBER;; 
PRO VAR lv_m1_bid        NUMBER;; 
PRO VAR lv_m1_eid        NUMBER;; 
PRO VAR lv_m1_begin_date VARCHAR2(14);; 
PRO VAR lv_m1_end_date   VARCHAR2(14);;
PRO VAR lv_m1_rep        VARCHAR2(14);;
PRO PRO
PRO VAR lv_m2_inst_num   VARCHAR2(1023);;
PRO VAR lv_m2_dbid       NUMBER;; 
PRO VAR lv_m2_bid        NUMBER;; 
PRO VAR lv_m2_eid        NUMBER;; 
PRO VAR lv_m2_begin_date VARCHAR2(14);; 
PRO VAR lv_m2_end_date   VARCHAR2(14);;
PRO VAR lv_m2_rep        VARCHAR2(14);;
--
DECLARE
  l_standard_filename VARCHAR2(32767);
  l_spool_filename VARCHAR2(32767);
  l_one_spool_filename VARCHAR2(32767);
  l_title_m1 VARCHAR2(32767);
  l_title_m2 VARCHAR2(32767);
  l_instances NUMBER;
  PROCEDURE put_line(p_line IN VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put_line;
  PROCEDURE update_log(p_module IN VARCHAR2) IS
  BEGIN
        put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
		put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
		put_line('-- update log');
		put_line('SPO &&edb360_log..txt APP;');
        put_line('SET TERM ON;');
		put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. &&section_id. '||p_module);
		put_line('SELECT ''Elapsed Hours so far: ''||ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3) FROM DUAL;');
        put_line('SET TERM OFF;');
		put_line('SPO OFF;');
  END update_log;
BEGIN
  SELECT COUNT(*) INTO l_instances FROM &&gv_object_prefix.instance;
  
  -- all nodes
  IF l_instances > 1 AND '&&edb360_bypass.' IS NULL THEN
    FOR j IN (WITH
              expensive2 AS (
              SELECT /*+ &&sq_fact_hints. &&ds_hint. &&section_id. */
                     h.dbid, 
                     LAG(h.snap_id) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id) bid,
                     h.snap_id eid,
                     CAST(s.begin_interval_time AS DATE) begin_date,
                     CAST(s.end_interval_time AS DATE) end_date,
                     h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id) value,
                     s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id) startup_time_interval
                FROM &&awr_object_prefix.sys_time_model h,
                     &&awr_object_prefix.snapshot s
               WHERE h.stat_name IN ('DB time', 'background elapsed time')
                 AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                 AND h.dbid = &&edb360_dbid.
                 AND s.snap_id = h.snap_id
                 AND s.dbid = h.dbid
                 AND s.instance_number = h.instance_number
                 AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
                 --AND s.end_interval_time BETWEEN TO_TIMESTAMP('&&edb360_date_to.', '&&edb360_date_format.') - TO_DSINTERVAL('+&&history_days. 00:00:00.000000') AND TO_TIMESTAMP('&&edb360_date_to.', '&&edb360_date_format.') -- includes all options
                 --AND s.end_interval_time BETWEEN TO_TIMESTAMP('&&edb360_date_from.', '&&edb360_date_format.') AND TO_TIMESTAMP('&&edb360_date_to.', '&&edb360_date_format.') -- includes all options
              ),
              expensive AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ dbid, bid, eid, begin_date, end_date, SUM(value) value
                FROM expensive2
               WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
                 AND value > 0
               GROUP BY
                     dbid, bid, eid, begin_date, end_date
              ),
              max_&&hist_work_days.wd1 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 AND &&history_days. > 10
                 AND &&edb360_max_work_days_peaks. >= 1
              ),
              max_&&hist_work_days.wd2 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 AND &&history_days. > 10
                 AND &&edb360_max_work_days_peaks. >= 2
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1)
              ),
              max_&&hist_work_days.wd3 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 AND &&history_days. > 10
                 AND &&edb360_max_work_days_peaks. >= 3
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd2)
              ),
              min_&&hist_work_days.wd AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MIN(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 AND &&history_days. > 10
                 AND &&edb360_min_work_days_peaks. >= 1
              ),
              max_&&history_days.d1 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND &&history_days. > 10
                 AND &&edb360_max_history_peaks. >= 1
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd2
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd3)
              ),
              max_&&history_days.d2 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND &&history_days. > 10
                 AND &&edb360_max_history_peaks. >= 2
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1
                                   UNION 
                                   SELECT value FROM max_&&hist_work_days.wd2
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd3
                                   UNION
                                   SELECT value FROM max_&&history_days.d1)
              ),
              max_&&history_days.d3 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND &&history_days. > 10
                 AND &&edb360_max_history_peaks. >= 3
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1
                                   UNION 
                                   SELECT value FROM max_&&hist_work_days.wd2
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd3
                                   UNION
                                   SELECT value FROM max_&&history_days.d1
                                   UNION
                                   SELECT value FROM max_&&history_days.d2)
              ),
              med_&&history_days.d AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND &&history_days. > 10
                 AND &&edb360_med_history. >= 1
              ),
              max_5wd1 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 --AND &&history_days. > 10
                 AND &&edb360_max_5wd_peaks. >= 1
              ),
              max_5wd2 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 --AND &&history_days. > 10
                 AND &&edb360_max_5wd_peaks. >= 2
                 AND value NOT IN (SELECT value FROM max_5wd1)
              ),
              max_5wd3 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 --AND &&history_days. > 10
                 AND &&edb360_max_5wd_peaks. >= 3
                 AND value NOT IN (SELECT value FROM max_5wd1
                                   UNION
                                   SELECT value FROM max_5wd2)
              ),
              min_5wd AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MIN(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 --AND &&history_days. > 10
                 AND &&edb360_min_5wd_peaks. >= 1
              ),
              max_7d1 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 --AND &&history_days. > 10
                 AND &&edb360_max_7d_peaks. >= 1
                 AND value NOT IN (SELECT value FROM max_5wd1
                                   UNION
                                   SELECT value FROM max_5wd2
                                   UNION
                                   SELECT value FROM max_5wd3)
              ),
              max_7d2 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 --AND &&history_days. > 10
                 AND &&edb360_max_7d_peaks. >= 2
                 AND value NOT IN (SELECT value FROM max_5wd1
                                   UNION
                                   SELECT value FROM max_5wd2
                                   UNION
                                   SELECT value FROM max_5wd3
                                   UNION
                                   SELECT value FROM max_7d1)
              ),
              max_7d3 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 --AND &&history_days. > 10
                 AND &&edb360_max_7d_peaks. >= 3
                 AND value NOT IN (SELECT value FROM max_5wd1
                                   UNION
                                   SELECT value FROM max_5wd2
                                   UNION
                                   SELECT value FROM max_5wd3
                                   UNION
                                   SELECT value FROM max_7d1
                                   UNION
                                   SELECT value FROM max_7d2)
              ),
              med_7d AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 --AND &&history_days. > 10
                 AND &&edb360_med_7d. >= 1
              ),
              small_range AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&hist_work_days.wd1' rep, 50 ob
                FROM expensive e,
                     max_&&hist_work_days.wd1 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&hist_work_days.wd2' rep, 53 ob
                FROM expensive e,
                     max_&&hist_work_days.wd2 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&hist_work_days.wd3' rep, 56 ob
                FROM expensive e,
                     max_&&hist_work_days.wd3 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'min&&hist_work_days.wd' rep, 100 ob
                FROM expensive e,
                     min_&&hist_work_days.wd m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&history_days.d1' rep, 60 ob
                FROM expensive e,
                     max_&&history_days.d1 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&history_days.d2' rep, 63 ob
                FROM expensive e,
                     max_&&history_days.d2 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&history_days.d3' rep, 66 ob
                FROM expensive e,
                     max_&&history_days.d3 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'med&&history_days.d' rep, 80 ob
                FROM expensive e,
                     med_&&history_days.d m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'med&&history_days.d' rep, 15 ob
                FROM expensive e,
                     med_&&history_days.d m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max5wd1' rep, 30 ob
                FROM expensive e,
                     max_5wd1 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max5wd2' rep, 33 ob
                FROM expensive e,
                     max_5wd2 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max5wd3' rep, 36 ob
                FROM expensive e,
                     max_5wd3 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'min5wd' rep, 90 ob
                FROM expensive e,
                     min_5wd m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max7d1' rep, 40 ob
                FROM expensive e,
                     max_7d1 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max7d2' rep, 43 ob
                FROM expensive e,
                     max_7d2 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max7d3' rep, 46 ob
                FROM expensive e,
                     max_7d3 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'med7d' rep, 70 ob
                FROM expensive e,
                     med_7d m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'med7d' rep, 10 ob
                FROM expensive e,
                     med_7d m
               WHERE m.value = e.value
              ),
              max_&&history_days.d AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MIN(dbid) dbid, MIN(bid) bid, MAX(eid) eid, MIN(begin_date) begin_date, MAX(end_date) end_date, 'max&&history_days.d' rep, 69 ob
                FROM small_range
               WHERE rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 
                             'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 
                             'max5wd1', 'max5wd2', 'max5wd3', 
                             'max7d1', 'max7d2', 'max7d3')
                 AND &&history_days. > 10
              HAVING COUNT(*) > 0
              ),
              max_7d AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MIN(dbid) dbid, MIN(bid) bid, MAX(eid) eid, MIN(begin_date) begin_date, MAX(end_date) end_date, 'max7d' rep, 49 ob
                FROM small_range
               WHERE rep IN ('max5wd1', 'max5wd2', 'max5wd3', 
                             'max7d1', 'max7d2', 'max7d3')
                 --AND &&history_days. > 10
              HAVING COUNT(*) > 0
              )
              SELECT dbid, bid, eid, begin_date, end_date, rep, ob
                FROM small_range
               UNION ALL
              SELECT dbid, bid, eid, begin_date, end_date, rep, ob
                FROM max_&&history_days.d
               WHERE '&&edb360_conf_incl_awr_range_rpt.' = 'Y'
               UNION ALL
              SELECT dbid, bid, eid, begin_date, end_date, rep, ob
                FROM max_7d
               WHERE '&&edb360_conf_incl_awr_range_rpt.' = 'Y'
               ORDER BY 7)
    LOOP
      IF j.ob < 20 THEN
        IF j.rep = 'med7d' THEN
          put_line('EXEC :lv_m1_begin_date := '''||TO_CHAR(j.begin_date, 'YYYYMMDDHH24MISS')||''';');
          put_line('EXEC :lv_m1_end_date := '''||TO_CHAR(j.end_date, 'YYYYMMDDHH24MISS')||''';');
          put_line('EXEC :lv_m1_dbid := '||j.dbid||';');
          put_line('EXEC :lv_m1_bid := '||j.bid||';');
          put_line('EXEC :lv_m1_eid := '||j.eid||';');
          put_line('EXEC :lv_m1_inst_num := NULL;');
          put_line('EXEC :lv_m1_rep := '''||j.rep||''';');
          l_title_m1 := 'rac_'||j.bid||'_'||j.eid||'_'||j.rep;
        ELSIF j.rep = 'med&&history_days.d' THEN
          put_line('EXEC :lv_m2_begin_date := '''||TO_CHAR(j.begin_date, 'YYYYMMDDHH24MISS')||''';');
          put_line('EXEC :lv_m2_end_date := '''||TO_CHAR(j.end_date, 'YYYYMMDDHH24MISS')||''';');
          put_line('EXEC :lv_m2_dbid := '||j.dbid||';');
          put_line('EXEC :lv_m2_bid := '||j.bid||';');
          put_line('EXEC :lv_m2_eid := '||j.eid||';');
          put_line('EXEC :lv_m2_inst_num := NULL;');
          put_line('EXEC :lv_m2_rep := '''||j.rep||''';');
          l_title_m2 := 'rac_'||j.bid||'_'||j.eid||'_'||j.rep;
        END IF;
      ELSIF j.ob >= 20 THEN
        put_line('EXEC :lv_begin_date := '''||TO_CHAR(j.begin_date, 'YYYYMMDDHH24MISS')||''';');
        put_line('EXEC :lv_end_date := '''||TO_CHAR(j.end_date, 'YYYYMMDDHH24MISS')||''';');
        put_line('EXEC :lv_dbid := '||j.dbid||';');
        put_line('EXEC :lv_bid := '||j.bid||';');
        put_line('EXEC :lv_eid := '||j.eid||';');
        put_line('EXEC :lv_inst_num := NULL;');
        put_line('EXEC :lv_rep := '''||j.rep||''';');
        
        -- main report
        put_line('-- update main report');
        put_line('SPO &&edb360_main_report..html APP;');
        put_line('PRO <li>rac_'||j.bid||'_'||j.eid||'_'||j.rep||' <small><em>('||TO_CHAR(j.begin_date,'&&edb360_date_format.')||' to '||TO_CHAR(j.end_date,'&&edb360_date_format.')||')</em></small><br />');
        put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
        put_line('SPO OFF;');
        put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
        put_line('EXEC :repo_seq := :repo_seq + 1;');
        put_line('SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;');
        
        -- eAdam
        IF '&&edb360_conf_incl_eadam.' = 'Y' AND j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 'max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
          put_line('DEF edb360_eadam_snaps = '''||CHR(38)||CHR(38)||'edb360_eadam_snaps., '||j.eid||''';');
        END IF;
        
        -- 12c perfhub
        IF '&&edb360_conf_incl_perfhub.' = 'Y' AND '&&db_version.' >= '12' AND j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 'max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
          put_line('COL edb360_bypass NEW_V edb360_bypass;');
          put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
          l_standard_filename := 'perfhub_rac_'||j.bid||'_'||j.eid||'_'||j.rep;
          l_spool_filename := '&&common_edb360_prefix._'||l_standard_filename;
          put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
          put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
          put_line('-- update log');
          put_line('SPO &&edb360_log..txt APP;');
          put_line('PRO');
          put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          put_line('PRO');
          put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. '||l_spool_filename);
          put_line('SPO OFF;');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
          :file_seq := :file_seq + 1;
          l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
          update_log(l_one_spool_filename||'.html');
          put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
          put_line('SELECT /* &&section_id. */ DBMS_PERF.REPORT_PERFHUB(0,GREATEST(TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS'')-(12/24),TO_DATE(''&&edb360_date_from.'',''&&edb360_date_format.'')),LEAST(TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS'')+(12/24),TO_DATE(''&&edb360_date_to.'',''&&edb360_date_format.'')),TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS'')-(1/24),TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS'')+(1/24),:lv_inst_num,:lv_dbid) FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
          put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
          put_line('SPO OFF;');
          put_line('-- update main report');
          put_line('SPO &&edb360_main_report..html APP;');
          put_line('PRO <a href="'||l_one_spool_filename||'.html">perfhub html</a>');
          put_line('SPO OFF;');
          put_line('-- zip');
          put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
        END IF;

        -- awr all modes
        IF '&&edb360_conf_incl_awr_rpt.' = 'Y' AND l_instances > 1 AND '&&db_version.' >= '11.2' THEN
          put_line('COL edb360_bypass NEW_V edb360_bypass;');
          put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
          l_standard_filename := 'awrrpt_rac_'||j.bid||'_'||j.eid||'_'||j.rep;
          l_spool_filename := '&&common_edb360_prefix._'||l_standard_filename;
          put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
          put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
          put_line('-- update log');
          put_line('SPO &&edb360_log..txt APP;');
          put_line('PRO');
          put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          put_line('PRO');
          put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. '||l_spool_filename);
          put_line('SPO OFF;');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
          
          IF '&&edb360_skip_html.' IS NULL THEN
            :file_seq := :file_seq + 1;
            l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
            update_log(l_one_spool_filename||'.html');
            put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
            put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_global_report_html(:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid,9)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
            put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
            put_line('SPO OFF;');
            put_line('-- update main report');
            put_line('SPO &&edb360_main_report..html APP;');
            put_line('PRO <a href="'||l_one_spool_filename||'.html">awr html</a>');
            put_line('SPO OFF;');
            put_line('-- zip');
            put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
            put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            
            IF '&&edb360_conf_incl_awr_diff_rpt.' = 'Y' AND j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 
                                                                      'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 
                                                                      'max5wd1', 'max5wd2', 'max5wd3', 
                                                                      'max7d1', 'max7d2', 'max7d3')
            THEN
              :file_seq := :file_seq + 1;
              l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename||'_diff';
              update_log(l_one_spool_filename||'.html');
              put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
              IF j.rep IN ('max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
                put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_global_diff_report_html(:lv_m1_dbid,:lv_m1_inst_num,:lv_m1_bid,:lv_m1_eid,:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              ELSIF j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3') THEN
                put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_global_diff_report_html(:lv_m2_dbid,:lv_m2_inst_num,:lv_m2_bid,:lv_m2_eid,:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              END IF;
              put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
              put_line('SPO OFF;');
              put_line('-- update main report');
              put_line('SPO &&edb360_main_report..html APP;');
              IF j.rep IN ('max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
                put_line('PRO <a title="Global DIFF with '||l_title_m1||' AWR" href="'||l_one_spool_filename||'.html">awr diff html</a>');
              ELSIF j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3') THEN
                put_line('PRO <a title="Global DIFF with '||l_title_m2||' AWR" href="'||l_one_spool_filename||'.html">awr diff html</a>');
              END IF;
              put_line('SPO OFF;');
              put_line('-- zip');
              put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
              put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            END IF;
          END IF;
          
          IF '&&edb360_skip_text.' IS NULL THEN
            :file_seq := :file_seq + 1;
            l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
            update_log(l_one_spool_filename||'.txt');
            put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.txt;');
            put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_global_report_text(:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid,9)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
            put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
            put_line('SPO OFF;');
            put_line('-- update main report');
            put_line('SPO &&edb360_main_report..html APP;');
            put_line('PRO <a href="'||l_one_spool_filename||'.txt">awr text</a>');
            put_line('SPO OFF;');
            put_line('-- zip');
            put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.txt >> &&edb360_log3..txt');
            put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            
            IF '&&edb360_conf_incl_awr_diff_rpt.' = 'Y' AND j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 
                                                                      'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 
                                                                      'max5wd1', 'max5wd2', 'max5wd3', 
                                                                      'max7d1', 'max7d2', 'max7d3')
            THEN
              :file_seq := :file_seq + 1;
              l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename||'_diff';
              update_log(l_one_spool_filename||'.txt');
              put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.txt;');
              IF j.rep IN ('max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
                put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_global_diff_report_text(:lv_m1_dbid,:lv_m1_inst_num,:lv_m1_bid,:lv_m1_eid,:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              ELSIF j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3') THEN
                put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_global_diff_report_text(:lv_m2_dbid,:lv_m2_inst_num,:lv_m2_bid,:lv_m2_eid,:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              END IF;
              put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
              put_line('SPO OFF;');
              put_line('-- update main report');
              put_line('SPO &&edb360_main_report..html APP;');
              IF j.rep IN ('max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
                put_line('PRO <a title="Global DIFF with '||l_title_m1||' AWR" href="'||l_one_spool_filename||'.txt">awr diff txt</a>');
              ELSIF j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3') THEN
                put_line('PRO <a title="Global DIFF with '||l_title_m2||' AWR" href="'||l_one_spool_filename||'.txt">awr diff txt</a>');
              END IF;
              put_line('SPO OFF;');
              put_line('-- zip');
              put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.txt >> &&edb360_log3..txt');
              put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            END IF;
          END IF;
        END IF;
  
        -- addm all nodes
        IF '&&edb360_conf_incl_addm_rpt.' = 'Y' AND l_instances > 1 THEN
          put_line('COL edb360_bypass NEW_V edb360_bypass;');
          put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
          put_line('VAR l_task_name VARCHAR2(30);');
          put_line('BEGIN');
          put_line('  :l_task_name := ''ADDM_''||TO_CHAR(SYSDATE, ''YYYYMMDD_HH24MISS'');');
          put_line('  DBMS_ADVISOR.CREATE_TASK(advisor_name => ''ADDM'', task_name =>  :l_task_name);');
          put_line('  DBMS_ADVISOR.SET_TASK_PARAMETER(task_name => :l_task_name, parameter => ''START_SNAPSHOT'', value => :lv_bid);');
          put_line('  DBMS_ADVISOR.SET_TASK_PARAMETER(task_name => :l_task_name, parameter => ''END_SNAPSHOT'', value => :lv_eid);');
          put_line('  DBMS_ADVISOR.SET_TASK_PARAMETER(task_name => :l_task_name, parameter => ''DB_ID'', value => :lv_dbid);');
          put_line('  '||CHR(38)||CHR(38)||'edb360_bypass.DBMS_ADVISOR.EXECUTE_TASK(task_name => :l_task_name);');
          put_line('END;');
          put_line('/');
          put_line('PRINT l_task_name;');
          l_standard_filename := 'addmrpt_rac_'||j.bid||'_'||j.eid||'_'||j.rep;
          l_spool_filename := '&&common_edb360_prefix._'||l_standard_filename;
          put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
          put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
          put_line('-- update log');
          put_line('SPO &&edb360_log..txt APP;');
          put_line('PRO');
          put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          put_line('PRO');
          put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. '||l_spool_filename);
          put_line('SPO OFF;');
          --IF '&&edb360_skip_text.' IS NULL THEN
            :file_seq := :file_seq + 1;
            l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
            update_log(l_one_spool_filename||'.txt');
            put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.txt;');
            put_line('SELECT /* &&section_id. */ DBMS_ADVISOR.get_task_report(:l_task_name) FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
            put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
            put_line('SPO OFF;');
            put_line('-- update main report');
            put_line('SPO &&edb360_main_report..html APP;');
            put_line('PRO <a href="'||l_one_spool_filename||'.txt">addm text</a>');
            put_line('SPO OFF;');
            put_line('-- zip');
            put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.txt >> &&edb360_log3..txt');
            put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
          --END IF;
          put_line('EXEC DBMS_ADVISOR.DELETE_TASK(task_name => :l_task_name);');
        END IF;
        
        -- ash all nodes
        IF ('&&edb360_conf_incl_ash_rpt.' = 'Y' OR '&&edb360_conf_incl_ash_analy_rpt.' = 'Y') AND l_instances > 1 AND '&&db_version.' >= '11.2' THEN
          put_line('COL edb360_bypass NEW_V edb360_bypass;');
          put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
          l_standard_filename := 'ashrpt_rac_'||j.bid||'_'||j.eid||'_'||j.rep;
          l_spool_filename := '&&common_edb360_prefix._'||l_standard_filename;
          put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
          put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
          put_line('-- update log');
          put_line('SPO &&edb360_log..txt APP;');
          put_line('PRO');
          put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          put_line('PRO');
          put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. '||l_spool_filename);
          put_line('SPO OFF;');
          
          IF '&&edb360_skip_html.' IS NULL THEN
            IF '&&edb360_conf_incl_ash_rpt.' = 'Y' THEN
              :file_seq := :file_seq + 1;
              l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
              update_log(l_one_spool_filename||'.html');
              put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
              put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.ash_global_report_html(:lv_dbid,:lv_inst_num,TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS''),TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS''))) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
              put_line('SPO OFF;');
              put_line('-- update main report');
              put_line('SPO &&edb360_main_report..html APP;');
              put_line('PRO <a href="'||l_one_spool_filename||'.html">ash html</a>');
              put_line('SPO OFF;');
              put_line('-- zip');
              put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
              put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            END IF;
            
            IF '&&edb360_conf_incl_ash_analy_rpt.' = 'Y' AND '&&db_version.' >= '12.1' THEN
              :file_seq := :file_seq + 1;
              l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename||'_analy';
              update_log(l_one_spool_filename||'.html');
              put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
              put_line('SELECT /* &&section_id. */ DBMS_WORKLOAD_REPOSITORY.ash_report_analytics(:lv_dbid,:lv_inst_num,TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS''),TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS'')) FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
              put_line('SPO OFF;');
              put_line('-- update main report');
              put_line('SPO &&edb360_main_report..html APP;');
              put_line('PRO <a href="'||l_one_spool_filename||'.html">ash analy html</a>');
              put_line('SPO OFF;');
              put_line('-- zip');
              put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
              put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            END IF;
          END IF;
          
          IF '&&edb360_skip_text.' IS NULL THEN
            :file_seq := :file_seq + 1;
            l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
            update_log(l_one_spool_filename||'.txt');
            put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.txt;');
            put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.ash_global_report_text(:lv_dbid,:lv_inst_num,TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS''),TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS''))) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
            put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
            put_line('SPO OFF;');
            put_line('-- update main report');
            put_line('SPO &&edb360_main_report..html APP;');
            put_line('PRO <a href="'||l_one_spool_filename||'.txt">ash text</a>');
            put_line('SPO OFF;');
            put_line('-- zip');
            put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.txt >> &&edb360_log3..txt');
            put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
          END IF;
        END IF;
                
        -- main report
        put_line('-- update main report');
        put_line('SPO &&edb360_main_report..html APP;');
        put_line('PRO </li>');
        put_line('SPO OFF;');
        put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
      END IF;
    END LOOP;
  END IF;

  -- each instance
  FOR i IN (SELECT instance_number
              FROM &&gv_object_prefix.instance
             WHERE '&&diagnostics_pack.' = 'Y'
               AND '&&edb360_bypass.' IS NULL
             ORDER BY
                   instance_number)
  LOOP
    FOR j IN (WITH
              expensive2 AS (
              SELECT /*+ &&sq_fact_hints. &&ds_hint. &&section_id. */
                     h.dbid, 
                     LAG(h.snap_id) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id) bid,
                     h.snap_id eid,
                     CAST(s.begin_interval_time AS DATE) begin_date,
                     CAST(s.end_interval_time AS DATE) end_date,
                     h.value - LAG(h.value) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id) value,
                     s.startup_time - LAG(s.startup_time) OVER (PARTITION BY h.dbid, h.instance_number, h.stat_id ORDER BY h.snap_id) startup_time_interval
                FROM &&awr_object_prefix.sys_time_model h,
                     &&awr_object_prefix.snapshot s
               WHERE h.instance_number = i.instance_number
                 AND h.stat_name IN ('DB time', 'background elapsed time')
                 AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
                 AND h.dbid = &&edb360_dbid.
                 AND s.snap_id = h.snap_id
                 AND s.dbid = h.dbid
                 AND s.instance_number = h.instance_number
                 AND s.end_interval_time - s.begin_interval_time > TO_DSINTERVAL('+00 00:01:00.000000') -- exclude snaps less than 1m appart
                 --AND s.end_interval_time BETWEEN TO_TIMESTAMP('&&edb360_date_to.', '&&edb360_date_format.') - TO_DSINTERVAL('+&&history_days. 00:00:00.000000') AND TO_TIMESTAMP('&&edb360_date_to.', '&&edb360_date_format.') -- includes all options
                 --AND s.end_interval_time BETWEEN TO_TIMESTAMP('&&edb360_date_from.', '&&edb360_date_format.') AND TO_TIMESTAMP('&&edb360_date_to.', '&&edb360_date_format.') -- includes all options
              ),
              expensive AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ dbid, bid, eid, begin_date, end_date, SUM(value) value
                FROM expensive2
               WHERE startup_time_interval = TO_DSINTERVAL('+00 00:00:00.000000') -- include only snaps from same startup
                 AND value > 0
               GROUP BY
                     dbid, bid, eid, begin_date, end_date
              ),
              max_&&hist_work_days.wd1 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 AND &&history_days. > 10
                 AND &&edb360_max_work_days_peaks. >= 1
              ),
              max_&&hist_work_days.wd2 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 AND &&history_days. > 10
                 AND &&edb360_max_work_days_peaks. >= 2
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1)
              ),
              max_&&hist_work_days.wd3 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 AND &&history_days. > 10
                 AND &&edb360_max_work_days_peaks. >= 3
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd2)
              ),
              min_&&hist_work_days.wd AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MIN(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 AND &&history_days. > 10
                 AND &&edb360_min_work_days_peaks. >= 1
              ),
              max_&&history_days.d1 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND &&history_days. > 10
                 AND &&edb360_max_history_peaks. >= 1
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd2
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd3)
              ),
              max_&&history_days.d2 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND &&history_days. > 10
                 AND &&edb360_max_history_peaks. >= 2
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1
                                   UNION 
                                   SELECT value FROM max_&&hist_work_days.wd2
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd3
                                   UNION
                                   SELECT value FROM max_&&history_days.d1)
              ),
              max_&&history_days.d3 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND &&history_days. > 10
                 AND &&edb360_max_history_peaks. >= 3
                 AND value NOT IN (SELECT value FROM max_&&hist_work_days.wd1
                                   UNION 
                                   SELECT value FROM max_&&hist_work_days.wd2
                                   UNION
                                   SELECT value FROM max_&&hist_work_days.wd3
                                   UNION
                                   SELECT value FROM max_&&history_days.d1
                                   UNION
                                   SELECT value FROM max_&&history_days.d2)
              ),
              med_&&history_days.d AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - &&history_days. AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 -- avoids selecting same twice
                 AND &&history_days. > 10
                 AND &&edb360_med_history. >= 1
              ),
              max_5wd1 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 --AND &&history_days. > 10
                 AND &&edb360_max_5wd_peaks. >= 1
              ),
              max_5wd2 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 --AND &&history_days. > 10
                 AND &&edb360_max_5wd_peaks. >= 2
                 AND value NOT IN (SELECT value FROM max_5wd1)
              ),
              max_5wd3 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 --AND &&history_days. > 10
                 AND &&edb360_max_5wd_peaks. >= 3
                 AND value NOT IN (SELECT value FROM max_5wd1
                                   UNION
                                   SELECT value FROM max_5wd2)
              ),
              min_5wd AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MIN(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 AND TO_CHAR(end_date, 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
                 AND TO_CHAR(end_date, 'HH24MM') BETWEEN '&&edb360_conf_work_time_from.' AND '&&edb360_conf_work_time_to.' 
                 --AND &&history_days. > 10
                 AND &&edb360_min_5wd_peaks. >= 1
              ),
              max_7d1 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 --AND &&history_days. > 10
                 AND &&edb360_max_7d_peaks. >= 1
                 AND value NOT IN (SELECT value FROM max_5wd1
                                   UNION
                                   SELECT value FROM max_5wd2
                                   UNION
                                   SELECT value FROM max_5wd3)
              ),
              max_7d2 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 --AND &&history_days. > 10
                 AND &&edb360_max_7d_peaks. >= 2
                 AND value NOT IN (SELECT value FROM max_5wd1
                                   UNION
                                   SELECT value FROM max_5wd2
                                   UNION
                                   SELECT value FROM max_5wd3
                                   UNION
                                   SELECT value FROM max_7d1)
              ),
              max_7d3 AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MAX(value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 --AND &&history_days. > 10
                 AND &&edb360_max_7d_peaks. >= 3
                 AND value NOT IN (SELECT value FROM max_5wd1
                                   UNION
                                   SELECT value FROM max_5wd2
                                   UNION
                                   SELECT value FROM max_5wd3
                                   UNION
                                   SELECT value FROM max_7d1
                                   UNION
                                   SELECT value FROM max_7d2)
              ),
              med_7d AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY value) value
                FROM expensive
               WHERE end_date BETWEEN TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - 8 AND TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') /* -1 */ -- avoids selecting same twice
                 --AND &&history_days. > 10
                 AND &&edb360_med_7d. >= 1
              ),
              small_range AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&hist_work_days.wd1' rep, 50 ob
                FROM expensive e,
                     max_&&hist_work_days.wd1 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&hist_work_days.wd2' rep, 53 ob
                FROM expensive e,
                     max_&&hist_work_days.wd2 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&hist_work_days.wd3' rep, 56 ob
                FROM expensive e,
                     max_&&hist_work_days.wd3 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'min&&hist_work_days.wd' rep, 100 ob
                FROM expensive e,
                     min_&&hist_work_days.wd m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&history_days.d1' rep, 60 ob
                FROM expensive e,
                     max_&&history_days.d1 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&history_days.d2' rep, 63 ob
                FROM expensive e,
                     max_&&history_days.d2 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max&&history_days.d3' rep, 66 ob
                FROM expensive e,
                     max_&&history_days.d3 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'med&&history_days.d' rep, 80 ob
                FROM expensive e,
                     med_&&history_days.d m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'med&&history_days.d' rep, 15 ob
                FROM expensive e,
                     med_&&history_days.d m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max5wd1' rep, 30 ob
                FROM expensive e,
                     max_5wd1 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max5wd2' rep, 33 ob
                FROM expensive e,
                     max_5wd2 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max5wd3' rep, 36 ob
                FROM expensive e,
                     max_5wd3 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'min5wd' rep, 90 ob
                FROM expensive e,
                     min_5wd m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max7d1' rep, 40 ob
                FROM expensive e,
                     max_7d1 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max7d2' rep, 43 ob
                FROM expensive e,
                     max_7d2 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'max7d3' rep, 46 ob
                FROM expensive e,
                     max_7d3 m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'med7d' rep, 70 ob
                FROM expensive e,
                     med_7d m
               WHERE m.value = e.value
               UNION
              SELECT /*+ &&sq_fact_hints. &&section_id. */ e.dbid, e.bid, e.eid, e.begin_date, e.end_date, 'med7d' rep, 10 ob
                FROM expensive e,
                     med_7d m
               WHERE m.value = e.value
              ),
              max_&&history_days.d AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MIN(dbid) dbid, MIN(bid) bid, MAX(eid) eid, MIN(begin_date) begin_date, MAX(end_date) end_date, 'max&&history_days.d' rep, 69 ob
                FROM small_range
               WHERE rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 
                             'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 
                             'max5wd1', 'max5wd2', 'max5wd3', 
                             'max7d1', 'max7d2', 'max7d3')
                 AND &&history_days. > 10
              HAVING COUNT(*) > 0
              ),
              max_7d AS (
              SELECT /*+ &&sq_fact_hints. &&section_id. */ MIN(dbid) dbid, MIN(bid) bid, MAX(eid) eid, MIN(begin_date) begin_date, MAX(end_date) end_date, 'max7d' rep, 49 ob
                FROM small_range
               WHERE rep IN ('max5wd1', 'max5wd2', 'max5wd3', 
                             'max7d1', 'max7d2', 'max7d3')
                 --AND &&history_days. > 10
              HAVING COUNT(*) > 0
              )
              SELECT dbid, bid, eid, begin_date, end_date, rep, ob
                FROM small_range
               UNION ALL
              SELECT dbid, bid, eid, begin_date, end_date, rep, ob
                FROM max_&&history_days.d
               WHERE '&&edb360_conf_incl_awr_range_rpt.' = 'Y'
               UNION ALL
              SELECT dbid, bid, eid, begin_date, end_date, rep, ob
                FROM max_7d
               WHERE '&&edb360_conf_incl_awr_range_rpt.' = 'Y'
               ORDER BY 7)
    LOOP
      IF j.ob < 20 THEN
        IF j.rep = 'med7d' THEN
          put_line('EXEC :lv_m1_begin_date := '''||TO_CHAR(j.begin_date, 'YYYYMMDDHH24MISS')||''';');
          put_line('EXEC :lv_m1_end_date := '''||TO_CHAR(j.end_date, 'YYYYMMDDHH24MISS')||''';');
          put_line('EXEC :lv_m1_dbid := '||j.dbid||';');
          put_line('EXEC :lv_m1_bid := '||j.bid||';');
          put_line('EXEC :lv_m1_eid := '||j.eid||';');
          put_line('EXEC :lv_m1_inst_num := '||i.instance_number||';');
          put_line('EXEC :lv_m1_rep := '''||j.rep||''';');
          l_title_m1 := i.instance_number||'_'||j.bid||'_'||j.eid||'_'||j.rep;
        ELSIF j.rep = 'med&&history_days.d' THEN
          put_line('EXEC :lv_m2_begin_date := '''||TO_CHAR(j.begin_date, 'YYYYMMDDHH24MISS')||''';');
          put_line('EXEC :lv_m2_end_date := '''||TO_CHAR(j.end_date, 'YYYYMMDDHH24MISS')||''';');
          put_line('EXEC :lv_m2_dbid := '||j.dbid||';');
          put_line('EXEC :lv_m2_bid := '||j.bid||';');
          put_line('EXEC :lv_m2_eid := '||j.eid||';');
          put_line('EXEC :lv_m2_inst_num := '||i.instance_number||';');
          put_line('EXEC :lv_m2_rep := '''||j.rep||''';');
          l_title_m2 := i.instance_number||'_'||j.bid||'_'||j.eid||'_'||j.rep;
        END IF;
      ELSIF j.ob >= 20 THEN
        put_line('EXEC :lv_begin_date := '''||TO_CHAR(j.begin_date, 'YYYYMMDDHH24MISS')||''';');
        put_line('EXEC :lv_end_date := '''||TO_CHAR(j.end_date, 'YYYYMMDDHH24MISS')||''';');
        put_line('EXEC :lv_dbid := '||j.dbid||';');
        put_line('EXEC :lv_bid := '||j.bid||';');
        put_line('EXEC :lv_eid := '||j.eid||';');
        put_line('EXEC :lv_inst_num := '||i.instance_number||';');
        put_line('EXEC :lv_rep := '''||j.rep||''';');
        
        -- main report
        put_line('-- update main report');
        put_line('SPO &&edb360_main_report..html APP;');
        put_line('PRO <li>'||i.instance_number||'_'||j.bid||'_'||j.eid||'_'||j.rep||' <small><em>('||TO_CHAR(j.begin_date,'&&edb360_date_format.')||' to '||TO_CHAR(j.end_date,'&&edb360_date_format.')||')</em></small><br />');
        put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
        put_line('SPO OFF;');
        put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
        put_line('EXEC :repo_seq := :repo_seq + 1;');
        put_line('SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;');
  
        -- 12c perfhub
        IF '&&edb360_conf_incl_perfhub.' = 'Y' AND '&&db_version.' >= '12' AND j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 'max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
          put_line('COL edb360_bypass NEW_V edb360_bypass;');
          put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
          l_standard_filename := 'perfhub_'||i.instance_number||'_'||j.bid||'_'||j.eid||'_'||j.rep;
          l_spool_filename := '&&common_edb360_prefix._'||l_standard_filename;
          put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
          put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
          put_line('-- update log');
          put_line('SPO &&edb360_log..txt APP;');
          put_line('PRO');
          put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          put_line('PRO');
          put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. '||l_spool_filename);
          put_line('SPO OFF;');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
          :file_seq := :file_seq + 1;
          l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
          update_log(l_one_spool_filename||'.html');
          put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
          put_line('SELECT /* &&section_id. */ DBMS_PERF.REPORT_PERFHUB(0,GREATEST(TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS'')-(12/24),TO_DATE(''&&edb360_date_from.'',''&&edb360_date_format.'')),LEAST(TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS'')+(12/24),TO_DATE(''&&edb360_date_to.'',''&&edb360_date_format.'')),TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS'')-(1/24),TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS'')+(1/24),:lv_inst_num,:lv_dbid) FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
          put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
          put_line('SPO OFF;');
          put_line('-- update main report');
          put_line('SPO &&edb360_main_report..html APP;');
          put_line('PRO <a href="'||l_one_spool_filename||'.html">perfhub html</a>');
          put_line('SPO OFF;');
          put_line('-- zip');
          put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
        END IF;

        -- awr one node
        IF '&&edb360_conf_incl_awr_rpt.' = 'Y' THEN 
          put_line('COL edb360_bypass NEW_V edb360_bypass;');
          put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
          l_standard_filename := 'awrrpt_'||i.instance_number||'_'||j.bid||'_'||j.eid||'_'||j.rep;
          l_spool_filename := '&&common_edb360_prefix._'||l_standard_filename;
          put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
          put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
          put_line('-- update log');
          put_line('SPO &&edb360_log..txt APP;');
          put_line('PRO');
          put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          put_line('PRO');
          put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. '||l_spool_filename);
          put_line('SPO OFF;');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
          
          IF '&&edb360_skip_html.' IS NULL THEN
            :file_seq := :file_seq + 1;
            l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
            update_log(l_one_spool_filename||'.html');
            put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
            put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_report_html(:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid,9)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
            put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
            put_line('SPO OFF;');
            put_line('-- update main report');
            put_line('SPO &&edb360_main_report..html APP;');
            put_line('PRO <a href="'||l_one_spool_filename||'.html">awr html</a>');
            put_line('SPO OFF;');
            put_line('-- zip');
            put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
            put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            
            IF '&&edb360_conf_incl_awr_diff_rpt.' = 'Y' AND j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 
                                                                      'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 
                                                                      'max5wd1', 'max5wd2', 'max5wd3', 
                                                                      'max7d1', 'max7d2', 'max7d3')
            THEN
              :file_seq := :file_seq + 1;
              l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename||'_diff';
              update_log(l_one_spool_filename||'.html');
              put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
              IF j.rep IN ('max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
                put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_diff_report_html(:lv_m1_dbid,:lv_m1_inst_num,:lv_m1_bid,:lv_m1_eid,:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              ELSIF j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3') THEN
                put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_diff_report_html(:lv_m2_dbid,:lv_m2_inst_num,:lv_m2_bid,:lv_m2_eid,:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              END IF;
              put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
              put_line('SPO OFF;');
              put_line('-- update main report');
              put_line('SPO &&edb360_main_report..html APP;');
              IF j.rep IN ('max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
                put_line('PRO <a title="DIFF with '||l_title_m1||' AWR" href="'||l_one_spool_filename||'.html">awr diff html</a>');
              ELSIF j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3') THEN
                put_line('PRO <a title="DIFF with '||l_title_m2||' AWR" href="'||l_one_spool_filename||'.html">awr diff html</a>');
              END IF;
              put_line('SPO OFF;');
              put_line('-- zip');
              put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
              put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            END IF;
          END IF;
          
          IF '&&edb360_skip_text.' IS NULL THEN
            :file_seq := :file_seq + 1;
            l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
            update_log(l_one_spool_filename||'.txt');
            put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.txt;');
            put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_report_text(:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid,9)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
            put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
            put_line('SPO OFF;');
            put_line('-- update main report');
            put_line('SPO &&edb360_main_report..html APP;');
            put_line('PRO <a href="'||l_one_spool_filename||'.txt">awr text</a>');
            put_line('SPO OFF;');
            put_line('-- zip');
            put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.txt >> &&edb360_log3..txt');
            put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            
            IF '&&edb360_conf_incl_awr_diff_rpt.' = 'Y' AND j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 
                                                                      'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3', 
                                                                      'max5wd1', 'max5wd2', 'max5wd3', 
                                                                      'max7d1', 'max7d2', 'max7d3')
            THEN
              :file_seq := :file_seq + 1;
              l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename||'_diff';
              update_log(l_one_spool_filename||'.txt');
              put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.txt;');
              IF j.rep IN ('max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
                put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_diff_report_text(:lv_m1_dbid,:lv_m1_inst_num,:lv_m1_bid,:lv_m1_eid,:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              ELSIF j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3') THEN
                put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_diff_report_text(:lv_m2_dbid,:lv_m2_inst_num,:lv_m2_bid,:lv_m2_eid,:lv_dbid,:lv_inst_num,:lv_bid,:lv_eid)) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              END IF;
              put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
              put_line('SPO OFF;');
              put_line('-- update main report');
              put_line('SPO &&edb360_main_report..html APP;');
              IF j.rep IN ('max5wd1', 'max5wd2', 'max5wd3', 'max7d1', 'max7d2', 'max7d3') THEN
                put_line('PRO <a title="DIFF with '||l_title_m1||' AWR" href="'||l_one_spool_filename||'.txt">awr diff txt</a>');
              ELSIF j.rep IN ('max&&hist_work_days.wd1', 'max&&hist_work_days.wd2', 'max&&hist_work_days.wd3', 'max&&history_days.d1', 'max&&history_days.d2', 'max&&history_days.d3') THEN
                put_line('PRO <a title="DIFF with '||l_title_m2||' AWR" href="'||l_one_spool_filename||'.txt">awr diff txt</a>');
              END IF;
              put_line('SPO OFF;');
              put_line('-- zip');
              put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.txt >> &&edb360_log3..txt');
              put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            END IF;
          END IF;
       END IF;
  
        -- addm one node
        IF '&&edb360_conf_incl_addm_rpt.' = 'Y' THEN 
          put_line('COL edb360_bypass NEW_V edb360_bypass;');
          put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
          put_line('VAR l_task_name VARCHAR2(30);');
          put_line('BEGIN');
          put_line('  :l_task_name := ''ADDM_''||TO_CHAR(SYSDATE, ''YYYYMMDD_HH24MISS'');');
          put_line('  DBMS_ADVISOR.CREATE_TASK(advisor_name => ''ADDM'', task_name =>  :l_task_name);');
          put_line('  DBMS_ADVISOR.SET_TASK_PARAMETER(task_name => :l_task_name, parameter => ''START_SNAPSHOT'', value => :lv_bid);');
          put_line('  DBMS_ADVISOR.SET_TASK_PARAMETER(task_name => :l_task_name, parameter => ''END_SNAPSHOT'', value => :lv_eid);');
          put_line('  DBMS_ADVISOR.SET_TASK_PARAMETER(task_name => :l_task_name, parameter => ''DB_ID'', value => :lv_dbid);');
          put_line('  DBMS_ADVISOR.SET_TASK_PARAMETER(task_name => :l_task_name, parameter => ''INSTANCE'', value => :lv_inst_num);');
          put_line('  '||CHR(38)||CHR(38)||'edb360_bypass.DBMS_ADVISOR.EXECUTE_TASK(task_name => :l_task_name);');
          put_line('END;');
          put_line('/');
          put_line('PRINT l_task_name;');
          l_standard_filename := 'addmrpt_'||i.instance_number||'_'||j.bid||'_'||j.eid||'_'||j.rep;
          l_spool_filename := '&&common_edb360_prefix._'||l_standard_filename;
          put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
          put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
          put_line('-- update log');
          put_line('SPO &&edb360_log..txt APP;');
          put_line('PRO');
          put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          put_line('PRO');
          put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. '||l_spool_filename);
          put_line('SPO OFF;');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
          put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
          --IF '&&edb360_skip_text.' IS NULL THEN
            :file_seq := :file_seq + 1;
            l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
            update_log(l_one_spool_filename||'.txt');
            put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.txt;');
            put_line('SELECT /* &&section_id. */ DBMS_ADVISOR.get_task_report(:l_task_name) FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
            put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
            put_line('SPO OFF;');
            put_line('-- update main report');
            put_line('SPO &&edb360_main_report..html APP;');
            put_line('PRO <a href="'||l_one_spool_filename||'.txt">addm text</a>');
            put_line('SPO OFF;');
            put_line('-- zip');
            put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.txt >> &&edb360_log3..txt');
            put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
          --END IF;
          put_line('EXEC DBMS_ADVISOR.DELETE_TASK(task_name => :l_task_name);');
        END IF;
    
        -- ash one node
        IF ('&&edb360_conf_incl_ash_rpt.' = 'Y' OR '&&edb360_conf_incl_ash_analy_rpt.' = 'Y') THEN 
          put_line('COL edb360_bypass NEW_V edb360_bypass;');
          put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
          l_standard_filename := 'ashrpt_'||i.instance_number||'_'||j.bid||'_'||j.eid||'_'||j.rep;
          l_spool_filename := '&&common_edb360_prefix._'||l_standard_filename;
          put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
          put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
          put_line('-- update log');
          put_line('SPO &&edb360_log..txt APP;');
          put_line('PRO');
          put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          put_line('PRO');
          put_line('PRO '||CHR(38)||CHR(38)||'hh_mm_ss. '||l_spool_filename);
          put_line('SPO OFF;');
          
          IF '&&edb360_skip_html.' IS NULL THEN
            IF '&&edb360_conf_incl_ash_rpt.' = 'Y' THEN
              :file_seq := :file_seq + 1;
              l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
              update_log(l_one_spool_filename||'.html');
              put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
              put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.ash_report_html(:lv_dbid,:lv_inst_num,TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS''),TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS''))) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
              put_line('SPO OFF;');
              put_line('-- update main report');
              put_line('SPO &&edb360_main_report..html APP;');
              put_line('PRO <a href="'||l_one_spool_filename||'.html">ash html</a>');
              put_line('SPO OFF;');
              put_line('-- zip');
              put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
              put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            END IF;
            
            IF '&&edb360_conf_incl_ash_analy_rpt.' = 'Y' AND '&&db_version.' >= '12.1' THEN
              :file_seq := :file_seq + 1;
              l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename||'_analy';
              update_log(l_one_spool_filename||'.html');
              put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.html;');
              put_line('SELECT /* &&section_id. */ DBMS_WORKLOAD_REPOSITORY.ash_report_analytics(:lv_dbid,:lv_inst_num,TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS''),TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS'')) FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
              put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
              put_line('SPO OFF;');
              put_line('-- update main report');
              put_line('SPO &&edb360_main_report..html APP;');
              put_line('PRO <a href="'||l_one_spool_filename||'.html">ash analy html</a>');
              put_line('SPO OFF;');
              put_line('-- zip');
              put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.html >> &&edb360_log3..txt');
              put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
            END IF;
          END IF;
          IF '&&edb360_skip_text.' IS NULL THEN
            :file_seq := :file_seq + 1;
            l_one_spool_filename := LPAD(:file_seq, 5, '0')||'_'||l_spool_filename;
            update_log(l_one_spool_filename||'.txt');
            put_line('SPO &&edb360_output_directory.'||l_one_spool_filename||'.txt;');
            put_line('SELECT output /* &&section_id. */ FROM TABLE(DBMS_WORKLOAD_REPOSITORY.ash_report_text(:lv_dbid,:lv_inst_num,TO_DATE(:lv_begin_date,''YYYYMMDDHH24MISS''),TO_DATE(:lv_end_date,''YYYYMMDDHH24MISS''))) WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NULL;');
            put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
            put_line('SPO OFF;');
            put_line('-- update main report');
            put_line('SPO &&edb360_main_report..html APP;');
            put_line('PRO <a href="'||l_one_spool_filename||'.txt">ash text</a>');
            put_line('SPO OFF;');
            put_line('-- zip');
            put_line('HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.'||l_one_spool_filename||'.txt >> &&edb360_log3..txt');
            put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
          END IF;
        END IF;
  
        -- main report
        put_line('-- update main report');
        put_line('SPO &&edb360_main_report..html APP;');
        put_line('PRO </li>');
        put_line('SPO OFF;');
        put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
      END IF;
    END LOOP;
  END LOOP;
END;
/
SPO OFF;
SET TERM ON;
PRO Please wait ...
SET TERM OFF; 
@&&edb360_output_directory.99910_&&common_edb360_prefix._rpt_driver.sql;
SET SERVEROUT OFF HEAD ON PAGES &&def_max_rows.;
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.99910_&&common_edb360_prefix._rpt_driver.sql >> &&edb360_log3..txt

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
