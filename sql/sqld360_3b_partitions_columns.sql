SPO &&one_spool_filename..html APP;
PRO </head>
@sql/sqld360_0d_html_header.sql
PRO <body>
PRO <h1><em>&&sqld360_conf_tool_page.SQLd360</a></em> &&sqld360_vYYNN.: SQL 360-degree view - &&section_id.. Partitions Page &&sqld360_conf_all_pages_logo.</h1>
PRO
PRO <pre>
PRO sqlid:&&sqld360_sqlid. dbname:&&database_name_short. version:&&db_version. host:&&host_hash. license:&&license_pack. days:&&history_days. today:&&sqld360_time_stamp.
PRO </pre>
PRO

PRO <table><tr class="main">

SET SERVEROUT ON ECHO OFF FEEDBACK OFF TIMING OFF 
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;

BEGIN
  FOR i IN (SELECT table_name, owner 
              FROM dba_tables 
             WHERE (owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.') 
               AND partitioned = 'YES'
             ORDER BY 1,2) 
  LOOP
    DBMS_OUTPUT.PUT_LINE('<td class="c">'||i.owner||'.'||i.table_name||'</td>');
  END LOOP;
END;
/

PRO </tr><tr class="main">
SPO OFF

-- this is to trick sqld360_9a_pre
DEF sqld360_main_report_bck = &&sqld360_main_report.
DEF sqld360_main_report = &&one_spool_filename.

SPO sqld360_partitions_columns_&&sqld360_sqlid._driver.sql
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;

DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN

  --put('DELETE plan_table WHERE statement_id = ''SQLD360_LOW_HIGH'';'); 
  --put('DECLARE');
  --put('  l_low VARCHAR2(256);');
  --put('  l_high VARCHAR2(256);');
  --put('  FUNCTION compute_low_high (p_data_type IN VARCHAR2, p_raw_value IN RAW)');
  --put('  RETURN VARCHAR2 AS');
  --put('    l_number NUMBER;');
  --put('    l_varchar2 VARCHAR2(256);');
  --put('    l_date DATE;');
  --put('  BEGIN');
  --put('    IF p_data_type = ''NUMBER'' THEN');
  --put('      DBMS_STATS.convert_raw_value(p_raw_value, l_number);');
  --put('      RETURN TO_CHAR(l_number);');
  --put('    ELSIF p_data_type IN (''VARCHAR2'', ''CHAR'', ''NVARCHAR2'', ''CHAR2'') THEN');
  --put('      DBMS_STATS.convert_raw_value(p_raw_value, l_varchar2);');
  --put('      RETURN l_varchar2;');
  --put('    ELSIF SUBSTR(p_data_type, 1, 4) IN (''DATE'', ''TIME'') THEN');
  --put('      DBMS_STATS.convert_raw_value(p_raw_value, l_date);');
  --put('      RETURN TO_CHAR(l_date, ''YYYY-MM-DD HH24:MI:SS'');');
  --put('    ELSE');
  --put('      RETURN RAWTOHEX(p_raw_value);');
  --put('    END IF;');
  --put('  END compute_low_high;');
  --put('BEGIN');
  --put('  FOR i IN (SELECT a.owner, a.table_name, a.partition_name, a.column_name, b.data_type, a.low_value, a.high_value');
  --put('              FROM dba_part_col_statistics a,');
  --put('                   dba_tab_cols b, ');
  --put('                   (SELECT table_owner, table_name, partition_name, partition_position ');
  --put('                      FROM (SELECT table_owner, table_name, partition_name, partition_position, ');
  --put('                                   ROW_NUMBER() OVER (ORDER BY partition_position) rn, COUNT(*) OVER () num_part ');
  --put('                              FROM dba_tab_partitions ');
  --put('                             WHERE (table_owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = ''LIST_OF_TABLES'' AND remarks = ''&&sqld360_sqlid.'') ) ');
  --put('                     WHERE (rn <= &&sqld360_conf_first_part OR rn >= num_part-&&sqld360_conf_last_part) ');
  --put('                     ORDER BY partition_position DESC) c ');
  --put('             WHERE (a.owner, a.table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = ''LIST_OF_TABLES'' AND remarks = ''&&sqld360_sqlid.'') ');
  --put('               AND ''&&sqld360_conf_translate_lowhigh.'' = ''Y''');
  --put('               AND a.owner = b.owner');
  --put('               AND a.table_name = b.table_name');
  --put('               AND a.column_name = b.column_name');
  --put('               AND a.owner = c.table_owner');
  --put('               AND a.table_name = c.table_name');
  --put('               AND a.partition_name = c.partition_name)');
  --put('  LOOP');
  --put('    l_low := compute_low_high(i.data_type, i.low_value);');
  --put('    l_high := compute_low_high(i.data_type, i.high_value);');
  --put('    INSERT INTO plan_table (statement_id, object_owner, object_name, object_node, object_type, partition_start, partition_stop)');
  --put('    VALUES (''SQLD360_LOW_HIGH'', i.owner, i.table_name, i.partition_name, i.column_name, l_low, l_high);');
  --put('  END LOOP;');
  --put('END;');
  --put('/');

  FOR i IN (SELECT table_name, owner 
              FROM dba_tables 
             WHERE (owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')
               AND partitioned = 'YES'
             ORDER BY 1,2) 
  LOOP
    put('SET PAGES 50000');
    put('SPO &&sqld360_main_report..html APP;');
    put('PRO <td>');
    put('SPO OFF');
    FOR j IN (SELECT table_owner, table_name, partition_name, partition_position
                FROM (SELECT table_owner, table_name, partition_name, partition_position,
                             ROW_NUMBER() OVER (ORDER BY partition_position) rn, COUNT(*) OVER () num_part
                        FROM dba_tab_partitions 
                       WHERE table_owner = i.owner
                         AND table_name = i.table_name)
               WHERE (rn <= &&sqld360_conf_first_part OR rn >= num_part-&&sqld360_conf_last_part)
               ORDER BY partition_position DESC) 
    LOOP

      --put('DEF title= ''Partition '||j.partition_name||'');
      --put('DEF DEF main_table = ''DBA_PART_COL_STATISTICS''');
      --put('BEGIN');
      --put(' :sql_text := ''');
      --put('SELECT /*+ &&top_level_hints. */');
      --put('       a.*,b.partition_start low_value_translated, b.partition_stop high_value_translated');
      --put('  FROM dba_part_col_statistics a,');
      --put('       plan_table b');
      --put(' WHERE a.owner = '''||j.table_owner||''''); 
      --put('   AND a.table_name = '''||j.table_name||'''');
      --put('   AND a.partition_name = '''||j.partition_name||'''');
      --put('   AND a.owner = b.object_owner(+)');
      --put('   AND a.table_name = b.object_name(+)');
      --put('   AND a.partition_name = b.object_node(+)');
      --put('   AND a.column_name = b.object_type(+)');
      --put('   AND b.statement_id(+) = ''SQLD360_LOW_HIGH''');
      --put(' ORDER BY a.owner, a.table_name, a.partition_name');
      --put(''';');
      --put('END;');
      --put('/ ');
      --put('@sql/sqld360_9a_pre_one.sql');

      put('DEF title= ''Partition '||j.partition_name||'');
      put('DEF DEF main_table = ''DBA_PART_COL_STATISTICS''');
      put('BEGIN');
      put(' :sql_text := q''[');
      put('SELECT /*+ &&top_level_hints. */');
      put('       a.* ');
      put('&&sqld360_skip_lowhigh.      ,CASE WHEN data_type = ''NUMBER'' THEN to_char(utl_raw.cast_to_number(a.low_value)) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type IN (''VARCHAR2'', ''CHAR'') THEN substr(to_char(utl_raw.cast_to_varchar2(a.low_value)),1,32) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type IN (''NVARCHAR2'',''NCHAR'') THEN substr(to_char(utl_raw.cast_to_nvarchar2(a.low_value)),1,32) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type = ''BINARY_DOUBLE'' THEN to_char(utl_raw.cast_to_binary_double(a.low_value)) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type = ''BINARY_FLOAT'' THEN to_char(utl_raw.cast_to_binary_float(a.low_value)) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type = ''DATE'' THEN rtrim( ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(100*(to_number(substr(a.low_value,1,2) ,''XX'')-100) + (to_number(substr(a.low_value,3,2) ,''XX'')-100),''0000''))||''-''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,5,2) ,''XX'')  ,''00''))||''-''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,7,2) ,''XX'')  ,''00''))||''/''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,9,2) ,''XX'')-1,''00''))||'':''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,11,2),''XX'')-1,''00''))||'':''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,13,2),''XX'')-1,''00''))) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type LIKE ''TIMESTAMP%'' THEN rtrim( ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(100*(to_number(substr(a.low_value,1,2) ,''XX'')-100) + (to_number(substr(a.low_value,3,2) ,''XX'')-100),''0000''))||''-''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,5,2) ,''XX'')  ,''00''))||''-''|| '); 
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,7,2) ,''XX'')  ,''00''))||''/''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,9,2) ,''XX'')-1,''00''))||'':''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,11,2),''XX'')-1,''00''))||'':''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.low_value,13,2),''XX'')-1,''00''))||''.''|| ');
      put('&&sqld360_skip_lowhigh.                    to_number(substr(a.low_value,15,8),''XXXXXXXX'')) ');
      put('&&sqld360_skip_lowhigh.       END low_value_translated, ');
      put('&&sqld360_skip_lowhigh.       CASE WHEN data_type = ''NUMBER'' THEN to_char(utl_raw.cast_to_number(a.high_value)) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type IN (''VARCHAR2'', ''CHAR'') THEN substr(to_char(utl_raw.cast_to_varchar2(a.high_value)),1,32) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type IN (''NVARCHAR2'',''NCHAR'') THEN substr(to_char(utl_raw.cast_to_nvarchar2(a.high_value)),1,32) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type = ''BINARY_DOUBLE'' THEN to_char(utl_raw.cast_to_binary_double(a.high_value)) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type = ''BINARY_FLOAT'' THEN to_char(utl_raw.cast_to_binary_float(a.high_value)) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type = ''DATE'' THEN rtrim( ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(100*(to_number(substr(a.high_value,1,2) ,''XX'')-100) + (to_number(substr(a.high_value,3,2) ,''XX'')-100),''0000''))||''-''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,5,2) ,''XX'')  ,''00''))||''-''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,7,2) ,''XX'')  ,''00''))||''/''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,9,2) ,''XX'')-1,''00''))||'':''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,11,2),''XX'')-1,''00''))||'':''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,13,2),''XX'')-1,''00''))) ');
      put('&&sqld360_skip_lowhigh.        WHEN data_type LIKE ''TIMESTAMP%'' THEN rtrim( ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(100*(to_number(substr(a.high_value,1,2) ,''XX'')-100) + (to_number(substr(a.high_value,3,2) ,''XX'')-100),''0000''))||''-''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,5,2) ,''XX'')  ,''00''))||''-''|| '); 
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,7,2) ,''XX'')  ,''00''))||''/''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,9,2) ,''XX'')-1,''00''))||'':''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,11,2),''XX'')-1,''00''))||'':''|| ');
      put('&&sqld360_skip_lowhigh.                    ltrim(to_char(     to_number(substr(a.high_value,13,2),''XX'')-1,''00''))||''.''|| ');
      put('&&sqld360_skip_lowhigh.                    to_number(substr(a.high_value,15,8),''XXXXXXXX'')) ');
      put('&&sqld360_skip_lowhigh.       END high_value_translated ');
      put('  FROM dba_part_col_statistics a,');
      put('       dba_tab_cols b');
      put(' WHERE a.owner = '''||j.table_owner||''''); 
      put('   AND a.table_name = '''||j.table_name||'''');
      put('   AND a.partition_name = '''||j.partition_name||'''');
      put('   AND a.owner = b.owner');
      put('   AND a.table_name = b.table_name');
      put('   AND a.column_name = b.column_name');
      put(' ORDER BY a.owner, a.table_name, a.partition_name, b.column_id');
      put(']'';');
      put('END;');
      put('/ ');
      put('@sql/sqld360_9a_pre_one.sql');
    END LOOP;
    put('SPO &&sqld360_main_report..html APP;');
    put('PRO </td>');
  END LOOP;
END;
/
SPO &&sqld360_main_report..html APP;
@sqld360_partitions_columns_&&sqld360_sqlid._driver.sql

SPO &&sqld360_main_report..html APP;
PRO </tr></table>
@@sqld360_0e_html_footer.sql
SPO OFF
SET PAGES 50000

HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_partitions_columns_&&sqld360_sqlid._driver.sql

DEF sqld360_main_report = &&sqld360_main_report_bck.
