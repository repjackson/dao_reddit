if Meteor.isClient
    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_stats', Router.current().params.username
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000



    Template.profile_layout.events
        'click .checkin': ->
            Docs.insert
                model:'log'
                body:"#{Meteor.user().username} checked in."
            Meteor.users.update Meteor.userId(),
                $set:checkedin:true

        'click .checkout': ->
            Docs.insert
                model:'log'
                body:"#{Meteor.user().username} checked out."
            Meteor.users.update Meteor.userId(),
                $set:checkedin:false


        'click .logout_other_clients': -> Meteor.logoutOtherClients()
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
