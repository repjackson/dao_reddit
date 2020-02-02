Meteor.publish 'docs', (
    prematch
    doc_limit=5
    sort_key='_timestamp'
    sort_direction=-1
    only_videos
    )->
    # console.log 'pre match', prematch
    # console.log selected_tags
    # console.log filter
    self = @
    match = {}
    if only_videos
        match.is_video = true
    # if selected_tags.length > 0 then match.tags = $all: selected_tags
    # if filter then match.model = filter
    keys = _.keys(prematch)
    for key in keys
        key_array = prematch["#{key}"]
        if key_array and key_array.length > 0
            match["#{key}"] = $all: key_array
        # console.log 'current facet filter array', current_facet_filter_array

    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:"#{sort_key}":sort_direction
        limit: doc_limit

Meteor.publish 'facet_results', (
    key
    prematch
    doc_limit=5
    sort_key='_timestamp'
    sort_direction=-1
)->
    # console.log 'key', key
    # console.log 'match', prematch
    self = @
    # current_facet_filter_array = _.where(prematch, {key:key})
    # current_facet_filter_array = prematch["#{key}"]
    # console.log 'current facet filter array', current_facet_filter_array

    match = {}
    # if current_facet_filter_array and current_facet_filter_array.length > 0
    #     match["#{key}"] = $all: current_facet_filter_array
    keys = _.keys(prematch)
    # console.log 'facet keys', key, keys
    for match_key in keys
        key_array = prematch["#{match_key}"]
        if key_array and key_array.length > 0
            match["#{match_key}"] = $all: key_array

    # match.tags = $all: selected_tags
    # match.model = 'reddit'
    # if parent_id then match.parent_id = parent_id

    filters = []
    result_array = []

    # console.log key, 'facet match:', match
    result_cloud = Docs.aggregate [
        { $match: match }
        { $project: "#{key}": 1 }
        { $unwind: "$#{key}" }
        { $group: _id: "$#{key}", count: $sum: 1 }
        { $match: _id: $nin: filters }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    result_cloud.forEach (result, i) =>
        # console.log 'result ', result
        # console.log 'key', key
        self.added 'results', Random.id(),
            name: result.name
            count: result.count
            key:key
            # index: i

    self.ready()


    # self.onStop ()-> subHandle.stop()



Meteor.publish 'emotion_averages', (prematch)->
    match = {}
    # if current_facet_filter_array and current_facet_filter_array.length > 0
    #     match["#{key}"] = $all: current_facet_filter_array
    self = @


    keys = _.keys(prematch)
    # console.log 'facet keys', key, keys
    for match_key in keys
        key_array = prematch["#{match_key}"]
        if key_array and key_array.length > 0
            match["#{match_key}"] = $all: key_array


    emotion_averages = Docs.aggregate [
        { $match: match }
        # { $project: "sadness_percent": 1 }
        { $group:
            _id: null
            sentiment_average: $avg: "$doc_sentiment_score"
            sadness_average: $avg: "$sadness_percent"
            joy_average: $avg: "$joy_percent"
            disgust_average: $avg: "$disgust_percent"
            fear_average: $avg: "$fear_percent"
            anger_average: $avg: "$anger_percent"
        }
        # { $project: _id: 0, name: 'sadness_average', sadness_average: 1 }
        # { $project: _id: 0, name: 'joy_average', joy_average: 1 }
        # { $project: _id: 0, name: 'disgust_average', disgust_average: 1 }
        # { $project: _id: 0, name: 'fear_average', fear_average: 1 }
        # { $project: _id: 0, name: 'anger_average', anger_average: 1 }
        ]
    emotion_averages.forEach (result)=>
        console.log 'avg', result
        self.added 'results', Random.id(),
            sentiment_average: result.sentiment_average
            sadness_average: result.sadness_average
            joy_average: result.joy_average
            disgust_average: result.disgust_average
            fear_average: result.fear_average
            anger_average: result.anger_average
            key:'emotion_average'


        #
    self.ready()



# Meteor.publish 'reddit_facets', (
#     selected_tags
#     tag_limit
#     doc_limit
#     view_nsfw
#     sort_key
#     sort_up
#     # sort_object
#     )->
#
#         self = @
#         match = {}
#
#         # match.tags = $all: selected_tags
#         match.model = 'reddit'
#         # if parent_id then match.parent_id = parent_id
#
#         # if view_private is true
#         #     match.author_id = Meteor.userId()
#
#         # if view_private is false
#         #     match.published = $in: [0,1]
#
#         if selected_tags.length > 0 then match.tags = $all: selected_tags
#         if selected_organizations.length > 0 then match.Organization = $all: selected_organizations
#         if selected_timestamp_tags.length > 0 then match.timestamp_tags = $all: selected_timestamp_tags
#
#         if tag_limit then tag_limit=tag_limit else tag_limit=20
#         if doc_limit then doc_limit=doc_limit else doc_limit=5
#         # if author_id then match.author_id = author_id
#
#         # 5749 arapahoe suite 2b
#         # 130pm
#
#         # if view_private is true then match.author_id = @userId
#         # if view_resonates?
#         #     if view_resonates is true then match.favoriters = $in: [@userId]
#         #     else if view_resonates is false then match.favoriters = $nin: [@userId]
#         # if view_read?
#         #     if view_read is true then match.read_by = $in: [@userId]
#         #     else if view_read is false then match.read_by = $nin: [@userId]
#         # if view_published is true
#         #     match.published = $in: [1,0]
#         # else if view_published is false
#         #     match.published = -1
#         #     match.author_id = Meteor.userId()
#
#         # if view_bookmarked?
#         #     if view_bookmarked is true then match.bookmarked_ids = $in: [@userId]
#         #     else if view_bookmarked is false then match.bookmarked_ids = $nin: [@userId]
#         # if view_complete? then match.complete = view_complete
#         # console.log view_complete
#
#
#
#         # match.site = Meteor.settings.public.site
#
#         console.log 'match:', match
#         # if view_images? then match.components?.image = view_images
#
#         # lightbank models
#         # if view_lightbank_type? then match.lightbank_type = view_lightbank_type
#         # match.lightbank_type = $ne:'journal_prompt'
#
#
#         # found_docs = Docs.find(match).fetch()
#         # found_docs.forEach (found_doc) ->
#         #     self.added 'docs', doc._id, fields
#         #         text: author_id.text
#         #         count: author_id.count
#
#         # doc_results = []
#         int_doc_limit = parseInt doc_limit
#         console.log sort_up
#         if sort_up
#             sort_direction = 1
#         else sort_direction = -1
#         subHandle = Docs.find(match, {limit:int_doc_limit, sort: {"#{sort_key}":sort_direction}}).observeChanges(
#             added: (id, fields) ->
#                 # console.log 'added doc', id, fields
#                 # doc_results.push id
#                 self.added 'docs', id, fields
#             changed: (id, fields) ->
#                 # console.log 'changed doc', id, fields
#                 self.changed 'docs', id, fields
#             removed: (id) ->
#                 # console.log 'removed doc', id, fields
#                 # doc_results.pull id
#                 self.removed 'docs', id
#         )
#
#         # for doc_result in doc_results
#
#         # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
#         #     added: (id, fields) ->
#         #         # console.log 'added doc', id, fields
#         #         self.added 'docs', id, fields
#         #     changed: (id, fields) ->
#         #         # console.log 'changed doc', id, fields
#         #         self.changed 'docs', id, fields
#         #     removed: (id) ->
#         #         # console.log 'removed doc', id, fields
#         #         self.removed 'docs', id
#         # )
#
#
#         # console.log 'doc handle count', subHandle
#
#         self.ready()
#
#         self.onStop ()-> subHandle.stop()
