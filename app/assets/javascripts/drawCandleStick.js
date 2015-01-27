$( document ).ready(function() {
  var candleSticksJSBaby = JSON.parse(gon.candle_sticks);
  var candleSticksJS = candleSticksJSBaby.map(function(dataCandleStick){
    return {x: new Date(dataCandleStick.x), y: dataCandleStick.y};
  });
  var chart = new CanvasJS.Chart("chartContainer",
  {
    title:{
      text: "Candlestick Chart",
    },
    exportEnabled: true,
    axisY: {
      includeZero: false,
      prefix: "$",
    },
    axisX: {
      valueFormatString: "DD-MMM",
    },
    data: [
    {
      type: "candlestick", 
      dataPoints: candleSticksJS   

    }
    ]
  });
  chart.render();
  });