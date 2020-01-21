Meteor.methods
    search_reddit: (query)->
        console.log 'searching reddit', query
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)->
            # console.log response.data
            if response.data.data.dist > 1
                console.log 'found data'
                _.each(response.data.data.children, (item)=>
                    console.log item
                    data = item.data
                    len = 200
                    reddit_post =
                        reddit_id: data.id
                        url: data.url
                        domain: data.domain
                        # comment_count: data.num_comments
                        permalink: data.permalink
                        title: data.title
                        root: query
                        # selftext: false
                        # thumbnail: false
                        tags:[query, data.title.toLowerCase()]
                        # tags:[query, data.domain.toLowerCase(), data.author.toLowerCase(), data.title.toLowerCase()]
                        model:'reddit'
                    # console.log reddit_post
                    image_check = /(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)/
                    image_result = image_check.test data.url
                    # if image_result
                    #     if Meteor.isDevelopment
                    #         console.log 'skipping image'
                    if data.domain in ['youtu.be','youtube.com', 'i.redd.it','i.imgur.com']
                        if Meteor.isDevelopment
                            console.log 'skipping youtube and imgur'
                    else
                        # # console.log reddit_post
                        existing_doc = Docs.findOne url:data.url
                        if existing_doc
                            if Meteor.isDevelopment
                                console.log 'skipping existing url', data.url
                                # console.log 'existing doc', existing_doc
                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                        unless existing_doc
                            # console.log 'importing url', data.url
                            new_reddit_post_id = Docs.insert reddit_post
                            # console.log 'calling watson on ', reddit_post.title
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                                # console.log 'get post res', res
                )
            else
                console.log 'NO found data'

        _.each(response.data.data.children, (item)->
            # data = item.data
            # len = 200
            console.log item.data
        )


    get_reddit_post: (doc_id, reddit_id, root)->
        # console.log 'getting reddit post'
        HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
            if err then console.error err
            else
                rd = res.data.data.children[0].data
                if rd.selftext
                    unless rd.is_video
                        # if Meteor.isDevelopment
                        #     console.log "self text", rd.selftext
                        Docs.update doc_id, {
                            $set: body: rd.selftext
                        }, ->
                        #     Meteor.call 'pull_site', doc_id, url
                            # console.log 'hi'
                if rd.selftext_html
                    unless rd.is_video
                        Docs.update doc_id, {
                            $set: html: rd.selftext_html
                        }, ->
                        #     Meteor.call 'pull_site', doc_id, url
                            # console.log 'hi'
                if rd.url
                    unless rd.is_video
                        url = rd.url
                        # if Meteor.isDevelopment
                        #     console.log "found url", url
                        Docs.update doc_id, {
                            $set:
                                reddit_url: url
                                url: url
                        }, ->
                            Meteor.call 'call_watson', doc_id, 'url', 'url', ->

                update_ob = {}

                Docs.update doc_id,
                    $set:
                        # rd: rd
                        thumbnail: rd.thumbnail
                        subreddit: rd.subreddit
                        author: rd.author
                        is_video: rd.is_video
                        ups: rd.ups
                        downs: rd.downs
                        over_18: rd.over_18
                    # $addToSet:
                    #     tags: $each: [rd.subreddit.toLowerCase(), rd.author.toLowerCase()]
                console.log Docs.findOne(doc_id)




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
    selected_keywords
    selected_concepts
    selected_locations
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
        if selected_organizations.length > 0 then match.Organization = $all: selected_organizations
        if selected_people.length > 0 then match.Person = $all: selected_people
        if selected_subreddits.length > 0 then match.subreddit = $all: selected_subreddits
        if selected_companies.length > 0 then match.Company = $all: selected_companies
        if selected_concepts.length > 0 then match.watson_concepts = $all: selected_concepts
        if selected_keywords.length > 0 then match.watson_keywords = $all: selected_keywords
        if selected_categories.length > 0 then match.categories = $all: selected_categories
        if selected_locations.length > 0 then match.Location = $all: selected_locations

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


        # author_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: author: 1 }
        #     { $unwind: "$author" }
        #     { $group: _id: '$author', count: $sum: 1 }
        #     { $match: _id: $nin: selected_authors }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: tag_limit }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'author_cloud', author_cloud
        # author_cloud.forEach (author, i) ->
        #     self.added 'authors', Random.id(),
        #         name: author.name
        #         count: author.count
        #         index: i


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
        subHandle = Docs.find(match, {limit:5, sort: {_timestamp:-1,ups:-1}}).observeChanges(
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
