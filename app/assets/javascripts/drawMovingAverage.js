$( document ).ready(function() {
var ctx = document.getElementById("myChart").getContext("2d");
var data = {
    labels: gon.date,
    datasets: [
        {
            label: "My First dataset",
            fillColor: "rgba(220,220,220,0.2)",
            strokeColor: "navy",
            pointColor: "navy",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: gon.moving_250s
        },
        {
            label: "My Second dataset",
            fillColor: "rgba(151,187,205,0.2)",
            strokeColor: "red",
            pointColor: "red",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: gon.moving_25s
        }
    ]
};
var myLineChart = new Chart(ctx).Line(data, {datasetFill : false});
});