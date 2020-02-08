@selected_tags = new ReactiveArray []

@selected_filters = new ReactiveArray []

# @selected_facets = new ReactiveArray ['categories', 'subreddits']
@current_queries = new ReactiveArray []



Template.home.onCreated ->
    @autorun => @subscribe 'docs',
        Session.get('match')
        Session.get('doc_limit')
        # Session.get('view_nsfw')
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('only_videos')
    @autorun => @subscribe 'emotion_averages',
        Session.get('match')

    @autorun => @subscribe 'ideas',
        current_queries.array()

    Session.setDefault 'only_videos', false
    Session.setDefault 'doc_limit', 5
    Session.setDefault 'sort_label', 'added'
    Session.setDefault 'sort_key', '_timestamp'
    Session.setDefault 'view_detail', true
    Session.setDefault 'view_tone', true
    Session.setDefault 'sort_direction', -1
    Session.setDefault 'match', {}


Template.home.onRendered ->
    Meteor.setTimeout ->
        $('.ui.nav.dropdown').dropdown()
    , 2300
    # Meteor.setTimeout ->
    #     categoryContent =
    #         Results.find({},{sort:count:1}).fetch()
    #     $('.ui.search')
    #         .search({
    #             # apiSettings: {
    #             #   url: 'http://www.reddit.com/search/?q={query}'
    #             # },
    #             type: 'category'
    #             hideDelay: 0
    #             selectFirstResult: false
    #             source: categoryContent
    #             minCharacters: 2
    #             maxResults: 10
    #             onSelect: (result, response)->
    #                 console.log result
    #                 # console.log response
    #                 match = Session.get('match')
    #                 category_array = match["#{result.category}"]
    #                 if category_array
    #                     if result.title in category_array
    #                         category_array = _.without(category_array, result.title)
    #                         match["#{result.category}"] = category_array
    #                         current_queries.remove result.title
    #                         Session.set('match', match)
    #                     else
    #                         category_array.push result.title
    #                         current_queries.push result.title
    #                         Session.set('match', match)
    #                         # Meteor.call 'agg_idea', result.title, result.category, 'entity', ->
    #                         # Meteor.call 'search_reddit', current_queries.array(), ->
    #                         # match["#{result.category}"] = ["#{result.title}"]
    #                 else
    #                     match["#{result.category}"] = ["#{result.title}"]
    #                     # Meteor.call 'agg_idea', result.title, result.key, 'entity', ->
    #                     current_queries.push result.title
    #                     # console.log current_queries.array()
    #                 Session.set('match', match)
    #                 console.log current_queries.array()
    #                 if current_queries.array().length > 0
    #                     Meteor.call 'search_reddit', current_queries.array(), ->
    #         })
    # , 2300

Template.home.events
    'click .ui.search': ->
        # categoryContent =
        #     Results.find({},{sort:count:1}).fetch()
        # $('.ui.search')
        #     .search({
        #         # apiSettings: {
        #         #   url: 'http://www.reddit.com/search/?q={query}'
        #         # },
        #         type: 'category'
        #         hideDelay: 0
        #         selectFirstResult: false
        #         source: categoryContent
        #         minCharacters: 2
        #         maxResults: 10
        #         onSelect: (result, response)->
        #             console.log result
        #             # console.log response
        #             match = Session.get('match')
        #             category_array = match["#{result.category}"]
        #             if category_array
        #                 if result.title in category_array
        #                     category_array = _.without(category_array, result.title)
        #                     match["#{result.category}"] = category_array
        #                     current_queries.remove result.title
        #                     Session.set('match', match)
        #                 else
        #                     category_array.push result.title
        #                     current_queries.push result.title
        #                     Session.set('match', match)
        #                     # Meteor.call 'agg_idea', result.title, result.category, 'entity', ->
        #                     # Meteor.call 'search_reddit', current_queries.array(), ->
        #                     # match["#{result.category}"] = ["#{result.title}"]
        #             else
        #                 match["#{result.category}"] = ["#{result.title}"]
        #                 # Meteor.call 'agg_idea', result.title, result.key, 'entity', ->
        #                 current_queries.push result.title
        #                 # console.log current_queries.array()
        #             Session.set('match', match)
        #             console.log current_queries.array()
        #             if current_queries.array().length > 0
        #                 Meteor.call 'search_reddit', current_queries.array(), ->
        #     })


    'click .clear_match': ->
        $('.clear_match').transition('pulse')
        Session.set('match', {})
        current_queries.clear()
    'click .print_match': ->
        console.log Session.get('match')
    'click .toggle_video': ->
        Session.set('only_videos', !Session.get('only_videos'))

    'click .toggle_theme': ->
        Session.set('invert_mode', !Session.get('invert_mode'))
    'click .set_sort_direction': ->
        if Session.equals('sort_direction', -1)
            Session.set('sort_direction', 1)
        else
            Session.set('sort_direction', -1)
        console.log Session.get('sort_direction')
    'click .toggle_detail': ->
        if Session.equals('view_detail', false)
            Session.set('view_detail', true)
        else
            Session.set('view_detail', false)
    'click .toggle_tone': ->
        if Session.equals('view_tone', false)
            Session.set('view_tone', true)
        else
            Session.set('view_tone', false)
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
        query = $('#search').val()
        Session.set('current_query', query)
        categoryContent =
            Results.find({},{sort:count:1}).fetch()
        $('.ui.search')
            .search({
                # apiSettings: {
                #   url: 'http://www.reddit.com/search/?q={query}'
                # },
                type: 'category'
                hideDelay: 0
                selectFirstResult: false
                source: categoryContent
                minCharacters: 2
                maxResults: 10
                onSelect: (result, response)->
                    console.log result
                    # console.log response
                    match = Session.get('match')
                    category_array = match["#{result.category}"]
                    if category_array
                        if result.title in category_array
                            category_array = _.without(category_array, result.title)
                            match["#{result.category}"] = category_array
                            current_queries.remove result.title
                            Session.set('match', match)
                        else
                            category_array.push result.title
                            current_queries.push result.title
                            Session.set('match', match)
                            # Meteor.call 'agg_idea', result.title, result.category, 'entity', ->
                            # Meteor.call 'search_reddit', current_queries.array(), ->
                            # match["#{result.category}"] = ["#{result.title}"]
                    else
                        match["#{result.category}"] = ["#{result.title}"]
                        # Meteor.call 'agg_idea', result.title, result.key, 'entity', ->
                        current_queries.push result.title
                        # console.log current_queries.array()
                    Session.set('match', match)
                    console.log current_queries.array()
                    if current_queries.array().length > 0
                        Meteor.call 'search_reddit', current_queries.array(), ->
            })

        if e.which is 13
            search = $('#search').val()

            current_queries.push search
            selected_tags.push search


            Meteor.call 'search_reddit', current_queries.array(), ->

            match = Session.get('match')
            # tags_array = match["#{@key}"]
            tags_array = match.tags
            if tags_array
                tags_array.push search
            else
                tags_array = [search]
            match.tags = tags_array

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
    settings: ->
      {
        position: 'bottom'
        limit: 10
        rules: [
          {
            # token: '@'
            collection: Results
            field: 'title'
            template: Template.result
          }
        ]
      }

    ideas: ->
        Results.find(
            model:'idea'
        )
    subs_ready: ->
        Template.instance().subscriptionsReady()
    toggle_video_class: ->
        if Session.equals('only_videos') then 'active' else ''
    toggle_tone_class: ->
        if Session.get('show_tone') then 'active' else 'basic'
    show_tone: -> Session.get('show_tone')

    invert_class: ->
        if Session.get('invert_mode')
            'inverted'
        else
            ''
    match: -> Session.get('match')
    view_detail: -> Session.get('view_detail')
    current_sort_key: -> Session.get('sort_key')
    current_sort_label: -> Session.get('sort_label')
    current_doc_limit: -> Session.get('doc_limit')
    current_tag_limit: -> Session.get('tag_limit')
    visible_facets: ->
        console.log selected_facets.array()
        selected_facets.array()
    emotion_average_doc: ->
        Results.findOne
            key:'emotion_average'
    sorting_up: -> Session.equals('sort_direction', -1)
    posts: ->
        Docs.find {
            model:'reddit'
        },
            sort: "#{Session.get('sort_key')}": Session.get('sort_direction')

    toggle_video: -> Session.set('only_videos', !Session.get('only_videos'))


Template.set_limit.events
    'click .set_limit': ->
        # console.log @
        Session.set('doc_limit', @amount)

Template.set_sort_key.events
    'click .set_sort': ->
        # console.log @
        Session.set('sort_key', @key)
        Session.set('sort_label', @label)


Template.tag_cloud.helpers
    selected_tags: -> selected_tags.array()
    current_queries: ->
        current_queries.array()


Template.tag_cloud.events
    'click .select_query': -> current_queries.push @title
    'click .unselect_query': ->
        current_queries.remove @valueOf()

        match = Session.get('match')
        # key_array = match["#{@key}"]
        # if key_array
        #     if @name in key_array
        #         key_array = _.without(key_array, @name)
        #         match["#{@key}"] = key_array
        #         current_queries.remove @name
        #         Session.set('match', match)
        #         Meteor.call 'search_reddit', current_queries.array(), ->
            # else
            #     key_array.push @name
            #     current_queries.push @name
            #     Session.set('match', match)
                # match["#{@key}"] = ["#{@name}"]
        # else
        #     match["#{@key}"] = ["#{@name}"]
        #     current_queries.push @name
            # console.log current_queries.array()
        Session.set('match', match)
        # console.log current_queries.array()
        if current_queries.array().length > 0
            Meteor.call 'search_reddit', current_queries.array(), ->
        # console.log Session.get('match')




    'click #clear_queries': -> current_queries.clear()

    # 'keyup #search': (e,t)->
    #     e.preventDefault()
    #     val = $('#search').val().toLowerCase().trim()
    #     switch e.which
    #         when 13 #enter
    #             switch val
    #                 when 'clear'
    #                     selected_tags.clear()
    #
    #                     $('#search').val ''
    #                 else
    #                     unless val.length is 0
    #                         selected_tags.push val.toString()
    #                         $('#search').val ''
    #         when 8
    #             if val.length is 0
    #                 selected_tags.pop()

    'autocompleteselect #search': (event, template, doc)->
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
        # console.log @
        # console.log parent
        # console.log current
        Meteor.call 'call_watson', parent._id, 'key', @mode, ->




Template.facet.onCreated ->
    @view_facet = new ReactiveVar false
    # @autorun => Meteor.subscribe 'results'
    @autorun => @subscribe(
        'facet_results'
        Template.currentData().key
        Session.get('match')
        Session.get('current_query')
        Session.get('doc_limit')
        # Session.get('view_nsfw')
        Session.get('sort_key')
        Session.get('sort_direction')
    )

Template.facet.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.dropdown')
    #       .dropdown()
    # , 2000



Template.facet.events
    'click .toggle_facet': (e,t)-> t.view_facet.set !t.view_facet.get()
    'click .toggle_filter': ->
        # console.log @
        match = Session.get('match')
        key_array = match["#{@key}"]
        if key_array
            if @name in key_array
                key_array = _.without(key_array, @name)
                match["#{@key}"] = key_array
                current_queries.remove @name
                Session.set('match', match)
            else
                key_array.push @name
                current_queries.push @name
                Session.set('match', match)
                # Meteor.call 'agg_idea', @name, @key, 'entity', ->
                # Meteor.call 'search_reddit', current_queries.array(), ->
                # match["#{@key}"] = ["#{@name}"]
        else
            match["#{@key}"] = ["#{@name}"]
            # Meteor.call 'agg_idea', @name, @key, 'entity', ->
            current_queries.push @name
            # console.log current_queries.array()
        Session.set('match', match)
        console.log current_queries.array()
        if current_queries.array().length > 0
            Meteor.call 'search_reddit', current_queries.array(), ->
        # console.log Session.get('match')

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
        Results.find(
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


Template.idea_segment.events
    'click .calc_emotion': ->
        Meteor.call 'agg_idea', @name, @key, 'entity'
