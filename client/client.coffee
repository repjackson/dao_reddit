@selected_tags = new ReactiveArray []

Template.home.onCreated ->
    @autorun => @subscribe 'reddit_tags',
        selected_tags.array()
        Session.get('current_query')
        Session.get('dummy')
    @autorun => @subscribe 'reddit_docs',
        selected_tags.array()

Template.home.events
    'click .pick_dao': (e,t)->
        selected_tags.push 'dao'
    'click .result': (e,t)->
        # console.log @
        # if selected_tags.array().length is 1
        #     Meteor.call 'call_wiki', search, ->
        Meteor.call 'log_term', @title, ->
        selected_tags.push @title
        $('#search').val('')
        Meteor.call 'call_wiki', @title, ->
        Session.set('current_query', null)
        Session.set('searching', false)
        Meteor.call 'search_reddit', selected_tags.array(), ->
        Meteor.setTimeout ->
            Session.set('dummy', !Session.get('dummy'))
        , 7000
    'click .select_query': -> queries.push @title
    'click .unselect_tag': ->
        selected_tags.remove @valueOf()
        # console.log selected_tags.array()
        # if selected_tags.array().length is 1
        #     Meteor.call 'call_wiki', search, ->

        if selected_tags.array().length > 0
            Meteor.call 'search_reddit', selected_tags.array(), ->
                Session.set('dummy', !Session.get('dummy'))

    # 'click .refresh_tags': ->

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
                , 7000
    , 1000)


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
        # if Template.instance().subscriptionsReady()
        #     ''
        # else
        #     'disabled'

    selected_tags: -> selected_tags.array()
    selected_tags_plural: -> selected_tags.array().length > 1
    searching: -> Session.get('searching')

    one_post: ->
        Docs.find().count() is 1
    docs: ->
        # if selected_tags.array().length > 0
        cursor =
            Docs.find {
                # model:'reddit'
            },
                sort:ups:-1
                limit:10
        # console.log cursor.fetch()
        cursor


    home_subs_ready: ->
        Template.instance().subscriptionsReady()

    home_subs_ready: ->
        if Template.instance().subscriptionsReady()
            Session.set('global_subs_ready', true)
        else
            Session.set('global_subs_ready', false)

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
        # Router.go "/doc/#{@_id}/view"

Template.doc_item.helpers
    has_thumbnail: ->
        # console.log @thumbnail
        @thumbnail not in ['self','default']



Template.registerHelper 'youtube_id', () ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
    match = @url.match(regExp)
    if (match && match[2].length == 11)
        console.log 'match 2', match[2]
        match[2]
    else
        console.log 'error'



Template.registerHelper 'is_streamable', () ->
    @domain is 'streamable.com'
Template.registerHelper 'is_youtube', () ->
    @domain is 'youtube.com'


Template.registerHelper 'lowered_title', () ->
    @title.toLowerCase()


Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value


Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')




Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)




Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()

Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
