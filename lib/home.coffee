@Terms = new Meteor.Collection 'terms'
# @Subreddits = new Meteor.Collection 'subreddits'
@Timestamp_tags = new Meteor.Collection 'timestamp_tags'

# @Redditor_leaders = new Meteor.Collection 'redditor_leaders'

if Meteor.isClient
    @selected_subreddits = new ReactiveArray []
    @selected_timestamp_tags = new ReactiveArray []
    Template.registerHelper 'calc_size', (metric) ->
        # console.log metric
        # console.log typeof parseFloat(@relevance)
        # console.log typeof (@relevance*100).toFixed()
        whole = parseInt(metric)
        # console.log whole

        if whole is 2 then 'f2'
        else if whole is 3 then 'f3'
        else if whole is 4 then 'f4'
        else if whole is 5 then 'f5'
        else if whole is 6 then 'f6'
        else if whole is 7 then 'f7'
        else if whole is 8 then 'f8'
        else if whole is 9 then 'f9'
        else if whole is 10 then 'f10'



    # Router.route '/reddit', (->
    #     @layout 'layout'
    #     @render 'reddit'
    #     ), name:'reddit'

    Template.home.onCreated ->
        Session.setDefault 'view_images', true
        Session.setDefault 'view_videos', true
        Session.setDefault 'view_articles', true
        Session.setDefault 'view_tweets', true
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'doc_sort_key', 'ups'
        Session.setDefault 'doc_sort_label', 'upvotes'
        Session.setDefault 'doc_limit', 5

    # Template.body.events
    #     'keydown':(e,t)->
    #         # console.log e.keyCode
    #         # console.log e.keyCode
    #         if e.keyCode is 27
    #             console.log 'hi'
    #             # console.log 'hi'
    #             Session.set('current_query', null)
    #             selected_tags.clear()
    #             $('#search').val('')
    #             $('#search').blur()
    #
    Template.home.onCreated ->
        @autorun => @subscribe 'reddit_tags',
            selected_tags.array()
            selected_authors.array()
            selected_subreddits.array()
            selected_timestamp_tags.array()
            Session.get('current_query')
            Session.get('dummy')
            Session.get('doc_limit')
            Session.get('doc_sort_key')
            Session.get('doc_sort_direction')
            Session.get('view_images')
            Session.get('view_videos')
            Session.get('view_articles')
        @autorun => @subscribe 'reddit_docs',
            selected_tags.array()
            Session.get('view_images')
            Session.get('view_videos')
            Session.get('view_articles')
            Session.get('doc_limit')
            Session.get('doc_sort_key')
            Session.get('doc_sort_direction')

        # @autorun => @subscribe 'all_redditors'



    Template.home.events
        # 'click .toggle_dark': ->
        #     Meteor.users.update Meteor.userId(),
        #         $set: dark_mode: !Meteor.user().dark_mode
        # 'click .toggle_menu': ->
        #     Session.set('view_menu', !Session.get('view_menu'))
        # 'click .calc_leaderboard': ->
        #     # console.log @
        #     # console.log selected_tags.array()
        #     Meteor.call 'calc_leaders', selected_tags.array(), (err,res)->
        #         console.log res
        #
        # 'click .toggle_images': -> Session.set('view_images', !Session.get('view_images'))
        # 'click .toggle_videos': -> Session.set('view_videos', !Session.get('view_videos'))
        # 'click .toggle_articles': -> Session.set('view_articles', !Session.get('view_articles'))

        'click .result': (event,template)->
            # console.log @
            if selected_tags.array().length is 1
                Meteor.call 'call_wiki', search, ->
            Meteor.call 'log_term', @title, ->
            selected_tags.push @title
            $('#search').val('')
            Meteor.call 'call_wiki', @title, ->
            Session.set('current_query', null)
            Session.set('searching', false)
            Meteor.call 'search_reddit', selected_tags.array(), ->
            Meteor.setTimeout ->
                Session.set('dummy', !Session.get('dummy'))
            , 10000
        'click .select_query': -> queries.push @title
        'click .unselect_tag': ->
            selected_tags.remove @valueOf()
            # console.log selected_tags.array()
            if selected_tags.array().length is 1
                Meteor.call 'call_wiki', search, ->

            if selected_tags.array().length > 0
                Meteor.call 'search_reddit', selected_tags.array(), ->

        'click .refresh_tags': ->
            Session.set('dummy', !Session.get('dummy'))

        'click .clear_selected_tags': ->
            Session.set('current_query',null)
            selected_tags.clear()

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    selected_tags.push search
                    console.log 'search', search
                    Meteor.call 'call_wiki', search, ->
                    Meteor.call 'search_reddit', selected_tags.array(), ->
                    Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    Meteor.setTimeout ->
                        Session.set('dummy', !Session.get('dummy'))
                    , 10000
        , 1000)

        'click .calc_doc_count': ->
            Meteor.call 'calc_doc_count', ->


        'click .calc_post': ->
            console.log @
            # Meteor.call 'get_reddit_post', (@_id)->


        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = selected_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             selected_tags.pop()
        #             Meteor.call 'search_reddit', selected_tags.array(), ->
        # , 1000)

        'click .reconnect': ->
            Meteor.reconnect()



    Template.home.helpers
        sorting_up: ->
            parseInt(Session.get('doc_sort_direction')) is 1

        connection: ->
            console.log Meteor.status()
            Meteor.status()
        connected: ->
            Meteor.status().connected
        invert_class: ->
            if Meteor.user()
                if Meteor.user().dark_mode
                    'invert'
        tags: ->
            if Session.get('current_query') and Session.get('current_query').length > 1
                Terms.find({}, sort:count:-1)
            else
                doc_count = Docs.find().count()
                # console.log 'doc count', doc_count
                if doc_count < 3
                    Tags.find({count: $lt: doc_count})
                else
                    Tags.find()

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        selected_tags: -> selected_tags.array()
        selected_tags_plural: -> selected_tags.array().length > 1
        searching: -> Session.get('searching')

        one_post: ->
            Docs.find().count() is 1
        docs: ->
            # if selected_tags.array().length > 0
            Docs.find {
                model:'reddit'
            },
                sort: "#{Session.get('doc_sort_key')}":parseInt(Session.get('doc_sort_direction'))
                limit:3

        home_subs_ready: ->
            Template.instance().subscriptionsReady()

        home_subs_ready: ->
            if Template.instance().subscriptionsReady()
                Session.set('global_subs_ready', true)
            else
                Session.set('global_subs_ready', false)

        doc_limit: ->
            Session.get('doc_limit')

        current_doc_sort_label: ->
            Session.get('doc_sort_label')


        result_cloud: ->
            console.log @


if Meteor.isServer
    Meteor.publish 'reddit_tags', (
        selected_tags
        selected_authors
        selected_subreddits
        selected_timestamp_tags
        query
        dummy
        view_images
        view_videos
        view_articles
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        console.log 'selected tags', selected_tags

        self = @
        match = {}
        match.model = 'reddit'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false
        # if selected_tags.length > 0 then match.tags = $all: selected_tags
            # match.$regex:"#{current_query}", $options: 'i'}
        if query and query.length > 1
        #     console.log 'searching query', query
        #     # match.tags = {$regex:"#{query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        #
            Terms.find {
                title: {$regex:"#{query}", $options: 'i'}
            },
                sort:
                    count: -1
                limit: 20
            # tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: "tags": 1 }
            #     { $unwind: "$tags" }
            #     { $group: _id: "$tags", count: $sum: 1 }
            #     { $match: _id: $nin: selected_tags }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        else
            # unless query and query.length > 2
            if selected_tags.length > 0 then match.tags = $all: selected_tags
            # match.tags = $all: selected_tags
            # console.log 'match for tags', match
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: "tags": 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                { $match: _id: $nin: selected_tags }
                # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }

            tag_cloud.forEach (tag, i) =>
                # console.log 'queried tag ', tag
                # console.log 'key', key
                self.added 'tags', Random.id(),
                    title: tag.name
                    count: tag.count
                    # category:key
                    # index: i

            # console.log doc_tag_cloud.count()

            self.ready()

    Meteor.publish 'reddit_docs', (
        selected_tags
        view_images
        view_videos
        view_articles
        )->
        # console.log selected_tags
        self = @
        match = {}
        if selected_tags.length > 0
            match.tags = $all: selected_tags
            sort = 'ups'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false

        # match.tags = $all: selected_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        console.log 'reddit match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort}":-1
            # sort:_timestamp:-1
            limit: 10
