if Meteor.isClient
    @selected_tags = new ReactiveArray []
    @selected_organizations = new ReactiveArray []
    @selected_people = new ReactiveArray []
    @selected_authors = new ReactiveArray []
    @selected_subreddits = new ReactiveArray []
    @selected_companies = new ReactiveArray []
    @selected_timestamp_tags = new ReactiveArray []

    Template.tag_cloud.onCreated ->
        @autorun -> Meteor.subscribe(
            'reddit_facets',
            selected_tags.array(),
            selected_organizations.array()
            selected_people.array()
            selected_subreddits.array()
            selected_companies.array()
            selected_authors.array()
            selected_timestamp_tags.array()
            Session.get('tag_limit')
            Session.get('doc_limit')
            Session.get('view_nsfw')
            Session.get('sort_key')
            Session.get('sort_nsfw')

            # Template.currentData().limit
        )

    Template.tag_cloud.helpers
        all_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        tag_cloud_class: ->
            button_class = switch
                when @index <= 10 then 'big'
                when @index <= 20 then 'large'
                when @index <= 30 then ''
                when @index <= 40 then 'small'
                when @index <= 50 then 'tiny'
            return button_class

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


        selected_tags: ->
            # model = 'event'
            # console.log "selected_#{model}_tags"
            selected_tags.array()


    Template.tag_cloud.events
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
            # console.log 'selected ', doc
            selected_tags.push doc.name
            $('#search').val ''

        # 'click #add': ->
        #     Meteor.call 'add', (err,id)->
        #         FlowRouter.go "/edit/#{id}"


# if Meteor.isServer
#     Meteor.publish 'tags', (selected_tags, filter, limit)->
#         self = @
#         match = {}
#         if selected_tags.length > 0 then match.tags = $all: selected_tags
#         if filter then match.model = filter
#         if limit
#             console.log 'limit', limit
#             calc_limit = limit
#         else
#             calc_limit = 20
#         cloud = Docs.aggregate [
#             { $match: match }
#             { $project: "tags": 1 }
#             { $unwind: "$tags" }
#             { $group: _id: "$tags", count: $sum: 1 }
#             { $match: _id: $nin: selected_tags }
#             { $sort: count: -1, _id: 1 }
#             { $limit: calc_limit }
#             { $project: _id: 0, name: '$_id', count: 1 }
#             ]
#
#         # console.log 'filter: ', filter
#         # console.log 'cloud: ', cloud
#
#         cloud.forEach (tag, i) ->
#             self.added 'tags', Random.id(),
#                 name: tag.name
#                 count: tag.count
#                 index: i
#
#         self.ready()
