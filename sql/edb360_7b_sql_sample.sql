@@&&edb360_0g.tkprof.sql
DEF section_id = '7b';
DEF section_name = 'SQL Sample';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');

SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;
SET TERM ON;
CL SCR;
PRO Searching for top SQL ...
PRO Please wait ...
SET TERM OFF; 

COL call_sqld360_bitmask NEW_V call_sqld360_bitmask FOR A6;
SELECT SUBSTR(
CASE '&&diagnostics_pack.' WHEN 'Y' THEN '1' ELSE '0' END||
CASE '&&tuning_pack.' WHEN 'Y' THEN '1' ELSE '0' END||
'0'|| -- TCB
LPAD(TRIM('&&edb360_conf_days.'), 3, '0')
, 1, 6) call_sqld360_bitmask
FROM DUAL;

COL call_sqld360_bitmask_tc NEW_V call_sqld360_bitmask_tc FOR A6;
SELECT SUBSTR(
CASE '&&diagnostics_pack.' WHEN 'Y' THEN '1' ELSE '0' END||
CASE '&&tuning_pack.' WHEN 'Y' THEN '1' ELSE '0' END||
'1'|| -- TCB
LPAD(TRIM('&&edb360_conf_days.'), 3, '0')
, 1, 6) call_sqld360_bitmask_tc
FROM DUAL;

DEF files_prefix = '';

-- watchdog
COL edb360_bypass NEW_V edb360_bypass;
SELECT ' echo timeout ' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds
/

-- to avoid in 12cR2 and 18c ORA-32034: unsupported use of WITH clause
def sq_fact_sql_sample_hints="inline" 
def &&skip_12r2_column.&&skip_18c_column. sq_fact_sql_sample_hints="&&sq_fact_hints."

COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;
SET VER OFF FEED OFF SERVEROUT ON HEAD OFF PAGES 50000 LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF;
SPO &&edb360_output_directory.99930_&&common_edb360_prefix._top_sql_driver.sql;
DECLARE
  l_count NUMBER := 0;
  CURSOR sql_cur IS
              WITH ranked_sql AS (
            SELECT /*+ &&sq_fact_sql_sample_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
                   /* &&section_id..&&report_sequence. */
                   &&skip_11g_column.&&skip_10g_column.con_id,
                   dbid,
                   sql_id,
                   MAX(user_id) user_id,
                   MAX(module) module,
                   ROUND(COUNT(*) / 360, 6) db_time_hrs,
                   ROUND(SUM(CASE session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) / 360, 6) cpu_time_hrs,
                   ROUND(SUM(CASE WHEN session_state = 'WAITING' AND wait_class IN ('User I/O', 'System I/O') THEN 1 ELSE 0 END) / 360, 6) io_time_hrs,
                   ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rank_num
              FROM &&awr_object_prefix.active_sess_history h
             WHERE sql_id IS NOT NULL
               AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
               AND dbid = &&edb360_dbid.
               AND '&&edb360_bypass.' IS NULL
             GROUP BY
                   &&skip_11g_column.&&skip_10g_column.con_id,
                   dbid,
                   sql_id
            HAVING COUNT(*) > 60 -- >10min
            ),
            top_sql AS (
            SELECT /*+ &&sq_fact_sql_sample_hints. &&section_id..&&report_sequence. */
                   &&skip_11g_column.&&skip_10g_column.r.con_id,
                   r.sql_id,
                   TRIM(TO_CHAR(ROUND(r.db_time_hrs, 2), '99990.00')) db_time_hrs,
                   TRIM(TO_CHAR(ROUND(r.cpu_time_hrs, 2), '99990.00')) cpu_time_hrs,
                   TRIM(TO_CHAR(ROUND(r.io_time_hrs, 2), '99990.00')) io_time_hrs,
                   r.rank_num,
                   NVL((SELECT a.name FROM audit_actions a WHERE a.action = h.command_type), TO_CHAR(h.command_type)) command_type,
                   NVL((SELECT u.username FROM &&dva_object_prefix.users u WHERE u.user_id = r.user_id), TO_CHAR(r.user_id)) username,
                   r.module,
                   --h.sql_text,
                   CASE 
                   WHEN h.sql_text IS NULL THEN 'unknown'
                   ELSE REPLACE(REPLACE(REPLACE(REPLACE(DBMS_LOB.SUBSTR(h.sql_text, 1000), CHR(10), ' '), '"', CHR(38)||'#34;'), '>', CHR(38)||'#62;'), '<', CHR(38)||'#60;')
                   END sql_text_1000
              FROM ranked_sql r,
                   &&awr_object_prefix.sqltext h
             WHERE r.rank_num <= &&edb360_conf_top_sql.
               &&skip_11g_column.&&skip_10g_column.AND h.con_id(+) = r.con_id
               AND h.dbid(+) = r.dbid
               AND h.sql_id(+) = r.sql_id
            ),
            not_shared AS (
            SELECT /*+ &&sq_fact_sql_sample_hints. &&section_id..&&report_sequence. */
                   &&skip_11g_column.&&skip_10g_column.con_id,
                   sql_id, COUNT(*) child_cursors,
                   RANK() OVER (ORDER BY COUNT(*) DESC NULLS LAST) AS sql_rank
              FROM &&gv_object_prefix.sql_shared_cursor
             WHERE sql_id NOT IN (SELECT sql_id FROM top_sql)
             GROUP BY
                   &&skip_11g_column.&&skip_10g_column.con_id,
                   sql_id
            HAVING COUNT(*) > 100
            ),
            top_not_shared AS (
            SELECT /*+ &&sq_fact_sql_sample_hints. &&section_id..&&report_sequence. */
                   DISTINCT
                   ns.sql_rank,
                   ns.child_cursors,
                   &&skip_11g_column.&&skip_10g_column.ns.con_id,
                   ns.sql_id,
                   REPLACE(REPLACE(REPLACE(REPLACE(DBMS_LOB.SUBSTR(s.sql_fulltext, 1000), CHR(10), ' '), '"', CHR(38)||'#34;'), '>', CHR(38)||'#62;'), '<', CHR(38)||'#60;') sql_text_1000
              FROM not_shared ns, &&gv_object_prefix.sql s
             WHERE s.sql_id(+) = ns.sql_id
               &&skip_11g_column.&&skip_10g_column.AND s.con_id(+) = ns.con_id
               AND ns.sql_rank <= &&edb360_conf_top_cur.
            ),
            by_signature AS (
            SELECT /*+ FULL(ts) FULL(ns) USE_HASH(ts ns h) &&sq_fact_sql_sample_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
                   /* &&section_id..&&report_sequence. */
                   &&skip_11g_column.&&skip_10g_column.h.con_id,
                   h.force_matching_signature,
                   h.dbid,
                   ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
                   COUNT(DISTINCT h.sql_id) distinct_sql_id,
                   MIN(h.sql_id) sample_sql_id,
                   COUNT(*) samples
              FROM &&awr_object_prefix.active_sess_history h,
                   top_sql ts,
                   top_not_shared ns
             WHERE h.sql_id IS NOT NULL
               AND h.force_matching_signature IS NOT NULL
               AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
               AND h.dbid = &&edb360_dbid.
               AND h.sql_id = ts.sql_id(+)
               &&skip_11g_column.&&skip_10g_column.AND h.con_id = ts.con_id(+)
               AND h.sql_id = ns.sql_id(+)
               &&skip_11g_column.&&skip_10g_column.AND h.con_id = ns.con_id(+)
               AND ts.sql_id(+) IS NULL
               AND ns.sql_id(+) IS NULL
               AND '&&edb360_bypass.' IS NULL
             GROUP BY
                   &&skip_11g_column.&&skip_10g_column.h.con_id,
                   h.force_matching_signature,
                   h.dbid
            HAVING COUNT(*) > 60 -- >10min
            ),
            top_signature AS (
            SELECT /*+ &&sq_fact_sql_sample_hints. &&section_id..&&report_sequence. */
                   r.rn,
                   &&skip_11g_column.&&skip_10g_column.r.con_id,
                   r.force_matching_signature,
                   r.distinct_sql_id,
                   r.sample_sql_id,
                   r.samples,
                   CASE 
                   WHEN h.sql_text IS NULL THEN 'unknown'
                   ELSE REPLACE(REPLACE(REPLACE(REPLACE(DBMS_LOB.SUBSTR(h.sql_text, 1000), CHR(10), ' '), '"', CHR(38)||'#34;'), '>', CHR(38)||'#62;'), '<', CHR(38)||'#60;')
                   END sql_text_1000
              FROM by_signature r,
                   &&awr_object_prefix.sqltext h
             WHERE r.rn <= &&edb360_conf_top_sig.
               &&skip_11g_column.&&skip_10g_column.AND h.con_id(+) = r.con_id
               AND h.dbid(+) = r.dbid
               AND h.sql_id(+) = r.sample_sql_id
            )
            SELECT rank_num,
                   &&skip_11g_column.&&skip_10g_column.con_id,
                   &&skip_12c_column.&&skip_18c_column.&&skip_19c_column.TO_NUMBER(NULL) con_id,
                   &&skip_11g_column.&&skip_10g_column.(SELECT pd.pdb_name FROM dba_pdbs pd WHERE pd.con_id = ts.con_id) pdb_name,
                   &&skip_12c_column.&&skip_18c_column.&&skip_19c_column.NULL pdb_name,
                   sql_id,
                   db_time_hrs, -- not null means Top as per DB time
                   cpu_time_hrs, -- not null means Top as per DB time
                   io_time_hrs, -- not null means Top as per DB time
                   command_type, -- not null means Top as per DB time
                   username, -- not null means Top as per DB time
                   module, -- not null means Top as per DB time
                   sql_text_1000,
                   1 top_type, -- as per DB time
                   0 child_cursors, -- <> 0 means Top as per number of cursors
                   0 signature, -- <> 0 means Top as per signature
                   0 distinct_sql_id -- <> 0 means Top as per signature
              FROM top_sql ts
             UNION ALL
            SELECT sql_rank rank_num,
                   &&skip_11g_column.&&skip_10g_column.con_id,
                   &&skip_12c_column.&&skip_18c_column.&&skip_19c_column.TO_NUMBER(NULL) con_id,
                   &&skip_11g_column.&&skip_10g_column.(SELECT pd.pdb_name FROM dba_pdbs pd WHERE pd.con_id = ns.con_id) pdb_name,
                   &&skip_12c_column.&&skip_18c_column.&&skip_19c_column.NULL pdb_name,
                   sql_id,
                   NULL db_time_hrs, -- not null means Top as per DB time
                   NULL cpu_time_hrs, -- not null means Top as per DB time
                   NULL io_time_hrs, -- not null means Top as per DB time
                   NULL command_type, -- not null means Top as per DB time
                   NULL username, -- not null means Top as per DB time
                   NULL module, -- not null means Top as per DB time
                   --sql_text sql_text_1000,
                   sql_text_1000,
                   2 top_type, -- as per not shared cursors
                   child_cursors, -- <> 0 means Top as per number of cursors
                   0 signature, -- <> 0 means Top as per signature
                   0 distinct_sql_id -- <> 0 means Top as per signature
              FROM top_not_shared ns    
             UNION ALL
            SELECT rn rank_num,
                   &&skip_11g_column.&&skip_10g_column.con_id,
                   &&skip_12c_column.&&skip_18c_column.&&skip_19c_column.TO_NUMBER(NULL) con_id,
                   &&skip_11g_column.&&skip_10g_column.(SELECT pd.pdb_name FROM dba_pdbs pd WHERE pd.con_id = ts.con_id) pdb_name,
                   &&skip_12c_column.&&skip_18c_column.&&skip_19c_column.NULL pdb_name,
                   sample_sql_id sql_id,
                   NULL db_time_hrs, -- not null means Top as per DB time
                   NULL cpu_time_hrs, -- not null means Top as per DB time
                   NULL io_time_hrs, -- not null means Top as per DB time
                   NULL command_type, -- not null means Top as per DB time
                   NULL username, -- not null means Top as per DB time
                   NULL module, -- not null means Top as per DB time
                   sql_text_1000,
                   3 top_type, -- as per force matching signature
                   0 child_cursors, -- <> 0 means Top as per number of cursors
                   force_matching_signature signature, -- <> 0 means Top as per signature
                   distinct_sql_id -- <> 0 means Top as per signature
              FROM top_signature ts
              ORDER BY 1, 10, 3 DESC, 2;
  sql_rec sql_cur%ROWTYPE;
  PROCEDURE put_line(p_line IN VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put_line;
  PROCEDURE update_log(p_module IN VARCHAR2) IS
  BEGIN
    put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
    put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
    put_line('PRO PRO update log');
    put_line('SPO &&edb360_log..txt APP;');
    put_line('SET HEAD OFF TERM ON;');
    put_line('PRO '||CHR(38)||chr(38)||'hh_mm_ss. '||p_module);
    put_line('SELECT ''Elapsed Hours so far: ''||ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3) FROM DUAL;');
    put_line('SET HEAD ON TERM OFF;');
    put_line('SPO OFF;');
  END update_log;
BEGIN
  OPEN sql_cur;
  LOOP
    FETCH sql_cur INTO sql_rec;
    EXIT WHEN sql_cur%NOTFOUND;
    put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
    put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
    put_line('PRO PRO update log');
    put_line('SPO &&edb360_log..txt APP;');
    put_line('PRO');
    put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    put_line('PRO');
    put_line('PRO rank:'||sql_rec.rank_num||' sql_id:'||sql_rec.sql_id);
    put_line('SPO OFF;');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
    put_line('PRO PRO update main report1');
    put_line('SPO &&edb360_main_report..html APP;');
    put_line('PRO <li title="pdb:'||sql_rec.pdb_name||' user:'||sql_rec.username||' module:'||sql_rec.module);
    put_line('PRO '||sql_rec.sql_text_1000||'">');
    IF sql_rec.top_type = 1 THEN
      put_line('PRO rank:'||sql_rec.rank_num||' '||sql_rec.sql_id||' et:'||sql_rec.db_time_hrs||'h cpu:'||sql_rec.cpu_time_hrs||'h io:'||sql_rec.io_time_hrs||'h type:'||SUBSTR(sql_rec.command_type, 1, 6));
    ELSIF sql_rec.top_type = 2 THEN
      put_line('PRO rank:'||sql_rec.rank_num||' '||sql_rec.sql_id||' cursors:'||sql_rec.child_cursors);
    ELSIF sql_rec.top_type = 3 THEN
      put_line('PRO rank:'||sql_rec.rank_num||' '||sql_rec.sql_id||' signature:'||sql_rec.signature||'('||sql_rec.distinct_sql_id||')');
    END IF;
    put_line('SET HEAD OFF VER OFF FEED OFF ECHO OFF;');
    put_line('SELECT ''*** time limit exceeded ***'' FROM DUAL WHERE '''||CHR(38)||CHR(38)||'edb360_bypass.'' IS NOT NULL;');
    put_line('SPO OFF;');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
    put_line('EXEC :repo_seq := :repo_seq + 1;');
    put_line('SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;');
    IF '&&db_version.' >= '12' AND sql_rec.pdb_name IS NOT NULL THEN
      put_line('SPO &&edb360_log..txt APP;');
      put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      put_line('PRO PRO changes PDB to '||sql_rec.pdb_name);
      put_line('ALTER SESSION SET CONTAINER = '||sql_rec.pdb_name||';');
      put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      put_line('SPO OFF;');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
    END IF;
    IF sql_rec.rank_num <= &&edb360_conf_planx_top. AND '&&skip_non_repo_script.' IS NULL THEN
      put_line('COL edb360_bypass NEW_V edb360_bypass;');
      put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
      update_log('PLANX rank:'||sql_rec.rank_num||' SQL_ID:'||sql_rec.sql_id||' TOP_type:'||sql_rec.top_type);
      put_line('@@'||CHR(38)||CHR(38)||'edb360_bypass.sql/planx.sql &&diagnostics_pack. '||sql_rec.sql_id);
      put_line('PRO PRO update main report2');
      put_line('SPO &&edb360_main_report..html APP;');
      put_line('PRO <a href="planx_'||sql_rec.sql_id||'_'||CHR(38)||chr(38)||'current_time..txt">planx(text)</a>');
      put_line('SPO OFF;');
      put_line('PRO PRO zip');
      put_line('HOS zip -mj &&edb360_zip_filename. planx_'||sql_rec.sql_id||'_'||CHR(38)||chr(38)||'current_time..txt >> &&edb360_log3..txt');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
    END IF;
    IF sql_rec.rank_num <= &&edb360_conf_sqlmon_top. AND '&&skip_10g_script.' IS NULL AND '&&skip_diagnostics.' IS NULL AND '&&skip_tuning.' IS NULL AND '&&skip_non_repo_script.' IS NULL THEN
      put_line('COL edb360_bypass NEW_V edb360_bypass;');
      put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
      update_log('SQLMON rank:'||sql_rec.rank_num||' SQL_ID:'||sql_rec.sql_id||' TOP_type:'||sql_rec.top_type);
      put_line('@@'||CHR(38)||CHR(38)||'edb360_bypass.sql/sqlmon.sql &&tuning_pack. '||sql_rec.sql_id);
      put_line('PRO PRO update main report3');
      put_line('SPO &&edb360_main_report..html APP;');
      put_line('PRO <a href="sqlmon_'||sql_rec.sql_id||'_'||CHR(38)||chr(38)||'current_time..zip">sqlmon(zip)</a>');
      put_line('SPO OFF;');
      put_line('PRO PRO zip');
      put_line('HOS zip -mj &&edb360_zip_filename. sqlmon_'||sql_rec.sql_id||'_'||CHR(38)||chr(38)||'current_time..zip >> &&edb360_log3..txt');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
    END IF;
    IF sql_rec.rank_num <= &&edb360_conf_sqlash_top. AND '&&skip_diagnostics.' IS NULL AND '&&skip_non_repo_script.' IS NULL THEN
      put_line('COL edb360_bypass NEW_V edb360_bypass;');
      put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
      update_log('SQLASH rank:'||sql_rec.rank_num||' SQL_ID:'||sql_rec.sql_id||' TOP_type:'||sql_rec.top_type);
      put_line('@@'||CHR(38)||CHR(38)||'edb360_bypass.sql/sqlash.sql &&diagnostics_pack. '||sql_rec.sql_id);
      put_line('PRO PRO update main report4');
      put_line('SPO &&edb360_main_report..html APP;');
      put_line('PRO <a href="sqlash_'||sql_rec.sql_id||'.zip">sqlash(zip)</a>');
      put_line('SPO OFF;');
      put_line('PRO PRO zip');
      put_line('HOS zip -mj &&edb360_zip_filename. sqlash_'||sql_rec.sql_id||'.zip >> &&edb360_log3..txt');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
    END IF;
    IF sql_rec.rank_num <= &&edb360_conf_sqlhc_top. AND '&&skip_non_repo_script.' IS NULL THEN
      put_line('COL edb360_bypass NEW_V edb360_bypass;');
      put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
      update_log('SQLHC rank:'||sql_rec.rank_num||' SQL_ID:'||sql_rec.sql_id||' TOP_type:'||sql_rec.top_type);
      put_line('@@'||CHR(38)||CHR(38)||'edb360_bypass.sql/sqlhc.sql &&license_pack. '||sql_rec.sql_id);
      put_line('PRO PRO update main report5');
      put_line('SPO &&edb360_main_report..html APP;');
      put_line('PRO <a href="'||CHR(38)||chr(38)||'files_prefix..zip">sqlhc(zip)</a>');
      put_line('SPO OFF;');
      put_line('PRO PRO zip');
      put_line('HOS zip -mj &&edb360_zip_filename. '||CHR(38)||chr(38)||'files_prefix..zip >> &&edb360_log3..txt');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
    END IF;
    IF sql_rec.rank_num <= &&edb360_conf_sqld360_top. THEN
      /* moved down into its own cursor loop (to avoid planx hanging */
      put_line('PRO PRO update main report6');
      put_line('SPO &&edb360_main_report..html APP;');
      put_line('PRO <a href="sqld360_&&edb360_dbmod._'||sql_rec.sql_id||'_&&host_hash._&&edb360_file_time..zip">sqld360(zip)</a>');
      put_line('SPO OFF;');
      put_line('PRO PRO zip');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
    END IF;
    put_line('PRO PRO update main report7');
    put_line('SPO &&edb360_main_report..html APP;');
    put_line('PRO </li>');
    put_line('SPO OFF;');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt');
  END LOOP;
  CLOSE sql_cur;
  IF '&&db_version.' >= '12' AND '&&edb360_pdb_name.' <> 'NONE' THEN
    put_line('SPO &&edb360_log..txt APP;');
    put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    put_line('PRO PRO changes PDB to &&edb360_pdb_name.');
    put_line('ALTER SESSION SET CONTAINER = &&edb360_pdb_name.;');
    put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    put_line('SPO OFF;');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
  END IF;
  -- SQLd360
  put_line('PRO');
  put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  put_line('PRO');
  put_line('PRO prepares to execute sqld360');
  put_line('PRO PRO deleting content of global temporary table "plan_table" as preparation to execute sqld360');
  put_line('DELETE plan_table;');
  OPEN sql_cur;
  LOOP
    FETCH sql_cur INTO sql_rec;
    EXIT WHEN sql_cur%NOTFOUND;
    l_count := l_count + 1;
    IF sql_rec.rank_num <= &&edb360_conf_sqld360_top. THEN
      update_log('SQLD360 rank:'||sql_rec.rank_num||' SQL_ID:'||sql_rec.sql_id||' TOP_type:'||sql_rec.top_type);
      put_line('PRO PRO prepares execution of sqld360');
      IF sql_rec.rank_num <= &&edb360_conf_sqld360_top_tc. THEN
        put_line('INSERT INTO plan_table (id, statement_id, operation, options, object_node) SELECT '||sql_rec.rank_num||', ''SQLD360_SQLID'', '''||sql_rec.sql_id||''', ''&&call_sqld360_bitmask_tc.'', '''||sql_rec.pdb_name||''' FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  <  :edb360_max_seconds;');
      ELSE
        put_line('INSERT INTO plan_table (id, statement_id, operation, options, object_node) SELECT '||sql_rec.rank_num||', ''SQLD360_SQLID'', '''||sql_rec.sql_id||''', ''&&call_sqld360_bitmask.'', '''||sql_rec.pdb_name||''' FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  <  :edb360_max_seconds;');
      END IF;
    END IF;
  END LOOP;
  CLOSE sql_cur;
  IF l_count > 0 THEN
    put_line('UNDEF 1');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_output_directory.99930_&&common_edb360_prefix._top_sql_driver.sql >> &&edb360_log3..txt');
    put_line('SPO &&edb360_log..txt APP;');
    put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    put_line('PRO PRO plan_table content before calling sqld360');
    put_line('SELECT operation||'' ''||object_node||'' ''||options||'' ''||object_node FROM plan_table WHERE statement_id = ''SQLD360_SQLID'';');
    put_line('SPO OFF;');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
    IF '&&skip_diagnostics.' IS NULL AND '&&edb360_conf_incl_eadam.' = 'Y' THEN
      put_line('SPO &&edb360_log..txt APP;');
      put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      put_line('DEF;');
      put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      put_line('PRO PRO calling eadam (ash) for top sql and peak snaps');
      put_line('COL edb360_bypass NEW_V edb360_bypass;');
      put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
      put_line('EXEC DBMS_APPLICATION_INFO.SET_MODULE(''&&edb360_prefix.'',''eadam'');');
      put_line('SPO OFF;');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
      put_line('@@sql/'||CHR(38)||CHR(38)||'edb360_bypass.&&skip_diagnostics.&&edb360_7c.eadam.sql');
    END IF;
    put_line('SPO &&edb360_log..txt APP;');
    put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    put_line('PRO PRO seconds left on eDB360 before calling SQLd360');
    put_line('VAR edb360_secs2go NUMBER;');
    put_line('EXEC :edb360_secs2go := 0;');
    put_line('EXEC :edb360_secs2go := :edb360_max_seconds - ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100);');
    put_line('PRINT :edb360_secs2go;');
    put_line('DEF edb360_secs2go = ''0'';');
    put_line('COL edb360_secs2go NEW_V edb360_secs2go FOR A8;');
    put_line('SELECT TO_CHAR(:edb360_secs2go) edb360_secs2go FROM DUAL;');
    put_line('PRO PRO calling sqld360');
    put_line('COL edb360_bypass NEW_V edb360_bypass;');
    put_line('SELECT '' echo timeout '' edb360_bypass FROM DUAL WHERE (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100  >  :edb360_max_seconds;');
    put_line('EXEC DBMS_APPLICATION_INFO.SET_MODULE(''&&edb360_prefix.'',''sqld360'');');
    put_line('SPO OFF;');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
    -- actual execution of sql/sqld360.sql
    put_line('@@'||CHR(38)||CHR(38)||'edb360_bypass.sqld360.sql');
    IF '&&db_version.' >= '12' AND '&&edb360_pdb_name.' NOT IN ('NONE', 'CDB$ROOT', 'PDB$SEED') THEN
      put_line('SPO &&edb360_log..txt APP;');
      put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      put_line('PRO PRO returns to original PDB');
      put_line('ALTER SESSION SET CONTAINER = &&edb360_pdb_name.;');
      put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      put_line('SPO OFF;');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
      put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
    END IF;
  END IF;
END;
/
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_output_directory.99930_&&common_edb360_prefix._top_sql_driver.sql >> &&edb360_log3..txt

SET TERM ON;
PRO Please wait ...
SET TERM OFF; 

-- execute dynamic script with sqld360 and others
@&&edb360_output_directory.99930_&&common_edb360_prefix._top_sql_driver.sql;

SET TERM ON;
PRO Please wait ...
SET TERM OFF; 

-- closing
SET VER OFF FEED OFF SERVEROUT ON HEAD OFF PAGES 50000 LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SPO &&edb360_output_directory.99950_&&common_edb360_prefix._top_sql_driver.sql;
DECLARE
  l_count NUMBER := 0;
  PROCEDURE put_line(p_line IN VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put_line;
  PROCEDURE update_log(p_module IN VARCHAR2) IS
  BEGIN
        put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
		put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
		put_line('PRO PRO update log');
		put_line('SPO &&edb360_log..txt APP;');
		put_line('PRO '||CHR(38)||chr(38)||'hh_mm_ss. '||p_module);
		put_line('SPO OFF;');
  END update_log;
BEGIN
  put_line('SPO &&edb360_log..txt APP;');
  put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  put_line('PRO PRO plan_table after calling sqld360');
  put_line('SELECT operation||'' ''||object_node||'' ''||remarks FROM plan_table WHERE statement_id = ''SQLD360_SQLID'';');
  put_line('SPO OFF;');
  put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
  put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
  FOR i IN (SELECT operation, remarks FROM plan_table WHERE statement_id = 'SQLD360_SQLID')
  LOOP
    l_count := l_count + 1;
    put_line('HOS mv '||i.remarks||' sqld360_&&edb360_dbmod._'||i.operation||'_&&host_hash._&&edb360_file_time..zip >> &&edb360_log3..txt');
    put_line('HOS zip -mj &&edb360_zip_filename. sqld360_&&edb360_dbmod._'||i.operation||'_&&host_hash._&&edb360_file_time..zip >> &&edb360_log3..txt');
  END LOOP;
  put_line('SPO &&edb360_log..txt APP;');
  IF l_count > 0 THEN
    put_line('PRO PRO just in case individual file "mv" failed');
    put_line('HOS zip -mj &&edb360_zip_filename. sqld360_*.zip >> &&edb360_log3..txt');
    -- do not delete plan_table since eadam script(next) needs it
  END IF;
  --put_line('PRO PRO deleting content of global temporary table "plan_table" as cleanup after sqld360');
  --put_line('DELETE plan_table;');
  put_line('SPO OFF;');
  put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
  put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
  IF '&&db_version.' >= '12' AND '&&edb360_pdb_name.' <> 'NONE' THEN
    put_line('SPO &&edb360_log..txt APP;');
    put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    put_line('PRO PRO changes PDB to &&edb360_pdb_name.');
    put_line('ALTER SESSION SET CONTAINER = &&edb360_pdb_name.;');
    put_line('PRO PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    put_line('SPO OFF;');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log..txt >> &&edb360_log3..txt');
    put_line('HOS zip -j &&edb360_zip_filename. &&edb360_log3..txt');
  END IF;
END;
/
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_output_directory.99950_&&common_edb360_prefix._top_sql_driver.sql >> &&edb360_log3..txt

SET TERM ON;
PRO Please wait ...
SET TERM OFF; 

-- execute dynamic script to rename sqld360 files and copy them into main zip
@&&edb360_output_directory.99950_&&common_edb360_prefix._top_sql_driver.sql;

SET TERM ON;
PRO Please wait ...
SET TERM OFF; 

-- closing
@@&&edb360_0g.tkprof.sql
SET SERVEROUT OFF HEAD ON PAGES &&def_max_rows.;
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.99930_&&common_edb360_prefix._top_sql_driver.sql &&edb360_output_directory.99950_&&common_edb360_prefix._top_sql_driver.sql sqld360_driver.sql >> &&edb360_log3..txt
SET HEA ON LIN 32767 NEWP NONE PAGES &&def_max_rows. LONG 32000000 LONGC 2000 WRA ON TRIMS ON TRIM ON TI OFF TIMI OFF NUM 20 SQLBL ON BLO . RECSEP OFF;
--COL row_num NEW_V row_num HEA '#' PRI;

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

