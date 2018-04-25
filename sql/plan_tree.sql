SET VERI OFF

--DEF diagnostics_pack = 'Y'

PRO This script makes use of information stored in tables licensed under Diagnostic Pack
PRO Press ENTER if you have the Diagnostic Pack license, otherwise enter CTRL+C
PAU

ACC sqld360_sqlid PROMPT 'Enter SQL_ID: ' 
ACC sqld360_phv   PROMPT 'Enter Plan Hash Value: ' 

PRO Crunching some data, might take a while....
PRO
--SET TERM OFF
DELETE plan_table WHERE statement_id = 'SQLD360_TREECOLOR' AND operation = '&&sqld360_sqlid.';
INSERT INTO plan_table (statement_id, operation, options) SELECT 'SQLD360_TREECOLOR', '&&sqld360_sqlid.', treeColor 
  FROM (SELECT plandata.adapt_id id,'data.setRowProperty('||plandata.adapt_id||', ''style'', ''background:#FF'||LPAD(LTRIM(TO_CHAR(255-(255*RATIO_TO_REPORT(num_samples) OVER ()),'XXXX')),2,'0')||'00'');' treeColor
          FROM (SELECT NVL(sql_plan_line_id,0) id, COUNT(*) num_samples
                  FROM gv$active_session_history 
                 WHERE sql_plan_hash_value = &&sqld360_phv.
                   AND sql_id = '&&sqld360_sqlid.'
                 GROUP BY NVL(sql_plan_line_id,0))  ashdata, 
                (SELECT sql_id, plan_hash_value, id, parent_id, dep, adapt_id, operation, options, object_name, skp 
                   FROM (SELECT sql_id, plan_hash_value, id, parent_id, dep, (ROW_NUMBER() OVER (ORDER BY id))-1 adapt_id, operation, options, object_name, skp   
                           FROM (SELECT DISTINCT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, a.operation, a.options, a.object_name, b.skp 
                                  FROM gv$sql_plan_statistics_all a, 
                                       (SELECT sql_id, plan_hash_value, extractvalue(value(b),'/row/@op') stepid, extractvalue(value(b),'/row/@skp') skp, extractvalue(value(b),'/row/@dep') dep 
                                          FROM gv$sql_plan_statistics_all a, 
                                               table(xmlsequence(extract(xmltype(a.other_xml),'/*/display_map/row'))) b 
                                         WHERE sql_id = '&&sqld360_sqlid.'
                                           AND other_xml IS NOT NULL 
                                           AND plan_hash_value = &&sqld360_phv.) b 
                                 WHERE a.sql_id = '&&sqld360_sqlid.'
                                   AND a.plan_hash_value = &&sqld360_phv.
                                   AND a.id = b.stepid(+) 
                                   AND (b.skp = 0 OR b.skp IS NULL)) 
                          ) 
                   ORDER BY id) plandata 
 WHERE plandata.id = ashdata.id );

SPO sqld360_&&sqld360_sqlid._plan_tree.html;
PRO <html>
PRO <!-- Author: mauro.pagano@gmail.com -->
PRO
PRO <head>
PRO
PRO <style type="text/css">
PRO body                {font:10pt Arial,Helvetica,Geneva,sans-serif; color:black; background:white;}
PRO h1                  {font-size:16pt; font-weight:bold; color:#336699; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
PRO h2                  {font-size:14pt; font-weight:bold; color:#336699; margin-top:4pt; margin-bottom:0pt;}
PRO h3                  {font-size:12pt; font-weight:bold; color:#336699; margin-top:4pt; margin-bottom:0pt;}
PRO pre                 {font:8pt monospace;Monaco,"Courier New",Courier;}
PRO a                   {color:#663300;}
PRO table               {font-size:8pt; border_collapse:collapse; empty-cells:show; white-space:nowrap; border:1px solid #cccc99;}
PRO li                  {font-size:8pt; color:black; padding-left:4px; padding-right:4px; padding-bottom:2px;}
PRO th                  {font-weight:bold; color:white; background:#0066CC; padding-left:4px; padding-right:4px; padding-bottom:2px;}
PRO tr                  {color:black; background:#fcfcf0;}
PRO tr.main             {color:black; background:#fcfcf0;}
PRO td                  {vertical-align:top; border:1px solid #cccc99;}
PRO td.c                {text-align:center;}
PRO font.n              {font-size:8pt; font-style:italic; color:#336699;}
PRO font.f              {font-size:8pt; color:#999999; border-top:1px solid #cccc99; margin-top:30pt;}
PRO .myNodeClass        {background:white;vertical-align:middle}
PRO .myWhiteNodeClass   {background:white;}
PRO .myYellowNodeClass  {background:yellow;}
PRO .myOrangeNodeClass  {background:orange;}
PRO .myRedNodeClass     {background:red;}
PRO </style>

-- chart header
PRO    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
PRO    <script type="text/javascript">
PRO      google.load("visualization", "1", {packages:["orgchart"]});
PRO      google.setOnLoadCallback(drawChart);
PRO      function drawChart() {
PRO        var data = google.visualization.arrayToDataTable([

-- body
SET HEAD OFF FEED OFF
PRO ['Step', 'Parent Step','Tooltip' ] 
WITH ashdata AS (SELECT NVL(sql_plan_line_id,0) id, COUNT(*) num_samples
                   FROM gv$active_session_history 
                  WHERE sql_plan_hash_value = &&sqld360_phv.
                    AND sql_id = '&&sqld360_sqlid.'
                  GROUP BY NVL(sql_plan_line_id,0))
SELECT ',[{v: '''||plandata.adapt_id||''',f: '''||plandata.adapt_id||' - '||operation||' '||options||NVL2(object_name,'<br>',' ')||object_name||'''}, '||''''||parent_id||''''||', ''Step ID:'||plandata.adapt_id||' (ASH Step ID:'||plandata.id||') ASH Samples:'||NVL(ashdata.num_samples,0)||' ('||TRUNC(100*NVL(RATIO_TO_REPORT(ashdata.num_samples) OVER (),0),2)||'%)'']' id2
  FROM (SELECT id, adapt_id, NVL(adapt_parent_id, parent_id) parent_id, operation, options, object_name 
          FROM (WITH skp_steps AS (SELECT sql_id, plan_hash_value, extractvalue(value(b),'/row/@op') stepid, extractvalue(value(b),'/row/@skp') skp,
                                          extractvalue(value(b),'/row/@dep') dep
                                     FROM gv$sql_plan_statistics_all a, 
                                          table(xmlsequence(extract(xmltype(a.other_xml),'/*/display_map/row'))) b 
                                    WHERE sql_id = '&&sqld360_sqlid.'
                                      AND other_xml IS NOT NULL 
                                      AND plan_hash_value = &&sqld360_phv.),
                 plan_all AS (SELECT sql_id, plan_hash_value, id, parent_id, dep, (ROW_NUMBER() OVER (ORDER BY id))-1 adapt_id, operation, options, object_name, skp 
                                FROM (SELECT DISTINCT a.sql_id, a.plan_hash_value, a.id, a.parent_id, NVL(b.dep,0) dep, a.operation,a.options,a.object_name, b.skp 
                                             FROM gv$sql_plan_statistics_all a, skp_steps b 
                                       WHERE a.sql_id = '&&sqld360_sqlid.'
                                         AND a.plan_hash_value = &&sqld360_phv.
                                         AND a.id = b.stepid(+) 
                                         AND (b.skp = 0 OR b.skp IS NULL) 
                                       ORDER BY a.id)) 
                SELECT dep, adapt_id, id, 
                       (SELECT MAX(adapt_id) 
                          FROM plan_all b 
                         WHERE a.dep-1 = b.dep 
                           AND b.adapt_id < a.adapt_id ) adapt_parent_id, parent_id,
                       a.operation operation, a.options, a.object_name
                  FROM plan_all a)
       ) plandata,
       ashdata
 WHERE ashdata.id(+) = plandata.id
 ORDER BY plandata.id
; 

-- chart footer
PRO        ]);;
PRO        
PRO        var options = {
PRO          backgroundColor: {fill: '#fcfcf0', stroke: '#336699', strokeWidth: 1},
PRO          titleTextStyle: {fontSize: 16, bold: false},
PRO          legend: {position: 'none'},
PRO          allowHtml:true,
PRO          allowCollapse:true,
PRO          tooltip: {textStyle: {fontSize: 14}},
PRO          nodeClass: 'myNodeClass'
PRO        };
PRO

SELECT options
  FROM plan_table
 WHERE statement_id = 'SQLD360_TREECOLOR'
   AND operation = '&&sqld360_sqlid.'
;      

PRO
PRO        var chart = new google.visualization.OrgChart(document.getElementById('orgchart'));
PRO        chart.draw(data, options);
PRO      }
PRO    </script>
PRO  </head>
PRO  <body>
PRO <h1> Execution plan tree for SQL_ID: &&sqld360_sqlid.  </h1>
PRO
PRO <br>
PRO
PRO    <div id="orgchart"></div>
PRO
SPO OFF