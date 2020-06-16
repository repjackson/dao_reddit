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


Meteor.publish 'omega_results', (dummy)->
    omega =
        Docs.findOne
            model:'omega_session'
    Docs.find
        _id:$in:omega.doc_result_ids


Meteor.publish 'omega_doc', ->
    omega =
        Docs.findOne
            model:'omega_session'
    if omega
        Docs.find omega._id
    else
        Docs.insert
            model:'omega_session'


Meteor.publish 'doc', (doc_id)->
    Docs.find
        _id:doc_id

Meteor.publish 'terms', (searching, query)->
    console.log searching
    console.log query



Meteor.publish 'tag_results', (
    selected_tags
    query
    dummy
    )->
    # console.log 'dummy', dummy
    # console.log 'query', query
    console.log 'selected tags', selected_tags


    # omega =
    #     Docs.findOne
    #         model:'omega_session'

    self = @
    match = {}

    match.model = $in: ['reddit','wikipedia']
    # console.log 'query length', query.length
    # if omega.query and omega.query.length > 0
    if query and query.length > 0
    #     console.log 'searching query', query
    #     # match.tags = {$regex:"#{query}", $options: 'i'}
    #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    #
        Terms.find {
            title: {$regex:"#{query}", $options: 'i'}
        },
            sort:
                count: -1
            limit: 10
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: selected_tags }
        #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 42 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]

    else
        # unless query and query.length > 2
        # if selected_tags.length > 0 then match.tags = $all: selected_tags
        if selected_tags.length > 0
            match.tags = $all: selected_tags
        else
            match.tags = $all: ['dao']
        console.log 'match for tags', match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            console.log 'queried tag ', tag
            # console.log 'key', key
            self.added 'tags', Random.id(),
                title: tag.name
                count: tag.count
                # category:key
                # index: i
            # Docs.update _id,
            #     $addToSet:
            #         tags:
            #             title:tag.name
            #             count:tag.count
        # console.log doc_tag_cloud.count()

        self.ready()

Meteor.publish 'doc_results', (
    selected_tags
    )->
    # console.log selected_tags
    self = @
    match = {model:$in:['reddit','wikipedia']}
    # if selected_tags.length > 0
    if selected_tags.length > 0
        match.tags = $all: selected_tags
    else
        match.tags = $all: ['dao']
    # else
    #     match.tags = $nin: ['wikipedia']
    #     sort = '_timestamp'
    #     # match. = $ne:'wikipedia'
    console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    # omega =
    #     Docs.findOne
    #         model:'omega_session'
    Docs.find match,
        sort:
            points:-1
            ups:-1
        limit:5
