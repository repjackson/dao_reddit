if Meteor.isClient
    Template.ads.events
        # 'click #logout': ->
        #     Session.set 'logging_out', true
        #     Meteor.logout ->
        #         Session.set 'logging_out', false
        #         Router.go '/'


    Template.ads.onRendered ->
        Meteor.setTimeout ->
            $('.item').popup()
        , 3000


    Template.ads.onCreated ->
        # @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'ads'

    Template.ads.helpers
        current_ad: ->
            Docs.findOne
                model:'ad'


if Meteor.isServer
    Meteor.publish 'ads', ->
        Docs.find
            model:'ad'
