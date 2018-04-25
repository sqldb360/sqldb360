DEF section_id = '1f';
DEF section_name = 'Observations';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'System-wide observations';
DEF main_table = 'V$PARAMETER2';
BEGIN
  :sql_text := q'[
WITH cbo_parameters AS (SELECT /*+ MATERIALIZE */ inst_id, name, value, isdefault FROM gv$sys_optimizer_env),
     fix_controls   AS (SELECT /*+ MATERIALIZE */ inst_id, bugno, value, is_default FROM gv$system_fix_control),
     instances      AS (SELECT /*+ MATERIALIZE */ inst_id, version FROM gv$instance),
     systemstats    AS (SELECT /*+ MATERIALIZE */ MAX(CASE WHEN pname = 'CPUSPEED' THEN pval1 ELSE NULL END) cpuspeed, -- used to determine if workload ss in place
                                                  MAX(CASE WHEN pname = 'CPUSPEEDN' THEN pval1 ELSE NULL END) cpuspeednw,
                                                  MAX(CASE WHEN pname = 'SREADTIM' THEN pval1 ELSE NULL END) sreadtim, 
                                                  MAX(CASE WHEN pname = 'MREADTIM' THEN pval1 ELSE NULL END) mreadtim, 
                                                  MAX(CASE WHEN pname = 'MBRC' THEN pval1 ELSE NULL END) mbrc
                          FROM sys.aux_stats$)
SELECT inst_id instance, scope, message
  FROM (SELECT inst_id, 'SYSTEM' scope, 'There are '||num_nondef_fixc||' CBO-related parameters set to non-default value' message
           FROM (SELECT COUNT(*) num_nondef_fixc, inst_id
                   FROM cbo_parameters 
                  WHERE isdefault = 'NO'
                  GROUP BY inst_id)
          WHERE num_nondef_fixc > 0
        UNION ALL
        SELECT inst_id, 'PARAMETER', 'Parameter '||name||' is set to non-default value of '||value
          FROM cbo_parameters 
         WHERE isdefault = 'NO'
        UNION ALL
        SELECT inst_id, 'SYSTEM', 'There are '||num_nondef_fixc||' fix_controls set to non-default value'
          FROM (SELECT COUNT(*) num_nondef_fixc, inst_id
                  FROM fix_controls 
                 WHERE is_default = 0
                 GROUP BY inst_id)
         WHERE num_nondef_fixc > 0
        UNION ALL
        SELECT inst_id, 'FIX_CONTROL', 'Fix control '||bugno||' is set to non-default value of '||value
          FROM fix_controls 
         WHERE is_default = 0
        UNION ALL
        SELECT cbo_parameters.inst_id, 'OFE', 'OPTIMIZER_FEATURES_ENABLE set to a value ('||cbo_parameters.value||') different than RDBMS version ('||db_version.version||')' 
          FROM cbo_parameters, 
               (SELECT inst_id, version 
                  FROM instances) db_version
         WHERE cbo_parameters.name = 'optimizer_features_enable'
           AND cbo_parameters.value <> SUBSTR(version,1,INSTR(version,'.',1,4)-1)
           AND cbo_parameters.inst_id = db_version.inst_id
        UNION ALL
        SELECT NULL, 'SYSTEM_STATS', 'SREADTIM is not null ('||sreadtim||') while MREADTIME is null'
          FROM systemstats 
         WHERE cpuspeed IS NOT NULL 
           AND sreadtim IS NOT NULL
           AND mreadtim IS NULL
        UNION ALL
        SELECT NULL, 'SYSTEM_STATS', 'MREADTIM is not null ('||mreadtim||') while SREADTIME is null'
          FROM systemstats 
         WHERE cpuspeed IS NOT NULL 
           AND sreadtim IS NULL
           AND mreadtim IS NOT NULL
        UNION ALL
        SELECT NULL, 'SYSTEM_STATS', 'Workload system stats gathered but MBRC is null'
          FROM systemstats 
         WHERE cpuspeed IS NOT NULL 
           AND mbrc IS NULL
        )
 ORDER BY inst_id, scope, message
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Cursors and Plans specific observations';
DEF main_table = 'V$SQL_PLAN';
BEGIN
  :sql_text := q'[
WITH vsql           AS (SELECT /*+ MATERIALIZE */ DISTINCT plan_hash_value, optimizer_env_hash_value FROM gv$sql WHERE sql_id = '&&sqld360_sqlid.'),
     vsqlplan       AS (SELECT /*+ MATERIALIZE */ DISTINCT plan_hash_value, id, operation, object_owner, object_name, cost, cardinality, filter_predicates FROM gv$sql_plan WHERE sql_id = '&&sqld360_sqlid.'),
     dbahistsql     AS (SELECT /*+ MATERIALIZE */ DISTINCT plan_hash_value, optimizer_env_hash_value FROM dba_hist_sqlstat WHERE sql_id = '&&sqld360_sqlid.' AND '&&diagnostics_pack.' = 'Y'),
     dbahistsqlplan AS (SELECT /*+ MATERIALIZE */ DISTINCT plan_hash_value, id, operation, object_owner, object_name, cost, cardinality, filter_predicates FROM dba_hist_sql_plan WHERE sql_id = '&&sqld360_sqlid.' AND '&&diagnostics_pack.' = 'Y'),
     indexes        AS (SELECT /*+ MATERIALIZE */ table_owner, table_name, owner, index_name, degree FROM dba_indexes WHERE (table_owner, table_name) IN (SELECT object_owner, object_name FROM plan_table WHERE statement_id = 'LIST_OF_TABLES' AND remarks = '&&sqld360_sqlid.')),
     ashdata        AS (SELECT /*+ INLINE */ cost sql_plan_hash_value, 
                               operation sql_plan_operation, 
                               options sql_plan_options, 
                               object_node event, 
                               other_tag wait_class, 
                               id sql_plan_line_id,
                               partition_id sql_exec_id,
                               TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,',',1,2)+1,INSTR(partition_start,',',1,3)-INSTR(partition_start,',',1,2)-1)) p1,
                               TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,',',1,4)+1,INSTR(partition_start,',',1,5)-INSTR(partition_start,',',1,4)-1)) p2,
                               TO_NUMBER(SUBSTR(partition_start,INSTR(partition_start,',',1,6)+1,INSTR(partition_start,',',1,7)-INSTR(partition_start,',',1,6)-1)) p3,
                               object_instance obj# 
                          FROM plan_table 
                         WHERE statement_id 
                          LIKE 'SQLD360_ASH_DATA%' 
                          AND remarks = '&&sqld360_sqlid.'),
    list_of_plans AS (SELECT plan_hash_value FROM vsql UNION SELECT plan_hash_value FROM dbahistsql UNION SELECT sql_plan_hash_value FROM ashdata)
SELECT scope, message
  FROM (SELECT 'OPTIMIZER_ENV' scope, 'There is/are '||COUNT(DISTINCT optimizer_env_hash_value)||' distinct CBO environments between memory and history for this SQL' message
         FROM (SELECT optimizer_env_hash_value 
                 FROM vsql
                UNION ALL
               SELECT optimizer_env_hash_value
                 FROM dbahistsql)
         UNION ALL
        SELECT 'INTERNAL_FUNCTION', 'Filter predicate potentially include implicit data-type conversion (might be a red herring in case of long in-list)'
          FROM (SELECT 1
                  FROM vsqlplan
                 WHERE filter_predicates LIKE '%INTERNAL FUNCTION%'
                   AND ROWNUM < 2
                 UNION ALL
                SELECT 1
                  FROM dbahistsqlplan
                 WHERE filter_predicates LIKE '%INTERNAL FUNCTION%'
                   AND ROWNUM < 2)
         WHERE ROWNUM < 2
         UNION ALL
        SELECT 'COST_OF_0', 'Plan Hash Value '||plan_hash_value||' includes operation with a cost of 0, VERY suspicious'
          FROM (SELECT plan_hash_value
                  FROM vsqlplan
                 WHERE cost = 0 
                   AND cardinality >= 1 -- always true, btw
                 UNION
                SELECT plan_hash_value
                  FROM dbahistsqlplan
                 WHERE cost = 0 
                   AND cardinality >= 1 -- always true, btw
                )
         UNION ALL
        SELECT DISTINCT 'INDEX_NOT_FOUND', 'Plan Hash Value '||plan_hash_value||' refences an index that was not found anymore, maybe dropped?'
          FROM (SELECT plan_hash_value, object_owner, object_name
                  FROM vsqlplan
                 WHERE operation = 'INDEX'
                 UNION
                SELECT plan_hash_value, object_owner, object_name
                  FROM dbahistsqlplan
                 WHERE operation = 'INDEX'
                ) plans,
               indexes
         WHERE plans.object_owner = indexes.owner(+)
           AND plans.object_name = indexes.index_name(+)
           AND indexes.index_name IS NULL
         UNION ALL
        SELECT 'FULL_SCAN_DOING_SINGLE_READS', 'From the ASH *sampled* data for physical reads, Plan Hash Value '||sql_plan_hash_value||' issued single block reads during full scan operations '||TRUNC(num_single_block_reads/num_samples,3)*100||'% of the times' 
          FROM (SELECT sql_plan_hash_value,
                       COUNT(*) num_samples, 
                       SUM(CASE WHEN event IN ('db file sequential read', 'cell single block physical read') THEN 1 ELSE 0 END) num_single_block_reads
                  FROM ashdata
                 WHERE sql_plan_operation IN ('TABLE ACCESS','INDEX')
                   AND (sql_plan_options LIKE 'FULL%' OR sql_plan_options LIKE 'STORAGE FULL%')
                   AND wait_class = 'User I/O' 
                 GROUP BY sql_plan_hash_value)
         WHERE TRUNC(num_single_block_reads/num_samples,3) >= 0.02 -- 2%
         UNION ALL
        SELECT 'FULL_SCAN_READING_FEW_BLOCKS', 'From the ASH *sampled* data for physical reads, Plan Hash Value '||sql_plan_hash_value||' spends most of its time ('||percent_per_phv_and_p3||'%) reading '||p3||' blocks at a time instead of '||POWER(1024,2)/&&sqld360_db_block_size.||' during full scans' 
          FROM (SELECT sql_plan_hash_value,
                       p3,
                       TRUNC(RATIO_TO_REPORT(COUNT(*)) OVER ()*100,3) percent_per_phv_and_p3, 
                       ROW_NUMBER() OVER (PARTITION BY sql_plan_hash_value ORDER BY COUNT(*) DESC) rwn
                  FROM ashdata
                 WHERE sql_plan_operation IN ('TABLE ACCESS','INDEX')
                   AND sql_plan_options LIKE 'FULL%'
                   AND event IN ('db file scattered read', 'direct path read')
                 GROUP BY sql_plan_hash_value, p3)
         WHERE rwn = 1
           AND p3 < (POWER(1024,2)/&&sqld360_db_block_size.) 
         UNION ALL
        SELECT 'SQL_MOSTLY_NOT_ON_CPU', 'From the ASH *sampled* data, Plan Hash Value '||sql_plan_hash_value||' spends '||TRUNC(num_samples_per_class/total_samples_per_phv*100,3)||'% of the time on '||wait_class||'-related wait events instead of CPU (usually preferrable, with exceptions :-)'
          FROM (SELECT sql_plan_hash_value, 
                       wait_class,
                       num_samples_per_class,
                       ROW_NUMBER() OVER (PARTITION BY sql_plan_hash_value ORDER BY num_samples_per_class DESC) rwn,
                       SUM(num_samples_per_class) OVER(PARTITION BY sql_plan_hash_value) total_samples_per_phv 
                  FROM (SELECT sql_plan_hash_value,
                               wait_class, 
                               COUNT(*) num_samples_per_class
                          FROM ashdata
                         GROUP BY sql_plan_hash_value, wait_class))
         WHERE rwn = 1
           AND wait_class <> 'CPU' -- so not on CPU
         UNION ALL
        SELECT 'MULTIPLE_PLANS','This SQL has/had '||COUNT(*)||' distinct execution plan(s)'
               &&skip_10g.&&skip_11r1.||', list of PHV is ('||LISTAGG(plan_hash_value, ',') WITHIN GROUP (ORDER BY plan_hash_value)||')'
          FROM list_of_plans
         UNION ALL
        SELECT 'POTENTIAL_PARSE_TIME', 'From the ASH *sampled* data, Plan Hash Value '||sql_plan_hash_value||' spent '||potential_parse_time||'% of the time not executing (SQL_EXEC_ID NULL), which usually is parse time'
          FROM (SELECT sql_plan_hash_value, 
                       TRUNC(SUM(CASE WHEN sql_exec_id IS NULL THEN 1 ELSE 0 END)/COUNT(*),3) potential_parse_time 
                  FROM ashdata
                 GROUP BY sql_plan_hash_value)
         WHERE potential_parse_time >= 0.1
         UNION ALL
        SELECT 'POTENTIAL_HWM_DESYNC', 'Object#: '||obj#||' block class#: '||p3||' sampled '||COUNT(*)||' times'
          FROM ashdata,
               (SELECT name 
                  FROM v$event_name
                 WHERE parameter3 = 'class#' 
                    OR (name LIKE '%-way' AND parameter3 IS NULL) --parameter3 not named even though it is populated
               ) e
         WHERE e.name = ashdata.event
           AND p3 IN (8,9,10,11,12)
         GROUP BY obj#, p3
         UNION ALL
        SELECT 'LARGE_PERC_PHV0', 'Large number of ASH samples ('||perc_0||'%) have PHV 0 with a valid SQL_EXEC_ID, very likely unresolved adaptive plan (some info based on ASH could be misleading)'
          FROM (SELECT TRUNC(SUM(CASE WHEN sql_plan_hash_value = 0 AND sql_exec_id IS NOT NULL THEN 1 ELSE 0 END)/COUNT(*),3)*100 perc_0
                  FROM ashdata
                 WHERE '&&sqld360_is_insert.' <> 'Y')
         WHERE perc_0 >= 2
        )
 ORDER BY scope, message
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Table-level observations';
DEF main_table = 'DBA_TABLES';
BEGIN
  :sql_text := q'[
WITH tablespaces AS (SELECT /*+ MATERIALIZE */ tablespace_name, block_size
                       FROM dba_tablespaces),
     tables    AS (SELECT /*+ MATERIALIZE */ owner, table_name, tablespace_name, num_rows, blocks, last_analyzed, degree
                     FROM dba_tables 
                    WHERE (owner, table_name) IN (SELECT object_owner, object_name 
                                                    FROM plan_table 
                                                   WHERE statement_id = 'LIST_OF_TABLES' 
                                                     AND remarks = '&&sqld360_sqlid.')),
     partitions AS (SELECT /*+ MATERIALIZE */ table_owner, table_name, partition_name, num_rows, blocks, last_analyzed
                      FROM dba_tab_partitions 
                     WHERE (table_owner, table_name) IN (SELECT object_owner, object_name 
                                                           FROM plan_table 
                                                          WHERE statement_id = 'LIST_OF_TABLES' 
                                                            AND remarks = '&&sqld360_sqlid.')),
     table_and_part_stats AS (SELECT /*+ MATERIALIZE */ owner, table_name, partition_name, stale_stats, stattype_locked
                                FROM dba_tab_statistics
                               WHERE (owner, table_name) IN (SELECT object_owner, object_name 
                                                               FROM plan_table 
                                                              WHERE statement_id = 'LIST_OF_TABLES' 
                                                                AND remarks = '&&sqld360_sqlid.')
                                 AND subpartition_name IS NULL),
     indexes    AS (SELECT /*+ MATERIALIZE */ table_owner, table_name, index_name, degree
                      FROM dba_indexes
                     WHERE (table_owner, table_name) IN (SELECT object_owner, object_name 
                                                           FROM plan_table 
                                                          WHERE statement_id = 'LIST_OF_TABLES' 
                                                            AND remarks = '&&sqld360_sqlid.')),
     ind_cols AS (SELECT col.index_owner, col.index_name, col.table_owner, col.table_name, idx.index_type, idx.uniqueness,
                         MAX(CASE col.column_position WHEN 01 THEN      col.column_name END)||
                         MAX(CASE col.column_position WHEN 02 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 03 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 04 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 05 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 06 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 07 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 08 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 09 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 10 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 11 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 12 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 13 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 14 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 15 THEN ':'||col.column_name END)||
                         MAX(CASE col.column_position WHEN 16 THEN ':'||col.column_name END) indexed_columns
                    FROM dba_ind_columns col,
                         dba_indexes idx
                   WHERE (idx.table_owner, idx.table_name) IN (SELECT object_owner, object_name 
                                                                 FROM plan_table 
                                                                WHERE statement_id = 'LIST_OF_TABLES' 
                                                                  AND remarks = '&&sqld360_sqlid.')
                     AND idx.owner = col.index_owner
                     AND idx.index_name = col.index_name
                   GROUP BY col.index_owner,col.index_name,col.table_owner,col.table_name,idx.index_type,idx.uniqueness)
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g., tab_stats_history AS (SELECT o.owner, o.object_name, h.analyzetime, h.rowcnt
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                          FROM sys.wri$_optstat_tab_history h,
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                               dba_objects o
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                         WHERE (o.owner, o.object_name) IN (SELECT object_owner, object_name 
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                                                              FROM plan_table 
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                                                             WHERE statement_id = 'LIST_OF_TABLES' 
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                                                               AND remarks = '&&sqld360_sqlid.')
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                           AND o.object_type = 'TABLE'
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                           AND o.object_id = h.obj#
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                           AND '&&diagnostics_pack.' = 'Y'
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                         UNION ALL
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                        SELECT owner, table_name, last_analyzed, num_rows
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                          FROM tables
     &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                       ) 
SELECT scope, owner, table_name, message
  FROM (SELECT 'TABLE_STATS' scope, owner, table_name,  'Table '||table_name||' has statistics more than a month old ('||TRUNC(SYSDATE-last_analyzed)||' days old)' message
          FROM tables
         WHERE last_analyzed < ADD_MONTHS(TRUNC(SYSDATE),-1)
         UNION ALL
        SELECT 'TABLE_STALE_STATS', owner, table_name,  'Table '||table_name||' has stale stats'
          FROM table_and_part_stats
         WHERE stale_stats = 'YES'
           AND partition_name IS NULL
         UNION ALL
        SELECT 'TABLE_LOCKED_STATS', owner, table_name,  'Table '||table_name||' has locked stats'
          FROM table_and_part_stats
         WHERE stattype_locked IN ('ALL','DATA')
           AND partition_name IS NULL
         UNION ALL
        SELECT 'TABLE_MISSING_STATS', owner, table_name,  'Table '||table_name||' has no stats'
          FROM tables
         WHERE num_rows IS NULL
         UNION ALL
        SELECT 'PARTITION_STATS', table_owner, table_name,  'Table '||table_name||' has '||num_old_parts||' partition(s) with statistics more than a month old'
          FROM (SELECT COUNT(*) num_old_parts, table_owner, table_name
                  FROM partitions
                 WHERE last_analyzed < ADD_MONTHS(TRUNC(SYSDATE),-1)
                 GROUP BY table_owner, table_name)
         WHERE num_old_parts > 0
         UNION ALL
        SELECT 'PARTITION_STALE_STATS', owner, table_name,  'Table partition '||table_name||'.'||partition_name||' has stale stats'
          FROM table_and_part_stats
         WHERE stale_stats = 'YES'
           AND partition_name IS NOT NULL
         UNION ALL
        SELECT 'PARTITION_LOCKED_STATS', owner, table_name,  'Table partition '||table_name||'.'||partition_name||' has locked stats'
          FROM table_and_part_stats
         WHERE stattype_locked IN ('ALL','DATA')
           AND partition_name IS NOT NULL
         UNION ALL
        SELECT 'PARTITION_MISSING_STATS', table_owner, table_name,  'Table partition '||table_name||'.'||partition_name||' has no stats'
          FROM partitions
         WHERE num_rows IS NULL
         UNION ALL 
        SELECT 'TABLE_STATS', owner, table_name,  'Table '||table_name||' stores 0 rows but accounts for more than 0 blocks'
          FROM tables
         WHERE num_rows = 0 and blocks > 0
         UNION ALL
        SELECT 'PARTITION_STATS', table_owner, table_name||'.'||partition_name,  'Table partition '||table_name||'.'||partition_name||' stores 0 rows but accounts for more than 0 blocks'
          FROM partitions
         WHERE num_rows = 0 and blocks > 0
         UNION ALL
        SELECT 'TABLE_STATS', owner, table_name,  'Table '||table_name||' seems empty (0 rows and 0 blocks)'
          FROM tables
         WHERE num_rows = 0 and blocks = 0
         UNION ALL  
        SELECT 'PARTITION_STATS', table_owner, table_name||'.'||partition_name,  'Table partition '||table_name||'.'||partition_name||' seems empty (0 rows and 0 blocks)'
          FROM partitions
         WHERE num_rows = 0 and blocks = 0      
         UNION ALL
        SELECT 'TABLE_DEGREE', owner, table_name,  'Table '||table_name||' has a non-default DEGREE ('||TRIM(degree)||')'
          FROM tables
         WHERE TRIM(degree) <> '1'
         UNION ALL
        SELECT 'TABLE_DEGREE', owner, table_name,  'Table '||table_name||' is smaller than 1G in size ('||TRUNC((tbs.block_size * t.blocks)/POWER(10,9),3)||'G) but has DEGREE different than 1 ('||TRIM(degree)||')'
          FROM tables t, tablespaces tbs 
         WHERE t.tablespace_name = tbs.tablespace_name
           AND TRIM(degree) <> '1'
           AND (tbs.block_size * t.blocks)/POWER(10,9) <= 1
         UNION ALL
        SELECT 'INDEX_DEGREE', tables.owner, tables.table_name, 'Table '||tables.table_name||' has '||COUNT(*)||' indexes with DEGREE different than the table itself'
          FROM tables, 
               indexes
         WHERE tables.owner = indexes.table_owner
           AND tables.table_name = indexes.table_name
           AND TRIM(tables.degree) <> TRIM(indexes.degree)
         GROUP BY tables.owner, tables.table_name
         HAVING COUNT(*) > 0
         UNION ALL
        SELECT 'REDUNDANT_INDEX', r.table_owner, r.table_name, 'Index '||r.index_name||' ('||r.indexed_columns||') is redundant because of '||i.index_name||' ('||i.indexed_columns||')'
          FROM ind_cols r,
               ind_cols i
         WHERE i.table_owner = r.table_owner
           AND i.table_name = r.table_name
           AND i.index_type = r.index_type
           AND i.index_name != r.index_name
           AND i.indexed_columns LIKE r.indexed_columns||':%'
           AND r.uniqueness = 'NONUNIQUE'
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g. UNION ALL
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g. SELECT 'TABLE_STATS_HISTORY', owner, table_name, 'Stats were 0 at some point, starting '||init_zero||' up until stats gathering on '||end_zero
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.   FROM (SELECT owner, object_name table_name, to_char(init_zero,'YYYY-MM-DD/HH24:MI:SS') init_zero, to_char(end_zero,'YYYY-MM-DD/HH24:MI:SS') end_zero
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.           FROM tab_stats_history
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.           MATCH_RECOGNIZE (
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.             PARTITION BY owner, object_name ORDER BY analyzetime
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.             MEASURES FIRST(iszero.analyzetime) init_zero,
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                      FIRST(a_nonzero.analyzetime) end_zero
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.             --ALL ROWS PER MATCH
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.             AFTER MATCH SKIP TO FIRST a_nonzero
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.             PATTERN (b_nonzero+ iszero+ a_nonzero+)  
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.             DEFINE b_nonzero AS rowcnt <> 0,
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                    iszero  AS rowcnt = 0,
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.                    a_nonzero AS rowcnt <> 0
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.           )
        &&sqld360_no_read_stats_h.&&sqld360_skip_stats_h.&&skip_10g.&&skip_11g.        )
        )
 ORDER BY owner, table_name, scope DESC
]';
END;
/
@@sqld360_9a_pre_one.sql

SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;
