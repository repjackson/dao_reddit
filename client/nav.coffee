Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    # @autorun => Meteor.subscribe 'alerts'
    @autorun => Meteor.subscribe 'model_docs', 'global_settings'
    # @autorun => Meteor.subscribe 'model_docs', 'model'

Template.nav.events
Template.nav.helpers
    view_chat: -> Session.get('view_chat')
    models: ->
        search = Session.get('current_global_query')
        Docs.find {
            title:{$regex:"#{search}", $options: 'i'}
            model:'model'
        }, sort: title:1

    current_query: ->
        search = Session.get('current_global_query')
