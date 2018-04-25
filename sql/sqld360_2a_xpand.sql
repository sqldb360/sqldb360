DEF title = 'Expanded SQL';
DEF main_table = 'DBMS_UTILITY';

@@sqld360_0s_pre_nondef

VAR myexpandedsql CLOB;

SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SET TERM OFF
SPO sqld360_xpand_&&sqld360_sqlid._driver.sql
DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN

  IF '&&db_version.' LIKE '11.2.0.3%' OR '&&db_version.'  LIKE '11.2.0.4%' THEN
    put('EXEC DBMS_SQL2.EXPAND_SQL_TEXT(:sqld360_fullsql,:myexpandedsql);');
  ELSIF '&&db_version.' LIKE '12%' THEN 
    put('EXEC DBMS_UTILITY.EXPAND_SQL_TEXT(:sqld360_fullsql,:myexpandedsql);'); 
  END IF;

END;
/

SPO OFF;
SET SERVEROUT OFF;  

EXEC :myexpandedsql := 'Feature not available (if version < 11.2.0.3) or error returned (if version >= 11.2.0.3)';

@sqld360_xpand_&&sqld360_sqlid._driver.sql
SPO &&one_spool_filename..txt
PRINT :myexpandedsql
SPO OFF;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SPO OFF;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename..txt">txt</a>
PRO </li>
SPO OFF;
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_xpand_&&sqld360_sqlid._driver.sql
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..txt
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html
