Meteor.publish 'idea_facet_results', (
    key
    prematch
    current_query
    doc_limit=5
    sort_key='_timestamp'
    sort_direction=-1
)->
    # console.log 'key', key
    # console.log 'match', prematch
    self = @
    # current_facet_filter_array = _.where(prematch, {key:key})
    # current_facet_filter_array = prematch["#{key}"]
    # console.log 'current facet filter array', current_facet_filter_array
    match = {}
    # if current_query.length > 3
    # match.tags_string = {$regex:"#{current_query}", $options: 'i'}
    # if current_facet_filter_array and current_facet_filter_array.length > 0
    #     match["#{key}"] = $all: current_facet_filter_array
    found_docs =
        Docs.find({tags_string: {$regex:"#{current_query}", $options: 'i'}}).count()
    console.log 'found ', found_docs, 'with string', current_query
    keys = _.keys(prematch)
    # console.log 'facet keys', key, keys
    for match_key in keys
        key_array = prematch["#{match_key}"]
        if key_array and key_array.length > 0
            match["#{match_key}"] = $all: key_array
    # match.tags = $all: selected_tags
    # match.model = 'reddit'
    # if parent_id then match.parent_id = parent_id
    console.log 'looking up idea facets with match', prematch, match
    filters = []
    result_array = []

    # console.log key, 'facet match:', match
    result_cloud = Ideas.aggregate [
        { $match: match }
        { $project: "#{key}": 1 }
        { $unwind: "$#{key}" }
        { $group: _id: "$#{key}", count: $sum: 1 }
        # { $match: _id: $nin: filters }
        # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, title: '$_id', count: 1 }
        ]
    result_cloud.forEach (result, i) =>
        # console.log 'result ', result
        # console.log 'key', key
        self.added 'idea_results', Random.id(),
            title: result.title
            count: result.count
            category:key
            # index: i

    self.ready()


    # self.onStop ()-> subHandle.stop()
