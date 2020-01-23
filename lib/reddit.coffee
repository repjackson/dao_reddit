if Meteor.isClient
    # create a local collection
    # delta = new (Meteor.Collection)(null)
    # # create a local persistence observer
    # deltaObserver = new LocalPersist(delta, 'delta',
    #     maxDocuments: 99
    #     storageFull: (col, doc) ->
    #         # function to handle maximum being exceeded
    #         col.remove _id: doc._id
    #         alert 'Shopping cart is full.'
    #         return
    # )
    # # create a helper to fetch the data
    # UI.registerHelper 'delta_docs', ->
    #     delta.find()
    # # that's it. just use the collection normally and the observer
    # # will keep it sync'd to browser storage. the data will be stored
    # # back into the collection when returning to the app (depending,
    # # of course, on availability of localStorage in the browser).
    # delta.insert
    #     item: 'DMB-01'
    #     desc: 'Discover Meteor Book'
    #     quantity: 1


    Template.reddit.onCreated ->
        # @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'model_docs', 'global_stats'
        # @autorun -> Meteor.subscribe 'reddit_posts', selected_tags.array(), 'reddit', 10
        @autorun -> Meteor.subscribe(
            'reddit_facets'
            selected_tags.array()
            selected_organizations.array()
            selected_people.array()
            selected_subreddits.array()
            selected_companies.array()
            selected_categories.array()
            selected_keywords.array()
            selected_concepts.array()
            selected_locations.array()
            selected_authors.array()
            selected_timestamp_tags.array()
            Session.get('tag_limit')
            Session.get('doc_limit')
            Session.get('view_nsfw')
            Session.get('sort_key')
            Session.get('sort_direction')

            # Template.currentData().limit
        )

        Session.setDefault 'limit', 5
        Session.setDefault 'sort_by', 'timestamp'
        Session.setDefault 'sort_direction', -1

    Template.reddit.helpers
        sorting_up: ->
            Session.equals('sort_direction', -1)
        # people: -> People.find({},limit:42)
        # authors: -> Authors.find({},limit:42)
        # companies: -> Companies.find({},limit:42)
        # subreddits: -> Subreddits.find({},limit:42)
        # organizations: -> Organizations.find({},limit:42)
        # concepts: -> Concepts.find({},limit:42)
        # keywords: -> Keywords.find({},limit:42)
        # locations: -> Locations.find({},limit:42)
        reddit_posts: ->
            Docs.find {
                model:'reddit'
            },
                sort: _timestamp: -1
        view_categories: -> 'Categories' in selected_facets.array()
        view_people: -> 'Person' in selected_facets.array()
        view_subreddits: -> 'subreddits' in selected_facets.array()
        view_companies: -> 'Company' in selected_facets.array()
        view_locations: -> 'Location' in selected_facets.array()
        view_organizations: -> 'Organization' in selected_facets.array()
        view_keywords: -> 'keywords' in selected_facets.array()
        view_concepts: -> 'concepts' in selected_facets.array()
        view_authors: -> 'authors' in selected_facets.array()



    Template.reddit.events
        'click .set_sort_direction': ->
            if Session.equals('sort_direction', -1)
                Session.set('sort_direction', 1)
            else
                Session.set('sort_direction', -1)
        'click .print_this': ->
            console.log @
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
        'click .import_site': ->
            site = $('.site').val()
            Meteor.call 'import_site', site


    Template.toggle_facet.events
        'click .toggle_facet': ->
            # console.log @
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


    Template.cfacet.helpers
        label: ->
            @valueOf()



    Template.reddit.helpers
        # cd: ->
        #     Delta.findOne()


        visible_facets: ->
            selected_facets.array()

        people: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then People.find { count: $lt: doc_count } else People.find({},limit:42)
        selected_people: -> selected_people.array()

        subreddits: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Subreddits.find { count: $lt: doc_count } else Subreddits.find({},limit:42)
        selected_subreddits: -> selected_subreddits.array()

        companies: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Companies.find { count: $lt: doc_count } else Companies.find({},limit:42)
        selected_companies: -> selected_companies.array()

        concepts: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Concepts.find { count: $lt: doc_count } else Concepts.find({},limit:42)
        selected_concepts: -> selected_concepts.array()

        keywords: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Keywords.find { count: $lt: doc_count } else Keywords.find({},limit:42)
        selected_keywords: -> selected_keywords.array()

        authors: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Authors.find { count: $lt: doc_count } else Authors.find({},limit:42)
        selected_authors: -> selected_authors.array()

        locations: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Locations.find { count: $lt: doc_count } else Locations.find({},limit:42)
        selected_locations: -> selected_locations.array()

        organizations: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Organizations.find { count: $lt: doc_count } else Organizations.find({},limit:42)
        selected_organizations: -> selected_organizations.array()

        categories: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Categories.find { count: $lt: doc_count } else Categories.find({},limit:42)
        selected_categories: -> selected_categories.array()

    Template.reddit.events
        'click .new_delta': ->
            Delta.insert {}

        'click .select_person': ->
            current_queries.push @name
            selected_people.push @name
            Meteor.call 'search_reddit', current_queries.array()
        'click .unselect_person': ->
            selected_people.remove @valueOf()
            current_queries.remove @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
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
        'click .unselect_concept': ->
            selected_concepts.remove @valueOf()
            current_queries.remove @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
        'click #clear_concepts': ->
            selected_concepts.clear()


        'click .select_keyword': ->
            current_queries.push @name
            selected_keywords.push @name
            Meteor.call 'search_reddit', current_queries.array()
        'click .unselect_keyword': ->
            selected_keywords.remove @valueOf()
            current_queries.remove @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
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
        'click .unselect_location': ->
            selected_locations.remove @valueOf()
            current_queries.remove @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
        'click #clear_locations': ->
            selected_locations.clear()


        'click .select_company': ->
            current_queries.push @name
            selected_companies.push @name
            Meteor.call 'search_reddit', current_queries.array()
        'click .unselect_company': ->
            selected_companies.remove @valueOf()
            current_queries.remove @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
        'click #clear_companies': ->
            selected_companies.clear()


        'click .select_organization': ->
            current_queries.push @name
            selected_organizations.push @name
            Meteor.call 'search_reddit', current_queries.array()
        'click .unselect_organization': ->
            selected_organizations.remove @valueOf()
            current_queries.remove @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
        'click #clear_organizations': ->
            selected_organizations.clear()


        'click .select_category': ->
            current_queries.push @name
            selected_categories.push @name
            Meteor.call 'search_reddit', current_queries.array()
        'click .unselect_category': ->
            selected_categories.remove @valueOf()
            current_queries.remove @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
        'click #clear_categories': ->
            selected_categories.clear()


    Template.reddit_post.events
        'click .pick_location': ->
            current_queries.push @valueOf()
            selected_locations.push @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
        'click .pick_company': ->
            current_queries.push @valueOf()
            selected_companies.push @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
        'click .pick_person': ->
            current_queries.push @valueOf()
            selected_people.push @valueOf()
            Meteor.call 'search_reddit', current_queries.array()
