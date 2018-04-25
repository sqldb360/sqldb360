-- parameter #1: schema (case sensitive)
-- parameter #2: object_name (case sensitive)
-- parameter #3: object_type (case sensitive)

@@set_tool_configuration.sql
@@set_session_environment.sql

SPO &&1._&&3._&&2..sql
@@get_ddl.sql &&1. &&2. &&3.
SPO OFF;
