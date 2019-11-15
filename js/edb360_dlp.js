

google.load("visualization", "1", {packages:["corechart","controls"]})
google.setOnLoadCallback(drawChart)

function drawChart() {
chartDataPoints = new google.visualization.arrayToDataTable(chartData)
var programmaticChart = new google.visualization.ChartWrapper({
chartType:chartType,
containerId:'linechart',
dataTable: chartDataPoints,
options: options
})
programmaticChart.draw()

initializeArrays(numColumns);

}
