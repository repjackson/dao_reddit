Meteor.publish 'current_doc ', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id



Meteor.publish 'tags', (
    selected_tags
    selected_authors=[]
    view_mode
    current_query=''
    limit
)->
    # console.log 'selected username', selected_authors
    self = @
    match = {}
    if selected_authors.length > 0 then match._author_username = $all: selected_authors
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if current_query.length > 0 then match.title = {$regex:"#{current_query}", $options: 'i'}


    match.model = 'thought'
    # if view_mode is 'voted'
        # match._author_id = $ne: Meteor.userId()
    if view_mode is 'upvoted'
        match.upvoter_ids = $in:[Meteor.userId()]
    if view_mode is 'downvoted'
        match.downvoter_ids = $in:[Meteor.userId()]
    if view_mode is 'unvoted'
        match.upvoter_ids = $nin:[Meteor.userId()]
        match.downvoter_ids = $nin:[Meteor.userId()]

    if limit
        console.log 'limit', limit
        calc_limit = limit
    else
        calc_limit = 20
    cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: calc_limit }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    # console.log 'filter: ', filter
    # console.log 'cloud: ', cloud

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    authors = Docs.aggregate [
        { $match: match }
        { $project: "_author_username": 1 }
        { $group: _id: "$_author_username", count: $sum: 1 }
        { $match: _id: $nin: selected_authors }
        { $sort: count: -1, _id: 1 }
        { $limit: 10 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    # console.log 'filter: ', filter
    # console.log 'cloud: ', cloud

    authors.forEach (author, i) ->
        self.added 'authors', Random.id(),
            name: author.name
            count: author.count
            index: i

    self.ready()


Meteor.publish 'docs', (
    selected_tags
    selected_authors
    view_mode
    # current_query=''
    # doc_limit=10
    # doc_sort_key='_timestamp'
    # doc_sort_direction=1
    )->
    match = {model:'thought'}
    # if current_query.length > 0 then match.title = {$regex:"#{current_query}", $options: 'i'}
    if view_mode is 'upvoted'
        match.upvoter_ids = $in:[Meteor.userId()]
    if view_mode is 'downvoted'
        match.downvoter_ids = $in:[Meteor.userId()]
    if view_mode is 'unvoted'
        match.upvoter_ids = $nin:[Meteor.userId()]
        match.downvoter_ids = $nin:[Meteor.userId()]
    # console.log selected_tags
    # console.log match
    # if doc_limit
    #     limit = doc_limit
    # else
    #     limit = 10
    # if doc_sort_key
    #     sort = doc_sort_key
    # if doc_sort_direction
    #     sort_direction = parseInt(doc_sort_direction)
    #     console.log sort_direction
    self = @
    if selected_tags.length > 0
        match.tags = $all: selected_tags
        # sort = 'ups'
        # match.source = $ne:'wikipedia'

    # if selected_authors.length > 0
    #     match._author_username = $all: selected_authors

    Docs.find match,
        # sort:"#{sort}":sort_direction
        sort:
            points:-1
            _timestamp:-1
        limit: 4


Meteor.publish 'me', ->
    Meteor.users.find @userId

Meteor.publish 'model_docs', (model)->
    # console.log 'pulling doc'
    Docs.find
        model:model

Meteor.publish 'user_from_username', (username)->
    # console.log 'pulling doc'
    Meteor.users.find
        username:username



Meteor.publish 'all_users', ()->
    Meteor.users.find()



Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
