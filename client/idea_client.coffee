# @selected_idea_types = new ReactiveArray []

Template.idea_section.onCreated ->
    @autorun => @subscribe 'ideas',
        Session.get('idea_prematch')

Template.idea_section.helpers
    ideas: ->
        Ideas.find()
        # Results.find(
        #     model:'idea'
        # )


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
    'click .toggle_facet': (e,t)-> t.view_facet.set !t.view_facet.get()
    'click .toggle_filter': ->
        console.log @
        prematch = Session.get('idea_prematch')
        key_array = prematch["#{@category}"]
        if key_array
            if @title in key_array
                key_array = _.without(key_array, @title)
                prematch["#{@category}"] = key_array
                # current_queries.remove @title
                Session.set('prematch', prematch)
            else
                key_array.push @title
                # current_queries.push @title
                Session.set('prematch', prematch)
                # Meteor.call 'search_reddit', current_queries.array(), ->
                # prematch["#{@category}"] = ["#{@title}"]
        else
            prematch["#{@category}"] = ["#{@title}"]
            # current_queries.push @title
            # console.log current_queries.array()
        Session.set('idea_prematch', prematch)
        console.log current_queries.array()
        if current_queries.array().length > 0
            Meteor.call 'search_reddit', current_queries.array(), ->
        # console.log Session.get('match')

Template.idea_facet.helpers
    view_facet: ->
        Template.instance().view_facet.get()
    toggle_facet_class: ->
        if Template.instance().view_facet.get()
            ''
        else
            'basic'

    toggle_filter_class: ->
        match = Session.get('match')
        key = Template.currentData().key
        if match["#{key}"]
            if @name in match["#{key}"]
                'active'
            else
                'basic'
        else
            'basic'

    match: ->
        # console.log Session.get('match')
        Session.get('match')

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
