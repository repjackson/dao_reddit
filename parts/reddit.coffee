if Meteor.isClient
    # Router.route '/reddit', (->
    #     @layout 'layout'
    #     @render 'reddit'
    #     ), name:'reddit'

    Template.reddit.onCreated ->
        # @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'model_docs', 'global_stats'
        # @autorun -> Meteor.subscribe 'reddit_posts', selected_tags.array(), 'reddit', 10
        Session.setDefault 'limit', 5
        Session.setDefault 'sort_by', 'timestamp'
        Session.setDefault 'sort_direction', -1

    Template.reddit.helpers
        people: -> People.find()
        companies: -> Companies.find()
        organizations: -> Organizations.find()
        concepts: -> Concepts.find()
        keywords: -> Keywords.find()
        reddit_posts: ->
            Docs.find {
                model:'reddit'
            },
                sort: _timestamp: -1
    Template.reddit.events
        'click .import_subreddit': ->
            subreddit = $('.subreddit').val()
            Meteor.call 'pull_subreddit', subreddit
        'keyup .subreddit': (e,t)->
            if e.which is 13
                subreddit = $('.subreddit').val()
                Meteor.call 'pull_subreddit', subreddit
        'keyup #search': (e,t)->
            if e.which is 13
                search = $('#search').val()
                Meteor.call 'search_reddit', search
        'click .import_site': ->
            site = $('.site').val()
            Meteor.call 'import_site', site


if Meteor.isServer
    Meteor.publish 'reddit_posts', (selected_tags, filter, limit)->
        # user = Meteor.users.findOne @userId
        # console.log selected_tags
        # console.log filter
        self = @
        match = {}
        # if Meteor.user()
        #     unless Meteor.user().roles and 'dev' in Meteor.user().roles
        #         match.view_roles = $in:Meteor.user().roles
        # else
        #     match.view_roles = $in:['public']

        # if filter is 'shop'
        #     match.active = true
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # if filter then match.model = filter
        match.model = 'reddit'
        Docs.find match,
            sort:_timestamp:-1
            limit: limit



    Meteor.publish 'reddit_facets', (
        selected_tags
        selected_organizations
        selected_people
        selected_subreddits
        selected_companies
        selected_authors
        # selected_author_ids=[]
        selected_timestamp_tags
        # model
        # author_id
        # parent_id
        tag_limit
        doc_limit
        view_nsfw
        sort_key
        sort_direction
        # sort_object
        )->

            self = @
            match = {}

            # match.tags = $all: selected_tags
            match.model = 'reddit'
            # if parent_id then match.parent_id = parent_id

            # if view_private is true
            #     match.author_id = Meteor.userId()

            # if view_private is false
            #     match.published = $in: [0,1]

            if selected_tags.length > 0 then match.tags = $all: selected_tags
            if selected_organizations.length > 0 then match.selected_organizations = $all: selected_organizations
            if selected_people.length > 0 then match.selected_people = $all: selected_people
            if selected_subreddits.length > 0 then match.selected_subreddits = $all: selected_subreddits
            if selected_companies.length > 0 then match.selected_companies = $all: selected_companies
            if selected_authors.length > 0 then match.selected_authors = $all: selected_authors

            # if selected_author_ids.length > 0
            #     match.author_id = $in: selected_author_ids
            #     match.published = 1
            if selected_timestamp_tags.length > 0 then match.timestamp_tags = $all: selected_timestamp_tags

            if tag_limit then tag_limit=tag_limit else tag_limit=20
            if doc_limit then doc_limit=doc_limit else doc_limit=5
            # if author_id then match.author_id = author_id

            # if view_private is true then match.author_id = @userId
            # if view_resonates?
            #     if view_resonates is true then match.favoriters = $in: [@userId]
            #     else if view_resonates is false then match.favoriters = $nin: [@userId]
            # if view_read?
            #     if view_read is true then match.read_by = $in: [@userId]
            #     else if view_read is false then match.read_by = $nin: [@userId]
            # if view_published is true
            #     match.published = $in: [1,0]
            # else if view_published is false
            #     match.published = -1
            #     match.author_id = Meteor.userId()

            # if view_bookmarked?
            #     if view_bookmarked is true then match.bookmarked_ids = $in: [@userId]
            #     else if view_bookmarked is false then match.bookmarked_ids = $nin: [@userId]
            # if view_complete? then match.complete = view_complete
            # console.log view_complete



            # match.site = Meteor.settings.public.site

            console.log 'match:', match
            # if view_images? then match.components?.image = view_images

            # lightbank models
            # if view_lightbank_type? then match.lightbank_type = view_lightbank_type
            # match.lightbank_type = $ne:'journal_prompt'

            # ancestor_ids_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: ancestor_array: 1 }
            #     { $unwind: "$ancestor_array" }
            #     { $group: _id: '$ancestor_array', count: $sum: 1 }
            #     { $match: _id: $nin: selected_ancestor_ids }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: tag_limit }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'theme ancestor_ids_cloud, ', ancestor_ids_cloud
            # ancestor_ids_cloud.forEach (ancestor_id, i) ->
            #     self.added 'ancestor_ids', Random.id(),
            #         name: ancestor_id.name
            #         count: ancestor_id.count
            #         index: i

            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: '$tags', count: $sum: 1 }
                { $match: _id: $nin: selected_tags }
                { $sort: count: -1, _id: 1 }
                { $limit: tag_limit }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme_tag_cloud, ',_tag_cloud
            tag_cloud.forEach (tag, i) ->
                self.added 'tags', Random.id(),
                    name: tag.name
                    count: tag.count
                    index: i

            #
            #
            # watson_keyword_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: watson_keywords: 1 }
            #     { $unwind: "$watson_keywords" }
            #     { $group: _id: '$watson_keywords', count: $sum: 1 }
            #     { $match: _id: $nin: selected_tags }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: tag_limit }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'cloud, ', cloud
            # watson_keyword_cloud.forEach (keyword, i) ->
            #     self.added 'watson_keywords', Random.id(),
            #         name: keyword.name
            #         count: keyword.count
            #         index: i

            timestamp_tags_cloud = Docs.aggregate [
                { $match: match }
                { $project: _timestamp_tags: 1 }
                { $unwind: "$_timestamp_tags" }
                { $group: _id: '$_timestamp_tags', count: $sum: 1 }
                { $match: _id: $nin: selected_timestamp_tags }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'timestamp_tags_cloud', timestamp_tags_cloud
            timestamp_tags_cloud.forEach (timestamp_tag, i) ->
                self.added 'timestamp_tags', Random.id(),
                    name: timestamp_tag.name
                    count: timestamp_tag.count
                    index: i


            people_cloud = Docs.aggregate [
                { $match: match }
                { $project: Person: 1 }
                { $unwind: "$Person" }
                { $group: _id: '$Person', count: $sum: 1 }
                { $match: _id: $nin: selected_people }
                { $sort: count: -1, _id: 1 }
                { $limit: tag_limit }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'people_cloud', people_cloud.toArray()
            people_cloud.forEach (person, i) ->
                console.log 'person:', person
                self.added 'people', Random.id(),
                    name: person.name
                    count: person.count
                    index: i


            organization_cloud = Docs.aggregate [
                { $match: match }
                { $project: Organization: 1 }
                { $unwind: "$Organization" }
                { $group: _id: '$Organization', count: $sum: 1 }
                { $match: _id: $nin: selected_organizations }
                { $sort: count: -1, _id: 1 }
                { $limit: tag_limit }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'organization_cloud, ', organization_cloud
            organization_cloud.forEach (organization, i) ->
                self.added 'organizations', Random.id(),
                    name: organization.name
                    count: organization.count
                    index: i


            location_cloud = Docs.aggregate [
                { $match: match }
                { $project: Location: 1 }
                { $unwind: "$Location" }
                { $group: _id: '$Location', count: $sum: 1 }
                { $match: _id: $nin: selected_organizations }
                { $sort: count: -1, _id: 1 }
                { $limit: tag_limit }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'location_cloud, ', location_cloud
            location_cloud.forEach (location, i) ->
                self.added 'locations', Random.id(),
                    name: location.name
                    count: location.count
                    index: i


            author_cloud = Docs.aggregate [
                { $match: match }
                { $project: authors: 1 }
                { $unwind: "$author" }
                { $group: _id: '$author', count: $sum: 1 }
                { $match: _id: $nin: selected_authors }
                { $sort: count: -1, _id: 1 }
                { $limit: tag_limit }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'author_cloud', author_cloud
            author_cloud.forEach (author, i) ->
                self.added 'authors', Random.id(),
                    name: author.name
                    count: author.count
                    index: i


            # author_match = match
            # author_match.published = 1
            #
            # author_tag_cloud = Docs.aggregate [
            #     { $match: author_match }
            #     { $project: _author_id: 1 }
            #     { $group: _id: '$_author_id', count: $sum: 1 }
            #     { $match: _id: $nin: selected_author_ids }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: tag_limit }
            #     { $project: _id: 0, text: '$_id', count: 1 }
            #     ]
            #
            #
            # # console.log author_tag_cloud
            #
            # # author_objects = []
            # # Meteor.users.find _id: $in: author_tag_cloud.
            #
            # author_tag_cloud.forEach (author_id) ->
            #     self.added 'author_ids', Random.id(),
            #         text: author_id.text
            #         count: author_id.count

            # found_docs = Docs.find(match).fetch()
            # found_docs.forEach (found_doc) ->
            #     self.added 'docs', doc._id, fields
            #         text: author_id.text
            #         count: author_id.count

            # doc_results = []
            int_doc_limit = parseInt doc_limit
            subHandle = Docs.find(match, {limit:5, sort: timestamp:-1}).observeChanges(
                added: (id, fields) ->
                    # console.log 'added doc', id, fields
                    # doc_results.push id
                    self.added 'docs', id, fields
                changed: (id, fields) ->
                    # console.log 'changed doc', id, fields
                    self.changed 'docs', id, fields
                removed: (id) ->
                    # console.log 'removed doc', id, fields
                    # doc_results.pull id
                    self.removed 'docs', id
            )

            # for doc_result in doc_results

            # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
            #     added: (id, fields) ->
            #         # console.log 'added doc', id, fields
            #         self.added 'docs', id, fields
            #     changed: (id, fields) ->
            #         # console.log 'changed doc', id, fields
            #         self.changed 'docs', id, fields
            #     removed: (id) ->
            #         # console.log 'removed doc', id, fields
            #         self.removed 'docs', id
            # )



            # console.log 'doc handle count', subHandle

            self.ready()

            self.onStop ()-> subHandle.stop()
