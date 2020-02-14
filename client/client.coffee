@selected_tags = new ReactiveArray []

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

Template.registerHelper 'is', (one,two)->
    # console.log 'one', one
    # console.log 'two', two
    one is two

Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment



Template.body.events
    'keydown':(e,t)->
        # console.log e.keyCode
        if e.keyCode is 27
            # console.log 'hi'
            Session.set('current_query', null)
            $('#search').val('')
            $('#search').blur()


Template.home.onCreated ->

    # @autorun => @subscribe 'docs',
    @autorun => @subscribe 'results', selected_tags.array(), Session.get('current_query')
    @autorun => @subscribe 'docs',
        selected_tags.array()
        Session.get('doc_limit')
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('only_videos')
    # @autorun => @subscribe 'emotion_averages',
    #     Session.get('match')

    Session.setDefault 'only_videos', false
    Session.setDefault 'doc_limit', 10
    Session.setDefault 'sort_label', 'added'
    Session.setDefault 'sort_key', '_timestamp'
    Session.setDefault 'view_detail', true
    Session.setDefault 'view_tone', true
    Session.setDefault 'sort_direction', -1
    # Session.setDefault 'match', {}


Template.home.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.nav.dropdown').dropdown()
    # , 2300

Template.home.events
    'click .select_query': -> queries.push @title
    'click .unselect_tag': ->
        selected_tags.remove @valueOf()

        # console.log selected_tags.array()
        if selected_tags.array().length > 0
            Meteor.call 'search_reddit', selected_tags.array(), ->
        # console.log Session.get('match')

    'click .clear_selected_tags': ->
        Session.set('current_query',null)
        selected_tags.clear()

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

    'focus .ui.search': ->
        Session.set('searching', true)
    'blur .ui.search': ->
        current_query = $('#search').val()
        Session.set('current_query', current_query)
        unless Session.get('current_query')
            Session.set('searching', false)

    'click .result': ->
        # console.log @
        selected_tags.push @title
        $('#search').val('')
        Session.set('current_query', null)
        Session.set('searching', false)
        Meteor.call 'search_reddit', selected_tags.array(), ->


    'click .toggle_video': ->
        Session.set('only_videos', !Session.get('only_videos'))

    # 'click .toggle_theme': ->
    #     Session.set('invert_mode', !Session.get('invert_mode'))
    'click .set_sort_direction': ->
        if Session.equals('sort_direction', -1)
            Session.set('sort_direction', 1)
        else
            Session.set('sort_direction', -1)
        console.log Session.get('sort_direction')
    # 'click .toggle_detail': ->
    #     if Session.equals('view_detail', false)
    #         Session.set('view_detail', true)
    #     else
    #         Session.set('view_detail', false)
    'click .toggle_tone': ->
        if Session.equals('view_tone', false)
            Session.set('view_tone', true)
        else
            Session.set('view_tone', false)
    'click .print_this': ->
        console.log @
    # 'click .call_reddit_post': ->
    #     console.log @
    #     Meteor.call 'get_reddit_post', @doc_id, @reddit_id, ->
    # 'click .import_subreddit': ->
    #     subreddit = $('.subreddit').val()
    #     Meteor.call 'pull_subreddit', subreddit
    # 'keyup .subreddit': (e,t)->
    #     if e.which is 13
    #         subreddit = $('.subreddit').val()
    #         Meteor.call 'pull_subreddit', subreddit

    'keyup .ui.search': _.throttle((e,t)->
        query = $('#search').val()
        Session.set('current_query', query)
        console.log Session.get('current_query')
        if e.which is 13
            search = $('#search').val()
            selected_tags.push search
            Meteor.call 'search_reddit', selected_tags.array(), ->
            $('#search').val('').blur()
            # $( "p" ).blur();
            # Meteor.setTimeout ->
            #     Session.set('sort_up', !Session.get('sort_up'))
            # , 4000
    , 1000)
    # 'click .import_site': ->
    #     site = $('.site').val()
    #     Meteor.call 'import_site', site



Template.home.helpers
    tags: ->
        Tags.find()
    selected_tags: ->
        # console.log selected_tags.array()
        selected_tags.array()

    searching: -> Session.get('searching')

    subs_ready: -> Template.instance().subscriptionsReady()
    toggle_video_class: -> if Session.equals('only_videos') then 'active' else ''
    toggle_tone_class: -> if Session.get('show_tone') then 'active' else 'basic'
    show_tone: -> Session.get('show_tone')

    invert_class: ->
        if Session.get('invert_mode')
            'inverted'
        else
            ''
    view_detail: -> Session.get('view_detail')
    current_sort_key: -> Session.get('sort_key')
    current_sort_label: -> Session.get('sort_label')
    current_doc_limit: -> Session.get('doc_limit')
    current_tag_limit: -> Session.get('tag_limit')
    # emotion_average_doc: ->
    #     Results.findOne
    #         key:'emotion_average'
    sorting_up: -> Session.equals('sort_direction', -1)
    posts: ->
        Docs.find {
            # model:'reddit'
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
