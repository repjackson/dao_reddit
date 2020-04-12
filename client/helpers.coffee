Template.registerHelper 'can_edit', () ->
    if Meteor.user().roles
        if 'admin' in Meteor.user().roles
            true
        else
            @_author_id is Meteor.userId()
    else
        @_author_id is Meteor.userId()

Template.registerHelper 'active_path', (metric) ->
    false
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

Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')

Template.registerHelper 'youtube_id', () ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
    match = @url.match(regExp)
    if (match && match[2].length == 11)
        console.log 'match 2', match[2]
        match[2]
    else
        console.log 'error'





Template.registerHelper 'delta_key_value_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    delta = Docs.findOne model:'delta'
    delta["#{key}"] is value

Template.registerHelper 'key_value_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    @["#{key}"] is value

Template.registerHelper 'key_value_isnt', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    @["#{key}"] isnt value



Template.registerHelper 'is_streamable', () ->
    @domain is 'streamable.com'
Template.registerHelper 'is_youtube', () ->
    @domain is 'youtube.com'
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

Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5
        if parent5._id
            parent = Template.parentData(5)
    else if parent6
        if parent6._id
            parent = Template.parentData(6)
    if parent
        parent["#{@key}"]


Template.registerHelper 'sorted_field_values', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5._id
        parent = Template.parentData(5)
    else if parent6._id
        parent = Template.parentData(6)
    if parent
        _.sortBy parent["#{@key}"], 'number'


Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)




Template.registerHelper 'is_admin', () ->
    # Meteor.users.findOne username:Router.current().params.username
    if Meteor.user() and Meteor.user().roles
        if 'admin' in Meteor.user().roles then true else false



Template.registerHelper 'current_doc', () ->
    # console.log 'looking for cd', Router.current().params.doc_id
    # Meteor.users.findOne username:Router.current().params.username
    Docs.findOne Router.current().params.doc_id

Template.registerHelper 'members', () ->
    # Meteor.users.findOne username:Router.current().params.username
    if @member_ids
        Meteor.users.find
            _id:$in:@member_ids



Template.registerHelper 'current_user', () ->
    # Meteor.users.findOne username:Router.current().params.username
    Meteor.users.findOne Router.current().params.user_id
Template.registerHelper 'is_current_user', () ->
    if Meteor.user()
        # if Meteor.user().username is Router.current().params.username
        if Meteor.user().username is Router.current().params.username
            true
    else
        if Meteor.user().roles and 'dev' in Meteor.user().roles
            true
        else
            false


Template.registerHelper 'upvote_class', () ->
    if Meteor.userId()
        if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else 'outline'
    else ''
Template.registerHelper 'downvote_class', () ->
    if Meteor.userId()
        if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else 'outline'
    else ''

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")


Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'

Template.registerHelper 'hsd', () ->
    Docs.findOne
        model:'home_stats'


Template.registerHelper 'session_is', (key, value)->
    Session.equals(key, value)

Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()
Template.registerHelper 'long_time', (input)-> moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'short_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input)-> moment(input).format("MMM D 'YY")
Template.registerHelper 'medium_date', (input)-> moment(input).format("MMMM Do YYYY")
Template.registerHelper 'medium_date', (input)-> moment(input).format("dddd, MMMM Do YYYY")
Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'int', (input)-> input.toFixed(0)
Template.registerHelper 'when', ()-> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input)-> moment(input).fromNow()
Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

Template.registerHelper 'current_month', ()-> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', ()-> moment(Date.now()).format("DD")


Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment

Template.registerHelper 'is_eric', ()-> if Meteor.userId() and Meteor.userId() in ['K77p8B9jpXbTz6nfD'] then true else false
Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()



Template.registerHelper 'view_template', -> "#{@field_type}_view"
Template.registerHelper 'edit_template', -> "#{@field_type}_edit"

Template.registerHelper 'current_model', ->
    Docs.findOne
        model:'model'
        slug: Router.current().params.model_slug



Template.registerHelper 'sortable_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            sortable:true
        }, sort:rank:1




Template.registerHelper 'fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        match = {}
        # if Meteor.user()
        #     match.view_roles = $in:Meteor.user().roles
        match.model = 'field'
        match.parent_id = model._id
        # console.log model
        cur = Docs.find match,
            sort:rank:1
        # console.log cur.fetch()
        cur

Template.registerHelper 'edit_fields', () ->
    console.log 'finding edit fields'
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            # edit_roles:$in:Meteor.user().roles
        }, sort:rank:1


Template.registerHelper 'is_an_admin', ()->
    if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c'] then true else false
