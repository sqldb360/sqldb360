-- edb360 configuration parameters for oci
DEF edb360_output_directory = '/tmp/';
DEF edb360_host_name_separator = '.';
DEF edb360_host_name_position = '1';
DEF edb360_host_name_occurrence = '2';
DEF edb360_conf_days = '61';
DEF edb360_conf_incl_dbname_index = 'Y';
DEF edb360_conf_incl_dbname_file = 'Y';
DEF edb360_conf_incl_eadam = 'N';
DEF edb360_conf_top_cur = '0';
DEF edb360_conf_top_sig = '0';
--DEF edb360_max_work_days_peaks = 2;
--DEF edb360_min_work_days_peaks = 0;
--DEF edb360_max_history_peaks = 2;
--DEF edb360_med_history = 0;
--DEF edb360_max_5wd_peaks = 2;
--DEF edb360_min_5wd_peaks = 0;
--DEF edb360_max_7d_peaks = 2;
--DEF edb360_med_7d = 0;
DEF edb360_conf_incl_awr_diff_rpt = 'N';
DEF skip_esp_and_escp = '--skip--';

-- sqld360 configuration parameters for bmcs
DEF sqld360_conf_incl_cboenv = 'N';
DEF sqld360_conf_incl_sqlmon = 'N';
DEF sqld360_conf_incl_ash_hist = 'N';
DEF sqld360_conf_incl_eadam = 'N';
DEF sqld360_conf_incl_rawash = 'N';
DEF sqld360_conf_incl_stats_h = 'N';
DEF sqld360_conf_incl_metadata = 'N';
DEF sqld360_conf_incl_sta = 'N';
DEF sqld360_conf_awr_timescale = 's';

-- additional transient parameters
DEF edb360_sections = '';
