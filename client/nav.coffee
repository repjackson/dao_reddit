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
        search = Session.get('current_global_query')
        Docs.find {
            title:{$regex:"#{search}", $options: 'i'}
            model:'model'
        }, sort: title:1

    current_query: ->
        search = Session.get('current_global_query')
    results: ->
        search = Session.get('current_global_query')
        found_sections =
            Docs.find(
                model:'section'
                title:{$regex:"#{search}", $options: 'i'}
            ).fetch()


Template.nav.events
    # 'keyup .global_search': _.throttle((e,t)->
    'keyup .global_search': (e,t)->
        # query = $('#search').val()
        search = $('.global_search').val().toLowerCase()
        Session.set('current_global_query', search)
        # console.log Session.get('current_global_query')
        found_sections =
            Docs.find(
                model:'section'
                title:{$regex:"#{search}", $options: 'i'}
            ).fetch()
        if search.length > 2 and found_sections.length is 1
            # console.log found_sections[0]
            # selection = found_sections[0]
            $('.global_search').val('')
            $('.global_search').blur()
            Session.set('current_global_query', null)
            Router.go "/#{found_sections[0].link}"
    		# $('.ui.basic.modal').modal('toggle')
    # , 500)

        # console.log found_sections.fetch()
        # if e.which is 13
        #     if search.length > 0
        #         selected_tags.push search
        #         console.log 'search', search
        #         # Meteor.call 'log_term', search, ->
        #         $('#search').val('')
        #         Session.set('current_query', null)
        #         # # $('#search').val('').blur()
        #         # # $( "p" ).blur();
        #         # Meteor.setTimeout ->
        #         #     Session.set('dummy', !Session.get('dummy'))
        #         # , 10000
