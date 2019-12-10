Highcharts = require('highcharts')
# import { Template } from 'meteor/templating';
# NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');

Template.question_view.onCreated ->

Template.question_view.onRendered ->
    Meteor.setTimeout =>
      $('#container').highcharts({
        chart: {
          type: 'bar'
        },
        title: {
          text: 'Fruit Consumption'
        },
        xAxis: {
          categories: ['Apples', 'Bananas', 'Oranges']
        },
        yAxis: {
          title: {
            text: 'Fruit eaten'
          },
        },
        series: [
          {
            name: 'Jane',
            data: [1, 0, 4]
          }, {
            name: 'John',
            data: [5, 7, 3]
          }
        ]
      })
    , 1000
