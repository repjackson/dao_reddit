if Meteor.isClient
    Router.route '/user/:username/pantry', (->
        @layout 'profile'
        @render 'user_pantry'
        ), name:'user_pantry'

    Template.user_pantry.onRendered ->
        @autorun -> Meteor.subscribe 'user_pantry_ingredients', Router.current().params.username

    Template.user_pantry.events

    Template.user_pantry.helpers
        user_pantry_ingredients: ->
            if Meteor.user().pantry_ingredient_ids
                Docs.find
                    model:'ingredient'
                    _id: $in: Meteor.user().pantry_ingredient_ids


if Meteor.isServer
    Meteor.publish 'user_pantry', (username)->
        user = Meteor.users.findOne username:username

        Docs.find
            model:'ingredient'
            _id: $in: user.pantry_ingredient_ids
