//  var dataCandleStick = [];
//  gon.daily_prices.forEach(function(daily_price){
//    dataCandleStick += {x: new Date(daily_price), y:[daily_price.open, daily_price.high, daily_price.low, daily_price.close] };
//  });
window.onload = function () {
  var candleSticksJSBaby = JSON.parse(gon.candle_sticks);
  var candleSticksJS = candleSticksJSBaby.map(function(dataCandleStick){
    return {x: new Date(dataCandleStick.x), y: dataCandleStick.y};
  });
  var chart = new CanvasJS.Chart("chartContainer",
  {
    title:{
      text: "CanvasJS Candlestick Chart",
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

      //[     // x: DATE, // y: [open, high, low, close]
//        {x: new Date(1970,00,01), y:[99.91, 100.15, 99.33, 99.61]},
//        {x: new Date(1970,00,02), y:[100.12, 100.45, 99.28, 99.51]},
//        {x: new Date(1970,00,03), y:[99.28, 100.36, 99.27, 99.79]},
//        {x: new Date(1970,00,04), y:[99.44, 100.62, 99.41, 99.62]},
//        {x: new Date(1970,00,05), y:[99.74, 100.45, 99.72, 99.96]},
//        {x: new Date(1970,00,06), y:[99.31, 100.46, 98.93, 99.50]},
//        {x: new Date(1970,00,07), y:[100.27, 100.27, 99.64, 100.19]},
//        {x: new Date(1970,00,08), y:[100.61, 100.67, 100.05, 100.38]},
//        {x: new Date(1970,00,09), y:[99.96, 100.11, 98.81, 99.21]},
//        {x: new Date(1970,00,10), y:[100.40, 100.52, 99.45, 100.35]},
//        {x: new Date(1970,00,11), y:[100.88, 100.93, 100.28, 100.65]},
//        {x: new Date(1970,00,12), y:[100.30, 100.52, 99.76, 99.92]},
//        {x: new Date(1970,00,13), y:[99.52, 100.29, 99.06, 99.45]},
//        {x: new Date(1970,00,14), y:[99.25, 100.00, 99.18, 99.56]},
//        {x: new Date(1970,00,15), y:[99.41, 100.10, 98.78, 99.67]},
//        {x: new Date(1970,00,16), y:[100.45, 100.62, 100.19, 100.50]},
//        {x: new Date(1970,00,17), y:[100.36, 100.54, 99.60, 100.52]},
//        {x: new Date(1970,00,18), y:[99.52, 100.02, 99.32, 99.70]},
//        {x: new Date(1970,00,19), y:[99.82, 100.66, 99.07, 99.73]},
//        {x: new Date(1970,00,20), y:[100.05, 100.96, 99.51, 100.38]},
//        {x: new Date(1970,00,21), y:[100.22, 100.66, 100.20, 100.22]},
//        {x: new Date(1970,00,22), y:[99.05, 100.29, 98.97, 99.62]},
//        {x: new Date(1970,00,23), y:[100.33, 100.90, 100.13, 100.78]},
//        {x: new Date(1970,00,24), y:[100.78, 100.93, 100.75, 100.85]},
//        {x: new Date(1970,00,25), y:[100.78, 100.92, 100.25, 100.33]},
//        {x: new Date(1970,00,26), y:[99.75, 100.72, 99.63, 100.58]},
//        {x: new Date(1970,00,27), y:[100.02, 100.36, 99.59, 99.85]},
//        {x: new Date(1970,00,28), y:[100.58, 100.81, 100.56, 100.72]},
//        {x: new Date(1970,00,29), y:[99.73, 100.08, 99.42, 99.51]},
//        {x: new Date(1970,00,30), y:[100.16, 100.47, 99.50, 100.26]},
//        {x: new Date(1970,00,31), y:[100.43, 100.95, 100.39, 100.88]}
//      ]
    }
    ]
  });
  chart.render();
  };