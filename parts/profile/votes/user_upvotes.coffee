if Meteor.isClient
    Router.route '/user/:username/upvotes', (->
        @layout 'profile'
        @render 'user_upvotes'
        ), name:'user_upvotes'

    Template.user_upvotes.onRendered ->
        @autorun -> Meteor.subscribe 'user_upvotes_ingredients', Router.current().params.username

    Template.user_upvotes.events

    Template.user_upvotes.helpers
        user_upvotes_ingredients: ->
            if Meteor.user().upvotes_ingredient_ids
                Docs.find
                    model:'ingredient'
                    _id: $in: Meteor.user().upvotes_ingredient_ids


if Meteor.isServer
    Meteor.publish 'user_upvotes', (username)->
        user = Meteor.users.findOne username:username

        Docs.find
            model:'ingredient'
            _id: $in: user.upvotes_ingredient_ids
