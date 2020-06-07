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

    call_wiki: (query)->
        console.log 'calling wiki', query
        term = query.split(' ').join('_')
        HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
            # console.log response.data
            if err
                console.log 'error'
                console.log err
            else

                console.log response
                console.log 'response'

                found_doc =
                    Docs.findOne
                        url: "https://en.wikipedia.org/wiki/#{term}"
                if found_doc
                    # console.log 'found wiki doc for term', term, found_doc
                    # Docs.update found_doc._id,
                    #     $addToSet:
                    #         tags:'wikipedia'
                    console.log 'found wiki doc', found_doc
                    Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                else
                    new_wiki_id = Docs.insert
                        title: query
                        tags:['wikipedia', query]
                        source: 'wikipedia'
                        model:'wikipedia'
                        # ups: 1000000
                        url:"https://en.wikipedia.org/wiki/#{term}"
                    Meteor.call 'call_watson', new_wiki_id, 'url','url', ->


    calc_doc_count: ->
        if Meteor.user()
            doc_count = Docs.find(author_id:Meteor.userId()).count()
            term_count = Terms.find(author_id:Meteor.userId()).count()
            console.log 'doc_count', doc_count
            console.log 'term_count', term_count
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
            console.log 'searching ', word
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



    calc_post: (doc_id)->
        doc = Docs.findOne doc_id
        # console.log 'got post', doc

        HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json", (err,res)->
            if err then console.error err
            else
                rd = res.data.data.children[0].data
                # console.log rd.url
                # if rd.is_video
                #     console.log 'pulling image comments watson'
                #     Meteor.call 'call_watson', doc_id, 'url', 'video'
                # else if rd.is_image
                #     console.log 'pulling image comments watson'
                #     Meteor.call 'call_watson', doc_id, 'url', 'image'

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
                # update_ob = {}

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
                    # $addToSet:
                        # tags: $each: [rd.subreddit]
                # console.log Docs.findOne(doc_id)
