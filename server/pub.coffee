Meteor.publish 'ideas', (
    selected_queries=[]
    prematch
    doc_limit=5
    )->
    Ideas.find(
        name:$in:selected_queries
    )



Meteor.publish 'docs', (
    prematch
    doc_limit=5
    sort_key='_timestamp'
    sort_direction=-1
    only_videos
    )->
    # console.log 'pre match', prematch
    # console.log selected_tags
    # console.log filter
    self = @
    match = {}
    if only_videos
        match.is_video = true
    # if selected_tags.length > 0 then match.tags = $all: selected_tags
    # if filter then match.model = filter
    keys = _.keys(prematch)
    for key in keys
        key_array = prematch["#{key}"]
        if key_array and key_array.length > 0
            match["#{key}"] = $all: key_array
        # console.log 'current facet filter array', current_facet_filter_array

    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:"#{sort_key}":sort_direction
        limit: doc_limit

Meteor.publish 'facet_results', (
    key
    prematch
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
    # if current_facet_filter_array and current_facet_filter_array.length > 0
    #     match["#{key}"] = $all: current_facet_filter_array
    keys = _.keys(prematch)
    # console.log 'facet keys', key, keys
    for match_key in keys
        key_array = prematch["#{match_key}"]
        if key_array and key_array.length > 0
            match["#{match_key}"] = $all: key_array

    # match.tags = $all: selected_tags
    # match.model = 'reddit'
    # if parent_id then match.parent_id = parent_id

    filters = []
    result_array = []

    # console.log key, 'facet match:', match
    result_cloud = Docs.aggregate [
        { $match: match }
        { $project: "#{key}": 1 }
        { $unwind: "$#{key}" }
        { $group: _id: "$#{key}", count: $sum: 1 }
        { $match: _id: $nin: filters }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
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

    self.ready()


    # self.onStop ()-> subHandle.stop()



Meteor.publish 'emotion_averages', (prematch)->
    match = {}
    self = @

    keys = _.keys(prematch)
    # console.log 'facet keys', key, keys
    for match_key in keys
        key_array = prematch["#{match_key}"]
        if key_array and key_array.length > 0
            match["#{match_key}"] = $all: key_array


    emotion_averages = Docs.aggregate [
        { $match: match }
        # { $project: "sadness_percent": 1 }
        { $group:
            _id: null
            sentiment_average: $avg: "$doc_sentiment_score"
            sadness_average: $avg: "$sadness_percent"
            joy_average: $avg: "$joy_percent"
            disgust_average: $avg: "$disgust_percent"
            fear_average: $avg: "$fear_percent"
            anger_average: $avg: "$anger_percent"
        }
    ]
    emotion_averages.forEach (result)=>
        # console.log 'avg', result
        self.added 'results', Random.id(),
            sentiment_average: result.sentiment_average
            sadness_average: result.sadness_average
            joy_average: result.joy_average
            disgust_average: result.disgust_average
            fear_average: result.fear_average
            anger_average: result.anger_average
            key:'emotion_average'
        #
    self.ready()
