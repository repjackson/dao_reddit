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
