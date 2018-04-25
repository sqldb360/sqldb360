DEF section_id = '5a';
DEF section_name = '10053 Trace';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = '10053 Trace';
DEF main_table = 'V$SQL';

@@sqld360_0s_pre_nondef

BEGIN
  DBMS_SQLDIAG.DUMP_TRACE (
      p_sql_id    => '&&sqld360_sqlid.',
      p_component => 'Optimizer',
      p_file_id   => 'sqld360_10053_&&sqld360_sqlid.');
END;
/

-- one of the next two command will fail depending on the version
HOS cp &&sqld360_udump_path.*_ora_&&sqld360_spid._sqld360_10053_&&sqld360_sqlid..trc &&one_spool_filename..trc
HOS cp &&sqld360_diagtrace_path.*_ora_&&sqld360_spid._sqld360_10053_&&sqld360_sqlid..trc &&one_spool_filename..trc

SET TERM OFF
-- if remote exec then both previous command failed
@@&&sqld360_remote_exec.sqld360_5g_remote_10053.sql

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SPO OFF;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..trc">txt</a>
PRO </li>
PRO </ol>
SPO OFF;
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..trc
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
