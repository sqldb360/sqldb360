-- called by repo_edb360_create.sql passing view to add to repository
DEF dd_view_name = '&1.';

-- computes repo_table_name
SELECT CASE
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'dba_hist_%' THEN '&&tool_repo_user..&&tool_prefix_1.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'dba_hist_')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'dba_%'      THEN '&&tool_repo_user..&&tool_prefix_2.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'dba_')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'gv$%'       THEN '&&tool_repo_user..&&tool_prefix_3.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'gv$')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'v$%'        THEN '&&tool_repo_user..&&tool_prefix_4.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'v$')
       END repo_table_name
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

-- computes if view_exists
SELECT CASE 
       WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N'
       END view_exists
  FROM dba_views
 WHERE owner = 'SYS'
   AND view_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$')
   AND ROWNUM = 1;

-- creates and executes ddl command + grants select on new repo table + gather stats on it
DECLARE
  l_list_ddl VARCHAR2(32767);
  l_list_sel VARCHAR2(32767);
  l_list_ins VARCHAR2(32767);
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
    drop_table('&&repo_table_name.');                                                 
    IF /* view contains LONG column(s) */ '&&contains_long_column.' = 'Y' THEN                                                 
      FOR i IN (SELECT column_name, data_type, data_length FROM dba_tab_columns WHERE owner = 'SYS' AND table_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$') ORDER BY column_id)                                                                                                  
      LOOP                                                                                                  
        l_list_ddl := l_list_ddl||','||LOWER(i.column_name)||' '||REPLACE(i.data_type,'LONG','CLOB');                                                                                                  
        IF i.data_type IN ('VARCHAR2', 'CHAR', 'RAW') THEN                                                                                                  
          l_list_ddl := l_list_ddl||'('||i.data_length||')';                                                                                                  
        END IF;                                                                                                  
        l_list_ins := l_list_ins||','||LOWER(i.column_name);                                                                                                  
        IF i.data_type = 'LONG' THEN                                                                                                  
          l_list_sel := l_list_sel||', TO_LOB('||LOWER(i.column_name)||')';                                                                                                  
        ELSE                                                                                                  
          l_list_sel := l_list_sel||', '||LOWER(i.column_name);                                                                                                  
        END IF;                                                                                                      
      END LOOP;                                                                                                  
      execute_immediate('CREATE TABLE &&repo_table_name. ('||TRIM(',' FROM l_list_ddl)||') &&compression_clause.');                                                                                                  
      execute_immediate('INSERT /*+ APPEND */ INTO &&repo_table_name. ('||TRIM(',' FROM l_list_ins)||') SELECT '||TRIM(',' FROM l_list_sel)||' FROM &&dd_view_name. &&query_predicate.');                                                                                                  
      execute_immediate('COMMIT');                                                                                                  
    ELSE /* view does not contain LONG column(s) */                                                  
      execute_immediate('CREATE TABLE &&repo_table_name. &&compression_clause. AS SELECT * FROM &&dd_view_name. &&query_predicate.');                                                 
    END IF; /* view contains LONG column(s) */
    execute_immediate('GRANT SELECT ON &&repo_table_name. TO SELECT_CATALOG_ROLE');
    DBMS_STATS.GATHER_TABLE_STATS(UPPER('&&tool_repo_user.'),REPLACE(UPPER('&&repo_table_name.'),UPPER('&&tool_repo_user..')));
  END IF; /* view exists */
END;
/
