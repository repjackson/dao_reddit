@selected_tags = new ReactiveArray []

# Accounts.ui.config
#     passwordSignupFields: 'USERNAME_ONLY'

Router.route '/', (->
    @layout 'layout'
    @render 'docs'
    ), name:'docs'


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
    # console.log 'looking for cd', Router.current().params.doc_id
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
