----------------------------------------------------------------------------------------
--
-- File name:   verify_stats_wr_sys.sql
--
-- Purpose:     Verify CBO statistics for AWR Tables and Indexes
--
-- Author:      Carlos Sierra
--
-- Version:     2016/11/22
--
-- Usage:       This script validates stats for AWR 
--
-- Example:     @verify_stats_wr_sys.sql
--
--  Notes:      Developed and tested on 11.2.0.3 and 12.1.0.2
--             
---------------------------------------------------------------------------------------
--
SET TERM ON;
SET HEA ON; 
SET LIN 32767; 
SET NEWP NONE; 
SET PAGES 1000; 
SET LONG 32000; 
SET LONGC 2000; 
SET WRA ON; 
SET TRIMS ON; 
SET TRIM ON; 
SET TI OFF;
SET TIMI OFF;
SET NUM 20; 
SET SQLBL ON; 
SET BLO .; 
SET RECSEP OFF;
SET ECHO OFF;
SET VER OFF;
SET FEED OFF;

DEF ash_date_format = 'YYYY-MM-DD"T"HH24:MI:SS';

COL my_spool_filename NEW_V my_spool_filename NOPRI;
SELECT 'verify_stats_wr_sys_'||name||'.txt' my_spool_filename FROM v$database;
SPO &&my_spool_filename.

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO Verify Statistics for AWR Tables                        verify_stats_wr_sys.sql
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO Getting SYS.WR_$% Tables
PRO ~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SELECT table_name, blocks, num_rows, TO_CHAR(last_analyzed, '&&ash_date_format') last_analyzed
  FROM dba_tables
 WHERE owner = 'SYS'
   AND table_name LIKE 'WR_$%'
 ORDER BY
       table_name
/

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO Getting SYS.WR_$% Table Partitions
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SELECT table_name, partition_name, blocks, num_rows, TO_CHAR(last_analyzed, '&&ash_date_format') last_analyzed
  FROM dba_tab_partitions
 WHERE table_owner = 'SYS'
   AND table_name LIKE 'WR_$%'
 ORDER BY
       table_name, partition_name
/

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO Getting SYS.WR_$% Tables and Partitions
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SELECT table_name, partition_name, inserts, updates, deletes, TO_CHAR(timestamp, '&&ash_date_format') time_stamp, truncated
  FROM dba_tab_modifications
 WHERE table_owner = 'SYS'
   AND table_name LIKE 'WR_$%'
 ORDER BY
       table_name, partition_name
/

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO Getting SYS.WR_$% Indexes
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SELECT table_name, index_name, leaf_blocks, num_rows, TO_CHAR(last_analyzed, '&&ash_date_format') last_analyzed
  FROM dba_indexes
 WHERE table_owner = 'SYS'
   AND table_name LIKE 'WR_$%'
 ORDER BY
       table_name, index_name
/

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO Getting SYS.WR_$% Index Partitions
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SELECT index_name, partition_name, leaf_blocks, num_rows, TO_CHAR(last_analyzed, '&&ash_date_format') last_analyzed
  FROM dba_ind_partitions
 WHERE index_owner = 'SYS'
   AND index_name LIKE 'WR_$%'
 ORDER BY
       index_name, partition_name
/

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO Getting SYS.WR_$% Segments
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

COL seg_part_name FOR A61;
COL segment_type FOR A18;

SELECT segment_name||' '||partition_name seg_part_name, segment_type, blocks
  FROM dba_segments
 WHERE owner = 'SYS'
   AND segment_name LIKE 'WR_$%'
 ORDER BY
       segment_name, partition_name
/

SPO OFF;

COL seg_part_name CLE;
COL segment_type CLE;
