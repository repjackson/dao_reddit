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

Template.meta_buttons.events
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



    'click .toggle_tags': (e,t)->
        if Session.equals('view_tags', @_id)
            Session.set('view_tags', null)
        else
            Session.set('view_tags', @_id)
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
        Meteor.call 'call_watson', @_id, 'url', 'url'
        # Meteor.call 'agg_omega', ->

    'click .call_watson_image': ->
        Meteor.call 'call_watson', @_id, 'url', 'image'
    'click .print_me': ->
        console.log @
    'click .goto_article': ->
        # console.log @
        Meteor.call 'log_view', @_id, ->
        # Router.go "/doc/#{@_id}/view"

Template.meta_buttons.helpers
    view_tags: -> Session.equals('view_tags', @_id)
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
        omega.dark_mode
        if omega.dark_mode
            # console.log 'hi dark'
            res+=' dark_mode'
        if @doc_sentiment_label is 'negative'
            res+='red'
        else if @doc_sentiment_label is 'positive'
            res+='green'
        else
            res+='black'
        res

    truncated: ->
        # console.log @
        # console.log @rd.selftext
        # console.log @rd.selftext.substr(0, 100)
        @rd.selftext.substr(0, 2500)


    has_thumbnail: ->
        # console.log @thumbnail
        @thumbnail and @thumbnail not in ['self','default']