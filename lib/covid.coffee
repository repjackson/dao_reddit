@Covid_tags = new Meteor.Collection 'covid_tags'
@Countries = new Meteor.Collection 'countries'


if Meteor.isClient
    @selected_covid_tags = new ReactiveArray []

    Router.route '/covid', (->
        @layout 'layout'
        @render 'covid'
        ), name:'covid'

    Template.covid.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'thought'
        # @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'covid_stat')
        @autorun => Meteor.subscribe 'covid_stats'
        @autorun => Meteor.subscribe 'covid_results',
            selected_covid_tags.array()
            Session.get('current_country')
            Session.get('current_date')
        # @autorun => Meteor.subscribe 'model_docs', 'covid_stat'

        # @autorun => Meteor.subscribe 'current_covid'
    Template.covid.helpers
        covid_stats: ->
            Docs.find
                model:'covid_stat'

        countries: ->
            Countries.find()

        covid_tags: ->
            if Session.get('current_query') and Session.get('current_query').length > 1
                Terms.find({}, sort:count:-1)
            else
                doc_count = Docs.find().count()
                # console.log 'doc count', doc_count
                if doc_count < 3
                    Covid_tags.find({count: $lt: doc_count})
                else
                    Covid_tags.find()



    Template.covid.events
        'click .pull_latest': ->
            Meteor.call 'pull_covid_data', ->


if Meteor.isServer
    Meteor.publish 'covid_stats', (country, date, limit=20)->
        Docs.find {
            model:'covid_stat'
        }, limit: limit

    Meteor.publish 'covid_results', (selected_covid_tags, country, date)->
        if selected_covid_tags.length > 0 then match.tags = $all: selected_covid_tags
        # match.tags = $all: selected_tags
        self = @
        match = {model:'covid_stat'}
        # console.log 'match for tags', match
        covid_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_covid_tags }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        covid_tag_cloud.forEach (tag, i) =>
            # console.log 'queried tag ', tag
            # console.log 'key', key
            self.added 'covid_tags', Random.id(),
                title: tag.name
                count: tag.count
                # category:key
                # index: i

        covid_country_cloud = Docs.aggregate [
            { $match: match }
            { $project: "country": 1 }
            { $group: _id: "$country", count: $sum: 1 }
            # { $match: _id: $nin: selected_tags }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            # { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        covid_country_cloud.forEach (country) =>
            console.log 'country ', country
            self.added 'countries', Random.id(),
                title: country.name
                count: country.count
                # category:key
                # index: i

        covid_date_cloud = Docs.aggregate [
            { $match: match }
            { $project: "date": 1 }
            { $group: _id: "$date", count: $sum: 1 }
            # { $match: _id: $nin: selected_tags }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            # { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        covid_date_cloud.forEach (date) =>
            console.log 'date ', country
            self.added 'dates', Random.id(),
                title: date.name
                count: date.count
                # category:key
                # index: i


        self.ready()


    Meteor.methods
        'pull_covid_data': ->
            console.log 'pulling covid'
            HTTP.get "https://pomber.github.io/covid19/timeseries.json", (err, response)=>
                # console.log response.data
                if err
                    console.log 'error'
                    console.log err
                else
                    countries = _.keys(response.data)
                    console.log 'countries length', countries.length
                    for country in countries
                        for day in response.data[country]
                            console.log 'day', day
                            existing_day =
                                Docs.findOne
                                    model:'covid_stat'
                                    country: country
                                    date:day.date
                            if existing_day
                                console.log existing_day
                                Docs.update({_id:existing_day._id},
                                    {$set:
                                        confirmed: day.confirmed
                                        deaths: day.deaths
                                        recovered: day.recovered
                                    }, -> )
                            else
                                console.log 'none found'
                                Docs.insert {
                                    model: 'covid_stat'
                                    country: country
                                    date: day.date
                                    confirmed: day.confirmed
                                    deaths: day.deaths
                                    recovered: day.recovered
                                }, ->

                    # for key in response.data
                    # console.log 'success'
                    # console.log response
