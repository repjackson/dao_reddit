@selected_tags = new ReactiveArray []
@selected_people = new ReactiveArray []
@selected_companies = new ReactiveArray []
@selected_subreddits = new ReactiveArray []
@selected_authors = new ReactiveArray []
@selected_keywords = new ReactiveArray []
@selected_concepts = new ReactiveArray []
@selected_locations = new ReactiveArray []
@selected_categories = new ReactiveArray []
@selected_movies = new ReactiveArray []
@selected_organizations = new ReactiveArray []
@selected_facilities = new ReactiveArray []
@selected_timestamp_tags = new ReactiveArray []
@selected_health_conditions = new ReactiveArray []
@selected_print_medias = new ReactiveArray []
@selected_sports = new ReactiveArray []

@selected_facets = new ReactiveArray []

# Delta = new Mongo.Collection(null);

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
    @autorun -> Meteor.subscribe(
        'reddit_facets'
        selected_tags.array()
        selected_organizations.array()
        selected_people.array()
        selected_subreddits.array()
        selected_companies.array()
        selected_categories.array()
        selected_health_conditions.array()
        selected_keywords.array()
        selected_concepts.array()
        selected_locations.array()
        selected_facilities.array()
        selected_movies.array()
        selected_print_medias.array()
        selected_sports.array()
        selected_authors.array()
        selected_timestamp_tags.array()
        Session.get('tag_limit')
        Session.get('doc_limit')
        Session.get('view_nsfw')
        Session.get('sort_key')
        Session.get('sort_up')

        # Template.currentData().limit
    )

    Session.setDefault 'doc_limit', 5
    Session.setDefault 'sort_label', 'added'
    Session.setDefault 'sort_key', '_timestamp'
    Session.setDefault 'sort_up', false
    Session.setDefault 'view_detail', true

Template.home.helpers
    sorting_up: -> Session.equals('sort_up', true)
    posts: ->
        Docs.find {
            model:'reddit'
        },
            sort: _timestamp: -1
    view_subreddits: -> 'subreddits' in selected_facets.array()
    view_authors: -> 'authors' in selected_facets.array()
    view_categories: -> 'categories' in selected_facets.array()
    view_companies: -> 'companies' in selected_facets.array()
    view_subreddits: -> 'subreddits' in selected_facets.array()



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
            $('#search').val('')
            Meteor.setTimeout ->
                Session.set('sort_up', !Session.get('sort_up'))
            , 4000

    'click .import_site': ->
        site = $('.site').val()
        Meteor.call 'import_site', site


Template.toggle_facet.events
    'click .toggle_facet': ->
        console.log @
        if @label in selected_facets.array()
            selected_facets.remove @label
        else
            selected_facets.push @label

Template.toggle_facet.helpers
    toggle_facet_class: ->
        if @label in selected_facets.array()
            'active'
        else
            'basic'


Template.home.helpers
    view_detail: -> Session.get('view_detail')
    current_sort_key: -> Session.get('sort_key')
    current_sort_label: -> Session.get('sort_label')
    current_doc_limit: -> Session.get('doc_limit')
    current_tag_limit: -> Session.get('tag_limit')
    visible_facets: ->
        console.log selected_facets.array()
        selected_facets.array()

    people: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then People.find { count: $lt: doc_count } else People.find({},limit:20)
    selected_people: -> selected_people.array()

    subreddits: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Subreddits.find { count: $lt: doc_count } else Subreddits.find({},limit:20)
    selected_subreddits: -> selected_subreddits.array()

    companies: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Companies.find { count: $lt: doc_count } else Companies.find({},limit:20)
    selected_companies: -> selected_companies.array()

    health_conditions: ->
        doc_count = Docs.find().count()
        # console.log Health_conditions.find().count()
        # Health_conditions.find()
        if 0 < doc_count < 3 then Health_conditions.find { count: $lt: doc_count } else Health_conditions.find({},limit:20)
    selected_health_conditions: -> selected_health_conditions.array()

    sports: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Sports.find { count: $lt: doc_count } else Sports.find({},limit:20)
    selected_sports: -> selected_sports.array()

    concepts: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Concepts.find { count: $lt: doc_count } else Concepts.find({},limit:20)
    selected_concepts: -> selected_concepts.array()

    keywords: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Keywords.find { count: $lt: doc_count } else Keywords.find({},limit:20)
    selected_keywords: -> selected_keywords.array()

    authors: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Authors.find { count: $lt: doc_count } else Authors.find({},limit:20)
    selected_authors: -> selected_authors.array()

    locations: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Locations.find { count: $lt: doc_count } else Locations.find({},limit:20)
    selected_locations: -> selected_locations.array()

    organizations: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Organizations.find { count: $lt: doc_count } else Organizations.find({},limit:20)
    selected_organizations: -> selected_organizations.array()

    facilities: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Facilities.find { count: $lt: doc_count } else Facilities.find({},limit:20)
    selected_facilities: -> selected_facilities.array()

    movies: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Movies.find { count: $lt: doc_count } else Movies.find({},limit:20)
    selected_movies: -> selected_movies.array()

    # print_medias: ->
    #     doc_count = Docs.find().count()
    #     if 0 < doc_count < 3 then Print_medias.find { count: $lt: doc_count } else Print_medias.find({},limit:20)
    # selected_print_medias: -> selected_print_medias.array()

    categories: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Categories.find { count: $lt: doc_count } else Categories.find({},limit:20)
    selected_categories: -> selected_categories.array()
    # category_settings: -> {
    #     position: 'bottom'
    #     limit: 10
    #     rules: [
    #         {
    #             collection: Categories
    #             field: 'name'
    #             matchAll: true
    #             template: Template.tag_result
    #         }
    #     ]
    # }
Template.set_limit.events
    'click .set_limit': ->
        console.log @
        Session.set('doc_limit', @amount)

Template.set_sort_key.events
    'click .set_sort': ->
        console.log @
        Session.set('sort_key', @key)
        Session.set('sort_label', @label)

Template.home.events
    'click .calc_tone': ->
        console.log @
        Meteor.call 'call_tone', @_id, 'body', 'text', ->

    'click .select_person': ->
        current_queries.push @name
        selected_people.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_person': ->
        selected_people.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000

    'click #clear_people': ->
        selected_people.clear()


    'click .select_subreddit': ->
        current_queries.push @name
        selected_subreddits.push @name
        Meteor.call 'search_reddit', current_queries.array()
    'click .unselect_subreddit': ->
        selected_subreddits.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
    'click #clear_subreddits': ->
        selected_subreddits.clear()


    'click .select_concept': ->
        current_queries.push @name
        selected_concepts.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_concept': ->
        selected_concepts.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_concepts': ->
        selected_concepts.clear()


    'click .select_movie': ->
        current_queries.push @name
        selected_movies.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_movie': ->
        selected_movies.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_movies': ->
        selected_movies.clear()


    'click .select_sport': ->
        current_queries.push @name
        selected_sports.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_sport': ->
        selected_sports.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_sports': ->
        selected_sports.clear()


    'click .select_print_media': ->
        current_queries.push @name
        selected_print_medias.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_print_media': ->
        selected_print_medias.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_print_medias': ->
        selected_print_medias.clear()


    'click .select_health_condition': ->
        current_queries.push @name
        selected_health_conditions.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000

    'click .unselect_health_condition': ->
        selected_health_conditions.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_health_conditions': ->
        selected_health_conditions.clear()



    'click .select_facility': ->
        current_queries.push @name
        selected_facilities.push @name
        Meteor.call 'search_reddit', current_queries.array()
    'click .unselect_facility': ->
        selected_facilities.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000

    'click #clear_facilities': ->
        selected_facilities.clear()


    'click .select_keyword': ->
        current_queries.push @name
        selected_keywords.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_keyword': ->
        selected_keywords.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_keywords': ->
        selected_keywords.clear()


    'click .select_author': ->
        current_queries.push @name
        selected_authors.push @name
        Meteor.call 'search_reddit', current_queries.array()
    'click .unselect_author': ->
        selected_authors.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
    'click #clear_authors': ->
        selected_authors.clear()


    'click .select_location': ->
        current_queries.push @name
        selected_locations.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_location': ->
        selected_locations.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_locations': ->
        selected_locations.clear()


    'click .select_company': ->
        current_queries.push @name
        selected_companies.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_company': ->
        selected_companies.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_companies': ->
        selected_companies.clear()


    'click .select_organization': ->
        current_queries.push @name
        selected_organizations.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_organization': ->
        selected_organizations.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click #clear_organizations': ->
        selected_organizations.clear()


    'click .select_category': ->
        current_queries.push @name
        selected_categories.push @name
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
    'click .unselect_category': ->
        selected_categories.remove @valueOf()
        current_queries.remove @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000

    'click #clear_categories': ->
        selected_categories.clear()
    'autocompleteselect input': (event, template, doc)->
        console.log("selected ", doc);







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
