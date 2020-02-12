DEF section_id = '5c';
DEF section_name = 'AWR';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'AWR Reports';
DEF main_table = 'DBA_HIST_SQLSTAT';
VAR AWRfiles CLOB;
VAR cluster_awr_points CLOB;
VAR inst1_awr_points CLOB;
VAR inst2_awr_points CLOB;
VAR inst3_awr_points CLOB;
VAR inst4_awr_points CLOB;
VAR inst5_awr_points CLOB;
VAR inst6_awr_points CLOB;
VAR inst7_awr_points CLOB;
VAR inst8_awr_points CLOB;

@@sqld360_0s_pre_nondef


SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SET TERM OFF
-- driver
SPO sqld360_awr_&&sqld360_sqlid._driver.sql
DECLARE
  l_standard_filename VARCHAR2(500);
  rep_count INTEGER := 0;
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
  FUNCTION Point(l_kind VARCHAR2, point_date date , bid number, eid number , begin_date date , end_date date , rep VARCHAR2) return VARCHAR2 is 
   l_point varchar2(32767);
   l_ann VARCHAR2(100);
   l_prefix VARCHAR2(100);
  BEGIN
   l_point:=
        '[new Date('||
        EXTRACT(YEAR FROM point_date)||','||
        (EXTRACT(MONTH FROM point_date) - 1)||','||
        EXTRACT(DAY FROM point_date)||','||
        TO_CHAR(point_date,'HH24,MI,SS')||
        ') ,'; 
   IF l_kind='G' THEN
    l_point:=l_point||' null, null ]';
   ELSE
    IF l_kind='C' THEN
     l_ann:='''C''';
     l_prefix:='rac';
    ELSE
     l_ann:=''''||l_kind||'''';
     l_prefix:=l_kind;
    END IF;
  
    l_point:=l_point||l_ann||','||
        ' ''<br><b>'||TO_CHAR(begin_date,'Mon DD, YYYY, HH:MI:SS PM') ||' to'||
           '<br>'   ||TO_CHAR(end_date  ,'Mon DD, YYYY, HH:MI:SS PM') ||'</b><br>awrrpt_'||
        l_prefix||'_'||bid||'_'||eid||'_'||rep||'<br>.'''||
        ' ]';
   END IF;
   RETURN l_point; 
  END;
  PROCEDURE addAWR(l_kind VARCHAR2, bid number, eid number , begin_date date , end_date date , rep VARCHAR2,p_id VARCHAR2, p_file VARCHAR2) IS
  l_point varchar2(32767);
  l_date_to date;
  BEGIN
   :AWRfiles:=:AWRfiles||CHR(10)||' ,[ ''' ||p_id||''' , '''||p_file||' '']';
        /* add an offset of 1 minute per instance number around the date to allow for all the points to be visible.
        in the future, the best display is to have all instances consolidated into one point and show their info in a consolidated tool tip
        but this is the first implementation with the goal of having the most important part of the AWR points functionality completed.   
        */
   IF l_kind='C' THEN
    l_date_to := begin_date;
   ELSE  
    l_date_to := begin_date + (CASE mod(to_number(l_kind),2) WHEN 0 THEN 1 ELSE -1 END)*to_number(l_kind)*1/1440;
   END IF;
   l_point:=CHR(10)||', '||point(l_kind, l_date_to,bid,eid,begin_date, end_date,rep);

      IF l_kind='C' THEN :cluster_awr_points:=:cluster_awr_points||l_point;
   ELSIF l_kind='1' THEN :inst1_awr_points:=:inst1_awr_points||l_point;
   ELSIF l_kind='2' THEN :inst2_awr_points:=:inst2_awr_points||l_point;
   ELSIF l_kind='3' THEN :inst3_awr_points:=:inst3_awr_points||l_point;
   ELSIF l_kind='4' THEN :inst4_awr_points:=:inst4_awr_points||l_point;
   ELSIF l_kind='5' THEN :inst5_awr_points:=:inst5_awr_points||l_point;
   ELSIF l_kind='6' THEN :inst6_awr_points:=:inst6_awr_points||l_point;
   ELSIF l_kind='7' THEN :inst7_awr_points:=:inst7_awr_points||l_point;
   ELSIF l_kind='8' THEN :inst8_awr_points:=:inst8_awr_points||l_point;   
   END IF;
  END;
BEGIN
  :AWRfiles:='';
  :cluster_awr_points :=' ';
  :inst1_awr_points :=' ';
  :inst2_awr_points :=' ';
  :inst3_awr_points :=' ';
  :inst4_awr_points :=' ';
  :inst5_awr_points :=' ';
  :inst6_awr_points :=' ';
  :inst7_awr_points :=' ';
  :inst8_awr_points :=' ';
  -- awr
  FOR i IN (SELECT dbid, instance_number, eid, bid,begin_date,end_date,ROWNUM rnum
              FROM(SELECT s.dbid, s.instance_number, s.eid, s.bid,s.begin_date,s.end_date,
                          SUM(elapsed_time_delta) elap_time
                     FROM dba_hist_sqlstat ss,
                          (SELECT s.dbid, s.instance_number, s.snap_id eid,
                                  CAST(s.begin_interval_time AS DATE) begin_date, 
                                  CAST(s.end_interval_time AS DATE) end_date,
                                  LAG(s.snap_id) OVER (PARTITION BY s.dbid, s.instance_number ORDER BY s.snap_id) bid
                             FROM dba_hist_snapshot s) s 
                    WHERE '&&diagnostics_pack.' = 'Y' 
                      AND ss.dbid = '&&sqld360_dbid.'
                      AND ss.sql_id = '&&sqld360_sqlid.'
                      AND s.eid = ss.snap_id
                      AND s.dbid = ss.dbid
                      AND s.instance_number = ss.instance_number
                    GROUP BY s.dbid, s.instance_number, s.eid, s.bid,s.begin_date,s.end_date  
                    ORDER BY s.instance_number, SUM(elapsed_time_delta) DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_awrrpt.)
  LOOP
      l_standard_filename:='sqld360_awr_&&sqld360_sqlid._'||i.instance_number||'_'||i.bid||'_'||i.eid||'.html';
      addAWR(i.instance_number,i.bid,i.eid,i.begin_date, i.end_date,'maxela'||i.rnum
            ,'awrrpt_'||i.instance_number||'_'||i.bid||'_'||i.eid||'_maxela'||i.rnum
            ,'&&one_spool_filename./'||l_standard_filename);
      put('SPO '||l_standard_filename||';');
      put('SELECT output FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_report_html(&&sqld360_dbid., '||i.instance_number||','||i.bid||','||i.eid||',9));');
      put('SPO OFF;');
    
      l_standard_filename:='sqld360_awr_&&sqld360_sqlid._G_'||i.bid||'_'||i.eid||'.html';
      addAWR('C',i.bid,i.eid,i.begin_date, i.end_date,'maxela'||i.rnum
            ,'awrrpt_rac'||'_'||i.bid||'_'||i.eid||'_maxela'||i.rnum
            ,'&&one_spool_filename./'||l_standard_filename);
      put('SPO '||l_standard_filename||';');
      put('SELECT output FROM TABLE(DBMS_WORKLOAD_REPOSITORY.awr_global_report_html('||i.dbid||','''','||i.bid||','||i.eid||',9));');
      put('SPO OFF;');      

  END LOOP;
  DECLARE 
   l_point varchar2(32767);
   l_ground_date DATE:=TO_DATE('&&sqld360_date_to.', '&&sqld360_date_format.');
  BEGIN
    l_point:=point('G', l_ground_date,0,0,l_ground_date, l_ground_date,null);
    :cluster_awr_points:=CHR(10)||'var racData = [ '||l_point||:cluster_awr_points||'];';
    :inst1_awr_points:=CHR(10)||'var instData1 = [ '||l_point||:inst1_awr_points||'];'; 
    :inst2_awr_points:=CHR(10)||'var instData2 = [ '||l_point||:inst2_awr_points||'];'; 
    :inst3_awr_points:=CHR(10)||'var instData3 = [ '||l_point||:inst3_awr_points||'];'; 
    :inst4_awr_points:=CHR(10)||'var instData4 = [ '||l_point||:inst4_awr_points||'];'; 
    :inst5_awr_points:=CHR(10)||'var instData5 = [ '||l_point||:inst5_awr_points||'];'; 
    :inst6_awr_points:=CHR(10)||'var instData6 = [ '||l_point||:inst6_awr_points||'];'; 
    :inst7_awr_points:=CHR(10)||'var instData7 = [ '||l_point||:inst7_awr_points||'];'; 
    :inst8_awr_points:=CHR(10)||'var instData8 = [ '||l_point||:inst8_awr_points||'];';    
  END;

END;
/
SPO OFF;

SPO edb360_awr_points.js;
PRINT :cluster_awr_points
PRINT :inst1_awr_points
PRINT :inst2_awr_points
PRINT :inst3_awr_points
PRINT :inst4_awr_points
PRINT :inst5_awr_points
PRINT :inst6_awr_points
PRINT :inst7_awr_points
PRINT :inst8_awr_points
PRO function populateEmptyColumns(numColumns,lArray){
PRO  var emptyCols=[];
PRO  var i;
PRO  for (i = 0; i < numColumns; i++) {
PRO   emptyCols.push(',0');
PRO  }
PRO  for (i = 0; i<lArray.length; i++) {
PRO   lArray[i]=lArray[i].concat(emptyCols);
PRO  }
PRO  return lArray;
PRO }
PRO 
PRO function initializeArrays(n) {
PRO  populateEmptyColumns(n,racData);
PRO  populateEmptyColumns(n,instData1);
PRO  populateEmptyColumns(n,instData2);
PRO  populateEmptyColumns(n,instData3);
PRO  populateEmptyColumns(n,instData4);
PRO  populateEmptyColumns(n,instData5);
PRO  populateEmptyColumns(n,instData6);
PRO  populateEmptyColumns(n,instData7);
PRO  populateEmptyColumns(n,instData8);
PRO }
SPO OFF

SPO edb360_show.html;
PRO <iframe id="AWRreport" src="" width="2048" height="1024"></iframe>
PRO <script type="text/javascript">
PRO var awrs = [ '-','-'
PRINT :AWRfiles
PRO ];
PRO function getUrlVars() {
PRO var vars = {};
PRO var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
PRO vars[key] = value;
PRO });
PRO return vars;
PRO }
PRO function findAWR(id){
PRO   for (i = 0; i < awrs.length; i++) {
PRO     if (awrs[i][0]==id) {
PRO       document.getElementById("AWRreport").src =awrs[i][1];
PRO       break;
PRO     }
PRO   }
PRO }
PRO findAWR(getUrlVars()["awr"]);
PRO </script>
SPO OFF

HOS zip -mjq &&sqld360_main_filename._&&sqld360_file_time. edb360_show.html edb360_awr_points.js

@sqld360_awr_&&sqld360_sqlid._driver.sql

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

SET PAGES 50000

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <li title="&&main_table.">&&title.
PRO <a href="&&one_spool_filename._awr.zip">zip</a>
PRO </li>
PRO </ol>
SPO OFF;
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_awr_&&sqld360_sqlid._driver.sql
HOS zip -jmq &&one_spool_filename. sqld360_awr_&&sqld360_sqlid.*
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..zip
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt
