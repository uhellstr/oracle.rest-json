var Request = require("request");
var data = []

Request.get("http://localhost:8080/ords/xepdb1/rest_data/testmodule/countrynames/", (error, response, body) => {
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