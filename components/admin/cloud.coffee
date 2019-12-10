if Meteor.isClient
    Template.cloud.onCreated ->
        @autorun -> Meteor.subscribe('tags', selected_tags.array(), Template.currentData().filter)
        @autorun -> Meteor.subscribe 'me'

    Template.cloud.helpers
        all_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find({},{limit:20})
        cloud_tag_class: ->
            button_class = switch
                when @index <= 5 then 'large'
                when @index <= 12 then ''
                when @index <= 20 then 'small'
            return button_class
        selected_tags: -> selected_tags.array()
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Tags
                    field: 'name'
                    matchAll: true
                    template: Template.tag_result
                }
            ]
        }


    Template.cloud.events
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()

        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_tags.pop()

        'autocompleteselect #search': (event, template, doc) ->
            selected_tags.push doc.name
            $('#search').val ''


if Meteor.isServer
    Meteor.publish 'tags', (selected_tags, filter)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}
        if Meteor.user()
            unless Meteor.user().roles and 'dev' in Meteor.user().roles
                match.view_roles = $in:Meteor.user().roles
        else
            match.view_roles = $in:['public']

        # selected_tags.push current_herd

        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if filter then match.model = filter
        if filter and filter is 'shop'
            match.active = true
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()
