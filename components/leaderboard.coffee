if Meteor.isClient
    Router.route '/leaderboard/', (->
        @layout 'layout'
        @render 'leaderboard'
        ), name:'leaderboard'

    Template.leaderboard.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'leaderboard_document'
        @autorun => Meteor.subscribe 'model_docs', 'ticket'
        @autorun => Meteor.subscribe 'users'

    Template.leaderboard.helpers
        tickets: ->
            Docs.find {
                model:'ticket'
            }, _timestamp:1

        ranked_iq_users: ->
            Meteor.users.find {}, sort:iq:-1

    Template.leaderboard.events
