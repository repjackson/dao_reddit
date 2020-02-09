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



Meteor.methods
    extract_ideas: ->
        doc = Docs.findOne
            # ideas_extracted: $ne: true
            categories:$exists:true
            # "watson.entities":$exists:true
        console.log doc
        for category in doc.categories
            console.log 'looking up category'
            existing_idea =
                Ideas.findOne
                    model:'category'
                    title:category
            if existing_idea
                console.log 'found existing idea'
            else
                Ideas.insert
                    model:'category'
                    title:category



    agg_idea: (idea_id)->
        # console.log idea

        # match = {name:idea}
        # if key
        #     match.key = key
        # match.type = type
        # found_idea =
        #     Ideas.findOne match
        # if found_idea
        #     # console.log found_idea
        #     idea_id = found_idea._id
        # else
        #     idea_id = Ideas.insert match
        #
        # agg_match = {"watson.entities":$exists:true}
        idea = Ideas.findOne idea_id
        console.log 'idea', idea
        # agg_match = {"watson.entities":$exists:true}
        #
        #
        if idea.type is 'subreddit'
            downloaded_reddit_posts =
                Docs.find({
                    subreddit:idea.name
                }).count()
            console.log 'post count', downloaded_reddit_posts
            Ideas.update idea_id,
                $set: downloaded_reddit_posts:downloaded_reddit_posts
        if idea.type is 'entity'
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
                    _id: null
                    sentiment_average: $avg: "$watson.entities.sentiment.score"
                    sadness_average: $avg: "$watson.entities.emotion.sadness"
                    joy_average: $avg: "$watson.entities.emotion.joy"
                    disgust_average: $avg: "$watson.entities.emotion.disgust"
                    fear_average: $avg: "$watson.entities.emotion.fear"
                    anger_average: $avg: "$watson.entities.emotion.anger"
                }
            ]
            idea_averages.forEach(Meteor.bindEnvironment((result) =>
                console.log 'result ', result
                console.log 'key', key
                Ideas.update idea_id,
                    $set:
                        sentiment_average:result.sentiment_average
                        sadness_average:result.sadness_average
                        joy_average:result.joy_average
                        disgust_average:result.disgust_average
                        fear_average:result.fear_average
                        anger_average:result.anger_average
                ))
            # self.added 'results', Random.id(),
            #     name: result.name
            #     count: result.count
            #     key:key
            #     # index: i

        # db.col.aggregate([
        #   {"$match":{
        #   "history":{
        #     "$elemMatch":{
        #       "startDate":{"$gte":ISODate("2018-01-15T11:13:14.000Z")},
        #       "endDate":{"$lte":ISODate("2018-02-12T11:13:14.000Z")}
        #      }
        #    }
        #  }},
        #  {"$unwind":"$history"},
        #  {"$match":{
        #    "history.startDate":{"$gte":ISODate("2018-01-15T11:13:14.000Z")},
        #    "history.endDate":{"$lte":ISODate("2018-02-12T11:13:14.000Z")}
        #  }},
        #  {"$match":{
        #    "$or":[
        #      {"history.APTCChange":{"$gt":10}},
        #      {"history.PremChange":{"$gt":10}},
        #      {"history.MbrRespChg":{"$gt":10}}
        #     ]
        #  }}
        # ])


        # # if type is 'entity'
        # doc_mention_ids =
        #     Docs.find({
        #         "#{key}": $in: [idea]
        #         # "watson.entities": $exists:true
        #     }, {
        #         fields: _id:1
        #         # limit:5
        #     }).fetch()
        # analyzed_ids =
        #     Docs.find({
        #         "#{key}": $in: [idea]
        #         "watson.entities": $exists:true
        #     }, {
        #         fields: _id:1
        #         # limit:5
        #     }).fetch()
        # unanalyzed_ids =
        # console.log 'doc mention ids', doc_mention_ids
        # console.log 'analyzed ids', analyzed_ids
        # console.log 'doc mention id length', doc_mention_ids.length
        # console.log 'analyzed ids length', analyzed_ids.length
        #
        # doc_mentions =
        #     Docs.find({
        #         "#{key}": $in: [idea]
        #         "watson.entities": $exists:true
        #     }, {
        #         fields: _id:1
        #         # limit:5
        #     }).count()
        #
        # # console.log 'doc mentions count', doc_mentions.count(), 'for', key, idea
        # #
        # total_sentiment_score = 0
        # emotion_doc_count = 0
        #
        # analyzed_doc_ids = []
        #
        # for doc in doc_mention_ids
        #     doc = Docs.findOne({_id:doc._id},{fields:"watson.entities":1})
        #     console.log doc
        #     # console.log _.findWhere(doc.watson.entities, {text:idea})
        #     if doc.watson
        #         if doc.watson.entities
        #             entity_object = _.findWhere(doc.watson.entities, {text:idea})
        #             # console.log entity_object
        #             if entity_object
        #                 if entity_object.sentiment
        #                     if entity_object.sentiment.score
        #                         console.log entity_object.sentiment.score
        #                         total_sentiment_score += entity_object.sentiment.score
        #                         emotion_doc_count++
        #                         analyzed_doc_ids.push doc._id
        # #
        # console.log 'total sentiment score', total_sentiment_score
        # console.log 'mentioned count', doc_mention_ids.length
        # console.log 'emotional count', emotion_doc_count
        # no_emotion_ids = _.without(doc_mention_ids,analyzed_doc_ids)
        # console.log 'mention_emotion_difference', no_emotion_ids
        # for id in no_emotion_ids
        #     Meteor.call 'analyze_entities', id
        # average_sentiment_score = total_sentiment_score/emotion_doc_count
        # Ideas.update idea_id,
        #     $set:
        #         doc_mention_count: doc_mention_ids.length
        #         doc_mention_ids:doc_mention_ids
        #         analyzed_doc_count: emotion_doc_count
        #         average_sentiment_score: average_sentiment_score
        #         analyzed_doc_ids: analyzed_doc_ids
