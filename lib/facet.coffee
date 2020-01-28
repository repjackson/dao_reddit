if Meteor.isClient
    Template.facet.onCreated ->
        # console.log Template.currentData().key
        # @autorun => Meteor.subscribe 'results'
        @autorun => Meteor.subscribe(
            'facet_results'
            Template.currentData().key
            selected_filters.array()
        )

    Template.facet.helpers
        results: ->
            Results.find()



if Meteor.isServer
    # Meteor.publish 'results', ->
    #     console.log Results.find().fetch()
    #     Results.find()
    Meteor.publish 'facet_results', (
        key
        filters=[]
    )->
        console.log 'this is key', key
        self = @
        match = {}

        # match.tags = $all: selected_tags
        # match.model = 'reddit'
        # if parent_id then match.parent_id = parent_id

        # if view_private is true
        #     match.author_id = Meteor.userId()

        # if view_private is false
        #     match.published = $in: [0,1]

        # if selected_tags.length > 0 then match.tags = $all: selected_tags
        # if selected_organizations.length > 0 then match.Organization = $all: selected_organizations
        # if selected_people.length > 0 then match.Person = $all: selected_people

        result_array = []

        console.log 'match:', match
        result_cloud = Docs.aggregate [
            { $match: match }
            { $project: "#{key}": 1 }
            { $unwind: "$#{key}" }
            { $group: _id: "$#{key}", count: $sum: 1 }
            { $match: _id: $nin: filters }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        result_cloud.forEach (result, i) =>
            console.log 'result ', result
            console.log 'key', key
            self.added 'results', Random.id(),
                name: result.name
                count: result.count
                key:key
                # index: i

        #
        self.ready()

        self.onStop ()-> subHandle.stop()
