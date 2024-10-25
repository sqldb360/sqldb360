/*
Compatible with sqldb360 20.1 or later
This is the full functioning JS code for 9e_line_chart_plus features to work 
when the edb360/sqld360 is collected with:

DEF edb360_conf_incl_plot_awr ='Y';
DEF edb360_conf_series_selection ='Y';

Instructions:
Replace the edb360_dlp.js on the unzipped directory of the generated edb360 report with edb360_dlp_full_features.js

cp edb360_dlp_full_features.js ./unzipped_edb360/edb360_dlp.js

The file is also compatible with sqld360s.
1) unzip the sqld360 in side the edb360 directory 
2) Replace the edb360_dlp.js on the unzipped directory of the generated sqld reports with edb360_dlp_full_features.js

*/

google.load("visualization", "1", {packages:["corechart","controls"]})
google.setOnLoadCallback(drawChart)
var racIdx = 0
var instIdx1 = 0
var instIdx2 = 0
var instIdx3 = 0
var instIdx4 = 0
var instIdx5 = 0
var instIdx6 = 0
var instIdx7 = 0
var instIdx8 = 0
var data = []


function drawChart() {
chartDataPoints = new google.visualization.arrayToDataTable(chartData)
var programmaticChart = new google.visualization.ChartWrapper({
chartType:chartType,
containerId:'linechart',
dataTable: chartDataPoints,
options: options
})
programmaticChart.draw()
/*
by Abel Macias
January 1st, 2020

JavaScript funtions to control 
- the presence of AWR points in the graphs and display the corresponding AWR report when clicked.
- toggle series when clicking the label
These functions have to be included inside the drawChart() function.

The functions need the following variables defined prior to load this :
chartype, numColumns, path7a
*/

 var columns = [];
 var series = {};
 for (var i = 0; i < chartDataPoints.getNumberOfColumns(); i++) {
     columns.push(i);
     if (i > 0) {
         series[i - 1] = Object.assign({},options.series[i -1]);
     }
 }

function selectHandler() {
var sel = programmaticChart.getChart().getSelection()
var selectedItem = sel[0]

 if (selectedItem) {
  if (selectedItem.row == null) {
      var col = selectedItem.column;
      var seriesCol = col -1 -annColumns;
      if (options.series[seriesCol].color =='#FFFFFF') {
            columns[col] = col
            options.series[seriesCol] = Object.assign({},series[seriesCol]) ;
        }
        else {
            options.series[seriesCol].color = '#FFFFFF';
            columns[col] = {
                   label: chartDataPoints.getColumnLabel(col),
                   type: chartDataPoints.getColumnType(col),
                   calc: function () { return null; }
               }
        }
      programmaticChart.setView({columns: columns});
      programmaticChart.draw();
  }
  else
  {
     var value = programmaticChart.getDataTable().getValue(selectedItem.row, 2)
     if (value != null) {
      var awrname = value.match(/(?:rac|\d)\_\d+\_\d+\_(?:max|med|min)\w{2,5}/)
      window.open(path7a+'/edb360_show.html?awr=awrrpt_'+awrname)
     }
    }  
  }
}

google.visualization.events.addListener(programmaticChart, 'select', selectHandler)

toggleAnnotations = function() {
if (programmaticChart.getOption('annotations.style') === 'line') {
programmaticChart.setOption('annotations.style','point')
} else {
programmaticChart.setOption('annotations.style','line')
}
programmaticChart.draw()
}

toggleAWRPoint = function(id){
switch(id){
case 0: if ( racIdx   == 0 ) { racIdx= 1;    } else { racIdx= 0;    } break
case 1: if ( instIdx1 == 0 ) { instIdx1 = 1; } else { instIdx1 = 0; } break
case 2: if ( instIdx2 == 0 ) { instIdx2 = 1; } else { instIdx2 = 0; } break
case 3: if ( instIdx3 == 0 ) { instIdx3 = 1; } else { instIdx3 = 0; } break
case 4: if ( instIdx4 == 0 ) { instIdx4 = 1; } else { instIdx4 = 0; } break
case 5: if ( instIdx5 == 0 ) { instIdx5 = 1; } else { instIdx5 = 0; } break
case 6: if ( instIdx6 == 0 ) { instIdx6 = 1; } else { instIdx6 = 0; } break
case 7: if ( instIdx7 == 0 ) { instIdx7 = 1; } else { instIdx7 = 0; } break
case 8: if ( instIdx8 == 0 ) { instIdx8 = 1; } else { instIdx8 = 0; } break
}
data=chartData.concat([])
if (racIdx > 0)   { data = data.concat(racData); }
if (instIdx1 >0 ) { data = data.concat(instData1); }
if (instIdx2 >0 ) { data = data.concat(instData2); }
if (instIdx3 >0 ) { data = data.concat(instData3); }
if (instIdx4 >0 ) { data = data.concat(instData4); }
if (instIdx5 >0 ) { data = data.concat(instData5); }
if (instIdx6 >0 ) { data = data.concat(instData6); }
if (instIdx7 >0 ) { data = data.concat(instData7); }
if (instIdx8 >0 ) { data = data.concat(instData8); }
programmaticChart.setDataTable(google.visualization.arrayToDataTable(data))
programmaticChart.draw()
}

initializeArrays(numColumns);

}
