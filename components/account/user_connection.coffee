if Meteor.isClient
    Template.user_connections.onCreated ->
        @autorun => Meteor.subscribe 'users'



    Template.user_connections.helpers
        connections: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                _id:$in: current_user.connected_ids
        nonconnections: ->
            Meteor.users.find
                _id:$nin:Meteor.user().connected_ids


    Template.user_connect_button.helpers
        is_connected: ->
            Meteor.user() and Meteor.user().connected_ids and @_id in Meteor.user().connected_ids


    Template.user_connect_button.events
        'click .connect':->
            Meteor.users.update Meteor.userId(),
                $addToSet: connected_ids:@_id
        'click .disconnect':->
            Meteor.users.update Meteor.userId(),
                $pull: connected_ids:@_id

        'keyup .assign_task': (e,t)->
            if e.which is 13
                post = t.$('.assign_task').val().trim()
                # console.log post
                current_user = Meteor.users.findOne username:Router.current().params.username
                Docs.insert
                    body:post
                    model:'task'
                    assigned_user_id:current_user._id
                    assigned_username:current_user.username

                t.$('.assign_task').val('')
