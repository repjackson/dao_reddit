Meteor.publish 'current_doc ', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id



Meteor.publish 'tags', (
    selected_tags,
    view_mode
    limit
)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.model = 'item'
    if view_mode is 'users'
        match.bought = $ne:true
        match._author_id = $ne: Meteor.userId()
    if view_mode is 'bought'
        match.bought = true
        match.buyer_id = Meteor.userId()
    if view_mode is 'selling'
        match.bought = $ne:true
        match._author_id = Meteor.userId()
    if view_mode is 'sold'
        match.bought = true
        match._author_id = Meteor.userId()

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

    self.ready()

Meteor.publish 'alerts', ->
    Docs.find
        model:'alert'
        to_user_id:Meteor.userId()
        read:$ne:true

# Meteor.publish 'alerts', ->
#     Docs.find
#         model:'alert'
#         to_user_id:Meteor.userId()
#         read:$ne:true

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
