Meteor.methods
    stringify_tags: ->
        docs = Docs.find({
            tags: $exists: true
            tags_string: $exists: false
        },{limit:1000})
        for doc in docs.fetch()
            # doc = Docs.findOne id
            # console.log 'about to stringify', doc
            tags_string = doc.tags.toString()
            # console.log 'tags_string', tags_string
            Docs.update doc._id,
                $set: tags_string:tags_string
            # console.log 'result doc', Docs.findOne doc._id
#

    call_wiki: (query)->
        # console.log 'calling wiki', query
        term = query.split(' ').join('_')
        HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
            # console.log response.data
            if err
                console.log 'error finding wiki article for ', query
                # console.log err
            else

                # console.log response
                # console.log 'response'

                found_doc =
                    Docs.findOne
                        url: "https://en.wikipedia.org/wiki/#{term}"
                if found_doc
                    # console.log 'found wiki doc for term', term, found_doc
                    # Docs.update found_doc._id,
                    #     $addToSet:
                    #         tags:'wikipedia'
                    # console.log 'found wiki doc', found_doc
                    Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                else
                    new_wiki_id = Docs.insert
                        title: query
                        tags:[query]
                        source: 'wikipedia'
                        model:'wikipedia'
                        # ups: 1000000
                        url:"https://en.wikipedia.org/wiki/#{term}"
                    Meteor.call 'call_watson', new_wiki_id, 'url','url', ->


    calc_doc_count: ->
        if Meteor.user()
            doc_count = Docs.find(author_id:Meteor.userId()).count()
            term_count = Terms.find(author_id:Meteor.userId()).count()
            # console.log 'doc_count', doc_count
            # console.log 'term_count', term_count
            Meteor.users.update Meteor.userId(),
                $set:
                    doc_count: doc_count
                    term_count:term_count

    log_doc_terms: (doc_id)->
        doc = Docs.findOne doc_id
        if doc.tags
            for tag in doc.tags
                Meteor.call 'log_term', tag, ->


    log_term: (term)->
        # console.log 'logging term', term
        found_term =
            Terms.findOne
                title:term
        unless found_term
            Terms.insert
                title:term
            # if Meteor.user()
            #     Meteor.users.update({_id:Meteor.userId()},{$inc: karma: 1}, -> )
            # console.log 'added term', term
        else
            Terms.update({_id:found_term._id},{$inc: count: 1}, -> )
            console.log 'found term', term


    lookup: =>
        selection = @words[4000..4500]
        for word in selection
            # console.log 'searching ', word
            # Meteor.setTimeout ->
            Meteor.call 'search_reddit', ([word])
            # , 5000

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
        # console.log 'tag', tag
        results =
            Docs.find {
                tags: $in: [tag]
            }
        # console.log 'pulling tags', results.count()
        # Docs.remove(
        #     tags: $in: [tag]
        # )
        for doc in results.fetch()
            res = Docs.update doc._id,
                $pull: tags: tag
            console.log res

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
        doc_count = omega.doc_results.length

        console.log 'doc count', doc_count
        filtered_agg_res = []
        for agg_tag in agg_res
            if agg_tag.count > doc_count
                filtered_agg_res.push agg_tag

        Docs.update omega._id,
            $set:
                agg:agg_res
                filtered_agg_res:filtered_agg_res
    agg_omega2: ()->
        omega =
            Docs.findOne
                model:'omega_session'

        # console.log 'running agg omega', omega
        match = {}
        match.tags =
            $all: omega.selected_tags

        doc_match = match
        doc_match.model = $in:['reddit']
        doc_results =
            Docs.find( doc_match,
                {
                    limit:1
                    sort:
                        points:-1
                        ups:-1
                    fields:
                        _id:1
                }
            ).fetch()
        # console.log doc_results
        doc_result_ids = []
        for result in doc_results
            doc_result_ids.push result._id
        # console.log _.keys(doc_results,'_id')
        Docs.update omega._id,
            $set:
                doc_result_ids:doc_result_ids

        found_wiki_doc =
            Docs.findOne
                model:'wikipedia'
                title:$in:omega.selected_tags
        if found_wiki_doc
            Docs.update omega._id,
                $addToSet:
                    doc_result_ids:found_wiki_doc._id

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
            { $limit: 42 }
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
                        added_tags = [query]
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
                if rd.is_video
                    # console.log 'pulling video comments watson'
                    Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                else if rd.is_image
                    # console.log 'pulling image comments watson'
                    Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                else
                    Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                    Meteor.call 'call_watson', doc_id, 'url', 'image', ->

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
                            Meteor.call 'call_watson', doc_id, 'url', 'url', ->
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
