if Meteor.isClient
    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_stats', Router.current().params.username
    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.sidenav').sidenav();
        , 200
    Template.nav.events
        'click .open': (e,t)->
            console.log @
            instance = M.Sidenav.getInstance(e);
            console.log instance
            instance.open();

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
