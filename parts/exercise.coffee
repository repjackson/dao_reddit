if Meteor.isClient
    Router.route '/exercise', (->
        @layout 'layout'
        @render 'exercise'
        ), name:'exercise'

    Template.exercise.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_stats', Router.current().params.username
    Template.exercise.onRendered ->

    Template.exercise.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()
        'click .recalc_user_stats': ->
            Meteor.call 'recalc_user_stats', Router.current().params.username, ->
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()

    Template.exercise.helpers
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
