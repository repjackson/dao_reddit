Template.doc_item.onCreated ->
    # console.log @
    @autorun => @subscribe 'doc', @data

Template.doc_item.onRendered ->
    # Meteor.setTimeout ->
    #     $('.header').popup(
    #         preserve:true;
    #         hoverable:false;
    #     )
    # , 1000

Template.doc_item.events
    'click .toggle_tag': (e,t)->
        omega = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $addToSet:
                selected_tags:@valueOf()
        Session.set('is_loading',true)
        Meteor.call 'agg_omega', ->
            Session.set('is_loading',false)
            Session.set('dummy',!Session.get('dummy'))


    'click .toggle_domain': (e,t)->
        omega = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $addToSet:
                selected_tags:@domain
        Session.set('is_loading',true)
        Meteor.call 'agg_omega', ->
            Session.set('is_loading',false)
            Session.set('dummy',!Session.get('dummy'))

    'keyup .add_tag': (e,t)->
        # omega  = Docs.findOne model:'omega_session'
        # Docs.update omega._id,
        #     $set:current_query:query
        # Session.set('current_query', query)
        # console.log Session.get('current_query')
        if e.which is 13
            tag = $(e.currentTarget).closest('.add_tag').val().trim().toLowerCase()
            console.log 'tag', tag
            # search = $('#search').val()
            if tag.length > 0
                # selected_tags.push search
                # omega  = Docs.findOne model:'omega_session'
                Docs.update @_id,
                    # $set:
                    #     current_query:''
                    $addToSet:
                        tags:tag
                        user_tags:tag
                $(e.currentTarget).closest('.add_tag').val('')
                # if search is 'dark'
                #     alert 'dark'
                #     Docs.update omega._id,
                #         $set:
                #             dark_mode:true
                #
                # # console.log 'search', search
                # Meteor.call 'call_wiki', search, ->
                # # Meteor.call 'search_reddit', selected_tags.array(), ->
                # Meteor.call 'search_reddit', omega.selected_tags, ->
                # Meteor.call 'log_term', search, ->
                # $('#search').val('')
                # # Session.set('current_query', '')
                # Docs.update omega._id,
                #     $set:
                #         current_query:''
                # # $('#search').val('').blur()
                # # $( "p" ).blur();
                # Meteor.call 'agg_omega'
                # Meteor.setTimeout ->
                #     Meteor.call 'agg_omega', ->
                #     Session.set('dummy', !Session.get('dummy'))
                # , 6000



    'click .toggle_tags': (e,t)->
        if Session.equals('view_tags', @_id)
            Session.set('view_tags', null)
        else
            Session.set('view_tags', @_id)
    'click .vote_up': (e,t)->
        Docs.update @_id,
            $inc:points:1
            # , ->
        # # console.log 'firing'
        # _.throttle((e,t)=>
        #     console.log 'firing'
        #     Session.set('is_loading',true)
        #     Meteor.call 'agg_omega', =>
        #         Session.set('is_loading',false)
        #         Session.set('dummy',!Session.get('dummy'))
        # , 1000)



    'click .vote_down': (e,t)->
        Docs.update @_id,
            $inc:points:-1
        # Session.set('is_loading',true)
        # Meteor.call 'agg_omega', ->
        #     Session.set('is_loading',false)
        #     Session.set('dummy',!Session.get('dummy'))

    'click .print_me': (e,t)->
        console.log @
    'click .pull_post': (e,t)->
        console.log @
        Meteor.call 'get_reddit_post', @_id, @reddit_id, =>
        # Meteor.call 'agg_omega', ->

    'click .call_watson': ->
        if @rd and @rd.selftext_html
            dom = document.createElement('textarea')
            # dom.innerHTML = doc.body
            dom.innerHTML = @rd.selftext_html
            console.log 'innner html', dom.value
            # return dom.value
            Docs.update @_id,
                $set:
                    parsed_selftext_html:dom.value
        Meteor.call 'call_watson', @_id, 'url', 'url', ->
        # Meteor.call 'agg_omega', ->

    'click .call_watson_image': ->
        Meteor.call 'call_watson', @_id, 'url', 'image', ->
    'click .print_me': ->
        console.log @
    'click .select_doc': ->
        console.log @
        omega = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $set:
                selected_doc_id: @_id

        # Meteor.call 'log_view', @_id, ->
        # Router.go "/doc/#{@_id}/view"

Template.doc_item.helpers

    doc_object: ->
        Docs.findOne
            _id:Template.instance().data
    omega_dark_mode_class: ->
        omega = Docs.findOne model:'omega_session'
        omega.dark_mode
        if omega.dark_mode
            # console.log 'hi dark'
            'dark_mode'
        else
            # console.log 'hi light'
            ''

    sentiment_class: ->
        # console.log @
        # console.log @doc_sentiment_label
        res = ''
        omega = Docs.findOne model:'omega_session'
        # omega.dark_mode
        # if omega.dark_mode
        #     # console.log 'hi dark'
        #     res+=' dark_mode'
        if @max_emotion_name
            if @max_emotion_name is 'anger'
                res+='teal'
            if @max_emotion_name is 'joy'
                res+='pink'
            if @max_emotion_name is 'fear'
                res+='brown'
            if @max_emotion_name is 'sadness'
                res+='yellow'
            if @max_emotion_name is 'disgust'
                res+='orange'

        # if @doc_sentiment_label is 'negative'
        #     res+='teal'
        # else if @doc_sentiment_label is 'positive'
        #     res+='pink'
        # else
        #     res+='black'
        res

    truncated: ->
        # console.log @
        # console.log @rd.selftext
        # console.log @rd.selftext.substr(0, 100)
        @rd.selftext.substr(0, 2500)


    has_thumbnail: ->
        # console.log @thumbnail
        @thumbnail and @thumbnail not in ['self','default']
