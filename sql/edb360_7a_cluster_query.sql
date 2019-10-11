              WITH
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