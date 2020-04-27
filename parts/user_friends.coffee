if Meteor.isClient
    Template.user_friends.onCreated ->
        @autorun => Meteor.subscribe 'users'



    Template.user_friends.helpers
        friends: ->
            current_user = Meteor.users.findOne Router.current().params.user_id
            Meteor.users.find
                _id:$in: current_user.friend_ids
        nonfriends: ->
            Meteor.users.find
                _id:$nin:Meteor.user().friend_ids


    Template.user_friend_button.helpers
        is_friend: ->
            Meteor.user() and Meteor.user().friend_ids and @_id in Meteor.user().friend_ids


    Template.user_friend_button.events
        'click .friend':->
            Meteor.users.update Meteor.userId(),
                $addToSet: friend_ids:@_id
        'click .unfriend':->
            Meteor.users.update Meteor.userId(),
                $pull: friend_ids:@_id

        'keyup .assign_task': (e,t)->
            if e.which is 13
                post = t.$('.assign_task').val().trim()
                # console.log post
                current_user = Meteor.users.findOne Router.current().params.user_id
                Docs.insert
                    body:post
                    model:'task'
                    assigned_user_id:current_user._id
                    assigned_username:current_user.username

                t.$('.assign_task').val('')
