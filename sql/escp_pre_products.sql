
/*
January 4, 2024
This script is obtained from lines 145 to 173 of options_packs_usage_statistics.sql    MOS DOC ID 1317265.1
to allow the products query to run within the context of esp.
*/

-- Prepare settings for pre 12c databases
define DFUS=DBA_
col DFUS_ new_val DFUS noprint

define DCOL1=CON_ID
col DCOL1_ new_val DCOL1 noprint
define DCID=-1
col DCID_ new_val DCID noprint

col CON_NAME format a30 wrap
define DCOL2=CON_NAME
col DCOL2_ new_val DCOL2 noprint
define DCNA=to_char(NULL)
col DCNA_ new_val DCNA noprint

select 'CDB_' as DFUS_, 'CON_ID' as DCID_, '(select NAME from V$CONTAINERS xz where xz.CON_ID=xy.CON_ID)' as DCNA_, 'XXXXXX' as DCOL1_, 'XXXXXX' as DCOL2_
  from CDB_FEATURE_USAGE_STATISTICS
  where exists (select 1 from V$DATABASE where CDB='YES')
    and rownum=1;

col GID     NOPRINT
-- Hide CON_NAME column for non-Container Databases:
col &&DCOL2 NOPRINT
col &&DCOL1 NOPRINT

-- Detect Oracle Cloud Service Packages
define OCS='N'
col OCS_ new_val OCS noprint
select 'Y' as OCS_ from V$VERSION where BANNER like 'Oracle %Perf%';
