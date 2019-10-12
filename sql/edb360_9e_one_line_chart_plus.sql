-- This chart creator does the same as 9e_one_line_chart.sql plus :
-- * Plots the begin date of the generated AWR report in 7a.

-- add seq to one_spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

-- display
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET TERM ON;
SPO &&edb360_log..txt APP;
PRO &&hh_mm_ss. &&section_id. "&&one_spool_filename._line_chart.html"
SPO OFF;
SET TERM OFF;

-- update main report
SPO &&edb360_main_report..html APP;
PRO <a href="&&one_spool_filename._line_chart.html">line</a>
SPO OFF;

-- get time t0
EXEC :get_time_t0 := DBMS_UTILITY.get_time;

-- header
SPO &&edb360_output_directory.&&one_spool_filename._line_chart.html;
@@edb360_0d_html_header.sql
PRO <!-- &&one_spool_filename._line_chart.html $ -->

-- chart header
PRO    &&edb360_conf_google_charts.
PRO    <script type="text/javascript" src="&&edb360_output_directory.edb360_awr_points.js"></script>
PRO    <script type="text/javascript">
PRO      google.load("visualization", "1", {packages:["corechart","controls"]});
PRO      google.setOnLoadCallback(drawChart);
PRO     var racIdx = 0;
PRO     var instIdx1 = 0;
PRO     var instIdx2 = 0;
PRO     var instIdx3 = 0;
PRO     var instIdx4 = 0;
PRO     var instIdx5 = 0;
PRO     var instIdx6 = 0;
PRO     var instIdx7 = 0;
PRO     var instIdx8 = 0;
PRO     var data = [];
PRO     var chartData = [
-- body
SET SERVEROUT ON;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
VAR edb360_series_props CLOB;
VAR AWRPointsControls CLOB;

DECLARE
  cur SYS_REFCURSOR;
  l_snap_id NUMBER;
  l_begin_time VARCHAR2(32);
  l_end_time VARCHAR2(32);
  l_col_01 NUMBER;
  l_col_02 NUMBER;
  l_col_03 NUMBER;
  l_col_04 NUMBER;
  l_col_05 NUMBER;
  l_col_06 NUMBER;
  l_col_07 NUMBER;
  l_col_08 NUMBER;
  l_col_09 NUMBER;
  l_col_10 NUMBER;
  l_col_11 NUMBER;
  l_col_12 NUMBER;
  l_col_13 NUMBER;
  l_col_14 NUMBER;
  l_col_15 NUMBER;
  l_line VARCHAR2(1000);
  l_sql_text VARCHAR2(32767);
  l_ncol NUMBER:=0;
  l_lastcol varchar2(2);
 PROCEDURE addAWRP(id IN NUMBER,condition IN VARCHAR2) is
 BEGIN
  IF instr(:addAWRPoints,nvl(condition,'-'))>0 THEN 
   :AWRPointsControls:=:AWRPointsControls||'<input type="checkbox" onchange="toggleAWRPoint('||id||');">'||
    (CASE WHEN id=0 THEN 'Cluster' ELSE to_char(id) END)||'</input>';
  END IF;
 END;
BEGIN
  EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''&&edb360_date_format.''';
  l_line := '[''Date''';
  IF '&&edb360_conf_incl_plot_awr.' ='Y' THEN
   l_line := l_line || q'[, {'type': 'string', 'role': 'annotation' } ]';
   l_line := l_line || q'[, {'type': 'string', 'role': 'tooltip' , 'p':{'html': true} } ]';
  END IF; 
  IF '&&tit_01.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_01.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='0';
  END IF;
  IF '&&tit_02.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_02.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='1';
  END IF;
  IF '&&tit_03.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_03.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='2';
  END IF;
  IF '&&tit_04.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_04.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='3';
  END IF;
  IF '&&tit_05.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_05.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='4';
  END IF;
  IF '&&tit_06.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_06.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='5';
  END IF;
  IF '&&tit_07.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_07.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='6';
  END IF;
  IF '&&tit_08.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_08.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='7';
  END IF;
  IF '&&tit_09.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_09.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='8';
  END IF;
  IF '&&tit_10.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_10.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='9';
  END IF;
  IF '&&tit_11.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_11.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='10';
  END IF;
  IF '&&tit_12.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_12.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='11';
  END IF;
  IF '&&tit_13.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_13.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='12';
  END IF;
  IF '&&tit_14.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_14.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='13';
  END IF;
  IF '&&tit_15.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_15.'''; 
    l_ncol := l_ncol +1;
    l_lastcol:='14';
  END IF;

  l_line := l_line||']';
  DBMS_OUTPUT.PUT_LINE(l_line);
  --OPEN cur FOR :sql_text;
  l_sql_text := DBMS_LOB.SUBSTR(:sql_text); -- needed for 10g
  OPEN cur FOR l_sql_text; -- needed for 10g
  LOOP
    FETCH cur INTO l_snap_id, l_begin_time, l_end_time,
    l_col_01, l_col_02, l_col_03, l_col_04, l_col_05,
    l_col_06, l_col_07, l_col_08, l_col_09, l_col_10,
    l_col_11, l_col_12, l_col_13, l_col_14, l_col_15;
    EXIT WHEN cur%NOTFOUND;
    IF l_col_01 IS NOT NULL AND l_col_02 IS NOT NULL AND l_col_03 IS NOT NULL AND l_col_04 IS NOT NULL AND l_col_05 IS NOT NULL AND l_col_06 IS NOT NULL AND l_col_07 IS NOT NULL AND l_col_08 IS NOT NULL AND l_col_09 IS NOT NULL AND l_col_10 IS NOT NULL AND l_col_11 IS NOT NULL AND l_col_12 IS NOT NULL AND l_col_13 IS NOT NULL AND l_col_14 IS NOT NULL AND l_col_15 IS NOT NULL THEN
      l_line := ', [new Date('||SUBSTR(l_end_time,1,4)||','||
      (TO_NUMBER(SUBSTR(l_end_time,6,2)) - 1)||','||
      SUBSTR(l_end_time,9,2)||','||
      SUBSTR(l_end_time,12,2)||','||
      SUBSTR(l_end_time,15,2)||','||
      NVL(SUBSTR(l_end_time,18,2),'0')||
      ')';
      IF '&&edb360_conf_incl_plot_awr.' = 'Y' THEN
       l_line := l_line||', null, null ';      
      END IF;       
      IF '&&tit_01.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_01; 
      END IF;
      IF '&&tit_02.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_02; 
      END IF;
      IF '&&tit_03.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_03; 
      END IF;
      IF '&&tit_04.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_04; 
      END IF;
      IF '&&tit_05.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_05; 
      END IF;
      IF '&&tit_06.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_06; 
      END IF;
      IF '&&tit_07.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_07; 
      END IF;
      IF '&&tit_08.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_08; 
      END IF;
      IF '&&tit_09.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_09; 
      END IF;
      IF '&&tit_10.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_10; 
      END IF;
      IF '&&tit_11.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_11; 
      END IF;
      IF '&&tit_12.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_12; 
      END IF;
      IF '&&tit_13.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_13; 
      END IF;
      IF '&&tit_14.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_14; 
      END IF;
      IF '&&tit_15.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_15; 
      END IF;             
      l_line := l_line||']';
      DBMS_OUTPUT.PUT_LINE(l_line);
    END IF;
  END LOOP;
  CLOSE cur;

 :AWRPointsControls:=' ';
 :AWRPointsIni:=' ';
 IF '&&edb360_conf_incl_plot_awr.' ='Y' THEN
  :AWRPointsControls:='<div id="AWRPointsControls_div" style="border: 1px solid #ccc">AWR Points Instances: ';
  addAWRP(1,'&&inst1_present.');
  addAWRP(2,'&&inst2_present.');
  addAWRP(3,'&&inst3_present.');
  addAWRP(4,'&&inst4_present.');
  addAWRP(5,'&&inst5_present.');
  addAWRP(6,'&&inst6_present.');
  addAWRP(7,'&&inst7_present.');
  addAWRP(8,'&&inst8_present.');
  addAWRP(0,NVL('&&is_single_instance.','C'));  
  :AWRPointsControls:=:AWRPointsControls||'<input type="checkbox" onchange="toggleAnnotations();" checked>long annotations</input></div>';
  :AWRPointsIni:='initializeArrays('||l_ncol||');';
 ELSE
  l_lastcol:='-';
 END IF; 
END;
/
SET SERVEROUT OFF;

SET HEA OFF;

PRO        ];
-- line chart footer

PRO      function drawChart() {     
PRO        chartDataPoints = new google.visualization.arrayToDataTable(chartData);
PRO        var programmaticChart = new google.visualization.ChartWrapper({
PRO        chartType:'&&chartype.',
PRO        containerId:'linechart',
PRO        dataTable: chartDataPoints,
PRO        options: {&&stacked.
PRO          chartArea:{left:90, top:75, width:'65%', height:'70%'},
PRO          backgroundColor: {fill: 'white', stroke: '#336699', strokeWidth: 1},
PRO          explorer: {actions: ['dragToZoom', 'rightClickToReset'], maxZoomIn: 0.01},
PRO          title: '&&section_id..&&report_sequence.. &&title.&&title_suffix.',
PRO          titleTextStyle: {fontSize: 18, bold: false},
PRO          focusTarget: 'category',
PRO          legend: {position: 'right', textStyle: {fontSize: 14}},
PRO          tooltip: {isHtml: true, textStyle: {fontSize: 14}},
PRO          annotations: { style: 'line' , stem: { color:'#000000' } },
PRO          hAxis: {title: '&&haxis.', gridlines: {count: -1}, titleTextStyle: {fontSize: 16, bold: false}},
PRO          series: { 0: { &&series_01.},  1: { &&series_02.},  2: { &&series_03.},  3: { &&series_04.},  4: { &&series_05.},  
PRO                    5: { &&series_06.},  6: { &&series_07.},  7: { &&series_08.},  8: { &&series_09.},  9: { &&series_10.},
PRO                   10: { &&series_11.}, 11: { &&series_12.}, 12: { &&series_13.}, 13: { &&series_14.}, 14: { &&series_15.}
PRO          },
PRO          vAxis: {title: '&&vaxis.', &&vbaseline. gridlines: {count: -1}, titleTextStyle: {fontSize: 16, bold: false}}
PRO        }
PRO      });
PRO      programmaticChart.draw();
PRO /*
PRO    by Abel Macias
PRO    October 11th, 2019
PRO 
PRO    JavaScript funtions to control the presence of AWR points in the graphs
PRO    and display the corresponding AWR report when clicked.
PRO 
PRO    These functions have to be included inside the drawChart() function.
PRO  */
PRO 
PRO function selectHandler() {
PRO     var selectedItem = programmaticChart.getChart().getSelection()[0];
PRO     if (selectedItem) {
PRO       var value = programmaticChart.getDataTable().getValue(selectedItem.row, 2);
PRO       if (value != null) {
PRO        var awrname = value.match(/(?:rac|\d)\_\d+\_\d+\_(?:max|med|min)\w{3,5}/);
PRO        window.open('./edb360_show.html?awr=awrrpt_'+awrname)
PRO       }
PRO     }
PRO   }
PRO 
PRO google.visualization.events.addListener(programmaticChart, 'select', selectHandler); 
PRO 
PRO toggleAnnotations = function() {
PRO   if (programmaticChart.getOption('annotations.style') === 'line') {
PRO         programmaticChart.setOption('annotations.style','point');
PRO       } else {
PRO         programmaticChart.setOption('annotations.style','line');
PRO       }
PRO   programmaticChart.draw();
PRO }
PRO 
PRO toggleAWRPoint = function(id){
PRO   switch(id){
PRO     case 0: if ( racIdx   == 0 ) { racIdx= 1;    } else { racIdx= 0;    } break;
PRO     case 1: if ( instIdx1 == 0 ) { instIdx1 = 1; } else { instIdx1 = 0; } break;
PRO     case 2: if ( instIdx2 == 0 ) { instIdx2 = 1; } else { instIdx2 = 0; } break;
PRO     case 3: if ( instIdx3 == 0 ) { instIdx3 = 1; } else { instIdx3 = 0; } break;
PRO     case 4: if ( instIdx4 == 0 ) { instIdx4 = 1; } else { instIdx4 = 0; } break;
PRO     case 5: if ( instIdx5 == 0 ) { instIdx5 = 1; } else { instIdx5 = 0; } break;
PRO     case 6: if ( instIdx6 == 0 ) { instIdx6 = 1; } else { instIdx6 = 0; } break;
PRO     case 7: if ( instIdx7 == 0 ) { instIdx7 = 1; } else { instIdx7 = 0; } break;
PRO     case 8: if ( instIdx8 == 0 ) { instIdx8 = 1; } else { instIdx8 = 0; } break;
PRO   }
PRO   data=chartData.concat([]);
PRO   if (racIdx > 0)   { data = data.concat(racData); }
PRO   if (instIdx1 >0 ) { data = data.concat(instData1); }
PRO   if (instIdx2 >0 ) { data = data.concat(instData2); }
PRO   if (instIdx3 >0 ) { data = data.concat(instData3); }
PRO   if (instIdx4 >0 ) { data = data.concat(instData4); }
PRO   if (instIdx5 >0 ) { data = data.concat(instData5); }
PRO   if (instIdx6 >0 ) { data = data.concat(instData6); }
PRO   if (instIdx7 >0 ) { data = data.concat(instData7); }
PRO   if (instIdx8 >0 ) { data = data.concat(instData8); }
PRO   programmaticChart.setDataTable(google.visualization.arrayToDataTable(data));
PRO   programmaticChart.draw();
PRO }
PRO 
PRINT :AWRPointsIni
PRO     }
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
PRINT :AWRPointsControls
PRO    <div id="linechart" class="google-chart"></div>
PRO

-- footer
PRO <br />
PRO <font class="n">Notes:<br />1) drag to zoom, and right click to reset<br />2) up to &&history_days. days of awr history were considered</font>
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
       --:row_count||' , &&section_id., &&main_table., &&edb360_prev_sql_id., -1, &&title_no_spaces., html , &&one_spool_filename._line_chart.html'
       '&&row_num., &&section_id., &&main_table., &&edb360_prev_sql_id., -1, &&title_no_spaces., line , &&one_spool_filename._line_chart.html'
  FROM DUAL
/
SPO OFF;
SET HEA ON;

-- zip
HOS zip -mj &&edb360_zip_filename. &&edb360_output_directory.&&one_spool_filename._line_chart.html >> &&edb360_log3..txt

SET TERM ON
PRO Finished one line plus
