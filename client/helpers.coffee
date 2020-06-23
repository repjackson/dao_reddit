
Template.registerHelper 'emotion_selector_class', () ->
    # console.log @
    if @title is 'anger'
        'red invert'
    else if @title is 'sadness'
        'blue invert'
    else if @title is 'joy'
        'green invert'
    else if @title is 'disgust'
        'orange invert'
    else if @title is 'fear'
        'grey invert'
Template.registerHelper 'sentence_class', () ->
    # console.log @
    if @tones.length
        for tone in @tones
            if tone.tone_id is 'sadness'
                'blue invert'
            else if tone.tone_id is 'joy'
                'green invert'
            else if tone.tone_id is 'anger'
                'red invert'
            else if tone.tone_id is 'analytical'
                'yellow invert'
            else if tone.tone_id is 'tentative'
                'olive invert'
            else if tone.tone_id is 'tentative'
                'olive invert'
            else
                'grey invert'
    else
        'grey invert'

Template.registerHelper 'emotion_color_class', () ->
    # console.log @
    # if @watson.setn
    # 'red'
    if @max_emotion_name
        switch @max_emotion_name
            when 'joy'
                # console.log 'joy'
                'green invert'
            when 'anger'
                # console.log 'anger'
                'red invert'
            when 'sadness'
                # console.log 'sadness'
                'blue invert'
            when 'disgust'
                # console.log 'disgust'
                'orange invert'
            when 'fear'
                # console.log 'fear'
                'grey invert'
    else if @doc_sentiment_label
        if @doc_sentiment_label is 'positive'
            'green invert'
        else
            'red invert'

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
Template.registerHelper 'is_gifv', () ->
    regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:gifv).*/
    match = @url.match(regExp)
    # console.log 'gifv match', match
    if match then true
    # true
Template.registerHelper 'gif_filename', () ->
    @url.slice(0,-1)
    # true

Template.registerHelper 'current_doc', () ->
    Docs.findOne Router.current().params.doc_id

Template.registerHelper 'is_image_domain', () ->
    # console.log 'image match', match
    if @domain
        console.log 'hi domain', @domain
        if @domain in ['i.imgur.com']
            console.log 'hi domain TRUE', @domain
            true
    # true

Template.registerHelper 'is_video', () ->
    if @domain
        if @domain in ['v.redd.it']
            true
    # true


Template.registerHelper 'above_50', (input) ->
    # console.log 'input', input
    # console.log @
    # console.log @["#{input}"]
    @["#{input}"] > .49

Template.registerHelper 'has_thumbnail', (input) ->
    # console.log @thumbnail
    @thumbnail and @thumbnail not in ['self','default']

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
    # console.log 'metric', metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log 'whole', whole

    if whole is 2 then 'f7'
    else if whole is 3 then 'f8'
    else if whole is 4 then 'f9'
    else if whole is 5 then 'f10'
    else if whole is 6 then 'f11'
    else if whole is 7 then 'f12'
    else if whole is 8 then 'f13'
    else if whole is 9 then 'f14'
    else if whole is 10 then 'f15'

Template.registerHelper 'tone_size', () ->
    # console.log 'this weight', @weight
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    # whole = parseInt(@["#{metric}"]*10)
    # console.log 'whole', whole
    if @weight
        if @weight is -5 then 'f6'
        else if @weight is -4 then 'f7'
        else if @weight is -3 then 'f8'
        else if @weight is -2 then 'f9'
        else if @weight is -1 then 'f10'
        else if @weight is 0 then 'f12'
        else if @weight is 1 then 'f12'
        else if @weight is 2 then 'f13'
        else if @weight is 3 then 'f14'
        else if @weight is 4 then 'f15'
        else if @weight is 5 then 'f16'
    else
        'f11'

Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)




Template.registerHelper 'is_loading', -> Session.get 'is_loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'fixed', (number)->
    # console.log number
    (number*100).toFixed()
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()

Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'publish_when', ()->
    if @watson
        if @watson.metadata
            if @watson.metadata.publication_date
                moment(@watson.metadata.publication_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
