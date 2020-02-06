Docs.allow
    insert: (userId, doc) ->
        if doc.model in ['bug','delta']
            true
        else
            userId and doc._author_id is userId
    update: (userId, doc) ->
        if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
            true
        else
            doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> true
    # remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles

Meteor.methods
    rename_key:(old_key,new_key,parent)->
        Docs.update parent._id,
            $pull:_keys:old_key
        Docs.update parent._id,
            $addToSet:_keys:new_key
        Docs.update parent._id,
            $rename:
                "#{old_key}": new_key
                "_#{old_key}": "_#{new_key}"

Meteor.methods
    move_emotion: ->
        emotion_docs = Docs.find({
            sadness_percent:
                $exists:true
            main_emotions:
                $exists:false
            }, limit:500)
        console.log 'emotion docs', emotion_docs.count()
        emotions = ['joy', 'sadness', 'fear', 'disgust', 'anger']
        for emotion_doc in emotion_docs.fetch()
            console.log 'converting', emotion_doc._id
            # old_emotion = watson.emotion.document.emotion
            main_emotions = []
            for emotion in emotions
                if emotion_doc["#{emotion}_percent"] > .5
                    # console.log emotion_doc["#{emotion}_percent"]
                    main_emotions.push emotion

            Docs.update({_id:emotion_doc._id},
                $set:
                    main_emotions: main_emotions
            )
            console.log main_emotions
            # console.log Docs.findOne(emotion_doc._id)
            # updated_doc = Docs.findOne emotion_doc._id
            # console.log updated_doc
        console.log 'main_emotions count', Docs.find(main_emotions:$exists:true).count()

    agg_idea: (idea, key, type)->
        console.log idea
        match = {name:idea}
        if key
            match.key = key
        match.type = type
        found_idea =
            Ideas.findOne match
        if found_idea
            # console.log found_idea
            idea_id = found_idea._id
        else
            idea_id = Ideas.insert match

        agg_match = {"watson.entities":$exists:true}


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
        idea_averages.forEach (result, i) =>
            console.log 'result ', result
            console.log 'key', key
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










    search_reddit: (query)->
        console.log 'searching reddit', query
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)->
            # console.log response.data
            if err then console.log err
            else if response.data.data.dist > 1
                console.log 'found data'
                _.each(response.data.data.children, (item)=>
                    # console.log item
                    data = item.data
                    len = 200
                    reddit_post =
                        reddit_id: data.id
                        url: data.url
                        domain: data.domain
                        comment_count: data.num_comments
                        permalink: data.permalink
                        title: data.title
                        # root: query
                        selftext: false
                        # thumbnail: false
                        tags:[query, data.title.toLowerCase()]
                        # tags:[query, data.domain.toLowerCase(), data.author.toLowerCase(), data.title.toLowerCase()]
                        model:'reddit'
                    # console.log reddit_post
                    image_check = /(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)/
                    image_result = image_check.test data.url
                    if image_result
                        reddit_post.is_image = true
                    #     if Meteor.isDevelopment
                    #         console.log 'skipping image'
                    if data.domain in ['youtu.be','youtube.com']
                        reddit_post.is_video = true
                        reddit_post.is_youtube = true
                    else if data.domain in ['i.redd.it','i.imgur.com','imgur.com']
                        reddit_post.is_image = true
                        # if Meteor.isDevelopment
                        #     console.log 'skipping youtube and imgur'
                    # else
                    # # console.log reddit_post
                    existing_doc = Docs.findOne url:data.url
                    if existing_doc
                        if Meteor.isDevelopment
                            console.log 'skipping existing url', data.url
                            # console.log 'existing doc', existing_doc
                        # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                    unless existing_doc
                        # console.log 'importing url', data.url
                        new_reddit_post_id = Docs.insert reddit_post
                        # console.log 'calling watson on ', reddit_post.title
                        Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                            # console.log 'get post res', res
                )
            else
                console.log 'NO found data'

        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        #     console.log item.data
        # )


    get_reddit_post: (doc_id, reddit_id, root)->
        console.log 'getting reddit post'
        HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
            if err then console.error err
            else
                console.log rd
                rd = res.data.data.children[0].data
                if rd.is_video
                    console.log 'pulling image comments watson'
                    Meteor.call 'call_watson', doc_id, 'url', 'video'
                if rd.is_image
                    console.log 'pulling image comments watson'
                    Meteor.call 'call_watson', doc_id, 'url', 'image'

                if rd.selftext
                    unless rd.is_video
                        # if Meteor.isDevelopment
                        #     console.log "self text", rd.selftext
                        Docs.update doc_id, {
                            $set: body: rd.selftext
                        }, ->
                        #     Meteor.call 'pull_site', doc_id, url
                            # console.log 'hi'
                # if rd.selftext_html
                #     unless rd.is_video
                #         Docs.update doc_id, {
                #             $set: html: rd.selftext_html
                #         }, ->
                        #     Meteor.call 'pull_site', doc_id, url
                            # console.log 'hi'
                if rd.url
                    unless rd.is_video
                        url = rd.url
                        # if Meteor.isDevelopment
                        #     console.log "found url", url
                        Docs.update doc_id, {
                            $set:
                                reddit_url: url
                                url: url
                        }, ->
                            Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                update_ob = {}

                Docs.update doc_id,
                    $set:
                        # rd: rd
                        thumbnail: rd.thumbnail
                        subreddit: rd.subreddit
                        author: rd.author
                        is_video: rd.is_video
                        ups: rd.ups
                        downs: rd.downs
                        over_18: rd.over_18
                    $addToSet:
                        tags: $each: [rd.subreddit, rd.author]
                # console.log Docs.findOne(doc_id)
