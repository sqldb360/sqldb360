-- add seq to one_spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

-- display
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET TERM ON;
SPO &&edb360_log..txt APP;
PRO &&hh_mm_ss. &&section_id. "&&one_spool_filename._pie_chart.html"
SPO OFF;
SET TERM OFF;

-- update main report
SPO &&edb360_main_report..html APP;
PRO <a href="&&one_spool_filename._pie_chart.html">pie</a>
SPO OFF;

-- get time t0
EXEC :get_time_t0 := DBMS_UTILITY.get_time;

-- header
SPO &&edb360_output_directory.&&one_spool_filename._pie_chart.html;
@@edb360_0d_html_header.sql
PRO <!-- &&one_spool_filename._pie_chart.html $ -->

-- chart header
PRO    &&edb360_conf_google_charts.
PRO    <script type="text/javascript">
PRO      google.load("visualization", "1", {packages:["corechart"]});
PRO      google.setOnLoadCallback(drawChart);
PRO      function drawChart() {
PRO        var data = google.visualization.arrayToDataTable([

-- body
SET SERVEROUT ON;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
DECLARE
  cur SYS_REFCURSOR;
  l_slice VARCHAR2(32767);
  l_value NUMBER;
  l_percent NUMBER;
  l_text VARCHAR2(32767);
  l_sql_text VARCHAR2(32767);
BEGIN
  DBMS_OUTPUT.PUT_LINE('[''Slice'', ''Value'']');
  --OPEN cur FOR :sql_text;
  l_sql_text := DBMS_LOB.SUBSTR(:sql_text); -- needed for 10g
  OPEN cur FOR l_sql_text; -- needed for 10g
  LOOP
    FETCH cur INTO l_slice, l_value, l_percent, l_text;
    EXIT WHEN cur%NOTFOUND;
    l_slice := l_slice||' ('||TRIM(TO_CHAR(l_percent, '990.0'))||'%)';
    DBMS_OUTPUT.PUT_LINE(',['''||l_slice||''', '||l_value||']');
  END LOOP;
  CLOSE cur;
END;
/
SET SERVEROUT OFF;

-- pie chart footer
PRO        ]);;
PRO        
PRO        var options = {
PRO          chartArea: {left:25, top:75, width:'95%', height:'80%'},
PRO          is3D: false,
PRO          backgroundColor: {fill: 'white', stroke: '#336699', strokeWidth: 1},
PRO          title: '&&section_id..&&report_sequence.. &&title.&&title_suffix.',
PRO          titleTextStyle: {fontSize: 18, bold: false},
PRO          legend: {position: 'right', textStyle: {fontSize: 14}},
PRO          tooltip: {textStyle: {fontSize: 14}, text: 'value'},
PRO          pieHole: 0.4,
PRO          sliceVisibilityThreshold: 1/1440
PRO        };
PRO
PRO        var chart = new google.visualization.PieChart(document.getElementById('piechart'));
PRO        chart.draw(data, options);
PRO      }
PRO    </script>
PRO  </head>
PRO  <body>
PRO
PRO<h1> &&edb360_conf_all_pages_icon. &&section_id..&&report_sequence.. &&title. <em>(&&main_table.)</em> &&edb360_conf_all_pages_logo. </h1>
PRO
PRO <br />
PRO &&abstract.
PRO &&abstract2.
PRO <br />
PRO
PRO    <div id="piechart" class="google-chart"></div>
PRO

-- footer
PRO <br />
PRO <font class="n">Notes:<br />1) up to &&history_days. days of awr history were considered<br />2) ASH reports are based on number of samples</font>
PRO <font class="n"><br />3) &&foot.</font>
PRO <pre>
SET LIN 80;
DESC &&main_table.
SET HEA OFF;
SET LIN 32767;
PRINT sql_text_display;
SET HEA ON;
--PRO &&row_count. rows selected.
PRO &&row_num. rows selected.
PRO </pre>

@@edb360_0e_html_footer.sql
SPO OFF;

-- get time t1
EXEC :get_time_t1 := DBMS_UTILITY.get_time;

-- update log2
SET HEA OFF;
SPO &&edb360_log2..txt APP;
SELECT TO_CHAR(SYSDATE, '&&edb360_date_format.')||' , '||
       TO_CHAR((:get_time_t1 - :get_time_t0)/100, '999,999,990.00')||'s , rows:'||
       --:row_count||' , &&section_id., &&main_table., &&edb360_prev_sql_id., -1, &&title_no_spaces., html , &&one_spool_filename._pie_chart.html'
       '&&row_num., &&section_id., &&main_table., &&edb360_prev_sql_id., -1, &&title_no_spaces., pie , &&one_spool_filename._pie_chart.html'
  FROM DUAL
/
SPO OFF;
SET HEA ON;

-- zip
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.&&one_spool_filename._pie_chart.html >> &&edb360_log3..txt
