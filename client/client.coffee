@selected_tags = new ReactiveArray []

# Accounts.ui.config
#     passwordSignupFields: 'USERNAME_ONLY'

Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'


Template.registerHelper 'calculated_size', (metric) ->
    # console.log metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
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



Template.registerHelper 'cd', () ->
    console.log 'looking for cd', Router.current().params.doc_id
    # Meteor.users.findOne username:Router.current().params.username
    Docs.findOne Router.current().params.doc_id



Template.registerHelper 'current_user', () ->
    # Meteor.users.findOne username:Router.current().params.username
    Meteor.users.findOne Router.current().params.user_id
Template.registerHelper 'is_current_user', () ->
    if Meteor.user()
        # if Meteor.user().username is Router.current().params.username
        if Meteor.userId() is Router.current().params.user_id
            true
    else
        if Meteor.user().roles and 'dev' in Meteor.user().roles
            true
        else
            false



Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'to_percent', (number)-> (number*100).toFixed()
# Template.registerHelper 'long_time', (input)-> moment(input).format("h:mm a")
# Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
# Template.registerHelper 'short_date', (input)-> moment(input).format("dddd, MMMM Do")
# Template.registerHelper 'med_date', (input)-> moment(input).format("MMM D 'YY")
# Template.registerHelper 'medium_date', (input)-> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input)-> moment(input).format("dddd, MMMM Do YYYY")
# Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
# Template.registerHelper 'int', (input)-> input.toFixed(0)
Template.registerHelper 'when', ()-> moment(@_timestamp).fromNow()
# Template.registerHelper 'from_now', (input)-> moment(input).fromNow()
# Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

# Template.registerHelper 'current_month', ()-> moment(Date.now()).format("MMMM")
# Template.registerHelper 'current_day', ()-> moment(Date.now()).format("DD")


Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment

Template.registerHelper 'is_eric', ()-> if Meteor.userId() and Meteor.userId() in ['K77p8B9jpXbTz6nfD'] then true else false
Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()


Template.home.onCreated ->
    @autorun => @subscribe 'results',
        selected_tags.array(),
        Session.get('current_query'),
        Session.get('dummy')
        Session.get('view_images')
        Session.get('view_videos')
        Session.get('view_articles')
    @autorun => @subscribe 'docs',
        selected_tags.array()

Template.home.onCreated ->
    Session.setDefault 'view_images', true
    Session.setDefault 'view_videos', true
    Session.setDefault 'view_articles', true
    Session.setDefault 'view_tweets', true
Template.body.events
    'keydown':(e,t)->
        # console.log e.keyCode
        # console.log e.keyCode
        if e.keyCode is 27
            console.log 'hi'
            # console.log 'hi'
            Session.set('current_query', null)
            selected_tags.clear()
            $('#search').val('')
            $('#search').blur()

Template.home.events
    # 'click .toggle_dark': ->
    #     Meteor.users.update Meteor.userId(),
    #         $set: dark_mode: !Meteor.user().dark_mode
    # 'click .toggle_menu': ->
    #     Session.set('view_menu', !Session.get('view_menu'))
    'click .toggle_images': -> Session.set('view_images', !Session.get('view_images'))
    'click .toggle_videos': -> Session.set('view_videos', !Session.get('view_videos'))
    'click .toggle_articles': -> Session.set('view_articles', !Session.get('view_articles'))


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
    view_images_class: -> if Session.get('view_images') then 'white' else 'grey'
    view_videos_class: -> if Session.get('view_videos') then 'white' else 'grey'
    view_articles_class: -> if Session.get('view_articles') then 'white' else 'grey'
    view_tweets_class: -> if Session.get('view_tweets') then 'white' else 'grey'
    subs_ready: -> Template.instance().subscriptionsReady()
    connection: ->
        console.log Meteor.status()
        Meteor.status()
    connected: ->
        Meteor.status().connected
    invert_class: ->
        if Meteor.user()
            if Meteor.user().dark_mode
                'invert'
    view_menu: -> Session.get('view_menu')
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
    posts: ->
        # if selected_tags.array().length > 0
        Docs.find {
            # model:'reddit'
        },
            sort: ups:-1
            # limit:1
