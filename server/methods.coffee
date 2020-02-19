Meteor.methods
#     stringify_tags: ->
#         docs = Docs.find({
#             tags: $exists: true
#             tags_string: $exists: false
#         },{limit:1000})
#         for doc in docs.fetch()
#             # doc = Docs.findOne id
#             console.log 'about to stringify', doc
#             tags_string = doc.tags.toString()
#             console.log 'tags_string', tags_string
#             Docs.update doc._id,
#                 $set: tags_string:tags_string
#             # console.log 'result doc', Docs.findOne doc._id
# #

    flatten: (doc_id)->
        if doc_id
            doc = Docs.findOne doc_id
            flattened_tags = _.flatten(doc.tags)

            # console.log 'flattened_tags', flattened_tags
            Docs.update doc._id,
                $set:
                    tags:flattened_tags
                    flattened:true
            console.log 'flattened', doc._id
        else
            docs = Docs.find({
                tags: $exists: true
                flattened: $ne: true
            },{limit:1000})
            for doc in docs.fetch()
                # doc = Docs.findOne id
                console.log 'about to flatten', doc

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


    search_reddit: (query)->
        console.log 'searching reddit for', query
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0",(err,response)=>
            # console.log response.data
            if err then console.log err
            else if response.data.data.dist > 1
                console.log 'found data'
                _.each(response.data.data.children, (item)=>
                    # console.log item
                    data = item.data
                    len = 200
                    added_tags = query
                    # added_tags.push data.domain.toLowerCase()
                    # console.log 'added_tags', added_tags
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
                    #     # if Meteor.isDevelopment
                    #     #     console.log 'skipping youtube and imgur'
                    else if data.domain in ['twitter.com']
                        reddit_post.is_twitter = true
                        # if Meteor.isDevelopment
                        #     console.log 'skipping youtube and imgur'
                    # else
                    # # console.log reddit_post
                    existing_doc = Docs.findOne url:data.url
                    if existing_doc
                        if Meteor.isDevelopment
                            # console.log 'skipping existing url', data.url
                            console.log 'adding', query, 'to tags'
                        Docs.update existing_doc._id,
                            $addToSet: tags: $each: query

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
                rd = res.data.data.children[0].data
                console.log rd.url
                # if rd.is_video
                #     console.log 'pulling image comments watson'
                #     Meteor.call 'call_watson', doc_id, 'url', 'video'
                # else if rd.is_image
                #     console.log 'pulling image comments watson'
                #     Meteor.call 'call_watson', doc_id, 'url', 'image'

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
                # if rd.url
                #     unless rd.is_video￼
                #         url = rd.url
                #         # if Meteor.isDevelopment
                #         #     console.log "found url", url
                #         Docs.update doc_id, {
                #             $set:
                #                 reddit_url: url
                #                 url: url
                #         }, ->
                #             Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                update_ob = {}

                Docs.update doc_id,
                    $set:
                        # rd: rd
                        thumbnail: rd.thumbnail
                        subreddit: rd.subreddit
                        author: rd.author
                        # is_video: rd.is_video
                        ups: rd.ups
                        # downs: rd.downs
                        # over_18: rd.over_18
                    # $addToSet:
                        # tags: $each: [rd.subreddit]
                # console.log Docs.findOne(doc_id)
