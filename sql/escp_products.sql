/*
January 4, 2024
Get the "products" query from lines 206 to 468 of options_packs_usage_statistics.sql    MOS DOC ID 1317265.1            
Must NOT include a ";" or "/" at the end
*/
with
MAP as (
-- mapping between features tracked by DBA_FUS and their corresponding database products (options or packs)
select '' PRODUCT, '' feature, '' MVERSION, '' CONDITION from dual union all
SELECT 'Active Data Guard'                                   , 'Active Data Guard - Real-Time Query on Physical Standby' , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Active Data Guard'                                   , 'Global Data Services'                                    , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Active Data Guard or Real Application Clusters'      , 'Application Continuity'                                  , '^1[89]\.|^2[0-9]\.'                           , ' '       from dual union all
SELECT 'Advanced Analytics'                                  , 'Data Mining'                                             , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'ADVANCED Index Compression'                              , '^12\.'                                        , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Advanced Index Compression'                              , '^12\.'                                        , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Advanced Index Compression'                              , '^1[89]\.|^2[0-9]\.'                           , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup HIGH Compression'                                 , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup LOW Compression'                                  , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup MEDIUM Compression'                               , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup ZLIB Compression'                                 , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Data Guard'                                              , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '^11\.2\.0\.[1-3]\.'                           , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '^(11\.2\.0\.[4-9]\.|1[289]\.|2[0-9]\.)'       , 'INVALID' from dual union all -- licensing required by Optimization for Flashback Data Archive
SELECT 'Advanced Compression'                                , 'HeapCompression'                                         , '^11\.2|^12\.1'                                , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'HeapCompression'                                         , '^12\.[2-9]|^1[89]\.|^2[0-9]\.'                , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Heat Map'                                                , '^12\.1'                                       , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Heat Map'                                                , '^12\.[2-9]|^1[89]\.|^2[0-9]\.'                , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Hybrid Columnar Compression Row Level Locking'           , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Information Lifecycle Management'                        , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Advanced Network Compression Service'             , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Utility Datapump (Export)'                        , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Utility Datapump (Import)'                        , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'SecureFile Compression (user)'                           , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'SecureFile Deduplication (user)'                         , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'ASO native encryption and checksumming'                  , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'INVALID' from dual union all -- no longer part of Advanced Security
SELECT 'Advanced Security'                                   , 'Backup Encryption'                                       , '^11\.2'                                       , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Backup Encryption'                                       , '^1[289]\.|^2[0-9]\.'                          , 'INVALID' from dual union all -- licensing required only by encryption to disk
SELECT 'Advanced Security'                                   , 'Data Redaction'                                          , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Encrypted Tablespaces'                                   , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Oracle Utility Datapump (Export)'                        , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'C002'    from dual union all
SELECT 'Advanced Security'                                   , 'Oracle Utility Datapump (Import)'                        , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'C002'    from dual union all
SELECT 'Advanced Security'                                   , 'SecureFile Encryption (user)'                            , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Transparent Data Encryption'                             , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Change Management Pack'                              , 'Change Management Pack'                                  , '^11\.2'                                       , ' '       from dual union all
SELECT 'Configuration Management Pack for Oracle Database'   , 'EM Config Management Pack'                               , '^11\.2'                                       , ' '       from dual union all
SELECT 'Data Masking Pack'                                   , 'Data Masking Pack'                                       , '^11\.2'                                       , ' '       from dual union all
SELECT '.Database Gateway'                                   , 'Gateways'                                                , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.Database Gateway'                                   , 'Transparent Gateway'                                     , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory ADO Policies'                                  , '^1[89]\.|^2[0-9]\.'                           , ' '       from dual union all -- part of In-Memory Column Store
SELECT 'Database In-Memory'                                  , 'In-Memory Aggregation'                                   , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Column Store'                                  , '^12\.1\.0\.2\.'                               , 'BUG'     from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Column Store'                                  , '^12\.1\.0\.[3-9]\.|^12\.2|^1[89]\.|^2[0-9]\.' , ' '       from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Distribute For Service (User Defined)'         , '^1[89]\.|^2[0-9]\.'                           , ' '       from dual union all -- part of In-Memory Column Store
SELECT 'Database In-Memory'                                  , 'In-Memory Expressions'                                   , '^1[89]\.|^2[0-9]\.'                           , ' '       from dual union all -- part of In-Memory Column Store
SELECT 'Database In-Memory'                                  , 'In-Memory FastStart'                                     , '^1[89]\.|^2[0-9]\.'                           , ' '       from dual union all -- part of In-Memory Column Store
SELECT 'Database In-Memory'                                  , 'In-Memory Join Groups'                                   , '^1[89]\.|^2[0-9]\.'                           , ' '       from dual union all -- part of In-Memory Column Store
SELECT 'Database Vault'                                      , 'Oracle Database Vault'                                   , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Database Vault'                                      , 'Privilege Capture'                                       , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'ADDM'                                                    , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Baseline'                                            , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Baseline Template'                                   , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Report'                                              , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Automatic Workload Repository'                           , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Baseline Adaptive Thresholds'                            , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Baseline Static Computations'                            , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Diagnostic Pack'                                         , '^11\.2'                                       , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'EM Performance Page'                                     , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.Exadata'                                            , 'Cloud DB with EHCC'                                      , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT '.Exadata'                                            , 'Exadata'                                                 , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT '.GoldenGate'                                         , 'GoldenGate'                                              , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression'                             , '^12\.1'                                       , 'BUG'     from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression'                             , '^12\.[2-9]|^1[89]\.|^2[0-9]\.'                , ' '       from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression Conventional Load'           , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression Row Level Locking'           , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.HW'                                                 , 'ODA Infrastructure'                                       , '^1[9]\.|^2[0-9]\.'                           , ' '       from dual union all
SELECT '.HW'                                                 , 'Sun ZFS with EHCC'                                       , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.HW'                                                 , 'ZFS Storage'                                             , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.HW'                                                 , 'Zone maps'                                               , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Label Security'                                      , 'Label Security'                                          , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Multitenant'                                         , 'Oracle Multitenant'                                      , '^1[28]\.'                                     , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
SELECT 'Multitenant'                                         , 'Oracle Multitenant'                                      , '^1[9]\.|^2[0-9]\.'                            , 'C005'    from dual union all -- licensing required only when more than three PDB containers are created
SELECT 'Multitenant'                                         , 'Oracle Pluggable Databases'                              , '^1[28]\.'                                     , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
SELECT 'OLAP'                                                , 'OLAP - Analytic Workspaces'                              , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'OLAP'                                                , 'OLAP - Cubes'                                            , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Partitioning'                                        , 'Partitioning (user)'                                     , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Partitioning'                                        , 'Zone maps'                                               , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.Pillar Storage'                                     , 'Pillar Storage'                                          , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.Pillar Storage'                                     , 'Pillar Storage with EHCC'                                , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT '.Provisioning and Patch Automation Pack'             , 'EM Standalone Provisioning and Patch Automation Pack'    , '^11\.2'                                       , ' '       from dual union all
SELECT 'Provisioning and Patch Automation Pack for Database' , 'EM Database Provisioning and Patch Automation Pack'      , '^11\.2'                                       , ' '       from dual union all
SELECT 'RAC or RAC One Node'                                 , 'Quality of Service Management'                           , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Real Application Clusters'                           , 'Real Application Clusters (RAC)'                         , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Real Application Clusters One Node'                  , 'Real Application Cluster One Node'                       , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Real Application Testing'                            , 'Database Replay: Workload Capture'                       , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'C004'    from dual union all
SELECT 'Real Application Testing'                            , 'Database Replay: Workload Replay'                        , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'C004'    from dual union all
SELECT 'Real Application Testing'                            , 'SQL Performance Analyzer'                                , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'C004'    from dual union all
SELECT '.Secure Backup'                                      , 'Oracle Secure Backup'                                    , '^1[289]\.|^2[0-9]\.'                          , 'INVALID' from dual union all  -- does not differentiate usage of Oracle Secure Backup Express, which is free
SELECT 'Spatial and Graph'                                   , 'Spatial'                                                 , '^11\.2'                                       , 'INVALID' from dual union all  -- does not differentiate usage of Locator, which is free
SELECT 'Spatial and Graph'                                   , 'Spatial'                                                 , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'Automatic Maintenance - SQL Tuning Advisor'              , '^1[289]\.|^2[0-9]\.'                          , 'INVALID' from dual union all  -- system usage in the maintenance window
SELECT 'Tuning Pack'                                         , 'Automatic SQL Tuning Advisor'                            , '^11\.2|^1[289]\.|^2[0-9]\.'                   , 'INVALID' from dual union all  -- system usage in the maintenance window
SELECT 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '^11\.2'                                       , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '^1[289]\.|^2[0-9]\.'                          , 'INVALID' from dual union all  -- default
SELECT 'Tuning Pack'                                         , 'SQL Access Advisor'                                      , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Monitoring and Tuning pages'                         , '^1[289]\.|^2[0-9]\.'                          , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Profile'                                             , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Tuning Advisor'                                      , '^11\.2|^1[289]\.|^2[0-9]\.'                   , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Tuning Set (user)'                                   , '^1[289]\.|^2[0-9]\.'                          , 'INVALID' from dual union all -- no longer part of Tuning Pack
SELECT 'Tuning Pack'                                         , 'Tuning Pack'                                             , '^11\.2'                                       , ' '       from dual union all
SELECT '.WebLogic Server Management Pack Enterprise Edition' , 'EM AS Provisioning and Patch Automation Pack'            , '^11\.2'                                       , ' '       from dual union all
select '' PRODUCT, '' FEATURE, '' MVERSION, '' CONDITION from dual
),
FUS as (
-- the current data set to be used: DBA_FEATURE_USAGE_STATISTICS or CDB_FEATURE_USAGE_STATISTICS for Container Databases(CDBs)
select
    &&DCID as CON_ID,
    &&DCNA as CON_NAME,
    -- Detect and mark with Y the current DBA_FUS data set = Most Recent Sample based on LAST_SAMPLE_DATE
      case when DBID || '#' || VERSION || '#' || to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS') =
                first_value (DBID    )         over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (VERSION )         over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS'))
                                               over (partition by &&DCID order by LAST_SAMPLE_DATE desc nulls last, DBID desc)
           then 'Y'
           else 'N'
    end as CURRENT_ENTRY,
    NAME            ,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    FIRST_USAGE_DATE,
    LAST_USAGE_DATE ,
    AUX_COUNT       ,
    FEATURE_INFO
from &&DFUS.FEATURE_USAGE_STATISTICS xy
),
PFUS as (
-- Product-Feature Usage Statitsics = DBA_FUS entries mapped to their corresponding database products
select
    CON_ID,
    CON_NAME,
    PRODUCT,
    NAME as FEATURE_BEING_USED,
    case  when CONDITION = 'BUG'
               --suppressed due to exceptions/defects
               then '3.SUPPRESSED_DUE_TO_BUG'
          when     detected_usages > 0                 -- some usage detection - current or past
               and CURRENTLY_USED = 'TRUE'             -- usage at LAST_SAMPLE_DATE
               and CURRENT_ENTRY  = 'Y'                -- current record set
               and (    trim(CONDITION) is null        -- no extra conditions
                     or CONDITION_MET     = 'TRUE'     -- extra condition is met
                    and CONDITION_COUNTER = 'FALSE' )  -- extra condition is not based on counter
               then '6.CURRENT_USAGE'
          when     detected_usages > 0                 -- some usage detection - current or past
               and CURRENTLY_USED = 'TRUE'             -- usage at LAST_SAMPLE_DATE
               and CURRENT_ENTRY  = 'Y'                -- current record set
               and (    CONDITION_MET     = 'TRUE'     -- extra condition is met
                    and CONDITION_COUNTER = 'TRUE'  )  -- extra condition is     based on counter
               then '5.PAST_OR_CURRENT_USAGE'          -- FEATURE_INFO counters indicate current or past usage
          when     detected_usages > 0                 -- some usage detection - current or past
               and (    trim(CONDITION) is null        -- no extra conditions
                     or CONDITION_MET     = 'TRUE'  )  -- extra condition is met
               then '4.PAST_USAGE'
          when CURRENT_ENTRY = 'Y'
               then '2.NO_CURRENT_USAGE'   -- detectable feature shows no current usage
          else '1.NO_PAST_USAGE'
    end as USAGE,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    case  when CONDITION like 'C___' and CONDITION_MET = 'FALSE'
               then to_date('')
          else FIRST_USAGE_DATE
    end as FIRST_USAGE_DATE,
    case  when CONDITION like 'C___' and CONDITION_MET = 'FALSE'
               then to_date('')
          else LAST_USAGE_DATE
    end as LAST_USAGE_DATE,
    EXTRA_FEATURE_INFO
from (
select m.PRODUCT, m.CONDITION, m.MVERSION,
       -- if extra conditions (coded on the MAP.CONDITION column) are required, check if entries satisfy the condition
       case
             when CONDITION = 'C001' and (   regexp_like(to_char(FEATURE_INFO), 'compression[ -]used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                                         and FEATURE_INFO not like '%(BASIC algorithm used: 0 times, LOW algorithm used: 0 times, MEDIUM algorithm used: 0 times, HIGH algorithm used: 0 times)%' -- 12.1 bug - Doc ID 1993134.1
                                          or regexp_like(to_char(FEATURE_INFO), 'compression[ -]used: *TRUE', 'i')                 )
                  then 'TRUE'  -- compression has been used
             when CONDITION = 'C002' and (   regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                                          or regexp_like(to_char(FEATURE_INFO), 'encryption used: *TRUE', 'i')                  )
                  then 'TRUE'  -- encryption has been used
             when CONDITION = 'C003' and CON_ID=1 and AUX_COUNT > 1
                  then 'TRUE'  -- more than one PDB are created
             when CONDITION = 'C005' and CON_ID=1 and AUX_COUNT > 3
                  then 'TRUE'  -- more than three PDBs are created
             when CONDITION = 'C004' and '&&OCS'= 'N'
                  then 'TRUE'  -- not in oracle cloud
             else 'FALSE'
       end as CONDITION_MET,
       -- check if the extra conditions are based on FEATURE_INFO counters. They indicate current or past usage.
       case
             when CONDITION = 'C001' and     regexp_like(to_char(FEATURE_INFO), 'compression[ -]used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                                         and FEATURE_INFO not like '%(BASIC algorithm used: 0 times, LOW algorithm used: 0 times, MEDIUM algorithm used: 0 times, HIGH algorithm used: 0 times)%' -- 12.1 bug - Doc ID 1993134.1
                  then 'TRUE'  -- compression counter > 0
             when CONDITION = 'C002' and     regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                  then 'TRUE'  -- encryption counter > 0
             else 'FALSE'
       end as CONDITION_COUNTER,
       case when CONDITION = 'C001'
                 then   regexp_substr(to_char(FEATURE_INFO), 'compression[ -]used:(.*?)(times|TRUE|FALSE)', 1, 1, 'i')
            when CONDITION = 'C002'
                 then   regexp_substr(to_char(FEATURE_INFO), 'encryption used:(.*?)(times|TRUE|FALSE)', 1, 1, 'i')
            when CONDITION = 'C003'
                 then   'AUX_COUNT=' || AUX_COUNT
            when CONDITION = 'C005'
                 then   'AUX_COUNT=' || AUX_COUNT
            when CONDITION = 'C004' and '&&OCS'= 'Y'
                 then   'feature included in Oracle Cloud Services Package'
            else ''
       end as EXTRA_FEATURE_INFO,
       f.CON_ID          ,
       f.CON_NAME        ,
       f.CURRENT_ENTRY   ,
       f.NAME            ,
       f.LAST_SAMPLE_DATE,
       f.DBID            ,
       f.VERSION         ,
       f.DETECTED_USAGES ,
       f.TOTAL_SAMPLES   ,
       f.CURRENTLY_USED  ,
       f.FIRST_USAGE_DATE,
       f.LAST_USAGE_DATE ,
       f.AUX_COUNT       ,
       f.FEATURE_INFO
  from MAP m
  join FUS f on m.FEATURE = f.NAME and regexp_like(f.VERSION, m.MVERSION)
  where nvl(f.TOTAL_SAMPLES, 0) > 0                        -- ignore features that have never been sampled
)
  where nvl(CONDITION, '-') != 'INVALID'                   -- ignore features for which licensing is not required without further conditions
    and not (CONDITION in ('C003', 'C005') and CON_ID not in (0, 1))  -- multiple PDBs are visible only in CDB$ROOT; PDB level view is not relevant
)
select
    grouping_id(CON_ID) as gid,
    CON_ID   ,
    decode(grouping_id(CON_ID), 1, '--ALL--', max(CON_NAME)) as CON_NAME,
    PRODUCT  ,
    decode(max(USAGE),
          '1.NO_PAST_USAGE'        , 'NO_USAGE'             ,
          '2.NO_CURRENT_USAGE'     , 'NO_USAGE'             ,
          '3.SUPPRESSED_DUE_TO_BUG', 'SUPPRESSED_DUE_TO_BUG',
          '4.PAST_USAGE'           , 'PAST_USAGE'           ,
          '5.PAST_OR_CURRENT_USAGE', 'PAST_OR_CURRENT_USAGE',
          '6.CURRENT_USAGE'        , 'CURRENT_USAGE'        ,
          'UNKNOWN') as USAGE,
    max(LAST_SAMPLE_DATE) as LAST_SAMPLE_DATE,
    min(FIRST_USAGE_DATE) as FIRST_USAGE_DATE,
    max(LAST_USAGE_DATE)  as LAST_USAGE_DATE
  from PFUS
  where USAGE in ('2.NO_CURRENT_USAGE', '4.PAST_USAGE', '5.PAST_OR_CURRENT_USAGE', '6.CURRENT_USAGE')   -- ignore '1.NO_PAST_USAGE', '3.SUPPRESSED_DUE_TO_BUG'
  group by rollup(CON_ID), PRODUCT
  having not (max(CON_ID) in (-1, 0) and grouping_id(CON_ID) = 1)            -- aggregation not needed for non-container databases
order by GID desc, CON_ID, decode(substr(PRODUCT, 1, 1), '.', 2, 1), PRODUCT
