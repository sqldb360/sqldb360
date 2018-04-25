-- parameter #1: schema (case sensitive)
-- parameter #2: object_name (case sensitive)
-- parameter #3: object_type (TABLE, INDEX, VIEW, SYNONYM, TYPE, PACKAGE, TRIGGER, SEQUENCE, PROCEDURE, LIBRARY, FUNCTION, MATERIALIZED VIEW) 

COL script_name NEW_V script_name NOPRI
SELECT CASE WHEN '&&3.' IN ('TABLE', 'VIEW', 'TYPE', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'MATERIALIZED_VIEW') THEN
'sql/desc_object.sql &&1. &&2.' ELSE 'sql/empty_script.sql' END script_name FROM DUAL;

PRO /* &&3. &&1..&&2. */
@@&&script_name.
SELECT DBMS_METADATA.GET_DDL('&&3.', '&&2.', '&&1.') FROM DUAL
/

