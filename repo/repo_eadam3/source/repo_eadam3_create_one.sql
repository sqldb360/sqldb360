-- called by repo_eadam3_create.sql passing view to add to repository
DEF dd_view_name = '&1.';

-- computes repo_table_name
SELECT CASE
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'dba_hist_%' THEN '&&tool_repo_user..&&tool_prefix_1.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'dba_hist_')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'dba_%'      THEN '&&tool_repo_user..&&tool_prefix_2.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'dba_')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'gv$%'       THEN '&&tool_repo_user..&&tool_prefix_3.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'gv$')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'v$%'        THEN '&&tool_repo_user..&&tool_prefix_4.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'v$')
       END repo_table_name
  FROM DUAL;

-- computes expected dmp and log file names
SELECT '&&eadam3_directory_path./&&repo_table_name..dmp' dmp_file_name,
       '&&eadam3_directory_path./&&repo_table_name._t.dmp' dmp_file_name_t,
       '&&eadam3_directory_path./'||REPLACE(UPPER('&&repo_table_name.'),UPPER('&&tool_repo_user..'))||'*.log' log_file_name
  FROM DUAL;

-- computes query_predicate
SELECT CASE 
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'dba_hist_%' THEN 'WHERE dbid = &&tool_repo_dbid.'||(CASE COUNT(*) WHEN 1 THEN ' AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.' END)
       END query_predicate
  FROM dba_tab_columns
 WHERE owner = 'SYS'
   AND table_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$')
   AND column_name = 'SNAP_ID';

-- computes if view contains_long_column
SELECT CASE 
       WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N'
       END contains_long_column
  FROM dba_tab_columns
 WHERE owner = 'SYS'
   AND table_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$')
   AND data_type = 'LONG'
   AND ROWNUM = 1;

-- computes if view contains_xmltype_column
SELECT CASE 
       WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N'
       END contains_xmltype_column
  FROM dba_tab_columns
 WHERE owner = 'SYS'
   AND table_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$')
   AND data_type = 'XMLTYPE'
   AND ROWNUM = 1;

-- computes if view_exists
SELECT CASE 
       WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N'
       END view_exists
  FROM dba_views
 WHERE owner = 'SYS'
   AND view_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$')
   AND ROWNUM = 1;

-- tries removing prior dmp and log files from directory
HOS rm &&dmp_file_name. >> repo_eadam3_create_log2.txt
HOS rm &&dmp_file_name_t. >> repo_eadam3_create_log2.txt
HOS rm &&log_file_name. >> repo_eadam3_create_log2.txt

-- creates and executes ddl command + grants select on new repo table + gather stats on it
DECLARE
  l_list_sel_tbl VARCHAR2(32767);
  l_list_sel_vw VARCHAR2(32767);
  PROCEDURE execute_immediate (p_dynamyc_string IN VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_dynamyc_string);
    EXECUTE IMMEDIATE p_dynamyc_string;
  END execute_immediate;
  PROCEDURE drop_table (p_table_name IN VARCHAR2) IS
  BEGIN
    execute_immediate('DROP TABLE '||p_table_name);                                                 
  EXCEPTION                                                 
    WHEN OTHERS THEN                                                 
      DBMS_OUTPUT.PUT_LINE(SQLERRM);                                                 
  END drop_table;
BEGIN
  IF /* view exists */ '&&view_exists.' = 'Y' THEN
    IF /* view contains LONG or XMLTYPE column(s) */ '&&contains_long_column.' = 'Y' OR '&&contains_xmltype_column.' = 'Y' THEN                                                 
      FOR i IN (SELECT column_name, data_type, data_length FROM dba_tab_columns WHERE owner = 'SYS' AND table_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$') ORDER BY column_id)                                                                                                  
      LOOP                                                                                                  
        -- regular select list for query on ctas
        IF i.data_type = 'LONG' THEN                                                                                                  
          l_list_sel_tbl := l_list_sel_tbl||', TO_LOB('||LOWER(i.column_name)||') '||LOWER(i.column_name);
        ELSIF i.data_type = 'XMLTYPE' THEN
          l_list_sel_tbl := l_list_sel_tbl||', v.'||LOWER(i.column_name)||'.getclobval() XMLTYPE_'||LOWER(i.column_name);
        ELSE                                                                                                  
          l_list_sel_tbl := l_list_sel_tbl||', '||LOWER(i.column_name);                                                                                                  
        END IF;
        -- exceptional select list on view for tables with xmltype                                                 
        IF i.data_type = 'XMLTYPE' THEN                                                 
          l_list_sel_vw := l_list_sel_vw||', CASE WHEN XMLTYPE_'||LOWER(i.column_name)||' IS NOT NULL THEN xmltype(XMLTYPE_'||LOWER(i.column_name)||') END '||LOWER(i.column_name);                                                 
        ELSE                                                 
          l_list_sel_vw := l_list_sel_vw||', '||LOWER(i.column_name);                                                 
        END IF;                                                     
      END LOOP;                                                                                                  
      IF /* view contains XMLTYPE column(s) and possibly LONG column(s) */ '&&contains_xmltype_column.' = 'Y' THEN
        drop_table('&&repo_table_name._t');                                                 
        execute_immediate('CREATE TABLE &&repo_table_name._t &&tool_extt_syntax.''&&repo_table_name._t.dmp'')) AS SELECT '||TRIM(',' FROM l_list_sel_tbl)||' FROM &&dd_view_name. v &&query_predicate.');
        execute_immediate('GRANT SELECT ON &&repo_table_name._t TO SELECT_CATALOG_ROLE');
        DBMS_STATS.GATHER_TABLE_STATS(UPPER('&&tool_repo_user.'),REPLACE(UPPER('&&repo_table_name._t'),UPPER('&&tool_repo_user..')));
        -- create view to access table and restore XMLTYPE column(s)
        execute_immediate('CREATE OR REPLACE VIEW  &&repo_table_name.                                          AS SELECT '||TRIM(',' FROM l_list_sel_vw) ||' FROM &&repo_table_name._t');
        execute_immediate('GRANT SELECT ON &&repo_table_name.   TO SELECT_CATALOG_ROLE');
      ELSE /* view contains LONG column(s) and not XMLTYPE column(s) */
        drop_table('&&repo_table_name.');                                                 
        execute_immediate('CREATE TABLE &&repo_table_name.   &&tool_extt_syntax.''&&repo_table_name..dmp''))   AS SELECT '||TRIM(',' FROM l_list_sel_tbl)||' FROM &&dd_view_name.   &&query_predicate.');
        execute_immediate('GRANT SELECT ON &&repo_table_name.   TO SELECT_CATALOG_ROLE');
        DBMS_STATS.GATHER_TABLE_STATS(UPPER('&&tool_repo_user.'),REPLACE(UPPER('&&repo_table_name.'  ),UPPER('&&tool_repo_user..')));
      END IF;
    ELSE /* view does not contain LONG nor XMLTYPE column(s) */                                                  
        drop_table('&&repo_table_name.');                                                 
        execute_immediate('CREATE TABLE &&repo_table_name.   &&tool_extt_syntax.''&&repo_table_name..dmp''))   AS SELECT * FROM &&dd_view_name. &&query_predicate.');                                                 
        execute_immediate('GRANT SELECT ON &&repo_table_name.   TO SELECT_CATALOG_ROLE');
        DBMS_STATS.GATHER_TABLE_STATS(UPPER('&&tool_repo_user.'),REPLACE(UPPER('&&repo_table_name.'  ),UPPER('&&tool_repo_user..')));
    END IF; /* view contains LONG or XMLTYPE column(s) */
  END IF; /* view exists */
END;
/
