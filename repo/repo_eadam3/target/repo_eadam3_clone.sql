SPO repo_eadam3_clone_log.txt;
EXEC DBMS_APPLICATION_INFO.SET_MODULE('EADAM3','CLONE');
--WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO ON;
SET HEA ON;
SET LIN 1000;
SET LONG 32000000;
SET LONGC 2000;
SET PAGES 1000;
SET SERVEROUT ON;
SET TIM ON;
SET TIMI ON;
SET TRIMS ON;
SET VER ON;

-- prefix for eadam3 tables
DEF tool_prefix_0 = 'eadam3#';
-- prefix for AWR "dba_hist_" views
DEF tool_prefix_1 = 'dba_hist#';
-- prefix for data dictionary "dba_" views
DEF tool_prefix_2 = 'dba#';
-- prefix for dynamic "gv$" views
DEF tool_prefix_3 = 'gv#';
-- prefix for dynamic "v$" views
DEF tool_prefix_4 = 'v#';
-- compression clause
DEF compression_clause = 'COMPRESS';

------------------------------------------------------------------------------------------
-- Parallel Execution
------------------------------------------------------------------------------------------

ALTER SESSION ENABLE PARALLEL QUERY;
ALTER SESSION ENABLE PARALLEL DML;
ALTER SESSION ENABLE PARALLEL DDL;
DEF select_hints = 'PARALLEL(4)';
DEF insert_hints = 'APPEND PARALLEL(4)';
DEF parallel_clause = 'PARALLEL 4'

-- list of repository owners
SELECT owner, COUNT(*) tables FROM dba_tables WHERE (table_name LIKE UPPER('&&tool_prefix_0.')||'%' OR table_name LIKE UPPER('&&tool_prefix_1.')||'%' OR table_name LIKE UPPER('&&tool_prefix_2.')||'%' OR table_name LIKE UPPER('&&tool_prefix_3.')||'%' OR table_name LIKE UPPER('&&tool_prefix_4.')||'%') GROUP BY owner;

-- parameter 1
PRO
ACC tool_repo_user_source PROMPT 'tool repository user source (i.e. eadam3): '

BEGIN
  IF UPPER(TRIM('&&tool_repo_user_source.')) = 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20000, 'SYS cannot be used as repository!');
  END IF;
END;
/

-- parameter 2
ACC tool_repo_user_target PROMPT 'tool repository user target (i.e. edb360): '

BEGIN
  IF UPPER(TRIM('&&tool_repo_user_target.')) = 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20000, 'SYS cannot be used as repository!');
  END IF;
END;
/

-- source and target must be different
BEGIN
  IF UPPER(TRIM('&&tool_repo_user_target.')) = UPPER(TRIM('&&tool_repo_user_source.')) THEN
    RAISE_APPLICATION_ERROR(-20000, 'source and taget repository users must be different');
  END IF;
END;
/

------------------------------------------------------------------------------------------
-- clones repository tables. it overrides existing tables.
------------------------------------------------------------------------------------------

DECLARE
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
  FOR i IN (SELECT owner, table_name FROM dba_tables WHERE owner = UPPER('&&tool_repo_user_source.') AND table_name NOT LIKE '%\_T' ESCAPE '\' AND (table_name LIKE UPPER('&&tool_prefix_0.%') OR table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%')) ORDER BY table_name)
  LOOP
    drop_table(LOWER('&&tool_repo_user_target..'||i.table_name));                                                 
    execute_immediate('CREATE TABLE '||LOWER('&&tool_repo_user_target..'||i.table_name)||' &&compression_clause. &&parallel_clause. AS SELECT /*+ &&select_hints. */ * FROM '||LOWER(i.owner||'.'||i.table_name));
    execute_immediate('GRANT SELECT ON '||LOWER('&&tool_repo_user_target..'||i.table_name)||' TO SELECT_CATALOG_ROLE');
    DBMS_STATS.GATHER_TABLE_STATS(UPPER('&&tool_repo_user_target.'),i.table_name);
  END LOOP;
  FOR i IN (SELECT owner, view_name FROM dba_views WHERE owner = UPPER('&&tool_repo_user_source.') AND (view_name LIKE UPPER('&&tool_prefix_0.%') OR view_name LIKE UPPER('&&tool_prefix_1.%') OR view_name LIKE UPPER('&&tool_prefix_2.%') OR view_name LIKE UPPER('&&tool_prefix_3.%') OR view_name LIKE UPPER('&&tool_prefix_4.%')) ORDER BY view_name)
  LOOP
    drop_table(LOWER('&&tool_repo_user_target..'||i.view_name));                                                 
    execute_immediate('CREATE TABLE '||LOWER('&&tool_repo_user_target..'||i.view_name)||' &&compression_clause. &&parallel_clause. AS SELECT /*+ &&select_hints. */ * FROM '||LOWER(i.owner||'.'||i.view_name));
    execute_immediate('GRANT SELECT ON '||LOWER('&&tool_repo_user_target..'||i.view_name)||' TO SELECT_CATALOG_ROLE');
    DBMS_STATS.GATHER_TABLE_STATS(UPPER('&&tool_repo_user_target.'),i.view_name);
  END LOOP;
END;
/

------------------------------------------------------------------------------------------
-- repository summary
------------------------------------------------------------------------------------------

-- control
SELECT * FROM &&tool_repo_user_source..&&tool_prefix_0.control;

-- list of repository tables with num_rows and blocks
SELECT table_name, num_rows, blocks FROM dba_tables WHERE owner = UPPER('&&tool_repo_user_target.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'))
ORDER BY table_name;

-- table count and total rows and blocks
SELECT COUNT(*) tables, SUM(num_rows), SUM(blocks) FROM dba_tables WHERE owner = UPPER('&&tool_repo_user_target.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'));

-- approximate repository size in GBs
SELECT ROUND(MIN(TO_NUMBER(p.value)) * SUM(blocks) / POWER(10,9), 3) approx_repo_size_gb FROM v$parameter p, dba_tables t WHERE p.name = 'db_block_size' AND t.owner = UPPER('&&tool_repo_user_target.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'));

-- list of repository owners
SELECT owner, COUNT(*) tables FROM dba_tables WHERE (table_name LIKE UPPER('&&tool_prefix_0.')||'%' OR table_name LIKE UPPER('&&tool_prefix_1.')||'%' OR table_name LIKE UPPER('&&tool_prefix_2.')||'%' OR table_name LIKE UPPER('&&tool_prefix_3.')||'%' OR table_name LIKE UPPER('&&tool_prefix_4.')||'%') GROUP BY owner;

SPO OFF;
--WHENEVER SQLERROR CONTINUE;
EXEC DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
