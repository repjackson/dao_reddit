if Meteor.isClient
    Router.route '/user/:username/tags', (->
        @layout 'profile'
        @render 'user_tags'
        ), name:'user_tags'

    Template.user_tags.onRendered ->
        @autorun -> Meteor.subscribe 'user_tag_review', Router.current().params.username

    Template.user_tags.events

    Template.user_tags.helpers
        user_tags_ingredients: ->
            if Meteor.user().tags_ingredient_ids
                Docs.find
                    model:'ingredient'
                    _id: $in: Meteor.user().tags_ingredient_ids


if Meteor.isServer
    Meteor.publish 'user_tags', (username)->
        user = Meteor.users.findOne username:username

        Docs.find
            model:'user_tag_review'
            tagged_user_id: user._id
