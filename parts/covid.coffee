if Meteor.isClient
    Router.route '/covid', (->
        @layout 'layout'
        @render 'covid'
        ), name:'covid'

    Template.covid.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'thought'
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'thought')
        @autorun => Meteor.subscribe 'model_docs', 'covid_stats'
        @autorun => Meteor.subscribe 'current_covid'
    Template.covid.events
        'click .pull_latest': ->
            Meteor.call 'pull_covid_data', ->


if Meteor.isServer
    Meteor.methods
        'pull_covid_data': ->
            console.log 'pulling covid'
            HTTP.get "https://pomber.github.io/covid19/timeseries.json", (err, response)=>
                console.log response.data
                if err
                    console.log 'error'
                    console.log err
                else
                    console.log 'success'
                    # console.log response
