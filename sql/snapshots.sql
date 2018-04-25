SELECT s.snap_id,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI:SS') end_time
  FROM dba_hist_snapshot s
 ORDER BY
       s.snap_id;