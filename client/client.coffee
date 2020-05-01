@selected_tags = new ReactiveArray []


Template.body.events
    'click a': ->
        $('.global_container')
        .transition('fade out', 250)
        .transition('fade in', 250)


    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1



Template.registerHelper 'can_edit', () ->
    if Meteor.user().roles
        if 'admin' in Meteor.user().roles
            true
        else
            @_author_id is Meteor.userId()
    else
        @_author_id is Meteor.userId()


Template.registerHelper 'session_key_value_is', (skey, value) ->
    console.log 'skey', skey
    console.log 'value', value
    Session.equals key,value

Template.registerHelper 'fixed', (input) ->
    if input
        input.toFixed(2)




Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')


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


Template.registerHelper 'in_role', (role)->
    if Meteor.user() and Meteor.user().roles
        if role in Meteor.user().roles
            true
        else
            false
    else
        false

Template.registerHelper 'page_doc', () ->
    page_doc = Docs.findOne Router.current().params.doc_id


Template.registerHelper 'field_value', () ->
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

Template.registerHelper 'product', () ->
    Docs.findOne @product_id


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


Template.registerHelper 'field_type_doc', ->
    doc =
        Docs.findOne
            model:'field_type'
            _id: @field_type_id
    # if doc
    #     console.log 'found field_type doc', doc
    # else
    #     console.log 'NO found field_type doc'
    if doc
        doc

Template.registerHelper 'active_path', ->
    false

Template.registerHelper 'view_template', ->
    # console.log 'view template this', @
    field_type_doc =
        Docs.findOne
            model:'field_type'
            _id: @field_type_id
    # console.log 'field type doc', field_type_doc
    "#{field_type_doc.slug}_view"


Template.registerHelper 'edit_template', ->
    field_type_doc =
        Docs.findOne
            model:'field_type'
            _id: @field_type_id

    # console.log 'field type doc', field_type_doc
    "#{field_type_doc.slug}_edit"


Template.registerHelper 'is_an_admin', ()->
    if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c'] then true else false
