SPO repo_eadam2_restore_log1.txt APP;

-- called by repo_eadam2_restore.sql passing view to add to repository
DEF dd_view_name = '&1.';

-- compute object names
SELECT NULL repo_external_table_name, NULL repo_heap_table_name, NULL source_view_name FROM DUAL;
SELECT REPLACE(LOWER(table_name), '#', 'e') repo_external_table_name,
       LOWER(table_name) repo_heap_table_name,
       LOWER(view_name) source_view_name
  FROM &&tool_repo_user..&&tool_prefix_0.tab_columns
 WHERE view_name = UPPER(TRIM('&&dd_view_name.'))
   AND ROWNUM = 1;

-- computes if view contains_long_column
SELECT CASE 
       WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N'
       END contains_long_column
  FROM &&tool_repo_user..&&tool_prefix_0.tab_columns
 WHERE view_name = UPPER(TRIM('&&dd_view_name.'))
   AND data_type = 'LONG'
   AND ROWNUM = 1;

-- computes if view contains_xmltype_column
SELECT CASE 
       WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N'
       END contains_xmltype_column
  FROM &&tool_repo_user..&&tool_prefix_0.tab_columns
 WHERE view_name = UPPER(TRIM('&&dd_view_name.'))
   AND data_type = 'XMLTYPE'
   AND ROWNUM = 1;

-- computes if view_exists
SELECT CASE 
       WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N'
       END view_exists
  FROM &&tool_repo_user..&&tool_prefix_0.tab_columns
 WHERE view_name = UPPER(TRIM('&&dd_view_name.'))
   AND ROWNUM = 1;

-- creates script to deal with one view
DECLARE
  l_external_table_column_list VARCHAR2(32767);
  l_heap_table_column_list VARCHAR2(32767);
  l_insert_column_list VARCHAR2(32767);
  l_select_column_list VARCHAR2(32767);
BEGIN
  IF /* view exists */ '&&view_exists.' = 'Y' THEN
    :script_one := :script_template;                                                 
    :script_one := REPLACE(:script_one, '<EXTERNAL_TABLE_NAME>', '&&repo_external_table_name.');                                                 
    :script_one := REPLACE(:script_one, '<HEAP_TABLE_NAME>', '&&repo_heap_table_name.');                                                 
    FOR i IN (SELECT column_name, data_type, data_length FROM &&tool_repo_user..&&tool_prefix_0.tab_columns WHERE view_name = UPPER(TRIM('&&dd_view_name.')) ORDER BY column_id)                                                                                                  
    LOOP                                                                                                  
      l_external_table_column_list := l_external_table_column_list||', '||RPAD(LOWER(i.column_name), 31)||'VARCHAR2(4000)'||CHR(10);
      l_heap_table_column_list := l_heap_table_column_list||', '||RPAD(LOWER(i.column_name), 31)||REPLACE(i.data_type,'LONG', 'CLOB');
      IF i.data_type IN ('VARCHAR2', 'CHAR', 'RAW') THEN
        l_heap_table_column_list := l_heap_table_column_list||'('||i.data_length||')';
      END IF;      
      l_heap_table_column_list := l_heap_table_column_list||CHR(10);
      l_insert_column_list := l_insert_column_list||', '||LOWER(i.column_name)||CHR(10);
      IF i.data_type = 'XMLTYPE' THEN
        l_select_column_list := l_select_column_list||', XMLTYPE(''<eadam2>NULL</eadam2>'')'||CHR(10);      
      ELSE
        l_select_column_list := l_select_column_list||', '||LOWER(i.column_name)||CHR(10);
      END IF;
    END LOOP;
    l_external_table_column_list := TRIM(CHR(10) FROM TRIM(',' FROM l_external_table_column_list));
    l_heap_table_column_list := TRIM(CHR(10) FROM TRIM(',' FROM l_heap_table_column_list));
    IF '&&contains_xmltype_column.' = 'Y' THEN
      l_insert_column_list := CHR(10)||'('||TRIM(',' FROM l_insert_column_list)||')';
      l_select_column_list := CHR(10)||' '||TRIM(',' FROM l_select_column_list);
    ELSE
      l_insert_column_list := '';                                                 
      l_select_column_list := '*';                                                 
    END IF;
    :script_one := REPLACE(:script_one, '<EXTERNAL_TABLE_COLUMN_LIST>', l_external_table_column_list);                                                 
    :script_one := REPLACE(:script_one, '<HEAP_TABLE_COLUMN_LIST>', l_heap_table_column_list);                                                 
    :script_one := REPLACE(:script_one, '<INSERT_COLUMN_LIST>', l_insert_column_list);                                                 
    :script_one := REPLACE(:script_one, '<SELECT_COLUMN_LIST>', l_select_column_list);                                                 
  ELSE
    :script_one := 'PRO view &&source_view_name. does not exist on repo_eadam2_&&tool_repo_db_name..zip';
  END IF;
END;
/

SET ECHO OFF;
SET FEED OFF;
SET HEA OFF;
SET TIM OFF;
SET TIMI OFF;
SET VER OFF;

SPO OFF;
SPO repo_eadam2_restore_&&repo_heap_table_name._script.sql
PRINT script_one;
SPO OFF;

SET ECHO ON;
SET FEED ON;
SET HEA ON;
SET TIM ON;
SET TIMI ON;
SET VER ON;

SPO repo_eadam2_restore_log1.txt APP;
@repo_eadam2_restore_&&repo_heap_table_name._script.sql
SPO OFF;

HOS zip -m repo_eadam2_logs repo_eadam2_restore_&&repo_heap_table_name._script.sql >> repo_eadam2_restore_log2.txt
HOS zip -q repo_eadam2_logs repo_eadam2_restore_log2.txt

