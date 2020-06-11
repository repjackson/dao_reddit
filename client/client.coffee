@selected_tags = new ReactiveArray []



Template.registerHelper 'youtube_id', () ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
    match = @url.match(regExp)
    if (match && match[2].length == 11)
        # console.log 'match 2', match[2]
        match[2]
    else
        console.log 'error'


Template.registerHelper 'is_image', () ->
    regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
    match = @url.match(regExp)
    # console.log 'image match', match
    if match then true
    # true


Template.registerHelper 'above_50', (input) ->
    # console.log 'input', input
    # console.log @
    # console.log @["#{input}"]
    @["#{input}"] > .49

Template.registerHelper 'parse', (input) ->
    console.log 'input', input

    # parser = new DOMParser()
    # doc = parser.parseFromString(input, 'text/html')
    # console.log 'dom parser', doc, doc.body
    # console.log 'dom parser', doc.body

    # // Otherwise, fallback to old-school method
    dom = document.createElement('textarea')
    # dom.innerHTML = doc.body
    dom.innerHTML = input
    console.log 'innner html', dom
    return dom.value


Template.registerHelper 'is_twitter', () ->
    @domain is 'twitter.com'
Template.registerHelper 'is_streamable', () ->
    @domain is 'streamable.com'
Template.registerHelper 'is_youtube', () ->
    @domain in ['youtube.com', 'youtu.be']


Template.registerHelper 'lowered_title', ()->
    @title.toLowerCase()

Template.registerHelper 'lowered', (input)->
    input.toLowerCase()

Template.registerHelper 'omega_doc', ()->
    Docs.findOne
        model:'omega_session'


Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value

Template.registerHelper 'key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    @["#{key}"] is value


Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')



Template.registerHelper 'calculated_size', (metric) ->
    console.log 'metric', metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    console.log 'whole', whole

    if whole is 2 then 'f2'
    else if whole is 3 then 'f3'
    else if whole is 4 then 'f4'
    else if whole is 5 then 'f5'
    else if whole is 6 then 'f6'
    else if whole is 7 then 'f7'
    else if whole is 8 then 'f8'
    else if whole is 9 then 'f9'
    else if whole is 10 then 'f10'

Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)




Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'fixed', (number)->
    # console.log number
    (number*100).toFixed()
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()

Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'publish_when', ()-> moment(@watson.metadata.publication_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
