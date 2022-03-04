DEF edb360_vYYNN = 'v203';
DEF edb360_vrsn = '&&edb360_vYYNN. (2022-02-16)';
DEF edb360_copyright = ' (c) 2022';

SET TERM OFF;
-- watchdog
VAR edb360_time0 NUMBER;
VAR edb360_max_seconds NUMBER;
EXEC :edb360_time0 := DBMS_UTILITY.GET_TIME;
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
EXEC :edb360_max_seconds := &&edb360_conf_max_hours. * 3600;
COL edb360_bypass NEW_V edb360_bypass;
SELECT NULL edb360_bypass FROM DUAL;

-- data dictionary views for tool repository. do not change values. this piece must execute after processing configuration scripts
DEF awr_hist_prefix = 'DBA_HIST_';
DEF awr_object_prefix = 'dba_hist_';
DEF dva_view_prefix = 'DBA_';
DEF dva_object_prefix = 'dba_';
DEF gv_view_prefix = 'GV$';
DEF gv_object_prefix = 'gv$';
DEF v_view_prefix = 'V$';
DEF v_object_prefix = 'v$';
-- when using a repository change then view prefixes
COL awr_object_prefix NEW_V awr_object_prefix;
COL dva_object_prefix NEW_V dva_object_prefix;
COL gv_object_prefix NEW_V gv_object_prefix;
COL v_object_prefix NEW_V v_object_prefix;
SELECT CASE WHEN '&&tool_repo_user.' IS NULL THEN '&&awr_object_prefix.' ELSE '&&tool_repo_user..&&tool_prefix_1.' END awr_object_prefix,
       CASE WHEN '&&tool_repo_user.' IS NULL THEN '&&dva_object_prefix.' ELSE '&&tool_repo_user..&&tool_prefix_2.' END dva_object_prefix,
       CASE WHEN '&&tool_repo_user.' IS NULL THEN '&&gv_object_prefix.'  ELSE '&&tool_repo_user..&&tool_prefix_3.' END gv_object_prefix,
       CASE WHEN '&&tool_repo_user.' IS NULL THEN '&&v_object_prefix.'   ELSE '&&tool_repo_user..&&tool_prefix_4.' END v_object_prefix
  FROM DUAL
/

@@moat369_fc_oracle_version
-- get dbid --in a CDB or PDB this will be the DBID of the container
COL edb360_dbid NEW_V edb360_dbid;
SELECT TRIM(TO_CHAR(NVL(TO_NUMBER('&&edb360_config_dbid.'), dbid))) edb360_dbid FROM &&v_object_prefix.database;

--dmk 31.1.2019 if in PDB work with DBID of PDB in v$database.CON_DBID if there are PDB specific snapshots
&&skip_noncdb.SELECT TRIM(TO_CHAR(NVL(TO_NUMBER('&&edb360_config_dbid.'), v.con_dbid))) edb360_dbid FROM &&v_object_prefix.database v, dba_hist_snapshot s WHERE s.dbid = v.con_dbid AND rownum <= 1;

-- snaps
SELECT startup_time, dbid, instance_number, COUNT(*) snaps,
       MIN(begin_interval_time) min_time, MAX(end_interval_time) max_time,
       MIN(snap_id) min_snap_id, MAX(snap_id) max_snap_id
  FROM &&awr_object_prefix.snapshot
 WHERE dbid = &&edb360_dbid.
 GROUP BY
       startup_time, dbid, instance_number
 ORDER BY
       startup_time, dbid, instance_number
/

COL history_days NEW_V history_days;
-- range: takes at least 31 days and at most as many as actual history, with a default of 31. parameter restricts within that range.
SELECT TO_CHAR(LEAST(CEIL(SYSDATE - CAST(MIN(begin_interval_time) AS DATE)), GREATEST(31, TO_NUMBER(NVL(TRIM('&&edb360_conf_days.'), '31'))))) history_days FROM &&awr_object_prefix.snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&edb360_dbid.;
SELECT TO_CHAR(TO_DATE('&&edb360_conf_date_to.', 'YYYY-MM-DD') - TO_DATE('&&edb360_conf_date_from.', 'YYYY-MM-DD') + 1) history_days FROM DUAL WHERE '&&edb360_conf_date_from.' != 'YYYY-MM-DD' AND '&&edb360_conf_date_to.' != 'YYYY-MM-DD';
SELECT '0' history_days FROM DUAL WHERE NVL(TRIM('&&diagnostics_pack.'), 'N') = 'N';
SET TERM OFF;

-- Dates format
DEF edb360_date_format = 'YYYY-MM-DD"T"HH24:MI:SS';
DEF edb360_timestamp_format = 'YYYY-MM-DD"T"HH24:MI:SS.FF';
DEF edb360_timestamp_tz_format = 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM';

COL edb360_date_from NEW_V edb360_date_from;
COL edb360_date_to NEW_V edb360_date_to;
SELECT CASE '&&edb360_conf_date_from.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE - &&history_days., '&&edb360_date_format.') ELSE '&&edb360_conf_date_from.T00:00:00' END edb360_date_from FROM DUAL;
SELECT CASE '&&edb360_conf_date_to.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE, '&&edb360_date_format.') ELSE '&&edb360_conf_date_to.T23:59:59' END edb360_date_to FROM DUAL;

VAR hist_work_days NUMBER;
VAR hist_days NUMBER;
BEGIN
  :hist_days := ROUND(TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - TO_DATE('&&edb360_date_from.', '&&edb360_date_format.'));
  :hist_work_days := 0;
  FOR i IN 0 .. :hist_days - 1
  LOOP
    IF TO_CHAR(TO_DATE('&&edb360_date_from.', '&&edb360_date_format.') + i, 'D') BETWEEN TO_NUMBER('&&edb360_conf_work_day_from.') AND TO_NUMBER('&&edb360_conf_work_day_to.') THEN
      :hist_work_days := :hist_work_days + 1;
      dbms_output.put_line((TO_DATE('&&edb360_date_from.', '&&edb360_date_format.') + i)||' '||:hist_work_days);
    END IF;
  END LOOP;
END;
/
PRINT hist_work_days;
PRINT hist_days;
COL hist_work_days NEW_V hist_work_days;
SELECT TO_CHAR(:hist_work_days) hist_work_days FROM DUAL;

-- parameter edb360_sections: report column, or section, or range of columns or range of sections i.e. 3, 3-4, 3a, 3a-4c, 3-4c, 3c-4 (max length of 5)
VAR edb360_sec_from VARCHAR2(2);
VAR edb360_sec_to   VARCHAR2(2);
VAR edb360_sections VARCHAR2(32);
PRO
BEGIN
  IF '&&edb360_sections.' IS NULL THEN -- no sections were selected as per config parameter on edb360_00_config.sql or custom file passed
    IF LOWER(NVL(TRIM('&&custom_config_filename.'), 'null')) = 'null' THEN -- 2nd execution parameter is null
      :edb360_sections := NULL; -- all sections
    ELSIF LENGTH(TRIM('&&custom_config_filename.')) <= 5 AND TRIM('&&custom_config_filename.') BETWEEN '1' AND '9' AND INSTR('&&custom_config_filename.',',') = 0 THEN -- assume 2nd execution parameter is a section selection
      :edb360_sections := LOWER(TRIM('&&custom_config_filename.')); -- second parameter becomes potential sections selection
    ELSIF INSTR('&&custom_config_filename.',',') > 0 THEN -- assume 2nd execution parameter is a section list
      :edb360_sections := ','||LOWER(TRIM('&&custom_config_filename.'))||','; -- second parameter becomes potential section list
    ELSE
      :edb360_sections := NULL; -- 2nd parameter was indeed a custom config file
    END IF;
  ELSE -- an actual selection of sections was passed on config parameter
    :edb360_sections := LOWER(TRIM('&&edb360_sections.'));
  END IF;
  IF LENGTH(:edb360_sections) > 5 AND INSTR(:edb360_sections,',') = 0 THEN -- wrong value of parameter passed (too long), then select all sections
    :edb360_sec_from := '1a';
    :edb360_sec_to := '9z';
  ELSIF LENGTH(:edb360_sections) = 5 AND SUBSTR(:edb360_sections, 3, 1) = '-' AND SUBSTR(:edb360_sections, 1, 2) BETWEEN '1a' AND '9z' AND SUBSTR(:edb360_sections, 4, 2) BETWEEN '1a' AND '9z' THEN -- i.e. 1a-7b
    :edb360_sec_from := SUBSTR(:edb360_sections, 1, 2);
    :edb360_sec_to := SUBSTR(:edb360_sections, 4, 2);
  ELSIF LENGTH(:edb360_sections) = 4 AND SUBSTR(:edb360_sections, 3, 1) = '-' AND SUBSTR(:edb360_sections, 1, 2) BETWEEN '1a' AND '9z' AND SUBSTR(:edb360_sections, 4, 1) BETWEEN '1' AND '9' THEN -- i.e. 3b-7
    :edb360_sec_from := SUBSTR(:edb360_sections, 1, 2);
    :edb360_sec_to := SUBSTR(:edb360_sections, 4, 1)||'z';
  ELSIF LENGTH(:edb360_sections) = 4 AND SUBSTR(:edb360_sections, 2, 1) = '-' AND SUBSTR(:edb360_sections, 1, 1) BETWEEN '1' AND '9' AND SUBSTR(:edb360_sections, 3, 2) BETWEEN '1a' AND '9z' THEN -- i.e. 3-5b
    :edb360_sec_from := SUBSTR(:edb360_sections, 1, 1)||'a';
    :edb360_sec_to := SUBSTR(:edb360_sections, 3, 2);
  ELSIF LENGTH(:edb360_sections) = 3 AND SUBSTR(:edb360_sections, 2, 1) = '-' AND SUBSTR(:edb360_sections, 1, 1) BETWEEN '1' AND '9' AND SUBSTR(:edb360_sections, 3, 1) BETWEEN '1' AND '9' THEN -- i.e. 3-5
    :edb360_sec_from := SUBSTR(:edb360_sections, 1, 1)||'a';
    :edb360_sec_to := SUBSTR(:edb360_sections, 3, 1)||'z';
  ELSIF LENGTH(:edb360_sections) = 2 AND SUBSTR(:edb360_sections, 1, 2) BETWEEN '1a' AND '9z' THEN -- i.e. 7b
    :edb360_sec_from := SUBSTR(:edb360_sections, 1, 2);
    :edb360_sec_to := :edb360_sec_from;
  ELSIF LENGTH(:edb360_sections) = 1 AND SUBSTR(:edb360_sections, 1, 1) BETWEEN '1' AND '9' THEN -- i.e. 7
    :edb360_sec_from := SUBSTR(:edb360_sections, 1, 1)||'a';
    :edb360_sec_to := SUBSTR(:edb360_sections, 1, 1)||'z';
  ELSIF INSTR(:edb360_sections,',') > 0 THEN -- i.e. 4b,5a
    :edb360_sec_from := 0;
    :edb360_sec_to := 0;
  ELSE -- wrong value of parameter passed (incorrect syntax), or nothing was passed
    :edb360_sec_from := '1a';
    :edb360_sec_to := '9z';
  END IF;
END;
/
PRO edb360_sec_from edb360_sec_to edb360_sections
PRINT edb360_sec_from;
PRINT edb360_sec_to;
PRINT edb360_sections;
PRO
COL skip_extras NEW_V skip_extras;
SELECT CASE WHEN :edb360_sections IS NOT NULL THEN ' echo skip ' END skip_extras FROM DUAL;
PRO
COL edb360_0g NEW_V edb360_0g;
COL edb360_1a NEW_V edb360_1a;
COL edb360_1b NEW_V edb360_1b;
COL edb360_1c NEW_V edb360_1c;
COL edb360_1d NEW_V edb360_1d;
COL edb360_1e NEW_V edb360_1e;
COL edb360_1f NEW_V edb360_1f;
COL edb360_1g NEW_V edb360_1g;
COL edb360_2a NEW_V edb360_2a;
COL edb360_2b NEW_V edb360_2b;
COL edb360_2c NEW_V edb360_2c;
COL edb360_2d NEW_V edb360_2d;
COL edb360_2e NEW_V edb360_2e;
COL edb360_3a NEW_V edb360_3a;
COL edb360_3b NEW_V edb360_3b;
COL edb360_3c NEW_V edb360_3c;
COL edb360_3d NEW_V edb360_3d;
COL edb360_3e NEW_V edb360_3e;
COL edb360_3f NEW_V edb360_3f;
COL edb360_3g NEW_V edb360_3g;
COL edb360_3h NEW_V edb360_3h;
COL edb360_3i NEW_V edb360_3i;
COL edb360_3j NEW_V edb360_3j;
COL edb360_4a NEW_V edb360_4a;
COL edb360_4b NEW_V edb360_4b;
COL edb360_4c NEW_V edb360_4c;
COL edb360_4d NEW_V edb360_4d;
COL edb360_4e NEW_V edb360_4e;
COL edb360_4f NEW_V edb360_4f;
COL edb360_4g NEW_V edb360_4g;
COL edb360_4h NEW_V edb360_4h;
COL edb360_4i NEW_V edb360_4i;
COL edb360_4j NEW_V edb360_4j;
COL edb360_4k NEW_V edb360_4k;
COL edb360_4l NEW_V edb360_4l;
COL edb360_5a NEW_V edb360_5a;
COL edb360_5b NEW_V edb360_5b;
COL edb360_5c NEW_V edb360_5c;
COL edb360_5d NEW_V edb360_5d;
COL edb360_5e NEW_V edb360_5e;
COL edb360_5f NEW_V edb360_5f;
COL edb360_5g NEW_V edb360_5g;
COL edb360_6a NEW_V edb360_6a;
COL edb360_6b NEW_V edb360_6b;
COL edb360_6c NEW_V edb360_6c;
COL edb360_6d NEW_V edb360_6d;
COL edb360_6e NEW_V edb360_6e;
COL edb360_6f NEW_V edb360_6f;
COL edb360_6g NEW_V edb360_6g;
COL edb360_6h NEW_V edb360_6h;
COL edb360_6i NEW_V edb360_6i;
COL edb360_6j NEW_V edb360_6j;
COL edb360_6k NEW_V edb360_6k;
COL edb360_6l NEW_V edb360_6l;
COL edb360_6m NEW_V edb360_6m;
COL edb360_6n NEW_V edb360_6n;
COL edb360_6o NEW_V edb360_6o;
COL edb360_7a NEW_V edb360_7a;
COL edb360_7b NEW_V edb360_7b;
COL edb360_7c NEW_V edb360_7c;
SELECT CASE '&&edb360_conf_incl_tkprof.' WHEN 'Y'                                       THEN 'edb360_0g_' ELSE ' echo skip ' END edb360_0g FROM DUAL;
SELECT CASE WHEN '1a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1a_' WHEN INSTR(:edb360_sections,',1a,') > 0 THEN 'edb360_1a_' ELSE ' echo skip ' END edb360_1a FROM DUAL;
SELECT CASE WHEN '1b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1b_' WHEN INSTR(:edb360_sections,',1b,') > 0 THEN 'edb360_1b_' ELSE ' echo skip ' END edb360_1b FROM DUAL;
SELECT CASE WHEN '1c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1c_' WHEN INSTR(:edb360_sections,',1c,') > 0 THEN 'edb360_1c_' ELSE ' echo skip ' END edb360_1c FROM DUAL;
SELECT CASE WHEN '1d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1d_' WHEN INSTR(:edb360_sections,',1d,') > 0 THEN 'edb360_1d_' ELSE ' echo skip ' END edb360_1d FROM DUAL;
SELECT CASE WHEN '1e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1e_' WHEN INSTR(:edb360_sections,',1e,') > 0 THEN 'edb360_1e_' ELSE ' echo skip ' END edb360_1e FROM DUAL;
SELECT CASE WHEN '1f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1f_' WHEN INSTR(:edb360_sections,',1f,') > 0 THEN 'edb360_1f_' ELSE ' echo skip ' END edb360_1f FROM DUAL;
SELECT CASE WHEN '1g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1g_' WHEN INSTR(:edb360_sections,',1g,') > 0 THEN 'edb360_1g_' ELSE ' echo skip ' END edb360_1g FROM DUAL;
SELECT CASE WHEN '2a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2a_' WHEN INSTR(:edb360_sections,',2a,') > 0 THEN 'edb360_2a_' ELSE ' echo skip ' END edb360_2a FROM DUAL;
SELECT CASE WHEN '2b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2b_' WHEN INSTR(:edb360_sections,',2b,') > 0 THEN 'edb360_2b_' ELSE ' echo skip ' END edb360_2b FROM DUAL;
SELECT CASE WHEN '2c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2c_' WHEN INSTR(:edb360_sections,',2c,') > 0 THEN 'edb360_2c_' ELSE ' echo skip ' END edb360_2c FROM DUAL;
SELECT CASE WHEN '2d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2d_' WHEN INSTR(:edb360_sections,',2d,') > 0 THEN 'edb360_2d_' ELSE ' echo skip ' END edb360_2d FROM DUAL;
SELECT CASE WHEN '2e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2e_' WHEN INSTR(:edb360_sections,',2e,') > 0 THEN 'edb360_2e_' ELSE ' echo skip ' END edb360_2e FROM DUAL;
SELECT CASE WHEN '3a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3a_' WHEN INSTR(:edb360_sections,',3a,') > 0 THEN 'edb360_3a_' ELSE ' echo skip ' END edb360_3a FROM DUAL;
SELECT CASE WHEN '3b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3b_' WHEN INSTR(:edb360_sections,',3b,') > 0 THEN 'edb360_3b_' ELSE ' echo skip ' END edb360_3b FROM DUAL;
SELECT CASE WHEN '3c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3c_' WHEN INSTR(:edb360_sections,',3c,') > 0 THEN 'edb360_3c_' ELSE ' echo skip ' END edb360_3c FROM DUAL;
SELECT CASE WHEN '3d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3d_' WHEN INSTR(:edb360_sections,',3d,') > 0 THEN 'edb360_3d_' ELSE ' echo skip ' END edb360_3d FROM DUAL;
SELECT CASE WHEN '3e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3e_' WHEN INSTR(:edb360_sections,',3e,') > 0 THEN 'edb360_3e_' ELSE ' echo skip ' END edb360_3e FROM DUAL;
SELECT CASE WHEN '3f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3f_' WHEN INSTR(:edb360_sections,',3f,') > 0 THEN 'edb360_3f_' ELSE ' echo skip ' END edb360_3f FROM DUAL;
SELECT CASE WHEN '3g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3g_' WHEN INSTR(:edb360_sections,',3g,') > 0 THEN 'edb360_3g_' ELSE ' echo skip ' END edb360_3g FROM DUAL;
SELECT CASE WHEN '3h' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3h_' WHEN INSTR(:edb360_sections,',3h,') > 0 THEN 'edb360_3h_' ELSE ' echo skip ' END edb360_3h FROM DUAL;
SELECT CASE WHEN '3i' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3i_' WHEN INSTR(:edb360_sections,',3i,') > 0 THEN 'edb360_3i_' ELSE ' echo skip ' END edb360_3i FROM DUAL;
SELECT CASE WHEN '3j' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3j_' WHEN INSTR(:edb360_sections,',3j,') > 0 THEN 'edb360_3j_' ELSE ' echo skip ' END edb360_3j FROM DUAL;
SELECT CASE WHEN '4a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4a_' WHEN INSTR(:edb360_sections,',4a,') > 0 THEN 'edb360_4a_' ELSE ' echo skip ' END edb360_4a FROM DUAL;
SELECT CASE WHEN '4b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4b_' WHEN INSTR(:edb360_sections,',4b,') > 0 THEN 'edb360_4b_' ELSE ' echo skip ' END edb360_4b FROM DUAL;
SELECT CASE WHEN '4c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4c_' WHEN INSTR(:edb360_sections,',4c,') > 0 THEN 'edb360_4c_' ELSE ' echo skip ' END edb360_4c FROM DUAL;
SELECT CASE WHEN '4d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4d_' WHEN INSTR(:edb360_sections,',4d,') > 0 THEN 'edb360_4d_' ELSE ' echo skip ' END edb360_4d FROM DUAL;
SELECT CASE WHEN '4e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4e_' WHEN INSTR(:edb360_sections,',4e,') > 0 THEN 'edb360_4e_' ELSE ' echo skip ' END edb360_4e FROM DUAL;
SELECT CASE WHEN '4f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4f_' WHEN INSTR(:edb360_sections,',4f,') > 0 THEN 'edb360_4f_' ELSE ' echo skip ' END edb360_4f FROM DUAL;
SELECT CASE WHEN '4g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4g_' WHEN INSTR(:edb360_sections,',4g,') > 0 THEN 'edb360_4g_' ELSE ' echo skip ' END edb360_4g FROM DUAL;
SELECT CASE WHEN '4h' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4h_' WHEN INSTR(:edb360_sections,',4h,') > 0 THEN 'edb360_4h_' ELSE ' echo skip ' END edb360_4h FROM DUAL;
SELECT CASE WHEN '4i' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4i_' WHEN INSTR(:edb360_sections,',4i,') > 0 THEN 'edb360_4i_' ELSE ' echo skip ' END edb360_4i FROM DUAL;
SELECT CASE WHEN '4j' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4j_' WHEN INSTR(:edb360_sections,',4j,') > 0 THEN 'edb360_4j_' ELSE ' echo skip ' END edb360_4j FROM DUAL;
SELECT CASE WHEN '4k' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4k_' WHEN INSTR(:edb360_sections,',4k,') > 0 THEN 'edb360_4k_' ELSE ' echo skip ' END edb360_4k FROM DUAL;
SELECT CASE WHEN '4l' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4l_' WHEN INSTR(:edb360_sections,',4l,') > 0 THEN 'edb360_4l_' ELSE ' echo skip ' END edb360_4l FROM DUAL;
SELECT CASE WHEN '5a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5a_' WHEN INSTR(:edb360_sections,',5a,') > 0 THEN 'edb360_5a_' ELSE ' echo skip ' END edb360_5a FROM DUAL;
SELECT CASE WHEN '5b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5b_' WHEN INSTR(:edb360_sections,',5b,') > 0 THEN 'edb360_5b_' ELSE ' echo skip ' END edb360_5b FROM DUAL;
SELECT CASE WHEN '5c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5c_' WHEN INSTR(:edb360_sections,',5c,') > 0 THEN 'edb360_5c_' ELSE ' echo skip ' END edb360_5c FROM DUAL;
SELECT CASE WHEN '5d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5d_' WHEN INSTR(:edb360_sections,',5d,') > 0 THEN 'edb360_5d_' ELSE ' echo skip ' END edb360_5d FROM DUAL;
SELECT CASE WHEN '5e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5e_' WHEN INSTR(:edb360_sections,',5e,') > 0 THEN 'edb360_5e_' ELSE ' echo skip ' END edb360_5e FROM DUAL;
SELECT CASE WHEN '5f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5f_' WHEN INSTR(:edb360_sections,',5f,') > 0 THEN 'edb360_5f_' ELSE ' echo skip ' END edb360_5f FROM DUAL;
SELECT CASE WHEN '5g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5g_' WHEN INSTR(:edb360_sections,',5g,') > 0 THEN 'edb360_5g_' ELSE ' echo skip ' END edb360_5g FROM DUAL;
SELECT CASE WHEN '6a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6a_' WHEN INSTR(:edb360_sections,',6a,') > 0 THEN 'edb360_6a_' ELSE ' echo skip ' END edb360_6a FROM DUAL;
SELECT CASE WHEN '6b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6b_' WHEN INSTR(:edb360_sections,',6b,') > 0 THEN 'edb360_6b_' ELSE ' echo skip ' END edb360_6b FROM DUAL;
SELECT CASE WHEN '6c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6c_' WHEN INSTR(:edb360_sections,',6c,') > 0 THEN 'edb360_6c_' ELSE ' echo skip ' END edb360_6c FROM DUAL;
SELECT CASE WHEN '6d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6d_' WHEN INSTR(:edb360_sections,',6d,') > 0 THEN 'edb360_6d_' ELSE ' echo skip ' END edb360_6d FROM DUAL;
SELECT CASE WHEN '6e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6e_' WHEN INSTR(:edb360_sections,',6e,') > 0 THEN 'edb360_6e_' ELSE ' echo skip ' END edb360_6e FROM DUAL;
SELECT CASE WHEN '6f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6f_' WHEN INSTR(:edb360_sections,',6f,') > 0 THEN 'edb360_6f_' ELSE ' echo skip ' END edb360_6f FROM DUAL;
SELECT CASE WHEN '6g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6g_' WHEN INSTR(:edb360_sections,',6g,') > 0 THEN 'edb360_6g_' ELSE ' echo skip ' END edb360_6g FROM DUAL;
SELECT CASE WHEN '6h' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6h_' WHEN INSTR(:edb360_sections,',6h,') > 0 THEN 'edb360_6h_' ELSE ' echo skip ' END edb360_6h FROM DUAL;
SELECT CASE WHEN '6i' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6i_' WHEN INSTR(:edb360_sections,',6i,') > 0 THEN 'edb360_6i_' ELSE ' echo skip ' END edb360_6i FROM DUAL;
SELECT CASE WHEN '6j' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6j_' WHEN INSTR(:edb360_sections,',6j,') > 0 THEN 'edb360_6j_' ELSE ' echo skip ' END edb360_6j FROM DUAL;
SELECT CASE WHEN '6k' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6k_' WHEN INSTR(:edb360_sections,',6k,') > 0 THEN 'edb360_6k_' ELSE ' echo skip ' END edb360_6k FROM DUAL;
SELECT CASE WHEN '6l' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6l_' WHEN INSTR(:edb360_sections,',6l,') > 0 THEN 'edb360_6l_' ELSE ' echo skip ' END edb360_6l FROM DUAL;
SELECT CASE WHEN '6m' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6m_' WHEN INSTR(:edb360_sections,',6m,') > 0 THEN 'edb360_6m_' ELSE ' echo skip ' END edb360_6m FROM DUAL;
SELECT CASE WHEN '6n' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6n_' WHEN INSTR(:edb360_sections,',6n,') > 0 THEN 'edb360_6n_' ELSE ' echo skip ' END edb360_6n FROM DUAL;
SELECT CASE WHEN '6o' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6o_' WHEN INSTR(:edb360_sections,',6o,') > 0 THEN 'edb360_6o_' ELSE ' echo skip ' END edb360_6o FROM DUAL;
SELECT CASE WHEN '7a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_7a_' WHEN INSTR(:edb360_sections,',7a,') > 0 THEN 'edb360_7a_' ELSE ' echo skip ' END edb360_7a FROM DUAL;
SELECT CASE WHEN '7b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_7b_' WHEN INSTR(:edb360_sections,',7b,') > 0 THEN 'edb360_7b_' ELSE ' echo skip ' END edb360_7b FROM DUAL;
SELECT CASE WHEN '7c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_7c_' WHEN INSTR(:edb360_sections,',7c,') > 0 THEN 'edb360_7c_' ELSE ' echo skip ' END edb360_7c FROM DUAL;

-- filename prefix
COL edb360_prefix NEW_V edb360_prefix;
SELECT CASE WHEN :edb360_sec_from = '1a' AND :edb360_sec_to = '9z' THEN 'edb360' ELSE 'edb360_'||:edb360_sec_from||'_'||:edb360_sec_to END edb360_prefix FROM DUAL;

-- esp init
DEF ecr_collection_key = '';

-- dummy
DEF skip_script = 'sql/edb360_0f_skip_script.sql ';

-- get 12c container
DEF edb360_con_id = '-1';
COL edb360_con_id NEW_V edb360_con_id;
-- 0-1:CDB$ROOT 2:PDB$SEED >2:PDB
--SELECT /* ignore if it fails to parse */ con_id edb360_con_id FROM v$instance;
SELECT /* ignore if it fails to parse */ SYS_CONTEXT('USERENV','CON_ID') edb360_con_id FROM DUAL;

-- get 12c PDB name
COL edb360_pdb_name NEW_V edb360_pdb_name;
SELECT 'NONE' edb360_pdb_name FROM DUAL;
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') edb360_pdb_name FROM DUAL;

-- get dbmod
COL edb360_dbmod NEW_V edb360_dbmod;
SELECT LPAD(MOD(&&edb360_dbid.,1e6),6,'6') edb360_dbmod FROM DUAL;

-- get instance number
COL connect_instance_number NEW_V connect_instance_number;
SELECT TO_CHAR(instance_number) connect_instance_number FROM &&v_object_prefix.instance;

-- get database name (up to 10, stop before first '.', no special characters)
COL database_name_short NEW_V database_name_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) database_name_short FROM DUAL;
SELECT SUBSTR('&&database_name_short.', 1, INSTR('&&database_name_short..', '.') - 1) database_name_short FROM DUAL;
SELECT TRANSLATE('&&database_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') database_name_short FROM DUAL;

-- get host name (up to 30, stop before first '.', no special characters)
COL host_name_short NEW_V host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) host_name_short FROM DUAL;
SELECT SUBSTR('&&host_name_short.', 1, INSTR('&&host_name_short..', '.') - 1) host_name_short FROM DUAL;
SELECT TRANSLATE('&&host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') host_name_short FROM DUAL;

-- get host_name_suffix
COL host_name_suffix NEW_V host_name_suffix FOR A30;
SELECT SUBSTR(SYS_CONTEXT('USERENV','HOST'), 1 + INSTR(SYS_CONTEXT('USERENV','HOST'), '&&edb360_host_name_separator.', '&&edb360_host_name_position.', '&&edb360_host_name_occurrence.'), 30) host_name_suffix FROM DUAL;

-- get host name (up to 30, stop before first '.', no special characters)
DEF esp_host_name_short = '';
COL esp_host_name_short NEW_V esp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) esp_host_name_short FROM DUAL;
SELECT SUBSTR('&&esp_host_name_short.', 1, INSTR('&&esp_host_name_short..', '.') - 1) esp_host_name_short FROM DUAL;
SELECT TRANSLATE('&&esp_host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') esp_host_name_short FROM DUAL;

-- get host hash
COL host_hash NEW_V host_hash;
SELECT LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_hash FROM DUAL;

-- get collection date
DEF esp_collection_yyyymmdd = '';
COL esp_collection_yyyymmdd NEW_V esp_collection_yyyymmdd FOR A8;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') esp_collection_yyyymmdd FROM DUAL;

-- get valid ranges for time buckets for calculations in 4f,4g,4h
COLUMN min_wait_time_milli NEW_VALUE min_wait_time_milli
COLUMN max_wait_time_milli NEW_VALUE max_wait_time_milli
SELECT MIN(wait_time_milli) min_wait_time_milli
     , MAX(wait_time_milli)*2 max_wait_time_milli
  FROM &&awr_object_prefix.event_histogram
 WHERE dbid = &&edb360_dbid.
   AND wait_time_milli < 1e9;

-- esp init
DEF ecr_collection_key = '';

-- setup
DEF main_table = '';
DEF title = '';
DEF title_no_spaces = '';
DEF title_suffix = '';
-- timestamp on filename
COL edb360_file_time NEW_V edb360_file_time FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') edb360_file_time FROM DUAL;
DEF common_edb360_prefix = '&&edb360_prefix._&&edb360_dbmod.';
DEF edb360_main_report = '&&edb360_output_directory.00001_&&common_edb360_prefix._index';
DEF edb360_log = '&&edb360_output_directory.00002_&&common_edb360_prefix._log';
DEF edb360_log2 = '&&edb360_output_directory.00003_&&common_edb360_prefix._log2';
DEF edb360_log3 = '&&edb360_output_directory.00004_&&common_edb360_prefix._log3';
DEF edb360_tkprof = '&&edb360_output_directory.00005_&&common_edb360_prefix._tkprof';
--DEF edb360_main_filename = '&&common_edb360_prefix._&&host_hash.';
COL edb360_main_filename NEW_V edb360_main_filename;
SELECT '&&common_edb360_prefix.'||(CASE '&&edb360_conf_incl_dbname_file.' WHEN 'Y' THEN '_&&database_name_short.' ELSE '_&&host_hash.' END) edb360_main_filename FROM DUAL
/
COL edb360_zip_filename NEW_V edb360_zip_filename;
SELECT '&&edb360_output_directory.&&edb360_main_filename._&&edb360_file_time.' edb360_zip_filename FROM DUAL
/
DEF edb360_tracefile_identifier = '&&common_edb360_prefix.';
DEF edb360_tar_filename = '&&edb360_output_directory.00008_&&edb360_zip_filename.';
DEF edb360_mv_host_command = '';

-- mount info
HOS export whoami=`whoami`
HOS dcli -g ~/dbs_group -l $whoami mount >> &&edb360_log3..txt

-- Exadata
ALTER SESSION SET "_serial_direct_read" = ALWAYS;
ALTER SESSION SET "_small_table_threshold" = 1001;
ALTER SESSION SET "_px_cdb_view_enabled" = FALSE;
-- nls
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = '&&edb360_date_format.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&edb360_timestamp_format.';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = '&&edb360_timestamp_tz_format.';
-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
-- workaround fairpoint
COL db_vers_ofe NEW_V db_vers_ofe;
SELECT TRIM('.' FROM TRIM('0' FROM version)) db_vers_ofe FROM &&v_object_prefix.instance;
ALTER SESSION SET optimizer_features_enable = '&&db_vers_ofe.';
-- to work around bug 12672969
ALTER SESSION SET "_optimizer_order_by_elimination_enabled"=false;
-- workaround Siebel
ALTER SESSION SET optimizer_index_cost_adj = 100;
--ALTER SESSION SET optimizer_dynamic_sampling = 2;
ALTER SESSION SET "_always_semi_join" = CHOOSE;
ALTER SESSION SET "_and_pruning_enabled" = TRUE;
ALTER SESSION SET "_subquery_pruning_enabled" = TRUE;
-- workaround bug 19567916
ALTER SESSION SET "_optimizer_aggr_groupby_elim" = FALSE;
-- workaround nigeria
--ALTER SESSION SET "_gby_hash_aggregation_enabled" = TRUE;
ALTER SESSION SET "_hash_join_enabled" = TRUE;
ALTER SESSION SET "_optim_peek_user_binds" = TRUE;
ALTER SESSION SET "_optimizer_skip_scan_enabled" = TRUE;
ALTER SESSION SET "_optimizer_sortmerge_join_enabled" = TRUE;
ALTER SESSION SET cursor_sharing = EXACT;
ALTER SESSION SET db_file_multiblock_read_count = 128;
ALTER SESSION SET optimizer_index_caching = 0;
ALTER SESSION SET optimizer_index_cost_adj = 100;
-- workaround 21150273 and 20465582
ALTER SESSION SET optimizer_dynamic_sampling = 0;
ALTER SESSION SET "_optimizer_dsdir_usage_control"=0;
ALTER SESSION SET "_sql_plan_directive_mgmt_control" = 0;
/* workaround for bug 24554937 affecting SQL_ID dfffkcnqfystw */
ALTER SESSION SET "_gby_hash_aggregation_enabled" = FALSE;

-- tracing script in case it takes long to execute so we can diagnose it
ALTER SESSION SET MAX_DUMP_FILE_SIZE = '1G';
ALTER SESSION SET TRACEFILE_IDENTIFIER = "&&edb360_tracefile_identifier.";
--ALTER SESSION SET STATISTICS_LEVEL = 'ALL';
BEGIN
  IF TO_NUMBER('&&sql_trace_level.') > 0 THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT FOREVER, LEVEL &&sql_trace_level.''';
  END IF;
END;
/
-- esp collection. note: skip if executing for one section
@&&skip_diagnostics.&&skip_extras.&&skip_esp_and_escp.sql/esp_master.sql
SET TERM OFF;

-- nls (2nd time as esp may change them)
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = '&&edb360_date_format.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&edb360_timestamp_format.';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = '&&edb360_timestamp_tz_format.';

-- initialization
--COL row_num NEW_V row_num FOR 9999999 HEA '#' PRI;
COL row_num NEW_V row_num HEA '#' PRI;
--COL nbsp NEW_V nbsp;
--SELECT CHR(38)||'nbsp;' nbsp FROM DUAL;

-- get rdbms version
COL db_version NEW_V db_version;
SELECT version db_version FROM &&v_object_prefix.instance;


COLUMN cdb_awr_hist_prefix   NEW_V cdb_awr_hist_prefix
COLUMN cdb_awr_object_prefix NEW_V cdb_awr_object_prefix
COLUMN cdb_view_prefix       NEW_V cdb_view_prefix
COLUMN cdb_object_prefix     NEW_V cdb_object_prefix
SELECT CASE WHEN '&&is_cdb' = 'Y' THEN 'CDB_HIST_' ELSE '&&awr_hist_prefix'   END cdb_awr_hist_prefix
,      CASE WHEN '&&is_cdb' = 'Y' THEN 'cdb_hist_' ELSE '&&awr_object_prefix' END cdb_awr_object_prefix
,      CASE WHEN '&&is_cdb' = 'Y' THEN 'CDB_'      ELSE '&&dva_view_prefix'   END cdb_view_prefix
,      CASE WHEN '&&is_cdb' = 'Y' THEN 'cdb_'      ELSE '&&dva_object_prefix' END cdb_object_prefix
FROM DUAL;

-- skip
--DEF skip_10g_column = '';
--COL skip_10g_column NEW_V skip_10g_column;
--DEF skip_10g_script = '';
--COL skip_10g_script NEW_V skip_10g_script;
--SELECT ' -- skip 10g ' skip_10g_column, ' echo skip 10g ' skip_10g_script FROM &&v_object_prefix.instance WHERE version LIKE '10%';
--
--DEF skip_11g_column = '';
--COL skip_11g_column NEW_V skip_11g_column;
--DEF skip_11g_script = '';
--COL skip_11g_script NEW_V skip_11g_script;
--SELECT ' -- skip 11g ' skip_11g_column, ' echo skip 11g ' skip_11g_script FROM &&v_object_prefix.instance WHERE version LIKE '11%';
--
--DEF skip_11r1_column = '';
--COL skip_11r1_column NEW_V skip_11r1_column;
--DEF skip_11r1_script = '';
--COL skip_11r1_script NEW_V skip_11r1_script;
--SELECT ' -- skip 11gR1 ' skip_11r1_column, ' echo skip 11gR1 ' skip_11r1_script FROM &&v_object_prefix.instance WHERE version LIKE '11.1%';
--
DEF skip_non_repo_column = '';
COL skip_non_repo_column NEW_V skip_non_repo_column;
DEF skip_non_repo_script = '';
COL skip_non_repo_script NEW_V skip_non_repo_script;
SELECT ' -- skip non-repository ' skip_non_repo_column, ' echo skip non-repository ' skip_non_repo_script FROM DUAL WHERE '&&tool_repo_user.' IS NOT NULL;
--
--DEF skip_12c_column = '';
--COL skip_12c_column NEW_V skip_12c_column;
--DEF skip_12c_script = '';
--COL skip_12c_script NEW_V skip_12c_script;
--SELECT ' -- skip 12c ' skip_12c_column, ' echo skip 12c ' skip_12c_script FROM &&v_object_prefix.instance WHERE version LIKE '12%';
--
--DEF skip_12r2_column = '';
--COL skip_12r2_column NEW_V skip_12r2_column;
--DEF skip_12r2_script = '';
--COL skip_12r2_script NEW_V skip_12r2_script;
--SELECT ' -- skip 12cR2 ' skip_12r2_column, ' echo skip 12cR2 ' skip_12r2_script FROM &&v_object_prefix.instance WHERE version LIKE '12.2%';
--
--DEF skip_18c_column = '';
--COL skip_18c_column NEW_V skip_18c_column;
--DEF skip_18c_script = '';
--COL skip_18c_script NEW_V skip_18c_script;
--SELECT ' -- skip 18c ' skip_18c_column, ' echo skip 18c ' skip_18c_script FROM &&v_object_prefix.instance WHERE version LIKE '18%';
--
--DEF skip_19c_column = '';
--COL skip_19c_column NEW_V skip_19c_column;
--DEF skip_19c_script = '';
--COL skip_19c_script NEW_V skip_19c_script;
--SELECT ' -- skip 19c ' skip_19c_column, ' echo skip 19c ' skip_19c_script FROM &&v_object_prefix.instance WHERE version LIKE '19%';

-- get average number of CPUs
COL avg_cpu_count NEW_V avg_cpu_count FOR A6;
SELECT TO_CHAR(ROUND(AVG(TO_NUMBER(value)),1)) avg_cpu_count FROM &&gv_object_prefix.system_parameter2 WHERE name = 'cpu_count';

-- get total number of CPUs
COL sum_cpu_count NEW_V sum_cpu_count FOR A3;
SELECT TO_CHAR(SUM(TO_NUMBER(value))) sum_cpu_count FROM &&gv_object_prefix.system_parameter2 WHERE name = 'cpu_count';

-- get average number of Cores
COL avg_core_count NEW_V avg_core_count FOR A5;
SELECT TO_CHAR(ROUND(AVG(TO_NUMBER(value)),1)) avg_core_count FROM &&gv_object_prefix.osstat WHERE stat_name = 'NUM_CPU_CORES';

-- get average number of Threads
COL avg_thread_count NEW_V avg_thread_count FOR A6;
SELECT TO_CHAR(ROUND(AVG(TO_NUMBER(value)),1)) avg_thread_count FROM &&gv_object_prefix.osstat WHERE stat_name = 'NUM_CPUS';

-- get CPU Load threshold (for intel assume 1.4x cores and for solaris use 4x cores) else 2x
COL cpu_load_threshold NEW_V cpu_load_threshold FOR A6;
SELECT TO_CHAR(CASE ROUND(AVG(TO_NUMBER(cpus.value))/AVG(TO_NUMBER(cores.value))) WHEN 2 THEN 1.4 * AVG(TO_NUMBER(cores.value)) WHEN 8 THEN 4 * AVG(TO_NUMBER(cores.value)) ELSE 2 * AVG(TO_NUMBER(cores.value)) END) cpu_load_threshold
  FROM &&gv_object_prefix.osstat cores, &&gv_object_prefix.osstat cpus
 WHERE cores.stat_name = 'NUM_CPU_CORES'
   AND cpus.stat_name = 'NUM_CPUS'
/

-- get number of Hosts
COL hosts_count NEW_V hosts_count FOR A2;
SELECT TO_CHAR(ROUND(AVG(TO_NUMBER(value)))) hosts_count FROM (select count(distinct INSTANCE_NUMBER) value,snap_id FROM &&awr_object_prefix.osstat WHERE stat_name = 'NUM_CPU_CORES' group by snap_id);

-- get cores_threads_hosts
COL cores_threads_hosts NEW_V cores_threads_hosts;
SELECT CASE TO_NUMBER('&&hosts_count.') WHEN 1 THEN 'cores:&&avg_core_count. threads:&&avg_thread_count.' ELSE 'cores:&&avg_core_count.(avg) threads:&&avg_thread_count.(avg) hosts:&&hosts_count.(avg)' END cores_threads_hosts FROM DUAL;

-- get block_size
COL database_block_size NEW_V database_block_size;
SELECT TRIM(TO_NUMBER(value)) database_block_size FROM &&v_object_prefix.system_parameter2 WHERE name = 'db_block_size';

-- snapshot ranges
SELECT '0' history_days FROM DUAL WHERE TRIM('&&history_days.') IS NULL;
COL tool_sysdate NEW_V tool_sysdate;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') tool_sysdate FROM DUAL;
COL between_times NEW_V between_times;
COL between_dates NEW_V between_dates;
SELECT ', between &&edb360_date_from. and &&edb360_date_to.' between_dates FROM DUAL;
COL minimum_snap_id NEW_V minimum_snap_id;
SELECT NVL(TO_CHAR(MIN(snap_id)), '0') minimum_snap_id FROM &&awr_object_prefix.snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&edb360_dbid. AND begin_interval_time > TO_DATE('&&edb360_date_from.', '&&edb360_date_format.');
SELECT '-1' minimum_snap_id FROM DUAL WHERE TRIM('&&minimum_snap_id.') IS NULL;
COL maximum_snap_id NEW_V maximum_snap_id;
SELECT NVL(TO_CHAR(MAX(snap_id)), '&&minimum_snap_id.') maximum_snap_id FROM &&awr_object_prefix.snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&edb360_dbid. AND end_interval_time < TO_DATE('&&edb360_date_to.', '&&edb360_date_format.');
SELECT '-1' maximum_snap_id FROM DUAL WHERE TRIM('&&maximum_snap_id.') IS NULL;

-- Determine if rac or single instance (null means rac)
-- and which instances were present in the history (null means instance not present).

COL inst1_present NEW_V inst1_present FOR A1;
COL inst2_present NEW_V inst2_present FOR A1;
COL inst3_present NEW_V inst3_present FOR A1;
COL inst4_present NEW_V inst4_present FOR A1;
COL inst5_present NEW_V inst5_present FOR A1;
COL inst6_present NEW_V inst6_present FOR A1;
COL inst7_present NEW_V inst7_present FOR A1;
COL inst8_present NEW_V inst8_present FOR A1;
COL skip_inst1 NEW_V skip_inst1;
COL skip_inst2 NEW_V skip_inst2;
COL skip_inst3 NEW_V skip_inst3;
COL skip_inst4 NEW_V skip_inst4;
COL skip_inst5 NEW_V skip_inst5;
COL skip_inst6 NEW_V skip_inst6;
COL skip_inst7 NEW_V skip_inst7;
COL skip_inst8 NEW_V skip_inst8;
COL is_single_instance NEW_V is_single_instance FOR A1;

WITH hist AS (
SELECT DISTINCT instance_number
  FROM &&awr_object_prefix.snapshot
WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
)
SELECT MAX(CASE instance_number WHEN 1 THEN '1' ELSE NULL END) inst1_present,
       MAX(CASE instance_number WHEN 2 THEN '2' ELSE NULL END) inst2_present,
       MAX(CASE instance_number WHEN 3 THEN '3' ELSE NULL END) inst3_present,
       MAX(CASE instance_number WHEN 4 THEN '4' ELSE NULL END) inst4_present,
       MAX(CASE instance_number WHEN 5 THEN '5' ELSE NULL END) inst5_present,
       MAX(CASE instance_number WHEN 6 THEN '6' ELSE NULL END) inst6_present,
       MAX(CASE instance_number WHEN 7 THEN '7' ELSE NULL END) inst7_present,
       MAX(CASE instance_number WHEN 8 THEN '8' ELSE NULL END) inst8_present,
       (CASE COUNT(instance_number) WHEN 1 THEN 'Y' ELSE NULL END) is_single_instance
  FROM hist;

SELECT NVL2('&&inst1_present.','','-- skip inst1') skip_inst1,
       NVL2('&&inst2_present.','','-- skip inst2') skip_inst2,
       NVL2('&&inst3_present.','','-- skip inst3') skip_inst3,
       NVL2('&&inst4_present.','','-- skip inst4') skip_inst4,
       NVL2('&&inst5_present.','','-- skip inst5') skip_inst5,
       NVL2('&&inst6_present.','','-- skip inst6') skip_inst6,
       NVL2('&&inst7_present.','','-- skip inst7') skip_inst7,
       NVL2('&&inst8_present.','','-- skip inst8') skip_inst8
  FROM DUAL;

SET SERVEROUT ON;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
DEF chart_setup_driver ='&&edb360_output_directory.99800_&&common_edb360_prefix._chart_setup_driver1.sql';
SPO &&chart_setup_driver.;
DECLARE
  l_count NUMBER;
  l_instances varchar2(15):='&&inst1_present.&&inst2_present.&&inst3_present.&&inst4_present.&&inst5_present.&&inst6_present.&&inst7_present.&&inst8_present.';
BEGIN
  FOR i IN 1 .. 8
  LOOP
    IF instr(l_instances,to_char(i,'fm9'))=0 THEN
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' NOPRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = '''';');
    ELSE
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' HEA ''Inst '||i||''' FOR 999990.000 PRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = ''Inst '||i||''';');
    END IF;
  END LOOP;
  FOR i IN 9 .. 15 LOOP
   DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' NOPRI;');
   DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = '''';');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;

hos echo "this is 0b" >> &&edb360_log3..txt
hos pwd >> &&edb360_log3..txt
hos cat &&chart_setup_driver. >> &&edb360_log3..txt

HOS zip -j &&edb360_zip_filename. &&chart_setup_driver. >> &&edb360_log3..txt

-- eAdam
DEF edb360_eadam_snaps = '-666';

-- ebs
DEF ebs_release = '';
DEF ebs_system_name = '';
COL ebs_release NEW_V ebs_release;
COL ebs_system_name NEW_V ebs_system_name;
SELECT /* ignore if it fails to parse */ release_name ebs_release, applications_system_name ebs_system_name FROM applsys.fnd_product_groups WHERE ROWNUM = 1;

-- siebel
DEF siebel_schema = 'NOT_A_SIEBEL_DB';
DEF siebel_app_ver = '';
COL siebel_schema NEW_V siebel_schema;
COL siebel_app_ver NEW_V siebel_app_ver;
SELECT owner siebel_schema FROM &&dva_object_prefix.tab_columns WHERE table_name = 'S_REPOSITORY' AND column_name = 'ROW_ID' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT /* ignore if it fails to parse */ app_ver siebel_app_ver FROM &&siebel_schema..s_app_ver WHERE ROWNUM = 1;

-- psft
DEF psft_schema = 'NOT_A_PSFT_DB';
DEF psft_tools_rel = '';
DEF psft_skip = '';
COL psft_schema NEW_V psft_schema;
COL psft_tools_rel NEW_V psft_tools_rel;
COL psft_skip NEW_V psft_skip
SELECT owner psft_schema
, '--skip psft' psft_skip
FROM &&cdb_object_prefix.tab_columns WHERE table_name = 'PSSTATUS' AND column_name = 'TOOLSREL' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT /* ignore if it fails to parse */ toolsrel psft_tools_rel 
FROM &&psft_schema..psstatus WHERE ROWNUM = 1;

-- inclusion config determine skip flags
COL edb360_skip_html NEW_V edb360_skip_html;
COL edb360_skip_xml NEW_V edb360_skip_xml;
COL edb360_skip_text NEW_V edb360_skip_text;
COL edb360_skip_csv  NEW_V edb360_skip_csv;
COL edb360_skip_line NEW_V edb360_skip_line;
COL edb360_skip_pie  NEW_V edb360_skip_pie;
COL edb360_skip_bar  NEW_V edb360_skip_bar;
COL edb360_skip_metadata  NEW_V edb360_skip_metadata;
SELECT CASE '&&edb360_conf_incl_html.'     WHEN 'N' THEN ' echo skip html ' END edb360_skip_html     FROM DUAL;
SELECT CASE '&&edb360_conf_incl_xml.'      WHEN 'N' THEN ' echo skip xml '  END edb360_skip_xml      FROM DUAL;
SELECT CASE '&&edb360_conf_incl_text.'     WHEN 'N' THEN ' echo skip text ' END edb360_skip_text     FROM DUAL;
SELECT CASE '&&edb360_conf_incl_csv.'      WHEN 'N' THEN ' echo skip csv '  END edb360_skip_csv      FROM DUAL;
SELECT CASE '&&edb360_conf_incl_line.'     WHEN 'N' THEN ' echo skip line ' END edb360_skip_line     FROM DUAL;
SELECT CASE '&&edb360_conf_incl_pie.'      WHEN 'N' THEN ' echo skip pie '  END edb360_skip_pie      FROM DUAL;
SELECT CASE '&&edb360_conf_incl_bar.'      WHEN 'N' THEN ' echo skip bar '  END edb360_skip_bar      FROM DUAL;
SELECT CASE '&&edb360_conf_incl_metadata.' WHEN 'N' THEN ' echo skip meta ' END edb360_skip_metadata FROM DUAL;

-- inclusion of some diagnostics from memory (not from history)
COL edb360_skip_ash_mem NEW_V edb360_skip_ash_mem;
COL edb360_skip_sql_mon NEW_V edb360_skip_sql_mon;
COL edb360_skip_stat_mem NEW_V edb360_skip_stat_mem;
COL edb360_skip_px_mem NEW_V edb360_skip_px_mem;
SELECT CASE '&&edb360_conf_incl_ash_mem.'  WHEN 'N' THEN ' echo skip ash mem '  END edb360_skip_ash_mem  FROM DUAL;
SELECT CASE '&&edb360_conf_incl_sql_mon.'  WHEN 'N' THEN ' echo skip sql mon '  END edb360_skip_sql_mon  FROM DUAL;
SELECT CASE '&&edb360_conf_incl_stat_mem.' WHEN 'N' THEN ' echo skip stat mem ' END edb360_skip_stat_mem FROM DUAL;
SELECT CASE '&&edb360_conf_incl_px_mem.'   WHEN 'N' THEN ' echo skip px mem '   END edb360_skip_px_mem   FROM DUAL;

DEF top_level_hints = ' NO_MERGE ';
DEF sq_fact_hints = ' MATERIALIZE NO_MERGE ';
DEF ds_hint = ' DYNAMIC_SAMPLING(4) ';
DEF ash_hints1 = ' FULL(h.ash) FULL(h.evt) FULL(h.sn) USE_HASH(h.sn h.ash h.evt) ';
DEF ash_hints2 = ' FULL(h.INT$&&awr_hist_prefix.ACT_SESS_HISTORY.sn) FULL(h.INT$&&awr_hist_prefix.ACT_SESS_HISTORY.ash) FULL(h.INT$&&awr_hist_prefix.ACT_SESS_HISTORY.evt) ';
DEF ash_hints3 = ' USE_HASH(h.INT$&&awr_hist_prefix.ACT_SESS_HISTORY.sn h.INT$&&awr_hist_prefix.ACT_SESS_HISTORY.ash h.INT$&&awr_hist_prefix.ACT_SESS_HISTORY.evt) ';
DEF def_max_rows = '10000';
DEF max_rows = '1e4';
DEF exclusion_list = "('ANONYMOUS','APEX_030200','APEX_040000','APEX_040200','APEX_180200','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS')";
DEF exclusion_list2 = "('SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF','MGDSYS','OJVMSYS','GSMADMIN_INTERNAL')";
DEF skip_html = '';
DEF skip_text = '';
DEF skip_csv = '';
DEF skip_lch = 'Y';
DEF skip_lch2 = 'Y';
DEF skip_pch = 'Y';
DEF skip_bch = 'Y';
DEF skip_all = '';
DEF abstract = '';
DEF abstract2 = '';
DEF foot = '';
DEF abstract_uom = 'Memory is accounted as power of two (binary) while storage and network traffic as power of ten (decimal). <br />';
--DEF sql_text = '';
COL sql_text FOR A100;
DEF chartype = '';
DEF stacked = '';
DEF haxis = '&&host_name_suffix. &&db_version. &&cores_threads_hosts.';
DEF vaxis = '';
DEF vbaseline = '';
DEF bar_height = '65%';
COL tit_01 NEW_V tit_01;
COL tit_02 NEW_V tit_02;
COL tit_03 NEW_V tit_03;
COL tit_04 NEW_V tit_04;
COL tit_05 NEW_V tit_05;
COL tit_06 NEW_V tit_06;
COL tit_07 NEW_V tit_07;
COL tit_08 NEW_V tit_08;
COL tit_09 NEW_V tit_09;
COL tit_10 NEW_V tit_10;
COL tit_11 NEW_V tit_11;
COL tit_12 NEW_V tit_12;
COL tit_13 NEW_V tit_13;
COL tit_14 NEW_V tit_14;
COL tit_15 NEW_V tit_15;
DEF tit_01 = '';
DEF tit_02 = '';
DEF tit_03 = '';
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
COL cont_01 NEW_V cont_01;
COL cont_02 NEW_V cont_02;
COL cont_03 NEW_V cont_03;
COL cont_04 NEW_V cont_04;
COL cont_05 NEW_V cont_05;
COL cont_06 NEW_V cont_06;
COL cont_07 NEW_V cont_07;
COL cont_08 NEW_V cont_08;
COL cont_09 NEW_V cont_09;
COL cont_10 NEW_V cont_10;
COL cont_11 NEW_V cont_11;
COL cont_12 NEW_V cont_12;
COL cont_13 NEW_V cont_13;
COL cont_14 NEW_V cont_14;
COL cont_15 NEW_V cont_15;
DEF cont_01 = '-1';
DEF cont_02 = '-1';
DEF cont_03 = '-1';
DEF cont_04 = '-1';
DEF cont_05 = '-1';
DEF cont_06 = '-1';
DEF cont_07 = '-1';
DEF cont_08 = '-1';
DEF cont_09 = '-1';
DEF cont_10 = '-1';
DEF cont_11 = '-1';
DEF cont_12 = '-1';
DEF cont_13 = '-1';
DEF cont_14 = '-1';
DEF cont_15 = '-1';
DEF wait_class_01 = '';
DEF event_name_01 = '';
DEF wait_class_02 = '';
DEF event_name_02 = '';
DEF wait_class_03 = '';
DEF event_name_03 = '';
DEF wait_class_04 = '';
DEF event_name_04 = '';
DEF wait_class_05 = '';
DEF event_name_05 = '';
DEF wait_class_06 = '';
DEF event_name_06 = '';
DEF wait_class_07 = '';
DEF event_name_07 = '';
DEF wait_class_08 = '';
DEF event_name_08 = '';
DEF wait_class_09 = '';
DEF event_name_09 = '';
DEF wait_class_10 = '';
DEF event_name_10 = '';
DEF wait_class_11 = '';
DEF event_name_11 = '';
DEF wait_class_12 = '';
DEF event_name_12 = '';
DEF exadata = '';
DEF max_col_number = '1';
DEF column_number = '1';
COL recovery NEW_V recovery;
SELECT CHR(38)||' recovery' recovery FROM DUAL;
-- this above is to handle event "RMAN backup & recovery I/O"
COL skip_html NEW_V skip_html;
COL skip_text NEW_V skip_text;
COL skip_csv NEW_V skip_csv;
COL skip_lch NEW_V skip_lch;
COL skip_lch2 NEW_V skip_lch2;
COL skip_pch NEW_V skip_pch;
COL skip_bch NEW_V skip_bch;
COL skip_all NEW_V skip_all;
COL dummy_01 NOPRI;
COL dummy_02 NOPRI;
COL dummy_03 NOPRI;
COL dummy_04 NOPRI;
COL dummy_05 NOPRI;
COL dummy_06 NOPRI;
COL dummy_07 NOPRI;
COL dummy_08 NOPRI;
COL dummy_09 NOPRI;
COL dummy_10 NOPRI;
COL dummy_11 NOPRI;
COL dummy_12 NOPRI;
COL dummy_13 NOPRI;
COL dummy_14 NOPRI;
COL dummy_15 NOPRI;
COL edb360_time_stamp NEW_V edb360_time_stamp FOR A20;
DEF total_hours = '';
SELECT TO_CHAR(SYSDATE, '&&edb360_date_format.') edb360_time_stamp FROM DUAL;
COL hh_mm_ss NEW_V hh_mm_ss FOR A8;
COL title_no_spaces NEW_V title_no_spaces;
COL spool_filename NEW_V spool_filename;
COL one_spool_filename NEW_V one_spool_filename;
COL report_sequence NEW_V report_sequence;
--VAR row_count NUMBER;
VAR sql_text CLOB;
VAR sql_text_backup CLOB;
VAR sql_text_backup2 CLOB;
VAR sql_text_display CLOB;
VAR file_seq NUMBER;
EXEC :file_seq := 8;
VAR repo_seq NUMBER;
EXEC :repo_seq := 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;
VAR get_time_t0 NUMBER;
VAR get_time_t1 NUMBER;
DEF current_time = '';
COL edb360_tuning_pack_for_sqlmon NEW_V edb360_tuning_pack_for_sqlmon;
COL skip_sqlmon_exec NEW_V skip_sqlmon_exec;
COL edb360_sql_text_100 NEW_V edb360_sql_text_100;
DEF exact_matching_signature = '';
DEF force_matching_signature = '';
-- this gives you two level of “indirection”, aka it goes into PL/SQL that dumps a script that is later on executed
-- I use this for bar charts on edb360
DEF wait_class_colors = " CASE wait_class WHEN 'ON CPU' THEN '34CF27' WHEN 'Scheduler' THEN '9FFA9D' WHEN 'User I/O' THEN '0252D7' WHEN 'System I/O' THEN '1E96DD' ";
DEF wait_class_colors2 = " WHEN 'Concurrency' THEN '871C12' WHEN 'Application' THEN 'C42A05' WHEN 'Commit' THEN 'EA6A05' WHEN 'Configuration' THEN '594611'  ";
DEF wait_class_colors3 = " WHEN 'Administrative' THEN '75763E'  WHEN 'Network' THEN '989779' WHEN 'Other' THEN 'F571A0' ";
DEF wait_class_colors4 = " WHEN 'Cluster' THEN 'CEC3B5' WHEN 'Queueing' THEN 'C6BAA5' ELSE '000000' END ";
--
COL series_01 NEW_V series_01;
COL series_02 NEW_V series_02;
COL series_03 NEW_V series_03;
COL series_04 NEW_V series_04;
COL series_05 NEW_V series_05;
COL series_06 NEW_V series_06;
COL series_07 NEW_V series_07;
COL series_08 NEW_V series_08;
COL series_09 NEW_V series_09;
COL series_10 NEW_V series_10;
COL series_11 NEW_V series_11;
COL series_12 NEW_V series_12;
COL series_13 NEW_V series_13;
COL series_14 NEW_V series_14;
COL series_15 NEW_V series_15;
DEF series_01 = ''
DEF series_02 = ''
DEF series_03 = ''
DEF series_04 = ''
DEF series_05 = ''
DEF series_06 = ''
DEF series_07 = ''
DEF series_08 = ''
DEF series_09 = ''
DEF series_10 = ''
DEF series_11 = ''
DEF series_12 = ''
DEF series_13 = ''
DEF series_14 = ''
DEF series_15 = ''

-- Variables and controls for 9e_one_line_chart_plus
DEF skip_lchp = '--skip--';
VAR AWRPointsIni VARCHAR2(100);
VAR addAWRPoints VARCHAR2(32);
BEGIN
 :addAWRPoints:=(CASE '&&is_single_instance.' WHEN 'Y' THEN '' ELSE 'C' END)||
  '&&inst1_present.&&inst2_present.&&inst3_present.&&inst4_present.&&inst5_present.&&inst6_present.&&inst7_present.&&inst8_present.';
END;
/

-- get udump directory path
COL edb360_udump_path NEW_V edb360_udump_path FOR A500;
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') edb360_udump_path FROM &&v_dollar.parameter2 WHERE name = 'user_dump_dest';
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') edb360_udump_path FROM &&v_dollar.diag_info WHERE name = 'Diag Trace';

-- get pid
COL edb360_spid NEW_V edb360_spid FOR A5;
SELECT TO_CHAR(spid) edb360_spid FROM &&v_dollar.session s, &&v_dollar.process p WHERE s.sid = SYS_CONTEXT('USERENV', 'SID') AND p.addr = s.paddr;

SET TERM OFF;
SET HEA ON;
SET LIN 32767;
SET NEWP NONE;
SET PAGES &&def_max_rows.;
SET TAB OFF;
SET LONG 32000000;
SET LONGC 2000;
SET WRA ON;
SET TRIMS ON;
SET TRIM ON;
SET TI OFF;
SET TIMI OFF;
SET NUM 20;
SET SQLBL ON;
SET BLO .;
SET RECSEP OFF;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
DEF
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
SPO OFF;

-- log header
SPO &&edb360_log..txt;
PRO begin log
PRO
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
HOS ps -ef
DEF;
PRO Parameters
COL sid FOR A40;
COL name FOR A40;
COL value FOR A50;
COL display_value FOR A50;
COL update_comment NOPRI;
SELECT *
  FROM &&v_object_prefix.spparameter
 WHERE isspecified = 'TRUE'
 ORDER BY
       name,
       sid,
       ordinal;
COL sid CLE;
COL name CLE;
COL value CLE;
COL display_value CLE;
COL update_comment CLE;
COL cpu_load_threshold CLEAR
SHOW PARAMETERS;
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
SPO OFF;

-- processes
SET TERM ON;
HOS ps -ef >> &&edb360_log3..txt

-- main header
COL report_dbname NEW_V report_dbname;
SELECT CASE '&&edb360_conf_incl_dbname_index.' WHEN 'Y' THEN 'Database:&&database_name_short..' END report_dbname FROM DUAL
/
SPO &&edb360_main_report..html;
@@edb360_0d_html_header.sql
PRO </head>
PRO <body>

PRO <h1><em>&&edb360_conf_tool_page.eDB360</a></em> &&edb360_vYYNN.: 360-degree comprehensive report on an Oracle database &&db_version. &&edb360_conf_all_pages_logo.</h1>
PRO
PRO <pre>
--PRO version:&&db_version. dbmod:&&edb360_dbmod. host:&&host_hash. license:&&license_pack. days:&&history_days. This report covers the time interval between &&edb360_date_from. and &&edb360_date_to. Timestamp: &&edb360_time_stamp.
PRO &&report_dbname. License:&&license_pack.. This report covers the time interval between &&edb360_date_from. and &&edb360_date_to.. Days:&&history_days.. Timestamp:&&edb360_time_stamp..
PRO </pre>
PRO
SPO OFF;

-- ash
HOS zip -mj &&edb360_zip_filename. awr_ash_pre_check_*.txt >> &&edb360_log3..txt
HOS zip -mj &&edb360_zip_filename. verify_stats_wr_sys_*.txt >> &&edb360_log3..txt
-- osw
--HOS zip -r osw_&&esp_host_name_short..zip `ps -ef | grep OSW | grep FM | awk -F 'OSW' '{print $2}' | cut -f 3 -d ' '`
--HOS zip -mT &&edb360_zip_filename. osw_&&esp_host_name_short..zip
-- zip esp into main
HOS zip -mj &&edb360_zip_filename. escp_output_&&esp_host_name_short._&&esp_collection_yyyymmdd..zip >> &&edb360_log3..txt
-- zip other files
HOS zip -mj &&edb360_zip_filename. 00000_readme_first_&&my_sid..txt >> &&edb360_log3..txt
HOS zip -j &&edb360_zip_filename. js/sorttable.js >> &&edb360_log3..txt
HOS zip -j &&edb360_zip_filename. js/edb360_img.jpg >> &&edb360_log3..txt
HOS zip -j &&edb360_zip_filename. js/database.jpg >> &&edb360_log3..txt
HOS zip -j &&edb360_zip_filename. js/edb360_favicon.ico >> &&edb360_log3..txt
HOS zip -j &&edb360_zip_filename. js/edb360_dlp.js >> &&edb360_log3..txt

