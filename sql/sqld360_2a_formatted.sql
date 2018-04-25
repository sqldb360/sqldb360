DEF title = 'Formatted SQL';
DEF main_table = 'V$SQL';

@@sqld360_0s_pre_nondef

SPO &&one_spool_filename..html

SET PAGES 0 HEAD OFF TIMING OFF

PRO <html>
PRO <script src="sql-formatter.js"></script>
PRO <script src="highlight.pack.js"></script>
PRO <link rel="stylesheet" href="vs.css">
PRO <body>
PRO Credits for formatting go to https://github.com/zeroturnaround/sql-formatter
PRO <br>
PRO Credits for syntax highlight go to https://highlightjs.org/
PRO <pre><code class="sql" id="output"></code></pre>
PRO <script>
PRO document.getElementById("output").innerHTML = window.sqlFormatter.format(" " +
SELECT CHR(34)||REPLACE(REPLACE(:sqld360_fullsql,CHR(34),CHR(92)||CHR(34)),CHR(10),' " +'||CHR(10)||'" ')||CHR(34)||'+' FROM dual;
PRO " ");
PRO </script>
PRO <script>hljs.initHighlightingOnLoad();</script>
PRO </body>
PRO </html>

SPO OFF;

SET HEAD ON PAGES &&def_max_rows.; 

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SPO OFF;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF HEAD ON PAGES 50000

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..html">txt</a>
PRO </li>
SPO OFF;

-- this SQL is because the previous 2 steps don't use the standard formula to increase the seq#
EXEC :repo_seq := :repo_seq+2;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

--HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_xpand_&&sqld360_sqlid._driver.sql
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..html
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html