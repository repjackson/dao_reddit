Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    # userId is doc._author_id
    remove: (userId, doc) -> userId is doc._author_id

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
        # if userId and doc._id == userId
        #     true

# Meteor.publish 'me', ()->
#     if Meteor.user()
#         Meteor.users.find Meteor.userId()
#     else
#         []
#
