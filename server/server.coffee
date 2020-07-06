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

Meteor.publish 'term', (title)->
    Terms.find
        title:title

Meteor.publish 'terms', (selected_tags, searching, query)->
    # console.log 'selected tags looking for terms', selected_tags
    # console.log 'looking for tags', Tags.find().fetch()
    Terms.find
        image:$exists:true
        title:$in:selected_tags



Meteor.publish 'tag_results', (
    selected_tags
    # selected_subreddits
    selected_domains
    # selected_authors
    selected_emotions
    query
    searching
    # dummy
    date_setting=0
    )->
    # console.log 'dummy', dummy
    # console.log 'selected tags', selected_tags
    # console.log 'query', query
    # console.log 'searching?', searching

    self = @
    match = {}

    match.model = $in: ['reddit','wikipedia']
    # console.log 'query length', query.length
    # if query
    # if query and query.length > 1
    if searching
        if query.length > 0
            # console.log 'searching query', query
            # #     # match.tags = {$regex:"#{query}", $options: 'i'}
            # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
            # #
            terms =
                Terms.find({
                    # title: {$regex:"#{query}"}
                    title: {$regex:"#{query}", $options: 'i'}
                    },
                        sort:
                            count: -1
                        limit: 20
                )
            # self.ready()

            # console.log terms.fetch()
            # terms
    else
        # unless query and query.length > 2
        # if selected_tags.length > 0 then match.tags = $all: selected_tags
        # console.log date_setting
        if date_setting
            if date_setting is 'today'
                now = Date.now()
                day = 24*60*60*1000
                yesterday = now-day
                console.log yesterday
                match._timestamp = $gt:yesterday


        if selected_tags.length > 0
            match.tags = $all: selected_tags
        else
            unless selected_domains.length > 0
                unless selected_emotions.length > 0
                    match.tags = $all: ['dao']
        # console.log 'match for tags', match
        # if selected_subreddits.length > 0
        #     match.subreddit = $all: selected_subreddits
        if selected_domains.length > 0
            match.domain = $in: selected_domains
        if selected_emotions.length > 0
            match.max_emotion_name = $in: selected_emotions
        # console.log 'match for tags', match


        agg_doc_count = Docs.find(match).count()
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $match: count: $lt: agg_doc_count }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
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



        # # agg_doc_count = Docs.find(match).count()
        # subreddit_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "subreddit": 1 }
        #     # { $unwind: "$subreddit" }
        #     { $group: _id: "$subreddit", count: $sum: 1 }
        #     { $match: _id: $nin: selected_subreddits }
        #     # { $match: count: $lt: agg_doc_count }
        #     # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ], {
        #     allowDiskUse: true
        # }
        #
        # subreddit_cloud.forEach (subreddit, i) =>
        #     # console.log 'queried subreddit ', subreddit
        #     # console.log 'key', key
        #     self.added 'subreddits', Random.id(),
        #         title: subreddit.name
        #         count: subreddit.count
        #         # category:key
        #         # index: i
        # # console.log doc_tag_cloud.count()
        #
        #
        domain_cloud = Docs.aggregate [
            { $match: match }
            { $project: "domain": 1 }
            # { $unwind: "$domain" }
            { $group: _id: "$domain", count: $sum: 1 }
            { $match: _id: $nin: selected_domains }
            # { $match: count: $lt: agg_doc_count }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 5 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        domain_cloud.forEach (domain, i) =>
            # console.log 'queried domain ', domain
            # console.log 'key', key
            self.added 'domain_results', Random.id(),
                title: domain.name
                count: domain.count
                # category:key
                # index: i
        # console.log doc_tag_cloud.count()

        emotion_cloud = Docs.aggregate [
            { $match: match }
            { $project: "max_emotion_name": 1 }
            # { $unwind: "$max_emotion_name" }
            { $group: _id: "$max_emotion_name", count: $sum: 1 }
            { $match: _id: $nin: selected_emotions }
            # { $match: count: $lt: agg_doc_count }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 5 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        emotion_cloud.forEach (emotion, i) =>
            # console.log 'queried emotion ', emotion
            # console.log 'key', key
            self.added 'emotion_results', Random.id(),
                title: emotion.name
                count: emotion.count
                # category:key
                # index: i
        # console.log doc_tag_cloud.count()

        self.ready()

Meteor.publish 'doc_results', (
    selected_tags
    # current_query
    # selected_subreddits
    selected_domains
    # selected_authors
    selected_emotions
    date_setting
    )->
    # console.log 'got selected tags', selected_tags
    # else
    self = @
    # console.log 'searching query', current_query
    match = {model:$in:['reddit','wikipedia']}
    # if current_query.length > 1
    #     match.title = {$regex:"#{current_query}", $options: 'i'}
    # if selected_tags.length > 0
    # console.log date_setting
    if date_setting
        if date_setting is 'today'
            now = Date.now()
            day = 24*60*60*1000
            yesterday = now-day
            # console.log yesterday
            match._timestamp = $gt:yesterday

    if selected_tags.length > 0
        # if selected_tags.length is 1
        #     console.log 'looking single doc', selected_tags[0]
        #     found_doc = Docs.findOne(title:selected_tags[0])
        #
        #     match.title = selected_tags[0]
        # else
        match.tags = $all: selected_tags
    else
        # unless selected_domains.length > 0
        #     unless selected_subreddits.length > 0
        #         unless selected_subreddits.length > 0
        #             unless selected_emotions.length > 0
        match.tags = $all: ['dao']
    if selected_domains.length > 0
        match.domain = $all: selected_domains
    #
    # if selected_subreddits.length > 0
    #     match.subreddit = $all: selected_subreddits
    if selected_emotions.length > 0
        match.max_emotion_name = $all: selected_emotions

    # else
    #     match.tags = $nin: ['wikipedia']
    #     sort = '_timestamp'
    #     # match. = $ne:'wikipedia'
    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:
            points:-1
            ups:-1
        limit:20
