Docs.allow
    insert: (userId, doc) -> false
    update: (userId, doc) -> false
    remove: (userId, doc) -> false


Meteor.publish 'results', (selected_tags, query)->
    console.log 'query', query
    console.log 'selected tags', selected_tags

    self = @
    match = {}
    # if selected_tags.length > 0 then match.tags = $all: selected_tags
        # match.$regex:"#{current_query}", $options: 'i'}
    if query and query.length > 2
        match.tags = {$regex:"#{query}", $options: 'i'}
        # match.tags_string = {$regex:"#{query}", $options: 'i'}

        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $match: _id: {$regex:"#{query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

    else
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # match.tags = $all: selected_tags
        console.log 'match for tags', match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

    tag_cloud.forEach (tag, i) =>
        console.log 'queried tag ', tag
        # console.log 'key', key
        self.added 'tags', Random.id(),
            title: tag.name
            count: tag.count
            # category:key
            # index: i
    self.ready()




Meteor.publish 'docs', (
    selected_tags
    )->
    # console.log selected_tags
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
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
        sort:ups:1
        limit: 7
