@@&&edb360_0g.tkprof.sql
DEF section_id = '6n';
DEF section_name = 'Active Session History (ASH) - Top PDBs - Time Series';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text_backup := q'[
SELECT /*+ &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(CASE WHEN con_id IN
       (@con_id_01@, @con_id_02@, @con_id_03@, @con_id_04@, @con_id_05@, @con_id_06@, @con_id_07@, @con_id_08@, @con_id_09@, @con_id_10@, @con_id_11@, @con_id_12@, @con_id_13@, @con_id_14@)
       THEN 0 ELSE 10 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "Others",
       ROUND(SUM(CASE con_id WHEN @con_id_01@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_01@",
       ROUND(SUM(CASE con_id WHEN @con_id_02@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_02@",
       ROUND(SUM(CASE con_id WHEN @con_id_03@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_03@",
       ROUND(SUM(CASE con_id WHEN @con_id_04@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_04@",
       ROUND(SUM(CASE con_id WHEN @con_id_05@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_05@",
       ROUND(SUM(CASE con_id WHEN @con_id_06@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_06@",
       ROUND(SUM(CASE con_id WHEN @con_id_07@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_07@",
       ROUND(SUM(CASE con_id WHEN @con_id_08@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_08@",
       ROUND(SUM(CASE con_id WHEN @con_id_09@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_09@",
       ROUND(SUM(CASE con_id WHEN @con_id_10@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_10@",
       ROUND(SUM(CASE con_id WHEN @con_id_11@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_11@",
       ROUND(SUM(CASE con_id WHEN @con_id_12@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_12@",
       ROUND(SUM(CASE con_id WHEN @con_id_13@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_13@",
       ROUND(SUM(CASE con_id WHEN @con_id_14@ THEN 10 ELSE 0 END) / ROUND(GREATEST(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE), (1/24/3600)) * 24 * 60 * 60), 3) "@pdb_name_14@"
  FROM &&awr_object_prefix.active_sess_history h
 WHERE @filter_predicate@
   AND &&edb360_con_id. < 2
   AND con_id > 1
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 1, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;

DEF filter_predicate = 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PDBs for Cluster for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top PDBs for Instance 1 for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top PDBs for Instance 2 for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top PDBs for Instance 3 for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top PDBs for Instance 4 for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top PDBs for Instance 5 for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top PDBs for Instance 6 for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top PDBs for Instance 7 for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top PDBs for Instance 8 for 1 day';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS')||', and between &&edb360_conf_work_time_from. and &&edb360_conf_work_time_to. hours' between_times FROM DUAL;

DEF filter_predicate = 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PDBs for Cluster for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top PDBs for Instance 1 for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top PDBs for Instance 2 for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top PDBs for Instance 3 for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top PDBs for Instance 4 for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top PDBs for Instance 5 for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top PDBs for Instance 6 for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top PDBs for Instance 7 for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top PDBs for Instance 8 for 5 working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;

DEF filter_predicate = 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PDBs for Cluster for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top PDBs for Instance 1 for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top PDBs for Instance 2 for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top PDBs for Instance 3 for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top PDBs for Instance 4 for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top PDBs for Instance 5 for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top PDBs for Instance 6 for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top PDBs for Instance 7 for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND sample_time BETWEEN TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_TIMESTAMP(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top PDBs for Instance 8 for 7 days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT '&&between_dates., and between &&edb360_conf_work_time_from. and &&edb360_conf_work_time_to. hours' between_times FROM DUAL;

DEF filter_predicate = 'TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PDBs for Cluster for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 1 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top PDBs for Instance 1 for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 2 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top PDBs for Instance 2 for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 3 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top PDBs for Instance 3 for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 4 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top PDBs for Instance 4 for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 5 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top PDBs for Instance 5 for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 6 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top PDBs for Instance 6 for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 7 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top PDBs for Instance 7 for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 8 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8 AND TO_CHAR(sample_time, ''D'') BETWEEN ''&&edb360_conf_work_day_from.'' AND ''&&edb360_conf_work_day_to.'' AND TO_CHAR(sample_time, ''HH24'') BETWEEN ''&&edb360_conf_work_time_from.'' AND ''&&edb360_conf_work_time_to.''');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top PDBs for Instance 8 for &&hist_work_days. working days';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

SELECT '&&between_dates.' between_times FROM DUAL;

DEF filter_predicate = '1 = 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');

DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PDBs for Cluster for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top PDBs for Instance 1 for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top PDBs for Instance 2 for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top PDBs for Instance 3 for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top PDBs for Instance 4 for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top PDBs for Instance 5 for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top PDBs for Instance 6 for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top PDBs for Instance 7 for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

--

DEF filter_predicate = 'instance_number = 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8');

DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top PDBs for Instance 8 for &&history_days. days of history';

@@&&skip_all.edb360_6n_ash_pdbs_ts_aux.sql
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
