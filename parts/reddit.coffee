if Meteor.isClient
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
        people: -> People.find({},limit:20)
        authors: -> Authors.find({},limit:20)
        companies: -> Companies.find({},limit:20)
        subreddits: -> Subreddits.find({},limit:20)
        organizations: -> Organizations.find({},limit:20)
        concepts: -> Concepts.find({},limit:20)
        keywords: -> Keywords.find({},limit:20)
        locations: -> Locations.find({},limit:20)
        reddit_posts: ->
            Docs.find {
                model:'reddit'
            },
                sort: _timestamp: -1
    Template.reddit.events
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
        'click .import_site': ->
            site = $('.site').val()
            Meteor.call 'import_site', site






    Template.reddit.helpers
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

        categories: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Categories.find { count: $lt: doc_count } else Categories.find({},limit:20)
        selected_categories: -> selected_categories.array()

    Template.reddit.events
        'click .select_person': ->
            current_queries.push @name
            selected_people.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_person': ->
            selected_people.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_people': ->
            selected_people.clear()


        'click .select_subreddit': ->
            current_queries.push @name
            selected_subreddits.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_subreddit': ->
            selected_subreddits.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_subreddits': ->
            selected_subreddits.clear()


        'click .select_concept': ->
            current_queries.push @name
            selected_concepts.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_concept': ->
            selected_concepts.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_concepts': ->
            selected_concepts.clear()


        'click .select_keyword': ->
            current_queries.push @name
            selected_keywords.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_keyword': ->
            selected_keywords.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_keywords': ->
            selected_keywords.clear()


        'click .select_author': ->
            current_queries.push @name
            selected_authors.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_author': ->
            selected_authors.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_authors': ->
            selected_authors.clear()


        'click .select_location': ->
            current_queries.push @name
            selected_locations.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_location': ->
            selected_locations.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_locations': ->
            selected_locations.clear()


        'click .select_company': ->
            current_queries.push @name
            selected_companies.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_company': ->
            selected_companies.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_companies': ->
            selected_companies.clear()


        'click .select_organization': ->
            current_queries.push @name
            selected_organizations.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_organization': ->
            selected_organizations.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_organizations': ->
            selected_organizations.clear()


        'click .select_category': ->
            current_queries.push @name
            selected_categories.push @name
            Meteor.call 'search_reddit', current_queries.array()


        'click .unselect_category': ->
            selected_categories.remove @valueOf()
            current_queries.remove @valueOf()
        'click #clear_categories': ->
            selected_categories.clear()
