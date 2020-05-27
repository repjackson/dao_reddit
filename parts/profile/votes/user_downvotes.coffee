if Meteor.isClient
    Router.route '/user/:username/downvotes', (->
        @layout 'profile'
        @render 'user_downvotes'
        ), name:'user_downvotes'

    Template.user_downvotes.onRendered ->
        @autorun -> Meteor.subscribe 'user_downvotes_ingredients', Router.current().params.username

    Template.user_downvotes.events

    Template.user_downvotes.helpers
        user_downvotes_ingredients: ->
            if Meteor.user().downvotes_ingredient_ids
                Docs.find
                    model:'ingredient'
                    _id: $in: Meteor.user().downvotes_ingredient_ids


if Meteor.isServer
    Meteor.publish 'user_downvotes', (username)->
        user = Meteor.users.findOne username:username

        Docs.find
            model:'ingredient'
            _id: $in: user.downvotes_ingredient_ids
