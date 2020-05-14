@@&&edb360_0g.tkprof.sql
DEF section_id = '2c';
DEF section_name = 'Automatic Storage Management (ASM)';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'ASM Attributes';
DEF main_table = '&&v_view_prefix.ASM_ATTRIBUTE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_attribute
 ORDER BY
       1, 2
]';
END;
/
&&skip_ver_le_10.@@edb360_9a_pre_one.sql

DEF title = 'ASM Client';
DEF main_table = '&&v_view_prefix.ASM_CLIENT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_client
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Template';
DEF main_table = '&&v_view_prefix.ASM_TEMPLATE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_template
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk Group';
DEF main_table = '&&v_view_prefix.ASM_DISKGROUP';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_diskgroup
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk Group Stat';
DEF main_table = '&&v_view_prefix.ASM_DISKGROUP_STAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_diskgroup_stat
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk';
DEF main_table = '&&v_view_prefix.ASM_DISK';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_disk
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk Stat';
DEF main_table = '&&v_view_prefix.ASM_DISK_STAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_disk_stat
 ORDER BY
       1, 2
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk IO Stats';
DEF main_table = '&&gv_view_prefix.ASM_DISK_IOSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.asm_disk_iostat
 ORDER BY
       1, 2, 3, 4, 5
]';
END;
/
&&skip_ver_le_10.@@edb360_9a_pre_one.sql

DEF title = 'ASM File';
DEF main_table = '&&v_view_prefix.ASM_FILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_file
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Files Count per Disk Group';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
count(*) files, name disk_group, 'Datafile' file_type
from
(select regexp_substr(name, '[^/]+', 1, 1) name from &&v_object_prefix.datafile)
group by name
union all
select count(*) files, name disk_group, 'Tempfile' file_type
from
(select regexp_substr(name, '[^/]+', 1, 1) name from &&v_object_prefix.tempfile)
group by name
order by 1 desc, 2, 3
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Data and Temp Files Count per Disk Group';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
count(*) files, name disk_group
from
(select regexp_substr(name, '[^/]+', 1, 1) name from &&v_object_prefix.datafile
union all
select regexp_substr(name, '[^/]+', 1, 1) name from &&v_object_prefix.tempfile)
group by name
order by 1 desc
]';
END;
/
@@edb360_9a_pre_one.sql

-- special addition from MOS 1551288.1
-- add seq to spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&common_edb360_prefix._&&section_id._&&report_sequence._failure_diskgroup_space_reserve_requirements' one_spool_filename FROM DUAL;
SPO &&edb360_output_directory.&&one_spool_filename..txt
@@ck_free_17.sql
SPO OFF
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.&&one_spool_filename..txt >> &&edb360_log3..txt
-- update main report
SPO &&edb360_main_report..html APP;
PRO <li title="&&v_view_prefix.ASM_DISKGROUP">DISK and CELL Failure Diskgroup Space Reserve Requirements
PRO <a href="&&one_spool_filename..txt">text</a>
PRO </li>
SPO OFF;
HOS zip -j &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt
-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
