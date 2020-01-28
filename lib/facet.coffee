if Meteor.isClient
    Template.facet.onCreated ->
        # @autorun => Meteor.subscribe 'results'
        @autorun => Meteor.subscribe(
            'facet_results'
            Template.currentData().key
            Session.get('match')
        )

    Template.facet.events
        'click .toggle_filter': ->
            console.log @
            match = Session.get('match')
            match["#{@key}"] = ["#{@name}"]
            Session.set('match', match)
            console.log Session.get('match')

    Template.facet.helpers
        toggle_filter_class: ->
            match = Session.get('match')
            key = Template.currentData().key
            if match["#{key}"]
                if @name in match["#{key}"]
                    'active'
        match: ->
            console.log Session.get('match')
            Session.get('match')
        results: ->
            # console.log Template.currentData().key
            Results.find(
                key:Template.currentData().key
            )



if Meteor.isServer
    # Meteor.publish 'results', ->
    #     console.log Results.find().fetch()
    #     Results.find()
    Meteor.publish 'facet_results', (
        key
        pre_match
    )->
        console.log 'key', key
        console.log 'match', pre_match
        self = @
        # current_facet_filter_array = _.where(pre_match, {key:key})
        current_facet_filter_array = pre_match["#{key}"]
        console.log 'current facet filter array', current_facet_filter_array

        match = {}
        if current_facet_filter_array and current_facet_filter_array.length > 0
            match["#{key}"] = $all: current_facet_filter_array

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
        filters = []
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
            # console.log 'result ', result
            # console.log 'key', key
            self.added 'results', Random.id(),
                name: result.name
                count: result.count
                key:key
                # index: i

        #
        self.ready()

        # self.onStop ()-> subHandle.stop()
