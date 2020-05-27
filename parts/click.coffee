if Meteor.isClient
    Router.route '/click', (->
        @layout 'layout'
        @render 'click'
        ), name:'click'

    Template.click.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_stats', Router.current().params.username
    Template.click.onRendered ->

    Template.click.events
        'click .click': ->
            Meteor.call 'click', ->

    Template.click.helpers
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
        click: ->
            Meteor.users.update Meteor.userId()
                $inc:points:1
