var Request = require("request");
var blessed = require('blessed')
  , contrib = require('blessed-contrib')
  , screen = blessed.screen()
  , line = contrib.line(
    { style:
      { line: "yellow"
      , text: "green"
      , baseline: "black"}
    , xLabelPadding: 1
    , xPadding: 2
    , showLegend: true
    , wholeNumbersOnly: true
    , label: 'Sweden Population'})

var year = []
var population = []

Request.get("http://localhost:8080/ords/xepdb1/rest_data/testmodule/country/Sweden", (error, response, body) => {
    if(error) {
        return console.dir(error);
    }
    var jsonArray = JSON.parse(body)    
    jsonArray.countrydata.forEach(x => {
      //console.log(x.COUNTRYNAME, " ", x.YEAR, " ", x.VAL)
      year.push(x.YEAR)
      population.push(x.VAL)
    })
        //
    var series1 = {
        title: 'Populatation',
        x: year,
        y: population
    }
    
    screen.append(line) //must append before setting data
    line.setData([series1])
    screen.render()     
  }); 
