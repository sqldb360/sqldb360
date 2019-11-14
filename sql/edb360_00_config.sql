-- edb360 configuration file. for those cases where you must change edb360 functionality

/*************************** ok to modify (if really needed) ****************************/

-- section to report. null means all (default)
-- report column, or section, or range of columns or range of sections i.e. 3, 3-4, 3a, 3a-4c, 3-4c, 3c-4
DEF edb360_sections = '';

-- edb360 trace
DEF sql_trace_level = '1';

-- history days (default 31)
-- if you have an AWR retention of lets say 100 days, and want to report on 60 then pass 60
-- if you want to limit reporting to one day (who knowns why) then pass 1
DEF edb360_conf_days = '31';

-- range of dates below superceed history days when values are other than YYYY-MM-DD
-- default values YYYY-MM-DD mean: use edb360_conf_days
-- actual values sample: 2016-04-26
DEF edb360_conf_date_from = 'YYYY-MM-DD';
DEF edb360_conf_date_to = 'YYYY-MM-DD';

-- working hours are defined between these two HH24MM values (i.e. 7:30AM and 7:30PM)
-- these hours are used to categorize "user" load between 7:30 AM and 7:30 pm
-- edb360 would produce some reports looking at load during "user" time below
DEF edb360_conf_work_time_from = '0730';
DEF edb360_conf_work_time_to = '1930';

-- working days are defined between 1 (Sunday) and 7 (Saturday) (default Mon-Fri)
DEF edb360_conf_work_day_from = '2';
DEF edb360_conf_work_day_to = '6';

-- maximum time in hours to allow edb360 to execute (default 24 hrs)
DEF edb360_conf_max_hours = '24';

-- Charts width in pixels (px) or %
DEF edb360_chart_width = '809px'

-- include database name on index page (default N)
DEF edb360_conf_incl_dbname_index = 'N';

-- include database name on zip filename (default N)
DEF edb360_conf_incl_dbname_file = 'N';

-- include GV$ACTIVE_SESSION_HISTORY (default N)
DEF edb360_conf_incl_ash_mem = 'N';

-- include GV$SQL_MONITOR (default N)
DEF edb360_conf_incl_sql_mon = 'N';

-- include GV$SYSSTAT (default Y)
DEF edb360_conf_incl_stat_mem = 'Y';

-- include GV$PX and GV$PQ (default Y)
DEF edb360_conf_incl_px_mem = 'Y';

-- include DBA_SEGMENTS on queries with no filter on segment_name (default Y)
-- note: some releases of Oracle produce suboptimal plans when no segment_name is passed
DEF edb360_conf_incl_segments = 'Y';

-- include DBA_SOURCE
-- note: applications such as EBS may take long to query such views
DEF edb360_conf_incl_source = 'Y';

-- include DBMS_METADATA calls (default Y)
-- note: some releases of Oracle take very long to generate metadata
DEF edb360_conf_incl_metadata = 'Y';

-- include eAdam for top SQL and peak snaps (default Y)
DEF edb360_conf_incl_eadam = 'Y';

-- limits the size of ASH extracted by eAdam
DEF edb360_eadam_row_limit = 10000000;

-- tool repository. set only if edb360 or eadam repository has been created
DEF tool_repo_user = '';

-- output directory for most staging files part of the zip (e.g.: "" or "./" or "/tmp/" or "/home/oracle/csierra/edb360/prod/")
DEF edb360_output_directory = '';

-- move generated edb360 zip file to directory (e.g.: "" or "./" or "/tmp/" or "/home/oracle/csierra/edb360/prod/")
DEF edb360_move_directory = '';

-- use only if you have to skip esp and escp (value --skip--) else null
--DEF skip_esp_and_escp = '--skip--';
DEF skip_esp_and_escp = '';

-- use if you need tool to act on a dbid stored on AWR, but that is not the current v$database.dbid
DEF edb360_config_dbid = '';

-- the following 3 allow the display of host_name suffix on charts
-- for example, to display ad2.r1 when host_name is iod-db-kiev-02008.node.ad2.r1, set them to 
-- separator = '.', position = '1' and occurrence = '2'
-- when all 3 are null then host_name suffix remains null
DEF edb360_host_name_separator = '';
DEF edb360_host_name_position = '';
DEF edb360_host_name_occurrence = '';

/**************************** not recommended to modify *********************************/

-- excluding report types reduce usability while providing marginal performance gain
DEF edb360_conf_incl_html = 'Y';
DEF edb360_conf_incl_xml  = 'N';
DEF edb360_conf_incl_text = 'N';
DEF edb360_conf_incl_csv  = 'N';
DEF edb360_conf_incl_line = 'Y';
DEF edb360_conf_incl_pie  = 'Y';
DEF edb360_conf_incl_bar  = 'Y';

-- excluding awr reports substantially reduces usability with minimal performance gain
DEF edb360_conf_incl_perfhub = 'Y';
DEF edb360_conf_incl_awr_rpt = 'Y';
DEF edb360_conf_incl_awr_diff_rpt = 'Y'; 
DEF edb360_conf_incl_awr_range_rpt = 'N';
DEF edb360_conf_incl_addm_rpt = 'N';
DEF edb360_conf_incl_ash_rpt = 'N';
DEF edb360_conf_incl_ash_analy_rpt = 'N';
DEF edb360_conf_incl_tkprof = 'Y';

DEF edb360_conf_incl_plot_awr ='N'; 
DEF edb360_conf_series_selection ='N';

-- up to how many max peaks to consider for reports for entire history work days (between 0 and 3)
DEF edb360_max_work_days_peaks = 3;
-- consider min peaks for entire history work days reports? (0 or 1)
DEF edb360_min_work_days_peaks = 1;
-- up to how many max peaks to consider for reports for entire history (between 0 and 3)
DEF edb360_max_history_peaks = 3;
-- consider median for entire history reports? (0 or 1)
DEF edb360_med_history = 1;
-- up to how many max peaks to consider for reports for last 5 work days (between 0 and 3)
DEF edb360_max_5wd_peaks = 3;
-- consider min peaks for last 5 work days reports? (0 or 1)
DEF edb360_min_5wd_peaks = 1;
-- up to how many max peaks to consider for reports for last 7 days (between 0 and 3)
DEF edb360_max_7d_peaks = 3;
-- consider median for last 7 days reports? (0 or 1)
DEF edb360_med_7d = 1;

-- top sql to execute further diagnostics (range 0-128)
DEF edb360_conf_top_sql = '16';
DEF edb360_conf_top_cur = '2';
DEF edb360_conf_top_sig = '2';
DEF edb360_conf_planx_top = '16';
DEF edb360_conf_sqlmon_top = '0';
DEF edb360_conf_sqlash_top = '0';
DEF edb360_conf_sqlhc_top = '0';
DEF edb360_conf_sqld360_top = '8';
DEF edb360_conf_sqld360_top_tc = '0';

/*********************************** must match repo ************************************/

-- prefix for AWR "dba_hist_" views
DEF tool_prefix_1 = 'dba_hist#';
-- prefix for data dictionary "dba_" views
DEF tool_prefix_2 = 'dba#';
-- prefix for dynamic "gv$" views
DEF tool_prefix_3 = 'gv#';
-- prefix for dynamic "v$" views
DEF tool_prefix_4 = 'v#';

/************************************ modifications *************************************/

-- If you need to modify any parameter create a new custom configuration file with a
-- subset of the DEF above, and place on same edb360-master/sql directory; then when
-- you execute edb360.sql, pass on second parameter the name of your configuration file

