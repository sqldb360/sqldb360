-- add seq to one_spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

-- display
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET TERM ON;
SPO &&sqld360_log..txt APP;
PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number. "&&one_spool_filename._scatter_chart.html"
SPO OFF;
SET TERM OFF;

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <a href="&&one_spool_filename._scatter_chart.html">scatter</a>
SPO OFF;

-- get time t0
EXEC :get_time_t0 := DBMS_UTILITY.get_time;

-- header
SPO &&one_spool_filename._scatter_chart.html;
@@sqld360_0d_html_header.sql
PRO <!-- &&one_spool_filename._line_chart.html $ -->

-- chart header
PRO    &&sqld360_conf_google_charts.
PRO    <script type="text/javascript">
PRO      google.load("visualization", "1", {packages:["corechart"]});
PRO      google.setOnLoadCallback(drawChart);
PRO      function drawChart() {
PRO         var data = new google.visualization.DataTable();
--PRO         data.addColumn('string','');
--PRO         data.addColumn('datetime','Time');
--PRO         data.addColumn('string','Bind Value');
--PRO         data.addColumn('string','Wait Class');
--PRO         data.addColumn('number','Number of samples');   
--PRO         data.addRows([
PRO           var data = google.visualization.arrayToDataTable([
PRO              [ 'Time', 'Bind Value', { role: 'tooltip' }]

-- body
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
DECLARE
  cur SYS_REFCURSOR;
  l_end_time VARCHAR2(32);
  l_col_01 VARCHAR2(1000);
  l_col_02 VARCHAR2(50);  
  l_tooltip VARCHAR2(100);
  --l_col_04 NUMBER;
  l_line VARCHAR2(1050);
  l_dump VARCHAR2(500);
  l_sql_text VARCHAR2(32767);
BEGIN
  l_sql_text := DBMS_LOB.SUBSTR(:sql_text); -- needed for 10g
  OPEN cur FOR l_sql_text; -- needed for 10g
  LOOP
    FETCH cur INTO l_end_time, l_col_01, l_col_02, l_tooltip;
    EXIT WHEN cur%NOTFOUND;

    --IF cur%ROWCOUNT > 1 THEN
    l_line := ', ';
    --ELSE
    --    l_line := '';
    --END IF;
    l_line := l_line||' [ ';      
    l_line := l_line||' new Date('||SUBSTR(l_end_time,1,4)||','||(TO_NUMBER(SUBSTR(l_end_time,6,2)) - 1)||','||SUBSTR(l_end_time,9,2)||','||SUBSTR(l_end_time,12,2)||','||SUBSTR(l_end_time,15,2)||','||NVL(SUBSTR(l_end_time,18,2),0)||',0)';
    IF l_col_02 = 'DATE' THEN  -- ingnoring TIMESTAMP here since they don't get peeked
        -- assuming the format is mm/dd/yyyy hh24:mi:ss (might only work for AMERICAN_AMERICA)
        l_line := l_line||', new Date('||SUBSTR(l_col_01,7,4)||','||(TO_NUMBER(SUBSTR(l_col_01,1,2)) - 1)||','||SUBSTR(l_col_01,4,2)||','||SUBSTR(l_col_01,12,2)||','||SUBSTR(l_col_01,15,2)||','||NVL(SUBSTR(l_col_01,18,2),0)||',0)';
    ELSIF l_col_02 LIKE 'NUMBER%' THEN
        l_line := l_line||' , '||l_col_01; 
    ELSIF l_col_02 LIKE 'VARCHAR%' OR l_col_02 LIKE 'CHAR%' THEN
        -- here we could use DUMP(xx,10,1,8) and avoid the innermost SUBSTR but maybe people are more familiar with SUBSTR than DUMP
        SELECT REPLACE(SUBSTR(DUMP(SUBSTR(l_col_01,1,8)), INSTR(DUMP(SUBSTR(l_col_01,1,8)),' ',1,2)+1),',','') INTO l_dump FROM DUAL;
        l_line := l_line||' , {v:'||l_dump||', f:'''||l_col_01||'''}';
    ELSE -- every other datatype, try to convert into number in JS (possibly failing)
        l_line := l_line||' , ''Number('||l_col_01||''')'; 
    END IF;
    l_line := l_line||', '''||l_tooltip||''']';
    DBMS_OUTPUT.PUT_LINE(l_line);
  END LOOP;
  CLOSE cur;
END;
/
SET SERVEROUT OFF;

-- scatter chart
PRO        ]);;
PRO        
PRO        var options = {&&stacked.
PRO          chartArea:{left:90, top:75, width:'80%', height:'70%'},
PRO          backgroundColor: {fill: '#ffffff', stroke: '#336699', strokeWidth: 1},
PRO          explorer: {actions: ['dragToZoom', 'rightClickToReset'], maxZoomIn: 0.01},
PRO          title: '&&section_id..&&report_sequence.. &&title.&&title_suffix.',
PRO          titleTextStyle: {fontSize: 18, bold: false},
PRO          legend: {position: 'none'},
PRO          tooltip: {textStyle: {fontSize: 14}},
PRO          hAxis: {title: '&&haxis.', gridlines: {count: -1}, titleTextStyle: {fontSize: 16, bold: false}},
PRO          vAxis: {title: '&&vaxis.', gridlines: {count: -1}, titleTextStyle: {fontSize: 16, bold: false}}
PRO        };
PRO
PRO        var chart = new google.visualization.ScatterChart(document.getElementById('scatterchart'));
PRO        chart.draw(data, options);
PRO      }
PRO    </script>
PRO  </head>
PRO  <body>
PRO <h1> &&sqld360_conf_all_pages_icon. &&section_id..&&report_sequence.. &&title.&&title_suffix. <em>(&&main_table.)</em> &&sqld360_conf_all_pages_logo. </h1>
PRO
PRO <br />
PRO &&abstract.
PRO &&abstract2.
PRO <br />
PRO
PRO    <div id="scatterchart" class="google-chart"></div>
PRO

-- footer
PRO<font class="n">Notes:<br>1) drag to zoom, and right click to reset<br>2) </font>
PRO<font class="n"><br>3) &&foot.</font>
PRO <br>
--PRO <pre>&&bubblesDetails.</pre>
PRO <pre>
SET LIN 80;
DESC &&main_table.
SET HEA OFF;
SET LIN 32767;
PRINT sql_text_display;
SET HEA ON;
PRO &&row_num. rows selected.
PRO </pre>

@@sqld360_0e_html_footer.sql
SPO OFF;

-- get time t1
EXEC :get_time_t1 := DBMS_UTILITY.get_time;

-- update log2
SET HEA OFF;
SPO &&sqld360_log2..txt APP;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')||' , '||
       TO_CHAR((:get_time_t1 - :get_time_t0)/100, '999999990.00')||' , '||
       '&&row_num. , &&main_table. , &&title_no_spaces., scatter_chart , &&one_spool_filename._scatter_chart.html'
  FROM DUAL
/
SPO OFF;
SET HEA ON;

-- zip
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename._scatter_chart.html
