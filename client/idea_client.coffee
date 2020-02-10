# @selected_idea_types = new ReactiveArray []

Template.idea_section.onCreated ->
    Session.setDefault('idea_limit', 5)
    @autorun => @subscribe 'ideas_from_query', Session.get('current_query')
    @autorun => @subscribe 'ideas',
        Session.get('idea_prematch')
        Session.get('idea_limit')
        # Session.get('view_nsfw')
        Session.get('idea_sort_key')
        Session.get('idea_sort_direction')

Template.idea_section.helpers
    ideas: ->
        Ideas.find {},
            sort: "#{Session.get('idea_sort_key')}": Session.get('idea_sort_direction')
    current_idea_sort_key: -> Session.get('idea_sort_key')
    current_idea_sort_label: -> Session.get('idea_sort_label')
    current_idea_limit: -> Session.get('idea_limit')
    idea_sorting_up: -> Session.equals('idea_sort_direction', -1)
    idea_subs_ready: -> Template.instance().subscriptionsReady()

Template.idea_section.events
    'click .set_idea_sort_direction': ->
        if Session.equals('idea_sort_direction', -1)
            Session.set('idea_sort_direction', 1)
        else
            Session.set('idea_sort_direction', -1)
        # console.log Session.get('idea_sort_direction')
Template.set_idea_limit.events
    'click .set_idea_limit': ->
        # console.log @
        Session.set('idea_limit', @amount)


Template.idea_segment.events
    'click .print_idea': ->
        console.log @


Template.idea_facet.onCreated ->
    # @view_facet = new ReactiveVar false
    Session.setDefault 'idea_prematch', {}

    Session.setDefault('selected_idea_type', 'null')
    # @autorun => Meteor.subscribe 'results'
    @autorun => @subscribe(
        'idea_facet_results'
        Template.currentData().key
        Session.get('idea_prematch')
        Session.get('current_query')
        Session.get('idea_limit')
        # Session.get('view_nsfw')
        Session.get('sort_key')
        Session.get('sort_direction')
    )

Template.idea_facet.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.dropdown')
    #       .dropdown()
    # , 2000



Template.idea_facet.events
    # 'click .toggle_facet': (e,t)-> t.view_facet.set !t.view_facet.get()
    'click .toggle_idea_filter': ->
        console.log @
        prematch = Session.get('idea_prematch')
        key_array = prematch["#{@category}"]
        if key_array
            if @title in key_array
                key_array = _.without(key_array, @title)
                prematch["#{@category}"] = key_array
                # queries.remove @title
                Session.set('prematch', prematch)
            else
                key_array.push @title
                # queries.push @title
                Session.set('prematch', prematch)
                # Meteor.call 'search_reddit', queries.array(), ->
                # prematch["#{@category}"] = ["#{@title}"]
        else
            prematch["#{@category}"] = ["#{@title}"]
            # queries.push @title
            # console.log queries.array()
        Session.set('idea_prematch', prematch)
        console.log queries.array()
        if queries.array().length > 0
            Meteor.call 'search_reddit', queries.array(), ->
        # console.log Session.get('match')

Template.idea_facet.helpers
    view_facet: ->
        Template.instance().view_facet.get()
    toggle_idea_facet_class: ->
        if Template.instance().view_facet.get()
            ''
        else
            'basic'

    toggle_idea_filter_class: ->
        # console.log @
        prematch = Session.get('idea_prematch')
        key = Template.parentData().key
        # console.log 'current data', Template.currentData()
        current = Template.currentData()
        # console.log 'parent data', Template.parentData()
        parent = Template.parentData()
        # console.log prematch
        if prematch["#{key}"]
            if current.title in prematch["#{key}"]
                'active'
            else
                'basic'
        else
            'basic'

    idea_prematch: ->
        # console.log Session.get('match')
        Session.get('idea_prematch')

    results: ->
        # console.log Template.currentData().key
        Idea_results.find(
            category:Template.currentData().key
        )


    top_results: ->
        # console.log Template.currentData().key
        Results.find({
            key:Template.currentData().key
        }, {limit:7}
        )


    bottom_results: ->
        # console.log Template.currentData().key
        Results.find({
            key:Template.currentData().key
        }, {skip:7}
        )




Template.set_idea_sort_key.events
    'click .set_sort': ->
        # console.log @
        Session.set('idea_sort_key', @key)
        Session.set('idea_sort_label', @label)
