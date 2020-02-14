Docs.allow
    insert: (userId, doc) -> false
    update: (userId, doc) -> false
    remove: (userId, doc) -> false

Meteor.methods
    stringify_tags: ->
        docs = Docs.find({
            tags: $exists: true
            tags_string: $exists: false
        },{limit:1000})
        for doc in docs.fetch()
            # doc = Docs.findOne id
            console.log 'about to stringify', doc
            tags_string = doc.tags.toString()
            console.log 'tags_string', tags_string
            Docs.update doc._id,
                $set: tags_string:tags_string
            # console.log 'result doc', Docs.findOne doc._id


    lower_tags: ->
        docs = Docs.find({
            tags: $exists: true
            lowered: $exists: false
        },{limit:1})
        for doc in docs.fetch()
            # doc = Docs.findOne id
            console.log 'about to lower', doc
            lowered_tags = []
            # tags_string = doc.tags.toString()
            for tag in doc.tags
                lowered_tag = tag.toLowerCase()
                lowered_tags.push lowered_tag

            console.log 'lowered_tags', lowered_tags
            # Docs.update doc._id,
            #     $set: tags_string:tags_string
            # console.log 'result doc', Docs.findOne doc._id


    flatten: ->
        docs = Docs.find({
            tags: $exists: true
            flattened: $ne: true
        },{limit:1000})
        for doc in docs.fetch()
            # doc = Docs.findOne id
            # console.log 'about to flatten', doc

            flattened_tags = _.flatten(doc.tags)

            # console.log 'flattened_tags', flattened_tags
            Docs.update doc._id,
                $set:
                    tags:flattened_tags
                    flattened:true
            console.log 'flattened', doc._id
            # console.log 'result doc', Docs.findOne doc._id


    rename_key:(old_key,new_key,parent)->
        Docs.update parent._id,
            $pull:_keys:old_key
        Docs.update parent._id,
            $addToSet:_keys:new_key
        Docs.update parent._id,
            $rename:
                "#{old_key}": new_key
                "_#{old_key}": "_#{new_key}"

    remove_tag: (tag)->
        console.log 'tag', tag
        results =
            Docs.find {
                tags: $in: [tag]
            }
        console.log 'pulling tags', results.count()
        # Docs.remove(
        #     tags: $in: [tag]
        # )
        for doc in results.fetch()
            res = Docs.update doc._id,
                $pull: tags: tag
            console.log res
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

    # agg_idea: (idea, tag, type)->






    search_reddit: (query)->
        console.log 'searching reddit for', query
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
                    added_tags = query
                    # added_tags.push data.title
                    console.log 'added_tags', added_tags
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
                        tags:added_tags
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
                    else if data.domain in ['twitter.com']
                        reddit_post.is_twitter = true
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
        # console.log 'getting reddit post'
        HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
            if err then console.error err
            else
                console.log rd
                rd = res.data.data.children[0].data
                if rd.is_video
                    console.log 'pulling image comments watson'
                    Meteor.call 'call_watson', doc_id, 'url', 'video'
                else if rd.is_image
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
        # if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.tags = $all: selected_tags

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
    if selected_tags.length > 0 then match.tags = $all: selected_tags
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
        sort:"#{sort_key}":sort_direction
        limit: doc_limit
