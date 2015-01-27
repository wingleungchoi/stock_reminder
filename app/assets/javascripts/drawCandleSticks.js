$( document ).ready(function() {
    var ctx = document.getElementById("candleStick").getContext("2d");
var data = {
    labels: gon.date,
    datasets: [
        {
            label: "My First dataset",
            fillColor: "rgba(220,220,220,0.5)",
            strokeColor: "rgba(220,220,220,0.8)",
            highlightFill: "rgba(220,220,220,0.75)",
            highlightStroke: "rgba(220,220,220,1)",
            data: gon.daily_prices.map(function(daily_price){
                return daily_price.high;
            })
        }
    ]
};
var myBarChart = new Chart(ctx).Bar(data, {});
});