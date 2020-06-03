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
        Session.get('current_query')
        Session.get('dummy')
    @autorun => @subscribe 'reddit_docs',
        selected_tags.array()

Template.home.events
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
    connection: ->
        console.log Meteor.status()
        Meteor.status()
    connected: ->
        Meteor.status().connected
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
            sort:ups:-1
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
Template.doc_item.events
    'click .call_watson': ->
        Meteor.call 'call_watson', @_id, 'url', 'url'
    'click .call_watson_image': ->
        Meteor.call 'call_watson', @_id, 'url', 'image'
    'click .print_me': ->
        console.log @
    'click .goto_article': ->
        console.log @
        Meteor.call 'log_view', @_id, ->
        Router.go "/doc/#{@_id}/view"

Template.doc_item.helpers
    has_thumbnail: ->
        # console.log @thumbnail
        @thumbnail not in ['self','default']
