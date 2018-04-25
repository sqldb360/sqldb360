@@set_tool_configuration.sql
@@set_session_environment.sql
HOS rm TOP_*_&&_md_tool..zip
HOS rm TOP_*_SCHEMAS.txt

SPO sql/driver_top_schemas.sql
WITH
applications AS (
SELECT owner, SUM(num_rows) num_rows, SUM(blocks) blocks, COUNT(*) tables
  FROM dba_tables
 WHERE owner NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS')
   AND owner NOT IN ('SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF','MGDSYS','OJVMSYS')
 GROUP BY
       owner
HAVING SUM(num_rows) > 1e6 
 ORDER BY
       2 DESC
)
SELECT '@@get_schema '||owner
  FROM applications
 WHERE ROWNUM <= &&_md_top_schemas.
/
SET HEA ON;
SPO TOP_&&_md_top_schemas._SCHEMAS.txt
WITH
applications AS (
SELECT owner, SUM(num_rows) num_rows, SUM(blocks) blocks, COUNT(*) tables
  FROM dba_tables
 WHERE owner NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS')
   AND owner NOT IN ('SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF','MGDSYS','OJVMSYS')
 GROUP BY
       owner
HAVING SUM(num_rows) > 1e6 
 ORDER BY
       2 DESC
)
SELECT *
  FROM applications
 WHERE ROWNUM <= &&_md_top_schemas.
/
SPO OFF;
@@set_session_environment.sql

@@driver_top_schemas.sql
HOS zip -m TOP_&&_md_top_schemas._&&_md_tool. &&_md_tool._*.zip 
HOS zip -m TOP_&&_md_top_schemas._&&_md_tool. TOP_&&_md_top_schemas._SCHEMAS.txt
HOS rm sql/driver_top_schemas.sql

