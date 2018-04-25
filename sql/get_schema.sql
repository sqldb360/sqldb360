-- parameter #1: schema (case sensitive)

@@set_tool_configuration.sql
@@set_session_environment.sql

HOS rm &&_md_tool._&&1..zip
HOS rm &&1._TABLES.txt

SPO sql/driver_schema.sql
SELECT CASE 
       WHEN object_type = 'TABLE' THEN '@@get_table &&1. '||object_name
       ELSE '@@get_object &&1. '||object_name||' '||REPLACE(object_type, ' ', '_')
       END||CHR(10)||
       'HOS zip -m &&1._'||REPLACE(object_type, ' ', '_')||' &&1._'||REPLACE(object_type, ' ', '_')||'_'||object_name||'.sql'
  FROM dba_objects
 WHERE owner = '&&1.'
   AND object_type IN ('TABLE', 'INDEX', 'VIEW', 'SYNONYM', 'TYPE', 'PACKAGE', 'TRIGGER', 'SEQUENCE', 'PROCEDURE', 'LIBRARY', 'FUNCTION', 'MATERIALIZED VIEW')
   AND (   CASE WHEN object_type = 'TABLE'             AND '&&_md_get_tables.'     = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'INDEX'             AND '&&_md_get_indexes.'    = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'VIEW'              AND '&&_md_get_views.'      = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'SYNONYM'           AND '&&_md_get_synonyms.'   = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'TYPE'              AND '&&_md_get_types.'      = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'PACKAGE'           AND '&&_md_get_packages.'   = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'TRIGGER'           AND '&&_md_get_triggers.'   = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'SEQUENCE'          AND '&&_md_get_sequences.'  = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'PROCEDURE'         AND '&&_md_get_procedures.' = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'LIBRARY'           AND '&&_md_get_libraries.'  = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'FUNCTION'          AND '&&_md_get_functions.'  = 'Y' THEN 'Y' END = 'Y'
        OR CASE WHEN object_type = 'MATERIALIZED VIEW' AND '&&_md_get_mat_views.'  = 'Y' THEN 'Y' END = 'Y'
       )
 ORDER BY
       object_type,
       object_name
/
SET HEA ON;
SPO &&1._TABLES.txt
SELECT table_name, num_rows, blocks
  FROM dba_tables
 WHERE owner = '&&1.'
 ORDER BY
       table_name
/
SPO OFF;

@@set_session_environment.sql
@@driver_schema.sql

HOS zip -m &&_md_tool._&&1. &&1._*.zip
HOS zip -m &&_md_tool._&&1. &&1._TABLES.txt
HOS rm sql/driver_schema.sql
HOS unzip -l &&_md_tool._&&1.
