Meteor.publish 'current_doc ', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id


Meteor.publish 'model_docs', (model)->
    # console.log 'pulling doc'
    Docs.find
        model:model

Meteor.publish 'user_from_username', (username)->
    # console.log 'pulling doc'
    Meteor.users.find
        username:username


Meteor.publish 'children', (model, parent_id, limit)->
    console.log model
    console.log parent_id
    limit = if limit then limit else 10
    Docs.find {
        model:model
        parent_id:parent_id
    }, limit:limit


Meteor.publish 'results', (
    selected_tags
    selected_authors
    selected_subreddits
    selected_timestamp_tags
    query
    dummy
    doc_limit
    doc_sort_key
    doc_sort_direction
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
            # console.log 'queried redditor ', redditor
            self.added 'redditor_leaders', Random.id(),
                title: redditor.title
                count: redditor.count
                # category:key
                # index: i

        subreddit_cloud = Docs.aggregate [
            { $match: match }
            { $project: "subreddit": 1 }
            { $group: _id: "$subreddit", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        subreddit_cloud.forEach (redditor, i) =>
            # console.log 'queried redditor ', redditor
            self.added 'subreddits', Random.id(),
                title: redditor.title
                count: redditor.count
                # category:key
                # index: i


        timestamp_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "_timestamp_tags": 1 }
            { $unwind: "$_timestamp_tags" }
            { $group: _id: "$_timestamp_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_timestamp_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        timestamp_tag_cloud.forEach (timestamp_tag, i) =>
            # console.log 'queried timestamp_tag ', timestamp_tag
            self.added 'timestamp_tags', Random.id(),
                title: timestamp_tag.title
                count: timestamp_tag.count
                # category:key
                # index: i

        # console.log doc_tag_cloud.count()

        self.ready()



Meteor.publish 'all_redditors', ->
    Redditors.find()

Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'docs', (
    selected_tags
    view_images
    view_videos
    view_articles
    doc_limit
    doc_sort_key
    doc_sort_direction

    )->
    # console.log selected_tags
    if doc_limit
        limit = doc_limit
    else
        limit = 10
    if doc_sort_key
        sort = doc_sort_key
    if doc_sort_direction
        sort_direction = parseInt(doc_sort_direction)
    self = @
    match = {model:'reddit'}
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
        sort:"#{sort}":sort_direction
        # sort:_timestamp:-1
        limit: limit
