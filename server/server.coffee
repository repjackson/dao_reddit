Docs.allow
    insert: (user_id, doc) -> true
    update: (user_id, doc) -> true
    # user_id is doc._author_id
    remove: (user_id, doc) -> false
        # user = Meteor.users.findOne user_id
        # if user.roles and 'admin' in user.roles
        #     true
        # else
        #     user_id is doc._author_id
# Facts.setUserIdFilter(()->true);

Meteor.publish 'doc', (doc_id)->
    Docs.find
        _id:doc_id

# Meteor.publish 'term', (title)->
#     Terms.find
#         title:title

# Meteor.publish 'terms', (picked_tags, searching, query)->
#     # console.log 'selected tags looking for terms', picked_tags
#     # console.log 'looking for tags', Tags.find().fetch()
#     Terms.find
#         image:$exists:true
#         title:$in:picked_tags



Meteor.publish 'tag_results', (
    picked_tags
    # selected_domains
    # selected_authors
    # selected_emotions
    query
    searching
    dummy
    # date_setting=0
    )->
    # console.log 'dummy', dummy
    # console.log 'selected tags', picked_tags
    # console.log 'query', query
    # console.log 'searching?', searching

    self = @
    match = {}

    # match.model = $in: ['reddit','wikipedia']
    match.model = 'reddit'
    # console.log 'query length', query.length
    # if query


    match.tags = $all: picked_tags
    # if picked_tags.length > 0
    # else
    #     # unless selected_domains.length > 0
    #     #     unless selected_emotions.length > 0
    #     match.tags = $all: ['love']
    # console.log 'match for tags', match
    # if selected_subreddits.length > 0
    #     match.subreddit = $all: selected_subreddits
    # if selected_domains.length > 0
    #     match.domain = $in: selected_domains
    # if selected_emotions.length > 0
    #     match.max_emotion_name = $in: selected_emotions
    # console.log 'match for tags', match


    agg_doc_count = Docs.find(match).count()
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $match: count: $lt: agg_doc_count }
        # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
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
    # console.log doc_tag_cloud.count()
    self.ready()


Meteor.publish 'doc_results', (
    picked_tags
    # current_query
    # date_setting
    )->
    # console.log 'got selected tags', picked_tags
    # else
    self = @
    # console.log 'searching query', current_query
    # match = {model:$in:['reddit','wikipedia']}
    match = {model:'reddit'}
    # if current_query.length > 1
    #     match.title = {$regex:"#{current_query}", $options: 'i'}
    # if picked_tags.length > 0
    # console.log date_setting
    # if date_setting
    #     if date_setting is 'today'
    #         now = Date.now()
    #         day = 24*60*60*1000
    #         yesterday = now-day
    #         # console.log yesterday
    #         match._timestamp = $gt:yesterday

    # if picked_tags.length > 0
    #     # if picked_tags.length is 1
    #     #     console.log 'looking single doc', picked_tags[0]
    #     #     found_doc = Docs.findOne(title:picked_tags[0])
    #     #
    #     #     match.title = picked_tags[0]
    #     # else
    match.tags = $all: picked_tags
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:
            ups:-1
            # points:-1
        limit:20


Meteor.methods
    search_reddit: (query)->
        # console.log 'searching reddit for', query
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&include_over_18=on&limit=20&include_facets=true",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&include_over_18=on&limit=100&include_facets=true",(err,response)=>
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
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        # added_tags = _.flatten(added_tags)
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
                            tags: query
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

                                # console.log 'existing doc', existing_doc.title
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
        # console.log 'getting reddit post', doc_id, reddit_id
        HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
            if err then console.error err
            else
                rd = res.data.data.children[0].data
                # console.log rd
                result =
                    Docs.update doc_id,
                        $set:
                            rd: rd
                # console.log result
                # if rd.is_video
                #     # console.log 'pulling video comments watson'
                #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                # else if rd.is_image
                #     # console.log 'pulling image comments watson'
                #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                # else
                #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                #     # Meteor.call 'call_visual', doc_id, ->
                if rd.selftext
                    unless rd.is_video
                        # if Meteor.isDevelopment
                        #     console.log "self text", rd.selftext
                        Docs.update doc_id, {
                            $set:
                                body: rd.selftext
                        }, ->
                        #     Meteor.call 'pull_site', doc_id, url
                            # console.log 'hi'
                if rd.selftext_html
                    unless rd.is_video
                        Docs.update doc_id, {
                            $set:
                                html: rd.selftext_html
                        }, ->
                            # Meteor.call 'pull_site', doc_id, url
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
                            # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                # update_ob = {}

                Docs.update doc_id,
                    $set:
                        rd: rd
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
