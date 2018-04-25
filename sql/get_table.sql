-- parameter #1: schema (case sensitive)
-- parameter #2: table_name (case sensitive)

@@set_tool_configuration.sql
@@set_session_environment.sql

SPO sql/driver_indexes.sql
SELECT 'PRO /************************************************************************************/'
  FROM dba_indexes
 WHERE owner = '&&1.'
   AND table_name = '&&2.'
   AND '&&_md_get_indexes.' = 'Y'
   AND ROWNUM = 1
/
SELECT '@@get_ddl &&1. '||index_name||' INDEX'
  FROM dba_indexes
 WHERE owner = '&&1.'
   AND table_name = '&&2.'
   AND '&&_md_get_indexes.' = 'Y'
 ORDER BY
       index_name
/
SPO sql/driver_triggers.sql
SELECT 'PRO /************************************************************************************/'
  FROM dba_triggers
 WHERE table_owner = '&&1.'
   AND table_name = '&&2.'
   AND '&&_md_get_triggers.' = 'Y'
   AND ROWNUM = 1
/
SELECT '@@get_ddl &&1. '||trigger_name||' TRIGGER'
  FROM dba_triggers
 WHERE table_owner = '&&1.'
   AND table_name = '&&2.'
   AND '&&_md_get_triggers.' = 'Y'
 ORDER BY
       trigger_name
/
SPO &&1._TABLE_&&2..sql
@@get_ddl.sql &&1. &&2. TABLE
@@driver_indexes.sql
@@driver_triggers.sql
SPO OFF;

HOS rm sql/driver_indexes.sql
HOS rm sql/driver_triggers.sql
