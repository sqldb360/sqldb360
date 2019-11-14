-- section to report. null means all (default)
-- report column, or section, or range of columns or range of sections i.e. 3, 3-4, 3a, 3a-4c, 3-4c, 3c-4
DEF edb360_sections = '';

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

DEF edb360_conf_incl_awr_diff_rpt = 'N';
DEF edb360_conf_incl_plot_awr ='Y';
DEF edb360_conf_series_selection ='Y';