Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    # userId is doc._author_id
    remove: (userId, doc) -> userId is doc._author_id

Meteor.users.allow
    insert: (user_id, doc, fields, modifier) ->
        # user_id
        true
        # if user_id and doc._id == user_id
        #     true
    update: (user_id, doc, fields, modifier) ->
        # true
        if user_id and doc._id == user_id
            true
    remove: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'admin' in user.roles
            true
        # if userId and doc._id == userId
        #     true

# Meteor.publish 'me', ()->
#     if Meteor.user()
#         Meteor.users.find Meteor.userId()
#     else
#         []
#

Meteor.publish 'current_doc ', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id


Meteor.publish 'results', (selected_tags,
    query
    dummy
    view_images
    view_videos
    view_articles
    )->
    # console.log 'dummy', dummy
    # console.log 'query', query
    console.log 'selected tags', selected_tags

    self = @
    match = {}
    match.model = 'reddit'
    # if view_images
    #     match.is_image = $ne:false
    # if view_videos
    #     match.is_video = $ne:false
    # if selected_tags.length > 0 then match.tags = $all: selected_tags
        # match.$regex:"#{current_query}", $options: 'i'}
    if query and query.length > 1
    #     console.log 'searching query', query
    #     # match.tags = {$regex:"#{query}", $options: 'i'}
    #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    #
        Terms.find {
            title: {$regex:"#{query}", $options: 'i'}
        },
            sort:
                count: -1
            limit: 20
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: selected_tags }
        #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 42 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]

    else
        # unless query and query.length > 2
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # match.tags = $all: selected_tags
        # console.log 'match for tags', match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            # console.log 'queried tag ', tag
            # console.log 'key', key
            self.added 'tags', Random.id(),
                title: tag.name
                count: tag.count
                # category:key
                # index: i
        # console.log 'ready'

        # console.log 'redditor cloud match', match
        # console.log 'looking for top redditors', selected_tags

        if selected_tags.length > 0
            # console.log 'looking for top redditors 2', selected_tags
            match.tags = $all: selected_tags
            redditor_leader_cloud = Docs.aggregate [
                { $match: match }
                { $project: "author": 1 }
                { $group: _id: "$author", count: $sum: 1 }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, title: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }

            redditor_leader_cloud.forEach (redditor, i) =>
                console.log 'queried redditor ', redditor
                self.added 'redditor_leaders', Random.id(),
                    title: redditor.title
                    count: redditor.count
                    # category:key
                    # index: i
            # console.log 'ready'

            # console.log doc_tag_cloud.count()

        self.ready()



Meteor.publish 'all_redditors', ->
    Redditors.find()

Meteor.publish 'docs', (
    selected_tags
    view_images
    view_videos
    view_articles
    )->
    # console.log selected_tags
    self = @
    match = {}
    if selected_tags.length > 0
        match.tags = $all: selected_tags
        sort = 'ups'
    else
        match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
        # match.source = $ne:'wikipedia'
    if view_images
        match.is_image = $ne:false
    if view_videos
        match.is_video = $ne:false

    # match.tags = $all: selected_tags
    # if filter then match.model = filter
    # keys = _.keys(prematch)
    # for key in keys
    #     key_array = prematch["#{key}"]
    #     if key_array and key_array.length > 0
    #         match["#{key}"] = $all: key_array
        # console.log 'current facet filter array', current_facet_filter_array

    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:"#{sort}":-1
        # sort:_timestamp:-1
        limit: 20
