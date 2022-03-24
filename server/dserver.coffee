Docs.allow
    insert: (user_id, doc) -> false
    update: (user_id, doc) -> false
    # user_id is doc._author_id
    remove: (user_id, doc) -> false

Meteor.publish 'doc', (doc_id)->
    Docs.find
        _id:doc_id



Meteor.publish 'tag_results', (
    picked_tags=null
    # query
    # searching
    dummy
    )->

    self = @
    match = {}

    # match.model = $in: ['reddit','wikipedia']
    match.model = 'reddit'
    # if query

    if picked_tags and picked_tags.length > 0
        match.tags = $all: picked_tags
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
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
    
        tag_cloud.forEach (tag, i) =>
            self.added 'tags', Random.id(),
                title: tag.name
                count: tag.count
                # category:key
                # index: i
        self.ready()
    else []

Meteor.publish 'doc_results', (
    picked_tags=null
    # current_query
    # date_setting
    )->
    # else
    self = @
    # match = {model:$in:['reddit','wikipedia']}
    match = {model:'reddit'}
    #         yesterday = now-day
    #         match._timestamp = $gt:yesterday

    # if picked_tags.length > 0
    #     # if picked_tags.length is 1
    #     #     found_doc = Docs.findOne(title:picked_tags[0])
    #     #
    #     #     match.title = picked_tags[0]
    #     # else
    if picked_tags and picked_tags.length > 0
        match.tags = $all: picked_tags
        
        Docs.find match,
            sort:
                ups:-1
                # points:-1
            limit:5
            fields:
                # youtube_id:1
                # thumbnail:1
                url:1
                ups:1
                title:1
                model:1
                num_comments:1
                tags:1
                # _timestamp:1
                domain:1


Meteor.methods
    search_reddit: (query)->
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&include_over_18=on&limit=20&include_facets=true",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
            if response.data.data.dist > 1
                _.each(response.data.data.children, (item)=>
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        # added_tags = _.flatten(added_tags)
                        console.log 'data', data
                        reddit_post =
                            reddit_id: data.id
                            url: data.url
                            domain: data.domain
                            comment_count: data.num_comments
                            permalink: data.permalink
                            title: data.title
                            # root: query
                            ups:data.ups
                            num_comments:data.num_comments
                            # selftext: false
                            # thumbnail: false
                            tags: query
                            model:'reddit'
                        existing_doc = Docs.findOne url:data.url
                        if existing_doc
                            # if Meteor.isDevelopment
                            # if typeof(existing_doc.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing_doc._id,
                                $addToSet: tags: $each: query
                                $set:
                                    title:data.title
                                    ups:data.ups
                                    num_comments:data.num_comments
                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                        unless existing_doc
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                        return true
                )

        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        # )
