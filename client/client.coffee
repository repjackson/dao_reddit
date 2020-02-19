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


Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment


Template.home.onCreated ->
    @autorun => @subscribe 'results', selected_tags.array(), Session.get('current_query')
    @autorun => @subscribe 'docs',
        selected_tags.array()

Template.body.events
    'keydown':(e,t)->
        console.log e.keyCode
        # console.log e.keyCode
        if e.keyCode is 27
            console.log 'hi'
            # console.log 'hi'
            Session.set('current_query', null)
            selected_tags.clear()
            $('#search').val('')
            $('#search').blur()

Template.home.events
    'click .result': ->
        # console.log @
        selected_tags.push @title
        $('#search').val('')
        Session.set('current_query', null)
        Session.set('searching', false)
        Meteor.call 'search_reddit', selected_tags.array(), ->
    'click .select_query': -> queries.push @title
    'click .unselect_tag': ->
        selected_tags.remove @valueOf()
        # console.log selected_tags.array()
        if selected_tags.array().length > 0
            Meteor.call 'search_reddit', selected_tags.array(), ->

    'click .clear_selected_tags': ->
        Session.set('current_query',null)
        selected_tags.clear()

    'keyup #search': _.throttle((e,t)->
        query = $('#search').val()
        Session.set('current_query', query)
        # console.log Session.get('current_query')
        if e.which is 13
            search = $('#search').val().trim().toLowerCase()
            selected_tags.push search
            # console.log 'search', search
            Meteor.call 'search_reddit', selected_tags.array(), ->
            $('#search').val('')
            Session.set('current_query', null)
            # $('#search').val('').blur()
            # $( "p" ).blur();
            # Meteor.setTimeout ->
            #     Session.set('sort_up', !Session.get('sort_up'))
            # , 4000
        else if e.which is 8
            search = $('#search').val()
            if search.length is 0
                last_val = selected_tags.array().slice(-1)
                console.log last_val
                $('#search').val(last_val)
                selected_tags.pop()
                Meteor.call 'search_reddit', selected_tags.array(), ->
    , 1000)


Template.home.helpers
    tags: ->
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

    searching: -> Session.get('searching')

    subs_ready: -> Template.instance().subscriptionsReady()
    posts: ->
        Docs.find {
            # model:'reddit'
        },
            sort: "#{Session.get('sort_key')}": Session.get('sort_direction')
