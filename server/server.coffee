Docs.allow
    insert: (user_id, doc) -> true
    update: (user_id, doc) -> true
    # user_id is doc._author_id
    remove: (user_id, doc) ->
        user = Meteor.users.findOne user_id
        if user.roles and 'admin' in user.roles
            true
        else
            user_id is doc._author_id

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
        # if user_id and doc._id == user_id
        #     true





Meteor.publish 'reddit_tags', (
    selected_tags
    query
    dummy
    )->
    # console.log 'dummy', dummy
    # console.log 'query', query
    console.log 'selected tags', selected_tags

    self = @
    match = {}
    match.model = 'reddit'
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

        # console.log doc_tag_cloud.count()

        self.ready()

Meteor.publish 'reddit_docs', (
    selected_tags
    )->
    # console.log selected_tags
    self = @
    match = {}
    if selected_tags.length > 0
        match.tags = $all: selected_tags
        sort = 'ups'
    else
        # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
        # match.source = $ne:'wikipedia'
    console.log 'reddit match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:"ups":-1
        # sort:_timestamp:-1
        limit: 10
