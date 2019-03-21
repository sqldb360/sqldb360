With dblksz As (
  Select value bsiz From v$parameter Where name='db_block_size'
),
     part   As (
  Select 10*1024*1024*1024/bsiz thold From dblksz
)
Select /*+  NO_MERGE  */
       owner, table_name, partitioned, blocks, blocks*bsiz bytes,
       Case When blocks*bsiz between 1024*1024*1024      and 1024*1024*1024*1024-1
                 Then to_char(round(blocks*bsiz /1024/1024/1024          ),'9999') ||' Gb'
            When blocks*bsiz between 1024*1024*1024      and 1024*1024*1024*1024*1024-1
                 Then to_char(round(blocks*bsiz /1024/1024/1024/1024     ),'9999') ||' Tb'
            When blocks*bsiz between 1024*1024*1024*1024 and 1024*1024*1024*1024*1024*1024-1
                 Then to_char(round(blocks*bsiz /1024/1024/1024/1024/1024),'9999') ||' Pb'
       Else '??????????' End  display
From   dba_tables, dblksz, part
Where  blocks > thold
And    partitioned='NO'
And    owner Not In ('ANONYMOUS','APEX_030200','APEX_040000','APEX_040200','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS')
And    owner Not In ('SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF','MGDSYS','OJVMSYS')
order by blocks desc ;
