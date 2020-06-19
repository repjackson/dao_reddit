Meteor.methods
    # stringify_tags: ->
    #     docs = Docs.find({
    #         tags: $exists: true
    #         tags_string: $exists: false
    #     },{limit:1000})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         # console.log 'about to stringify', doc
    #         tags_string = doc.tags.toString()
    #         # console.log 'tags_string', tags_string
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #         # console.log 'result doc', Docs.findOne doc._id
    #



    log_doc_terms: (doc_id)->
        doc = Docs.findOne doc_id
        if doc.tags
            for tag in doc.tags
                Meteor.call 'log_term', tag, ->


    log_term: (term_title)->
        # console.log 'logging term', term
        found_term =
            Terms.findOne
                title:term_title
        unless found_term
            Terms.insert
                title:term_title
            # if Meteor.user()
            #     Meteor.users.update({_id:Meteor.userId()},{$inc: karma: 1}, -> )
            # console.log 'added term', term
        else
            Terms.update({_id:found_term._id},{$inc: count: 1}, -> )
            # console.log 'found term', term
            Meteor.call 'call_wiki', @term_title, =>
                Meteor.call 'calc_term', @term_title, ->

    calc_term: (term_title)->
        term =
            Terms.findOne
                title:term_title
        found_wiki_doc =
            Docs.findOne
                model:$in:['wikipedia']
                # model:$in:['wikipedia','reddit']
                title:term_title
        if found_wiki_doc
            if found_wiki_doc.watson.metadata.image
                Terms.update term._id,
                    $set:image:found_wiki_doc.watson.metadata.image


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

    # agg_omega: (query, key, collection)->
    agg_omega: ->
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        #     console.log res
        #     console.log 'res from async agg'
        agg_res = Meteor.call 'agg_omega2'
        # console.log 'hi'
        # console.log 'agg res', agg_res
        omega = Docs.findOne model:'omega_session'
        doc_count = omega.total_doc_result_count
        # doc_count = omega.doc_result_ids.length
        unless omega.selected_doc_id in omega.doc_result_ids
            Docs.update omega._id,
                $set:selected_doc_id:omega.doc_result_ids[0]
        # console.log 'doc count', doc_count
        filtered_agg_res = []
        for agg_tag in agg_res
            if agg_tag.count < doc_count
                filtered_agg_res.push agg_tag

        Docs.update omega._id,
            $set:
                # agg:agg_res
                filtered_agg_res:filtered_agg_res
    agg_omega2: ()->
        omega =
            Docs.findOne
                model:'omega_session'

        # console.log 'running agg omega', omega
        match = {}
        if omega.selected_tags.length > 0
            match.tags =
                $all: omega.selected_tags
        else
            match.tags =
                $all: ['dao']

        doc_match = match
        # console.log 'running agg omega', omega
        doc_match.model = $in:['reddit','wikipedia']
        # console.log 'doc_count', Docs.find(doc_match).count()
        total_doc_result_count =
            Docs.find( doc_match,
                {
                    fields:
                        _id:1
                }
            ).count()
        # console.log total_doc_result_count
        doc_results =
            Docs.find( doc_match,
                {
                    limit:20
                    sort:
                        points:-1
                        ups:-1
                    fields:
                        _id:1
                }
            ).fetch()
        # console.log doc_results
        if doc_results[0]
            unless doc_results[0].rd
                if doc_results[0].reddit_id
                    Meteor.call 'get_reddit_post', doc_results[0]._id, doc_results[0].reddit_id, =>
        # console.log doc_results
        doc_result_ids = []
        for result in doc_results
            doc_result_ids.push result._id
        # console.log _.keys(doc_results,'_id')
        Docs.update omega._id,
            $set:
                doc_result_ids:doc_result_ids
                total_doc_result_count:total_doc_result_count
        # if doc_re
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
        options = {
            explain:false
            allowDiskUse:true
        }

        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        limit = 33
        # console.log 'omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $group: _id: "$max_emotion_name", count: $sum: 1 }
            { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
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




    # get_top_emotion: ->
    #     # console.log 'getting emotion'
    #     emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
    #     #
    #     current_most_emotion = ''
    #     current_max_emotion_count = 0
    #     current_max_emotion_percent = 0
    #     omega = Docs.findOne model:'omega_session'
    #     # doc_results =
    #         # Docs.find
    #
    #     doc_match = {_id:$in:omega.doc_result_ids}
    #     for doc_id in omega.doc_result_ids
    #         doc = Docs.findOne(doc_id)
    #         if doc.max_emotion_percent
    #             if doc.max_emotion_percent > current_max_emotion_percent
    #                 current_max_emotion_percent = doc.max_emotion_percent
    #                 if doc.max_emotion_name is 'anger'
    #                     emotion_color = 'green'
    #                 else if doc.max_emotion_name is 'disgust'
    #                     emotion_color = 'teal'
    #                 else if doc.max_emotion_name is 'sadness'
    #                     emotion_color = 'orange'
    #                 else if doc.max_emotion_name is 'fear'
    #                     emotion_color = 'grey'
    #                 else if doc.max_emotion_name is 'joy'
    #                     emotion_color = 'red'
    #
    #                 Docs.update omega._id,
    #                     $set:
    #                         current_most_emotion:doc.max_emotion_name
    #                         current_max_emotion_percent: current_max_emotion_percent
    #                         emotion_color:emotion_color
    #     # for emotion in emotion_list
    #     #     emotion_match = doc_match
    #     #     emotion_match.max_emotion_name = emotion
    #     #     found_emotions =
    #     #         Docs.find(emotion_match)
    #     #
    #     #     # Docs.update omega._id,
    #     #     #     $set:
    #     #     #         "current_#{emotion}_count":found_emotions.count()
    #     #     if omega.current_most_emotion < found_emotions.count()
    #     #         current_most_emotion = emotion
    #     #         current_max_emotion_count = found_emotions.count()
    #     # # console.log 'current_most_emotion ', current_most_emotion
    #     emotion_match = doc_match
    #     emotion_match.max_emotion_name = $exists:true
    #     # main_emotion = Docs.findOne(emotion_match)
    #
    #     # for doc_id in omega.doc_result_ids
    #     #     doc = Docs.findOne(doc_id)
    #     # if main_emotion
    #     #     console.log main_emotion
    #     #     Docs.update omega._id,
    #     #         $set:
    #     #             emotion_color:emotion_color
    #     #             max_emotion_name:main_emotion.max_emotion_name
