DEF section_id = '2g';
DEF section_name = 'Binds';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Binds Summary from Memory';
DEF main_table = 'GV$SQL_BIND_CAPTURE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       inst_id, child_number, name, position, datatype_string, MIN(value_string) min_value, MAX(value_string) max_value, COUNT(DISTINCT value_string) distinct_combinations
  FROM gv$sql_bind_capture 
 WHERE sql_id = '&&sqld360_sqlid.'
 GROUP BY inst_id, child_number, name, position, datatype_string
 ORDER BY inst_id, child_number, name, position, datatype_string
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Binds List from Memory';
DEF main_table = 'GV$SQL_BIND_CAPTURE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       sbc.*, 
       s.plan_hash_value
  FROM gv$sql_bind_capture sbc,
       gv$sql s
 WHERE sbc.sql_id = '&&sqld360_sqlid.'
   AND sbc.inst_id = s.inst_id
   AND sbc.child_number = s.child_number
   AND sbc.sql_id = s.sql_id
 ORDER BY sbc.inst_id, sbc.child_number, sbc.position
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Binds Summary from History';
DEF main_table = 'DBA_HIST_SQLBIND';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       instance_number, name, position, datatype_string, MIN(value_string) min_value, MAX(value_string) max_value, COUNT(DISTINCT value_string) distinct_combinations
  FROM dba_hist_sqlbind
 WHERE sql_id = '&&sqld360_sqlid.'
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. 
   AND '&&diagnostics_pack.' = 'Y'
 GROUP BY instance_number, name, position, datatype_string
 ORDER BY instance_number, name, position, datatype_string
]';
END;
/
@@sqld360_9a_pre_one.sql


DEF title = 'Binds List from History';
DEF main_table = 'DBA_HIST_SQLBIND';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM dba_hist_sqlbind
 WHERE sql_id = '&&sqld360_sqlid.'
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. 
   AND '&&diagnostics_pack.' = 'Y'
 ORDER BY snap_id desc, instance_number, position
]';
END;
/
@@sqld360_9a_pre_one.sql





-- find if there are histograms 
COL num_binds NEW_V num_binds
SELECT TRIM(TO_CHAR(COUNT(name))) num_binds 
  FROM (SELECT name
          FROM gv$sql_bind_capture
         WHERE sql_id = '&&sqld360_sqlid.'
        UNION
        SELECT name
          FROM dba_hist_sqlbind
         WHERE sql_id = '&&sqld360_sqlid.'
           AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. 
           AND '&&diagnostics_pack.' = 'Y');
DEF title= 'Captured Binds Details'
DEF main_table = 'GV$SQL_BIND_CAPTURE'

-- storing the report sequence before forking to a new page
EXEC :repo_seq_bck := :repo_seq;

--this one initiated a new file name, need it in the next anchor
@@sqld360_0s_pre_nondef
SET TERM OFF ECHO OFF 
-- need to fix the file name for the partitions
SPO &&sqld360_main_report..html APP;
PRO <li>Captured Binds Details  
PRO <a href="&&one_spool_filename..html">page</a> <small><em>(&&num_binds.)</em></small>
PRO </li>
SPO OFF;
@@sqld360_2i_captured_binds.sql

-- storing the report sequence before forking to a new page
EXEC :repo_seq := :repo_seq_bck+1;








DEF title = 'Binds with unstable datatype';
DEF main_table = 'GV$SQL_BIND_CAPTURE';
BEGIN
  :sql_text := q'[
SELECT name, position, COUNT(DISTINCT datatype_string) DISTINCT_DATATYPE, MIN(datatype_string) MIN_DATATYPE, MAX(datatype_string) MAX_DATATYPE
  FROM (SELECT name, position, datatype_string
          FROM gv$sql_bind_capture
         WHERE sql_id = '&&sqld360_sqlid.'
         UNION
         SELECT name, position, datatype_string
           FROM dba_hist_sqlbind
          WHERE sql_id = '&&sqld360_sqlid.'
            AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. 
            AND '&&diagnostics_pack.' = 'Y' )
 GROUP BY name, position 
 HAVING COUNT(*) > 1
]';
END;
/
@@sqld360_9a_pre_one.sql


SPO &&sqld360_main_report..html APP;
PRO </ol>
SPO OFF;