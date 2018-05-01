'use strict';

const request = require("request");
const _ = require('lodash');
const Push = require( 'pushover-notifications' )

require("babel-polyfill");

module.exports.dailySolarPush = (event, context, callback) => {
  var start_date = new Date();
  start_date.setDate(start_date.getDate() - 30);
  var start_date = start_date.toISOString().split('T')[0];

  var end_date = new Date();
  end_date.setDate(end_date.getDate() - 1);
  var end_date = end_date.toISOString().split('T')[0];

  const options = {
    url: 'https://monitoringapi.solaredge.com/site/' + process.env.SITE_ID + '/energy.json?timeUnit=DAY&endDate=' + end_date + '&startDate=' + start_date + '&api_key=' + process.env.API_KEY
  };

  function calculatePercentage($oldFigure, $newFigure) {
    var percentChange = (($oldFigure - $newFigure) / $oldFigure) * 100;
    return Math.abs(percentChange).toFixed(0);
  }

  request(options, function (error, response, body) {
    if (!error && response.statusCode == 200) {
      var json = JSON.parse(body)

      var values = _.map(json.energy.values, 'value')
      var total = values.reduce(function(acc, val) { return acc + val; })
      var average = (total/values.length).toFixed(2);

      var last_value = values.slice(-1)[0];
      var last_value_human = (last_value / 1000).toFixed(2);

      var average_label = 'the average of the last 30 days'
      var new_value_label = 'yesterday'

      var difference = calculatePercentage(average, last_value)

      if (last_value >= average) {
        var difference_label = 'higher'
      } else {
        var difference_label = 'lower'
      }

      var message = "Hi Martijn, " + new_value_label + " your solar panels generated " + last_value_human +
      "kWh. That's " + difference + "% " + difference_label + " compared " +
      "to " + average_label + "."

      var push = new Push( {
        user: process.env.PUSHOVER_USER_TOKEN,
        token: process.env.PUSHOVER_APP_TOKEN,
      })

      var msg = {
        message: message,
        title: "RusPower"
      }

      push.send( msg, function( err, result ) {
        if ( err ) {
          throw err
        }

        console.log( result )
      })
    }
  })
};
