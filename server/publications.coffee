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



Meteor.publish 'all_users', ()->
    Meteor.users.find()



Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
