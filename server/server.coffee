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

Meteor.publish 'omega_doc', ->
    omega =
        Docs.findOne
            model:'omega_session'
    if omega
        Docs.find omega._id
    else
        Docs.insert
            model:'omega_session'

# Meteor.publish 'tags', (
#     selected_tags
#     query
#     dummy
#     )->
#     # console.log 'dummy', dummy
#     # console.log 'query', query
#     console.log 'selected tags', selected_tags
#
#
#     omega =
#         Docs.findOne
#             model:'omega_session'
#
#     self = @
#     match = {}
#     match.model = $in: ['reddit','wikipedia']
#     # console.log 'query length', query.length
#     # if omega.query and omega.query.length > 0
#     if omega.query and omega.query.length > 0
#     #     console.log 'searching query', query
#     #     # match.tags = {$regex:"#{query}", $options: 'i'}
#     #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
#     #
#         Terms.find {
#             title: {$regex:"#{omega.query}", $options: 'i'}
#         },
#             sort:
#                 count: -1
#             limit: 10
#         # tag_cloud = Docs.aggregate [
#         #     { $match: match }
#         #     { $project: "tags": 1 }
#         #     { $unwind: "$tags" }
#         #     { $group: _id: "$tags", count: $sum: 1 }
#         #     { $match: _id: $nin: selected_tags }
#         #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
#         #     { $sort: count: -1, _id: 1 }
#         #     { $limit: 42 }
#         #     { $project: _id: 0, name: '$_id', count: 1 }
#         #     ]
#
#     else
#         # unless query and query.length > 2
#         # if selected_tags.length > 0 then match.tags = $all: selected_tags
#         match.tags = $all: omega.selected_tags
#         # console.log 'match for tags', match
#         tag_cloud = Docs.aggregate [
#             { $match: match }
#             { $project: "tags": 1 }
#             { $unwind: "$tags" }
#             { $group: _id: "$tags", count: $sum: 1 }
#             { $match: _id: $nin: selected_tags }
#             # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
#             { $sort: count: -1, _id: 1 }
#             { $limit: 20 }
#             { $project: _id: 0, name: '$_id', count: 1 }
#         ], {
#             allowDiskUse: true
#         }
#
#         tag_cloud.forEach (tag, i) =>
#             # console.log 'queried tag ', tag
#             # console.log 'key', key
#             self.added 'tags', Random.id(),
#                 title: tag.name
#                 count: tag.count
#                 # category:key
#                 # index: i
#             # Docs.update omega._id,
#             #     $addToSet:
#             #         tags:
#             #             title:tag.name
#             #             count:tag.count
#         # console.log doc_tag_cloud.count()
#
#         self.ready()

# Meteor.publish 'docs', (
#     selected_tags
#     )->
#     # console.log selected_tags
#     self = @
#     match = {model:'reddit'}
#     # if selected_tags.length > 0
#     match.tags = $all: selected_tags
#     # else
#     #     match.tags = $nin: ['wikipedia']
#     #     sort = '_timestamp'
#     #     # match. = $ne:'wikipedia'
#     console.log 'reddit match', match
#     # console.log 'sort key', sort_key
#     # console.log 'sort direction', sort_direction
#     omega =
#         Docs.findOne
#             model:'omega_session'
#     Docs.find match,
#         sort:"ups":-1
#         # sort:_timestamp:-1
#         limit:5

Meteor.methods
    # agg_omega: (query, key, collection)->
    agg_omega: ->
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        #     console.log res
        #     console.log 'res from async agg'
        agg_res = Meteor.call 'agg_omega2'
        # console.log 'hi'
        # console.log 'agg res', agg_res
        omega = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $set:agg:agg_res
    agg_omega2: ()->
        omega =
            Docs.findOne
                model:'omega_session'

        # console.log 'running agg omega', omega
        match = {}
        match.tags =
            $all: omega.selected_tags

        doc_match = match
        doc_match.model = 'reddit'
        doc_results =
            Docs.find( doc_match,
                {
                    limit:7
                    sort:ups:-1
                }
            ).fetch()
        # console.log doc_results
        Docs.update omega._id,
            $set:doc_results:doc_results
        # Docs.update omega._id,
        #     $set:
        #         match:match
        # limit=20
        options = { explain:false }
        # console.log 'omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 40 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]
        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
                # printed = console.log(agg.toArray())
                # # console.log(agg.toArray())
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null



    search_reddit: (query)->
        # console.log 'searching reddit for', query
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=0",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=0&limit=50",(err,response)=>
            # console.log response.data
            if err then console.log err
            else if response.data.data.dist > 1
                # console.log 'found data'
                # console.log 'data length', response.data.data.children.length
                _.each(response.data.data.children, (item)=>
                    # console.log item.data
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        added_tags = query
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
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
                            tags: added_tags
                            model:'reddit'
                        existing_doc = Docs.findOne url:data.url
                        if existing_doc
                            # if Meteor.isDevelopment
                                # console.log 'skipping existing url', data.url
                                # console.log 'adding', query, 'to tags'
                            # console.log 'type of tags', typeof(existing_doc.tags)
                            # if typeof(existing_doc.tags) is 'string'
                            #     # console.log 'unsetting tags because string', existing_doc.tags
                            #     Doc.update
                            #         $unset: tags: 1
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
                    else
                        console.log 'NO found data'
                )

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
                # console.log rd
                if rd.is_video
                    # console.log 'pulling video comments watson'
                    Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                else if rd.is_image
                    # console.log 'pulling image comments watson'
                    Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                else
                    Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                    Meteor.call 'call_watson', doc_id, 'url', 'image', ->

                # if rd.selftext
                #     unless rd.is_video
                #         # if Meteor.isDevelopment
                #         #     console.log "self text", rd.selftext
                #         Docs.update doc_id, {
                #             $set: body: rd.selftext
                #         }, ->
                #         #     Meteor.call 'pull_site', doc_id, url
                #             # console.log 'hi'
                # if rd.selftext_html
                #     unless rd.is_video
                #         Docs.update doc_id, {
                #             $set: html: rd.selftext_html
                #         }, ->
                #             # Meteor.call 'pull_site', doc_id, url
                #             console.log 'hi'
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
                # update_ob = {}

                Docs.update doc_id,
                    $set:
                        # rd: rd
                        url: rd.url
                        thumbnail: rd.thumbnail
                        subreddit: rd.subreddit
                        author: rd.author
                        is_video: rd.is_video
                        ups: rd.ups
                        # downs: rd.downs
                        over_18: rd.over_18
                    # $addToSet:
                    #     tags: $each: [rd.subreddit.toLowerCase()]
                # console.log Docs.findOne(doc_id)
