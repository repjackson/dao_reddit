if Meteor.isClient
    Router.route '/help', (->
        @layout 'layout'
        @render 'help'
        ), name:'help'
    Template.help.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'ticket'
        @autorun => Meteor.subscribe 'all_users'

    Template.help.helpers
        tickets: ->
            Docs.find
                model:'ticket'
        users: ->
            Meteor.users.find({credit:$gt:1},
                sort:credit:-1)

        events: ->
            Docs.find
                model:'event'

    Template.help.events
        'click .new_ticket': ->
            Docs.insert
                model:'ticket'
        'click .refresh_stats': ->
            Meteor.call 'refresh_global_stats', ->
        'click .send_password_reset_email': ->
            Meteor.call 'send_password_reset_email', Meteor.userId(), ->



if Meteor.isServer
    Meteor.methods
