Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    @autorun => Meteor.subscribe 'alerts'
    @autorun => Meteor.subscribe 'model_docs', 'global_settings'
    @autorun => Meteor.subscribe 'model_docs', 'model'

Template.nav.events
    'click .notifications': ->
        Notification.requestPermission().then((result)->
          console.log(result);
        );

        n = new Notification("Hi! ", {tag: 'soManyNotification'});

    'click .toggle_chat': ->
        $('.main_area').transition('jiggle', 250)
        Session.set('view_chat', !Session.get('view_chat'))
    'click .goto_model': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', @slug, ->
            Session.set 'loading', false
Template.nav.helpers
    view_chat: -> Session.get('view_chat')
    models: ->
        Docs.find {
            model:'model'
        }, sort: title:1
