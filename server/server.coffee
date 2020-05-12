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

Meteor.users.allow
    insert: (user_id, doc, fields, modifier) ->
        # user_id
        true
        # if user_id and doc._id == user_id
        #     true
    update: (user_id, doc, fields, modifier) ->
        # true
        if user_id and doc._id == user_id
            true
    remove: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'admin' in user.roles
            true
        # if user_id and doc._id == user_id
        #     true

# Meteor.publish 'me', ()->
#     if Meteor.user()
#         Meteor.users.find Meteor.user_id()
#     else
#         []
#
