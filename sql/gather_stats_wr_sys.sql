----------------------------------------------------------------------------------------
--
-- File name:   gather_stats_wr_sys.sql
--
-- Purpose:     Gather fresh CBO statistics for AWR Tables and Indexes
--
-- Author:      Carlos Sierra
--
-- Version:     2015/04/02
--
-- Usage:       This script generates and executes another, which gathers stats for AWR 
--
-- Example:     @gather_stats_wr_sys.sql
--
--  Notes:      Developed and tested on 11.2.0.3
--
--  Ref:        MOS 387914.1 and 1965061.1
--             
---------------------------------------------------------------------------------------
--
SET HEA OFF PAGES 0;
SPO gather_stats_awr.sql;
SELECT 'EXEC DBMS_STATS.GATHER_TABLE_STATS(''SYS'','''||table_name||''',force=>TRUE);'
  FROM dba_tables
 WHERE owner = 'SYS'
   AND table_name LIKE 'WR_$%'
 ORDER BY
       table_name
/
SPO OFF;
SET HEA ON PAGES 24;
SET ECHO ON;
@gather_stats_awr.sql
