var Request = require("request");
var config = require("./config.json")
var data = []

Request.get(config.resturl +"/countrynames/", (error, response, body) => {
    if(error) {
        return console.dir(error);
    }
    var jsonArray = JSON.parse(body)    
    jsonArray.countryname.forEach(x => {
        console.log(x.COUNTRYCODE, " ", x.COUNTRYNAME)
        data.push(x.COUNTRYCODE,x.COUNTRYNAME)
    })

    // Display array values
    //for (var i = 0; i < data.length; i++) {
    //    console.log(data[i])
    //}
});