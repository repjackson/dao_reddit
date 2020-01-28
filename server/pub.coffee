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
    selected_categories
    selected_health_conditions
    selected_keywords
    selected_concepts
    selected_locations
    selected_facilities
    selected_movies
    selected_print_medias
    selected_sports
    selected_authors
    selected_timestamp_tags
    tag_limit
    doc_limit
    view_nsfw
    sort_key
    sort_up
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
        if selected_organizations.length > 0 then match.Organization = $all: selected_organizations
        if selected_people.length > 0 then match.Person = $all: selected_people
        if selected_subreddits.length > 0 then match.subreddit = $all: selected_subreddits
        if selected_companies.length > 0 then match.Company = $all: selected_companies
        if selected_concepts.length > 0 then match.watson_concepts = $all: selected_concepts
        if selected_keywords.length > 0 then match.watson_keywords = $all: selected_keywords
        if selected_categories.length > 0 then match.categories = $all: selected_categories
        if selected_health_conditions.length > 0 then match.HealthCondition = $all: selected_health_conditions
        if selected_print_medias.length > 0 then match.PrintMedia = $all: selected_print_medias
        if selected_facilities.length > 0 then match.Facility = $all: selected_facilities
        if selected_movies.length > 0 then match.Movie = $all: selected_movies
        if selected_locations.length > 0 then match.Location = $all: selected_locations
        if selected_sports.length > 0 then match.Sport = $all: selected_sports
        if selected_authors.length > 0 then match.author = $all: selected_authors

        # if selected_author_ids.length > 0
        #     match.author_id = $in: selected_author_ids
        #     match.published = 1
        if selected_timestamp_tags.length > 0 then match.timestamp_tags = $all: selected_timestamp_tags

        if tag_limit then tag_limit=tag_limit else tag_limit=20
        if doc_limit then doc_limit=doc_limit else doc_limit=5
        # if author_id then match.author_id = author_id

        # 5749 arapahoe suite 2b
        # 130pm

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
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'theme_tag_cloud, ',_tag_cloud
        tag_cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        #

        category_cloud = Docs.aggregate [
            { $match: match }
            { $project: categories: 1 }
            { $unwind: "$categories" }
            { $group: _id: '$categories', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        category_cloud.forEach (category, i) ->
            self.added 'categories', Random.id(),
                name: category.name
                count: category.count
                index: i

        health_condition_cloud = Docs.aggregate [
            { $match: match }
            { $project: HealthCondition: 1 }
            { $unwind: "$HealthCondition" }
            { $group: _id: '$HealthCondition', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        health_condition_cloud.forEach (health_condition, i) ->
            self.added 'health_conditions', Random.id(),
                name: health_condition.name
                count: health_condition.count
                index: i

        keyword_cloud = Docs.aggregate [
            { $match: match }
            { $project: watson_keywords: 1 }
            { $unwind: "$watson_keywords" }
            { $group: _id: '$watson_keywords', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        keyword_cloud.forEach (keyword, i) ->
            self.added 'keywords', Random.id(),
                name: keyword.name
                count: keyword.count
                index: i

        facility_cloud = Docs.aggregate [
            { $match: match }
            { $project: Facility: 1 }
            { $unwind: "$Facility" }
            { $group: _id: '$Facility', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        facility_cloud.forEach (facility, i) ->
            self.added 'facilities', Random.id(),
                name: facility.name
                count: facility.count
                index: i

        movie_cloud = Docs.aggregate [
            { $match: match }
            { $project: Movie: 1 }
            { $unwind: "$Movie" }
            { $group: _id: '$Movie', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        movie_cloud.forEach (movie, i) ->
            self.added 'movies', Random.id(),
                name: movie.name
                count: movie.count
                index: i

        sport_cloud = Docs.aggregate [
            { $match: match }
            { $project: Sport: 1 }
            { $unwind: "$Sport" }
            { $group: _id: '$Sport', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        sport_cloud.forEach (sport, i) ->
            self.added 'sports', Random.id(),
                name: sport.name
                count: sport.count
                index: i

        subreddit_cloud = Docs.aggregate [
            { $match: match }
            { $project: subreddit: 1 }
            # { $unwind: "$subreddit" }
            { $group: _id: '$subreddit', count: $sum: 1 }
            { $match: _id: $nin: selected_subreddits }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        subreddit_cloud.forEach (subreddit, i) ->
            # console.log subreddit
            self.added 'subreddits', Random.id(),
                name: subreddit.name
                count: subreddit.count
                index: i

        concept_cloud = Docs.aggregate [
            { $match: match }
            { $project: watson_concepts: 1 }
            { $unwind: "$watson_concepts" }
            { $group: _id: '$watson_concepts', count: $sum: 1 }
            { $match: _id: $nin: selected_concepts }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        concept_cloud.forEach (concept, i) ->
            self.added 'concepts', Random.id(),
                name: concept.name
                count: concept.count
                index: i

        # location_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: Location: 1 }
        #     { $unwind: "$Location" }
        #     { $group: _id: '$Location', count: $sum: 1 }
        #     { $match: _id: $nin: selected_locations }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: tag_limit }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'cloud, ', cloud
        # location_cloud.forEach (location, i) ->
        #     self.added 'locations', Random.id(),
        #         name: location.name
        #         count: location.count
        #         index: i

        timestamp_tags_cloud = Docs.aggregate [
            { $match: match }
            { $project: _timestamp_tags: 1 }
            { $unwind: "$_timestamp_tags" }
            { $group: _id: '$_timestamp_tags', count: $sum: 1 }
            { $match: _id: $nin: selected_timestamp_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
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
            # console.log 'person:', person
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


        print_media_cloud = Docs.aggregate [
            { $match: match }
            { $project: PrintMedia: 1 }
            { $unwind: "$PrintMedia" }
            { $group: _id: '$PrintMedia', count: $sum: 1 }
            { $match: _id: $nin: selected_print_medias }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'print_media_cloud, ', print_media_cloud
        print_media_cloud.forEach (print_media, i) ->
            self.added 'print_medias', Random.id(),
                name: print_media.name
                count: print_media.count
                index: i


        company_cloud = Docs.aggregate [
            { $match: match }
            { $project: Company: 1 }
            { $unwind: "$Company" }
            { $group: _id: '$Company', count: $sum: 1 }
            { $match: _id: $nin: selected_companies }
            { $sort: count: -1, _id: 1 }
            { $limit: tag_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'company_cloud, ', company_cloud
        company_cloud.forEach (company, i) ->
            self.added 'companies', Random.id(),
                name: company.name
                count: company.count
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
            { $project: author: 1 }
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
        console.log sort_up
        if sort_up
            sort_direction = 1
        else sort_direction = -1
        subHandle = Docs.find(match, {limit:int_doc_limit, sort: {"#{sort_key}":sort_direction}}).observeChanges(
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
