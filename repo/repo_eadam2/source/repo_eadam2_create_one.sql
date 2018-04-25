SPO repo_eadam2_create_log1.txt APP;
SET TERM OFF;

-- called by repo_eadam2_create.sql passing view to add to repository
DEF dd_view_name = '&1.';

EXEC :view_counter :=  :view_counter + 1;
SELECT LPAD(:view_counter, 3, '0') view_counter, SYSDATE current_time FROM DUAL;

SET TERM ON;
PRO &&view_counter. &&current_time. &&dd_view_name.
SET TERM OFF;

-- computes repo_table_name
SELECT CASE
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'dba_hist_%' THEN '&&tool_prefix_1.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'dba_hist_')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'dba_%'      THEN '&&tool_prefix_2.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'dba_')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'gv$%'       THEN '&&tool_prefix_3.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'gv$')
       WHEN LOWER(TRIM('&&dd_view_name.')) LIKE 'v$%'        THEN '&&tool_prefix_4.'||REPLACE(LOWER(TRIM('&&dd_view_name.')),'v$')
       END repo_table_name
  FROM DUAL;

-- computes query_predicate
BEGIN
  :query_predicate := NULL;
  FOR i IN (SELECT table_name, column_name FROM dba_tab_columns WHERE owner = 'SYS' AND table_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$') AND column_name IN ('DBID', 'SNAP_ID', 'SQL_TEXT', 'SQL_FULLTEXT', 'ACCESS_PREDICATES', 'FILTER_PREDICATES') ORDER BY column_id)                                                                                                  
  LOOP                                                                                                  
    IF i.table_name LIKE 'DBA_HIST%' THEN
      IF i.column_name = 'DBID' THEN
        :query_predicate := :query_predicate||' AND v.dbid = &&tool_repo_dbid.';
      ELSIF i.column_name = 'SNAP_ID' THEN
        :query_predicate := :query_predicate||' AND v.snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.';
      END IF;
    END IF;
    IF i.column_name = 'SQL_TEXT' THEN
      :query_predicate := :query_predicate||' AND (v.sql_text IS NULL OR v.sql_text NOT LIKE ''%&&columns_delimiter.%'')';
    ELSIF i.column_name = 'SQL_FULLTEXT' THEN
      :query_predicate := :query_predicate||' AND (v.sql_fulltext IS NULL OR v.sql_fulltext NOT LIKE ''%&&columns_delimiter.%'')';
    ELSIF i.column_name = 'ACCESS_PREDICATES' THEN
      :query_predicate := :query_predicate||' AND (v.access_predicates IS NULL OR v.access_predicates NOT LIKE ''%&&columns_delimiter.%'')';
    ELSIF i.column_name = 'FILTER_PREDICATES' THEN
      :query_predicate := :query_predicate||' AND (v.filter_predicates IS NULL OR v.filter_predicates NOT LIKE ''%&&columns_delimiter.%'')';
    END IF;
  END LOOP;
  IF :query_predicate IS NOT NULL THEN
    :query_predicate := 'WHERE 1 = 1'||:query_predicate;
  END IF;
END;
/
SELECT 'query_predicate' title, :query_predicate query_predicate FROM DUAL;

SET COLSEP '&&columns_delimiter.';
SPO OFF;

------------------------------------------------------------------------------------------
-- view data
------------------------------------------------------------------------------------------

-- no need to exit since some views may not exist on older releases, then a empty file should be created
--WHENEVER SQLERROR CONTINUE;
SPO &&repo_table_name..txt
SELECT v.*, '$' dollar_sign FROM &&dd_view_name. v &&query_predicate.;
SPO OFF;
--WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- zip view data
HOS zip -m repo_eadam2_&&tool_repo_db_name. &&repo_table_name..txt >> repo_eadam2_create_log2.txt

------------------------------------------------------------------------------------------
-- columns metadata
------------------------------------------------------------------------------------------

SPO &&tool_prefix_0.tab_columns.txt APP
SELECT
  UPPER(TRIM('&&dd_view_name.')) view_name
, SUBSTR(UPPER('&&repo_table_name.'), 1, 30) table_name
, column_name   
, data_type     
, data_length   
, data_precision
, data_scale    
, nullable      
, column_id     
, char_length   
, char_used     
, '$' dollar_sign
FROM dba_tab_columns
WHERE owner = 'SYS'
AND table_name = REPLACE(UPPER(TRIM('&&dd_view_name.')), 'V$', 'V_$')
ORDER BY column_id;
SPO OFF;

-- zip columns (so far)
HOS zip repo_eadam2_&&tool_repo_db_name. &&tool_prefix_0.tab_columns.txt >> repo_eadam2_create_log2.txt

------------------------------------------------------------------------------------------
-- end
------------------------------------------------------------------------------------------

SET COLSEP ' ';

-- zip execution logs (so far)
HOS zip repo_eadam2_&&tool_repo_db_name. repo_eadam2_create_log1.txt >> repo_eadam2_create_log2.txt
HOS zip -q repo_eadam2_&&tool_repo_db_name. repo_eadam2_create_log2.txt
