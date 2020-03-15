if Meteor.isClient
    Router.route '/doc/:doc_id/view', (->
        @layout 'layout'
        @render 'doc_page'
        ), name:'doc_page'



    Template.doc_page.onCreated ->
        # @autorun => Meteor.subscribe('doc', Router.current().params.doc_id)
        # Meteor.subscribe 'doc', Router.current().params.doc_id
        Meteor.subscribe 'current_doc', Router.current().params.doc_id
        Meteor.subscribe 'users'
        console.log @
    Template.doc_page.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000

    Template.doc_page.events
        'click .call_watson': ->
            Meteor.call 'call_watson', @_id, 'url', 'url'
        'click .call_watson_image': ->
            Meteor.call 'call_watson', @_id, 'url', 'image'
        'click .print_me': ->
            console.log @
        'click .pull_tone': ->
            Meteor.call 'call_tone', @_id, 'url', 'text', ->


    Template.array_view.events
        'click .toggle_post_filter': ->
            console.log @
            value = @valueOf()
            console.log Template.currentData()
            current = Template.currentData()
            console.log Template.parentData()
            # match = Session.get('match')
            # key_array = match["#{current.key}"]
            # if key_array
            #     if value in key_array
            #         key_array = _.without(key_array, value)
            #         match["#{current.key}"] = key_array
            #         selected_tags.remove value
            #         Session.set('match', match)
            #     else
            #         key_array.push value
            #         selected_tags.push value
            #         Session.set('match', match)
            #         Meteor.call 'search_reddit', selected_tags.array(), ->
            #         # Meteor.call 'agg_idea', value, current.key, 'entity', ->
            #         console.log @
            #         # match["#{current.key}"] = ["#{value}"]
            # else
            if value in selected_tags.array()
                selected_tags.remove value
            else
                # match["#{current.key}"] = ["#{value}"]
                selected_tags.push value
                # console.log selected_tags.array()
            # Session.set('match', match)
            # console.log selected_tags.array()
            if selected_tags.array().length > 0
                Meteor.call 'search_reddit', selected_tags.array(), ->
            # console.log Session.get('match')

    Template.array_view.helpers
        values: ->
            # console.log @key
            Template.parentData()["#{@key}"]

        post_label_class: ->
            match = Session.get('match')
            key = Template.parentData().key
            doc = Template.parentData(2)
            # console.log key
            # console.log doc
            # console.log @
            if @valueOf() in selected_tags.array()
                'active'
            else
                'basic'
            # if match["#{key}"]
            #     if @valueOf() in match["#{key}"]
            #         'active'
            #     else
            #         'basic'
            # else
            #     'basic'



    Template.emotion_circle.helpers
        emotion_circle_class: ->
            # emotion = @watson.emotion.document.emotion
            # console.log @emotion
            # console.log @color
            # console.log @percent
            classes = "#{@color}"
            size = switch
                when @percent < .2
                    classes += ' mini'
                when @percent < .3
                    classes += ' tiny'
                    # console.log 'small'
                when @percent < .4
                    classes += ' small'
                when @percent < .6
                    classes += ' '
                    # console.log 'reg'
                when @percent < .7
                    classes += ' large'
                    # console.log 'large'
                when @percent < .9
                    classes += ' big'
                    # console.log 'big'
                when @percent < 1.1
                    classes += ' massive'
                    # console.log 'massive'
            # console.log classes
            classes
            # switch emotion.


    Template.doc_page.onCreated ->
        @view_detail = new ReactiveVar false

    Template.doc_page.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000

    Template.doc_page.helpers
        view_tone: -> Session.get('view_tone')

        when: -> moment(@_timestamp).fromNow()
        view_detail: -> Template.instance().view_detail.get()
        top_score: ->
            # console.log @
            if @tones.length > 0
                majority = _.filter(@tones,(tone)-> tone.score>0.5)
                max = _.max(majority,(tone)->tone.score)
                # console.log max.score*100
                max.score*10

        tone_sentence_class: ->
            # console.log @tones
            if @tones.length > 0
                majority = _.filter(@tones,(tone)-> tone.score>0.5)
                max = _.max(majority,(tone)->tone.score)
                # console.log max
                classes = ""
                classes = switch max.tone_id
                    when 'analytical' then 'violet'
                    when 'confident' then 'blue'
                    when 'anger' then 'red'
                    when 'sadness' then 'blue'
                    when 'tentative' then 'yellow'
                    when 'joy' then 'green'
                    when 'fear' then 'orange'
                    else ''
                # console.log "ui text #{classes}"
                "ui text #{classes}"
        post_header_class: ->
            if @doc_sentiment_label is 'positive'
                if @doc_sentiment_score > .5
                    'green'
                else
                    'blue'
            else if @doc_sentiment_label is 'negative'
                if @doc_sentiment_score < -.5
                    'red'
                else
                    'yellow'
    Template.doc_page.events
        'click .toggle_detail': (e,t)->
            t.view_detail.set !t.view_detail.get()
        'click .remove': ->
            Docs.remove @_id
        'click .call_tone': ->
            console.log @
            Meteor.call 'call_tone', @_id, 'body', 'text', ->
        'click .call_entities': ->
            console.log @
            Meteor.call 'analyze_entities', @_id, 'body', ->




if Meteor.isServer
    Meteor.publish 'current_doc', (doc_id)->
        Docs.find doc_id
