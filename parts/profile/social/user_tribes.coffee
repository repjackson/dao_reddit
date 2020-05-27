if Meteor.isClient
    Router.route '/user/:username/tribes', (->
        @layout 'profile'
        @render 'user_tribes'
        ), name:'user_tribes'

    Template.user_tribes.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'tribe'

    Template.user_tribes.helpers
        user_tribes: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'tribe'
                member_ids: $in: [user._id]
