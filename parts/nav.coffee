if Meteor.isClient
    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_stats', Router.current().params.username
    Template.nav.onRendered ->

    Template.nav.events
        'keyup #search': (e,t)->
            if e.which is 13
                val = t.$('#search').val().trim().toLowerCase()
                if val.length > 0
                    Meteor.call 'talk', val, (e,r)->
                        Session.set('talk_result')

    Template.nav.helpers
        talk_result: ->
            Session.get('talk_result')


if Meteor.isServer
    Meteor.methods
        talk: (entry)->
            'hi'
