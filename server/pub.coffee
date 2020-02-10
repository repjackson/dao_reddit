
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
    # current_query
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
    # if current_query and current_query.length > 3
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
    console.log 'looking up facets with match', match
    filters = []
    result_array = []

    # console.log key, 'facet match:', match
    result_cloud = Docs.aggregate [
        { $match: match }
        { $project: "#{key}": 1 }
        { $unwind: "$#{key}" }
        { $group: _id: "$#{key}", count: $sum: 1 }
        { $match: _id: $nin: filters }
        { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    result_cloud.forEach (result, i) =>
        # console.log 'result ', result
        # console.log 'key', key
        self.added 'results', Random.id(),
            title: result.name
            count: result.count
            category:key
            # index: i

    self.ready()


    # self.onStop ()-> subHandle.stop()



Meteor.publish 'emotion_averages', (prematch)->
    match = {}
    self = @
    console.log 'prematch', prematch
    keys = _.keys(prematch)
    console.log 'facet keys', keys
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

    entities = [
        'Person'
        'Sport'
        'Company'
        'Organization'
        'Facility'
        'PrintMedia'
        'Location'
        'HealthCondition'
        'Broadcaster'
        'SportingEvent'
        'Facility'
        'Hashtag'
        'GeographicFeature'
        'SportingEvent'
    ]

    queried_entities = _.intersection(entities,keys)
    console.log 'queried_entities', queried_entities

    agg_match = match
    index = 0
    for key in queried_entities
        ideas = prematch["#{key}"]
        for idea in ideas
        # idea = prematch["#{key}"][index]
            console.log 'idea',idea
            if idea
                idea_averages = Docs.aggregate [
                    { $match: agg_match }
                    # { $limit: 100 }
                    { $project: "watson.entities": 1 }
                    { $unwind: "$watson.entities" }
                    { $match:
                        "watson.entities.type": "#{key}"
                        "watson.entities.text": "#{idea}"
                    }
                    { $group:
                        _id: idea
                        sentiment_average: $avg: "$watson.entities.sentiment.score"
                        sadness_average: $avg: "$watson.entities.emotion.sadness"
                        joy_average: $avg: "$watson.entities.emotion.joy"
                        disgust_average: $avg: "$watson.entities.emotion.disgust"
                        fear_average: $avg: "$watson.entities.emotion.fear"
                        anger_average: $avg: "$watson.entities.emotion.anger"
                    }
                ]

                idea_averages.forEach((result) =>
                    console.log 'result ', result
                    console.log 'key', key
                    self.added 'results', Random.id(),
                        key:key
                        name:result._id
                        model:'idea'
                        sentiment_average:result.sentiment_average
                        sadness_average:result.sadness_average
                        joy_average:result.joy_average
                        disgust_average:result.disgust_average
                        fear_average:result.fear_average
                        anger_average:result.anger_average
                    )
                # console.log 'index', index
                # index++



    self.ready()
