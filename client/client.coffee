@selected_tags = new ReactiveArray []

@selected_filters = new ReactiveArray []

@selected_facets = new ReactiveArray ['categories', 'subreddits']
@current_queries = new ReactiveArray []

Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'int', (input) -> input.toFixed(0)
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")


Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', () ->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'is_eric', () -> if Meteor.userId() and Meteor.userId() in ['K77p8B9jpXbTz6nfD'] then true else false
Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

Template.registerHelper 'in_dev', () -> Meteor.isDevelopment


Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'docs', Session.get('match')
    #     Session.get('tag_limit')
    #     Session.get('doc_limit')
    #     Session.get('view_nsfw')
    #     Session.get('sort_key')
    #     Session.get('sort_up')
    #     # Template.currentData().limit
    # )

    Session.setDefault 'doc_limit', 5
    Session.setDefault 'sort_label', 'added'
    Session.setDefault 'sort_key', '_timestamp'
    Session.setDefault 'sort_up', false
    Session.setDefault 'view_detail', true
    Session.setDefault 'view_detail', true
    Session.setDefault 'match', {}

Template.home.helpers
    sorting_up: -> Session.equals('sort_up', true)
    posts: ->
        Docs.find {
            model:'reddit'
        },
            sort: _timestamp: -1
    # view_subreddits: -> 'subreddits' in selected_facets.array()
    # view_authors: -> 'authors' in selected_facets.array()
    # view_categories: -> 'categories' in selected_facets.array()
    # view_companies: -> 'companies' in selected_facets.array()
    # view_subreddits: -> 'subreddits' in selected_facets.array()
    # view_locations: -> 'location' in selected_facets.array()
    # view_keywords: -> 'keywords' in selected_facets.array()
    # view_concepts: -> 'concepts' in selected_facets.array()
    # view_people: -> 'people' in selected_facets.array()
    # view_facilities: -> 'facilities' in selected_facets.array()
    # view_movies: -> 'movies' in selected_facets.array()
    # view_health_conditions: -> 'health_conditions' in selected_facets.array()



Template.home.events
    'click .set_sort_direction': ->
        if Session.equals('sort_up', false)
            Session.set('sort_up', true)
        else
            Session.set('sort_up', false)
    'click .toggle_detail': ->
        if Session.equals('view_detail', false)
            Session.set('view_detail', true)
        else
            Session.set('view_detail', false)
    'click .print_this': ->
        console.log @
    'click .call_reddit_post': ->
        console.log @
        Meteor.call 'get_reddit_post', @doc_id, @reddit_id, ->
    # 'click .import_subreddit': ->
    #     subreddit = $('.subreddit').val()
    #     Meteor.call 'pull_subreddit', subreddit
    # 'keyup .subreddit': (e,t)->
    #     if e.which is 13
    #         subreddit = $('.subreddit').val()
    #         Meteor.call 'pull_subreddit', subreddit
    'keyup #search': (e,t)->
        if e.which is 13
            search = $('#search').val()
            Meteor.call 'search_reddit', search
            selected_tags.push search

            match = Session.get('match')
            # tags_array = match["#{@key}"]
            tags_array = match.tags
            if tags_array
                tags_array.push search
            else
                tags_array = [search]
            match.tags = tags_array

            Session.set('match', match)
            Session.set('match', match)
            console.log Session.get('match')

            $('#search').val('')
            # Meteor.setTimeout ->
            #     Session.set('sort_up', !Session.get('sort_up'))
            # , 4000

    'click .import_site': ->
        site = $('.site').val()
        Meteor.call 'import_site', site



Template.home.helpers
    match: -> Session.get('match')
    view_detail: -> Session.get('view_detail')
    current_sort_key: -> Session.get('sort_key')
    current_sort_label: -> Session.get('sort_label')
    current_doc_limit: -> Session.get('doc_limit')
    current_tag_limit: -> Session.get('tag_limit')
    visible_facets: ->
        console.log selected_facets.array()
        selected_facets.array()

    # categories: ->
    #     doc_count = Docs.find().count()
    #     if 0 < doc_count < 3 then Categories.find { count: $lt: doc_count } else Categories.find({},limit:20)
    # selected_categories: -> selected_categories.array()
    # # category_settings: -> {
    # #     position: 'bottom'
    # #     limit: 10
    # #     rules: [
    # #         {
    # #             collection: Categories
    # #             field: 'name'
    # #             matchAll: true
    # #             template: Template.tag_result
    # #         }
    # #     ]
    # # }






Template.set_limit.events
    'click .set_limit': ->
        console.log @
        Session.set('doc_limit', @amount)

Template.set_sort_key.events
    'click .set_sort': ->
        console.log @
        Session.set('sort_key', @key)
        Session.set('sort_label', @label)

# Template.home.events
    # 'click .select_concept': ->
    #     current_queries.push @name
    #     selected_concepts.push @name
    #     Meteor.call 'search_reddit', current_queries.array()
    #     Meteor.setTimeout ->
    #         Session.set('sort_up', !Session.get('sort_up'))
    #     , 4000
    # 'click .unselect_concept': ->
    #     selected_concepts.remove @valueOf()
    #     current_queries.remove @valueOf()
    #     Meteor.call 'search_reddit', current_queries.array()
    #     Meteor.setTimeout ->
    #         Session.set('sort_up', !Session.get('sort_up'))
    #     , 4000
    # 'click #clear_concepts': ->
    #     selected_concepts.clear()

    # 'autocompleteselect input': (event, template, doc)->
    #     console.log("selected ", doc);







Template.tag_cloud.helpers
    tags: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()
    selected_tags: -> selected_tags.array()


Template.tag_cloud.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_tags.clear()

                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_tags.pop()

    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_tags.push doc.name
        $('#search').val ''



Template.call_watson.events
    'click .autotag': ->
        # console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        parent = Template.parentData()
        current = Template.currentData()
        console.log @
        console.log parent
        console.log current
        Meteor.call 'call_watson', parent._id, 'key', @mode, ->




Template.facet.onCreated ->
    @view_facet = new ReactiveVar true
    # @autorun => Meteor.subscribe 'results'
    @autorun => Meteor.subscribe(
        'facet_results'
        Template.currentData().key
        Session.get('match')
    )


# Template.toggle_facet.events
#     'click .toggle_facet': ->
#         # console.log @
#         if @label in selected_facets.array()
#             selected_facets.remove @label
#         else
#             selected_facets.push @label
#
# Template.toggle_facet.helpers
#     toggle_facet_class: ->
#         if @label in selected_facets.array()
#             'active'
#         else
#             'basic'



Template.facet.events
    'click .toggle_facet': (e,t)->
        t.view_facet.set !t.view_facet.get()
    'click .toggle_filter': ->
        console.log @
        match = Session.get('match')
        key_array = match["#{@key}"]
        if key_array
            if @name in key_array
                key_array = _.without(key_array, @name)
                match["#{@key}"] = key_array
                Session.set('match', match)
            else
                key_array.push @name
                Session.set('match', match)
                # match["#{@key}"] = ["#{@name}"]
        else
            match["#{@key}"] = ["#{@name}"]
        Session.set('match', match)
        console.log Session.get('match')

Template.facet.helpers
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
                ''
            else
                'basic'
    match: ->
        console.log Session.get('match')
        Session.get('match')
    results: ->
        # console.log Template.currentData().key
        Results.find(
            key:Template.currentData().key
        )






Template.array_view.helpers
    values: ->
        console.log @key
        Template.parentData()["#{@key}"]


Template.post.helpers
    view_detail: -> Session.get('view_detail')
    post_header_class: ->
        if @doc_sentiment_label is 'positive'
            if @doc_sentiment_score > .5
                'green'
            else
                'blue'
        else if @doc_sentiment_label is 'negative'
            if @doc_sentiment_score < -.5
                'red'
            else
                'orange'
Template.post.events
    'click .pick_location': ->
        current_queries.push @valueOf()
        selected_locations.push @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000

    'click .pick_company': ->
        current_queries.push @valueOf()
        selected_companies.push @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000

    'click .pick_person': ->
        current_queries.push @valueOf()
        selected_people.push @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000


    'click .calc_tone': ->
        console.log @
        Meteor.call 'call_tone', @_id, 'body', 'text', ->
