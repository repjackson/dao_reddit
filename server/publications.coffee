Meteor.publish 'current_doc ', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id




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



Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'docs', (
    selected_tags
    doc_limit
    doc_sort_key
    doc_sort_direction
    )->
    # console.log selected_tags
    if doc_limit
        limit = doc_limit
    else
        limit = 10
    if doc_sort_key
        sort = doc_sort_key
    if doc_sort_direction
        sort_direction = parseInt(doc_sort_direction)
    self = @
    match = {
        model:'rental'
        _author_id:$ne:Meteor.userId()
        bought:$ne:true
    }
    if selected_tags.length > 0
        match.tags = $all: selected_tags
        sort = 'ups'
        # match.source = $ne:'wikipedia'

    Docs.find match,
        # sort:"#{sort}":sort_direction
        sort:_timestamp:-1
        limit: limit
