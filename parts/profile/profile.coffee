if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile'
        @render 'user_dashboard'
        ), name:'user_dashboard'

    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_stats', Router.current().params.username
    Template.profile.onRendered ->

    Template.profile.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()
        'click .recalc_user_stats': ->
            Meteor.call 'recalc_user_stats', Router.current().params.username, ->
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()

    Template.profile.helpers
        user: ->
            Meteor.users.findOne username:Router.current().params.username
        upvoted_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            console.log user.upvoted_ids
        downvoted_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            console.log user.downvoted_ids

if Meteor.isServer
    Meteor.methods
        recalc_user_stats: (username)->
            user = Meteor.users.findOne username:username
            upvoted =
                Docs.find {
                    model:"post"
                    upvoter_ids: $in: [Meteor.userId()]
                },
                    fields: _id:1
            console.log upvoted.count()
            downvoted =
                Docs.find {
                    model:"post"
                    downvoter_ids: $in: [Meteor.userId()]
                },
                    fields: _id:1
            console.log upvoted.count()
            Meteor.users.update user._id,
                $set:
                    like_count: upvoted.count()
                    dislike_count: downvoted.count()
                    upvoted_ids: upvoted.fetch()
                    downvoted_ids: downvoted.fetch()
