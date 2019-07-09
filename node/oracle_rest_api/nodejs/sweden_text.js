var Request = require("request");
var config = require("./config.json")
var data = []

Request.get(config.resturl + "/country/Sweden", (error, response, body) => {
    if(error) {
        return console.dir(error);
    }
    var jsonArray = JSON.parse(body)    
    jsonArray.countrydata.forEach(x => {
        console.log(x.COUNTRYNAME, " ", x.YEAR, " ", x.VAL)
        data.push(x.YEAR,x.VAL)
    })

    // Display array values
    //for (var i = 0; i < data.length; i++) {
    //    console.log(data[i])
    // }


});