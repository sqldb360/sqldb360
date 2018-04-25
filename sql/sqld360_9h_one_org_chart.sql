-- add seq to one_spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

-- display
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET TERM ON;
SPO &&sqld360_log..txt APP;
PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number. "&&one_spool_filename._org_chart.html"
SPO OFF;
SET TERM OFF;

-- update main report
SPO &&sqld360_main_report..html APP;
PRO <a href="&&one_spool_filename._org_chart.html">tree</a>
SPO OFF;

-- get time t0
EXEC :get_time_t0 := DBMS_UTILITY.get_time;

-- header
SPO &&one_spool_filename._org_chart.html;
@@sqld360_0o_html_header_org.sql
PRO <!-- &&one_spool_filename._org_chart.html $ -->

-- chart header
PRO    &&sqld360_conf_google_charts.
PRO    <script type="text/javascript">
PRO      google.load("visualization", "1", {packages:["orgchart"]});
PRO      google.setOnLoadCallback(drawChart);
PRO      function drawChart() {
PRO        var data = google.visualization.arrayToDataTable([

-- body
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
DECLARE
  cur SYS_REFCURSOR;
  l_step_id VARCHAR2(1000);
  l_parent_id NUMBER;
  l_text VARCHAR2(4000);
  l_sql_text VARCHAR2(32767);
  l_sort NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('[''Step'', ''Parent Step'',''Tooltip'' ]');
  --OPEN cur FOR :sql_text;
  l_sql_text := DBMS_LOB.SUBSTR(:sql_text); -- needed for 10g
  OPEN cur FOR l_sql_text; -- needed for 10g
  LOOP
    FETCH cur INTO l_step_id, l_parent_id, l_text, l_sort;
    EXIT WHEN cur%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(',['||l_step_id||', '''||NVL(l_parent_id,'')||''', '''||l_text||''']');
  END LOOP;
  CLOSE cur;
END;
/
SET SERVEROUT OFF;

-- chart footer
PRO        ]);;
PRO        
PRO        var options = {
PRO          backgroundColor: {fill: '#fcfcf0', stroke: '#336699', strokeWidth: 1},
PRO          title: '&&section_id..&&report_sequence.. &&title.&&title_suffix.',
PRO          titleTextStyle: {fontSize: 16, bold: false},
PRO          legend: {position: 'none'},
PRO          allowHtml:true,
PRO          allowCollapse:true,
PRO          tooltip: {textStyle: {fontSize: 14}},
PRO          nodeClass: 'myNodeClass'
PRO        };
PRO
--PRO        &&treeColor.;

SET HEA OFF PAGES 0

SELECT options
  FROM plan_table
 WHERE statement_id = 'SQLD360_TREECOLOR'
   AND operation = '&&sqld360_sqlid.';

SET HEA ON

PRO
PRO        var chart = new google.visualization.OrgChart(document.getElementById('orgchart'));
PRO        chart.draw(data, options);
PRO
PRO function reset_children_color(idx) {
PRO   var subtree_children = chart.getChildrenIndexes(idx)
PRO   var collapsed = chart.getCollapsedNodes()
PRO   for (var j = 0; j < subtree_children.length; j++) {
PRO     if (collapsed.indexOf(subtree_children[j]) == -1) {
PRO       data.setRowProperty(subtree_children[j], 'style', data.getRowProperty(subtree_children[j],'expandedStyle'))
PRO       reset_children_color(subtree_children[j])
PRO     } else {
PRO       data.setRowProperty(subtree_children[j], 'style', data.getRowProperty(subtree_children[j],'collapsedStyle'))
PRO     }
PRO   }
PRO }
PRO 
PRO // this is used to stop the recursion, only user initiated ones are allowed
PRO // no recursion due to code calling itself (chart.collapse)
PRO var top_level_collapse = true
PRO google.visualization.events.addListener(chart, 'collapse', function(e) {
PRO   // Get the list of collapsed node
PRO   var collapsed = chart.getCollapsedNodes()
PRO   if (top_level_collapse) {
PRO     if (e.collapsed) {
PRO       // We are collapsing a node, just care about the node itself (kids will disappear)
PRO       data.setRowProperty(e.row, 'style', data.getRowProperty(e.row,'collapsedStyle'))
PRO     } else {
PRO      // We are expanding a node, need to change the color of the node and its kids recursively
PRO      data.setRowProperty(e.row, 'style', data.getRowProperty(e.row,'expandedStyle')); 
PRO      var children = chart.getChildrenIndexes(e.row)
PRO      for (i = 0; i < children.length; i++) {
PRO        // Child node can be collapsed too or not
PRO        if (collapsed.indexOf(children[i]) == -1) {
PRO          data.setRowProperty(children[i], 'style', data.getRowProperty(children[i],'expandedStyle'))
PRO          reset_children_color(children[i])
PRO        } else {
PRO          data.setRowProperty(children[i], 'style', data.getRowProperty(children[i],'collapsedStyle'))
PRO        }
PRO      }
PRO     }
PRO     chart.draw(data, options)
PRO     top_level_collapse = false
PRO     chart.collapse(e.row, e.collapsed)
PRO     // need to set the other node to collapsed, otherwise you close one branch and another expands
PRO     for (var i = 0; i < collapsed.length; i++) {
PRO       chart.collapse(collapsed[i], true)
PRO     }
PRO     top_level_collapse = true
PRO   }
PRO }) 
--PRO // storing the initial colors, used for expand node
--PRO var default_colors = {}
--PRO for (var i = 0; i < data.getNumberOfRows(); i++) {
--PRO   if (data.getRowProperty(i,'style') != null)
--PRO     default_colors[i] = data.getRowProperty(i,'style')
--PRO   else
--PRO     default_colors[i] = 'background:#FFFFFF'
--PRO }
--PRO 
--PRO // compute subtree impact, used to color the node
--PRO // Also while navigating the tree, save the current color of each node
--PRO function find_subtree_impact(idx) {
--PRO   var substree_impact = 0
--PRO   var subtree_children = chart.getChildrenIndexes(idx)
--PRO   for (var j = 0; j < subtree_children.length; j++) {
--PRO     if (data.getRowProperty(subtree_children[j],'style') != null) {
--PRO       substree_impact += 255 - parseInt(data.getRowProperty(subtree_children[j],'style').substring(14, 16),16)
--PRO       data.setRowProperty(subtree_children[j], 'oldstyle', data.getRowProperty(subtree_children[j],'style'));
--PRO     }  
--PRO     substree_impact += find_subtree_impact(subtree_children[j])
--PRO   }
--PRO   return substree_impact
--PRO }
--PRO 
--PRO // reset node color to original colors
--PRO function reset_node_color(idx) {
--PRO   var subtree_children = chart.getChildrenIndexes(idx)
--PRO   for (var j = 0; j < subtree_children.length; j++) {
--PRO     //data.setRowProperty(subtree_children[j], 'style', default_colors[subtree_children[j]])
--PRO     data.setRowProperty(subtree_children[j], 'style', data.getRowProperty(subtree_children[j],'oldstyle'));
--PRO     reset_node_color(subtree_children[j])
--PRO   }
--PRO }
--PRO 
--PRO // this is used to stop the recursion, only user initiated ones are allowed
--PRO // no recursion due to code calling itself (chart.collapse)
--PRO var top_level_collapse = true
--PRO google.visualization.events.addListener(chart, 'collapse', function(e) {
--PRO   // Get the list of collapsed node
--PRO   var collapsed = chart.getCollapsedNodes()
--PRO   if (top_level_collapse) {
--PRO     if (e.collapsed) {
--PRO       // this call only get first level children (use recursion for other)
--PRO       var children = chart.getChildrenIndexes(e.row)
--PRO       aggr_impact = 0
--PRO       // Track my current color
--PRO       if (data.getRowProperty(e.row,'style') != null) {
--PRO         aggr_impact += 255 - parseInt(data.getRowProperty(e.row,'style').substring(14, 16),16)
--PRO       }
--PRO       // Track the color of all my direct children
--PRO       for (i = 0; i < children.length; i++) {
--PRO         if (data.getRowProperty(children[i],'style') != null) {
--PRO           aggr_impact += 255 - parseInt(data.getRowProperty(children[i],'style').substring(14, 16),16)
--PRO           data.setRowProperty(children[i], 'oldstyle', data.getRowProperty(children[i],'style'));
--PRO         }
--PRO         // Track the color of my grandkids (recursively), only if the parent is not already collapsed
--PRO         if (collapsed.indexOf(children[i]) == -1) {
--PRO           aggr_impact += find_subtree_impact(children[i])
--PRO         }
--PRO       }
--PRO       if (aggr_impact > 0) {
--PRO         // this is weird because JS does not seem to have LPAD
--PRO         final_color = ('00' + (255 - aggr_impact).toString(16)).slice(-'00'.length)
--PRO         // saving the previous color for when the node is collapsed and then immediately expanded
--PRO         data.setRowProperty(e.row, 'oldstyle', data.getRowProperty(e.row,'style'))
--PRO         // Saving this for when the node gets expanded from its father gets expanded too
--PRO         data.setRowProperty(e.row, 'beforeCollapse', data.getRowProperty(e.row,'style')) 
--PRO         data.setRowProperty(e.row, 'style', 'background:#FF' + final_color + '00')
--PRO       } else {
--PRO         data.setRowProperty(e.row, 'oldstyle', data.getRowProperty(e.row,'style'))
--PRO         data.setRowProperty(e.row, 'style', 'background:#FFFFFF')
--PRO       }
--PRO     } else {
--PRO       // reset the current node back to its color
--PRO       //data.setRowProperty(e.row, 'style', default_colors[e.row])
--PRO       data.setRowProperty(e.row, 'style', data.getRowProperty(e.row,'beforeCollapse')); /////
--PRO       var children = chart.getChildrenIndexes(e.row)
--PRO       for (i = 0; i < children.length; i++) {
--PRO         //data.setRowProperty(children[i], 'style', default_colors[children[i]])
--PRO         data.setRowProperty(children[i], 'style', data.getRowProperty(children[i],'oldstyle'));
--PRO         reset_node_color(children[i])
--PRO       }
--PRO     }
--PRO     chart.draw(data, options)
--PRO     top_level_collapse = false
--PRO     chart.collapse(e.row, e.collapsed)
--PRO     // need to set the other node to collapsed, otherwise you close one branch and another expands
--PRO     for (var i = 0; i < collapsed.length; i++) {
--PRO         chart.collapse(collapsed[i], true);
--PRO     }
--PRO     top_level_collapse = true
--PRO   }
--PRO });
PRO      }
PRO    </script>
PRO  </head>
PRO  <body>
PRO <h1> &&sqld360_conf_all_pages_icon. &&section_id..&&report_sequence.. &&title.&&title_suffix. <em>(&&main_table.)</em> &&sqld360_conf_all_pages_logo. </h1>
PRO
PRO <br>
PRO &&abstract.
PRO &&abstract2.
PRO
PRO    <div id="orgchart"></div>
PRO

-- footer
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
       '&&row_num. , &&main_table. , &&title_no_spaces., org_chart , &&one_spool_filename._org_chart.html'
  FROM DUAL
/
SPO OFF;
SET HEA OFF;

-- zip
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename._org_chart.html
