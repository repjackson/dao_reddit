@selected_tags = new ReactiveArray []

Template.admin.helpers
    doc_count: ->
        Docs.find().count()


Template.home.onCreated ->
    Session.setDefault('current_query', '')
    Session.setDefault('dummy', true)
    @autorun => @subscribe 'terms',
        selected_tags.array()
    @autorun => @subscribe 'tag_results',
        selected_tags.array()
        Session.get('current_query')
        Session.get('dummy')
    @autorun => @subscribe 'doc_results',
        selected_tags.array()

Template.tone.events
    # 'click .upvote_sentence': ->
    'click .tone_item': ->
        # console.log @
        doc_id = Docs.findOne()._id
        if @weight is 3
            Meteor.call 'reset_sentence', doc_id, @, ->
        else
            Meteor.call 'upvote_sentence', doc_id, @, ->
    # 'click .downvote_sentence': ->
    #     # console.log @
    #     Meteor.call 'downvote_sentence', omega.selected_doc_id, @, ->

Template.home.events
    'click .result': (e,t)->
        Meteor.call 'log_term', @title, ->
        selected_tags.push @title

        $('#search').val('')
        Meteor.call 'call_wiki', @title, ->
        Meteor.call 'calc_term', @title, ->
        Session.set('current_query', '')
        Session.set('searching', false)

        Meteor.call 'search_reddit', selected_tags.array(), ->
        Meteor.setTimeout ->
            Session.set('dummy', !Session.get('dummy'))
        , 7000
    # 'click .call_visual': ->
    #     Meteor.call 'call_visual', @_id, (err,res)->
    #         console.log res

    'click .select_query': ->
        selected_tags.push @title
        Meteor.call 'search_reddit', selected_tags.array(), ->
        $('#search').val('')
        Session.set('current_query', '')
        Session.set('searching', false)

    'click .unselect_tag': ->
        selected_tags.remove @valueOf()
        console.log selected_tags.array()
        if selected_tags.array().length is 1
            Meteor.call 'call_wiki', selected_tags.array(), ->

        if selected_tags.array().length > 0
            Meteor.call 'search_reddit', selected_tags.array(), ->
                Session.set('dummy', !Session.get('dummy'))

    # 'click .refresh_tags': ->

    'click .clear_selected_tags': ->
        Session.set('current_query','')
        selected_tags.clear()
    # 'keyup #search': _.throttle((e,t)->
    'keyup #search': (e,t)->
        query = $('#search').val()
        Session.set('current_query', query)
        # if query.length > 0
        console.log Session.get('current_query')
        if e.which is 13
            search = $('#search').val().trim().toLowerCase()
            if search.length > 0
                selected_tags.push search
                console.log 'search', search
                Meteor.call 'call_wiki', search, ->
                Meteor.call 'search_reddit', selected_tags.array(), ->
                Meteor.call 'log_term', search, ->

                $('#search').val('')
                Session.set('current_query', '')
                Meteor.setTimeout ->
                    Session.set('dummy', !Session.get('dummy'))
                , 6000


    # 'keydown #search': _.throttle((e,t)->
    #     if e.which is 8
    #         search = $('#search').val()
    #         if search.length is 0
    #             last_val = selected_tags.array().slice(-1)
    #             console.log last_val
    #             $('#search').val(last_val)
    #             selected_tags.pop()
    #             Meteor.call 'search_reddit', selected_tags.array(), ->
    # , 1000)

    'click .reconnect': ->
        Meteor.reconnect()

    'click .toggle_tag': (e,t)-> selected_tags.push @valueOf()


    # 'click .toggle_domain': (e,t)->
    #     omega = Docs.findOne model:'omega_session'
    #     Docs.update omega._id,
    #         $addToSet:
    #             selected_tags:@domain

    'keyup .add_tag': (e,t)->
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
                # # console.log 'search', search
                Meteor.call 'call_wiki', tag, ->
                Meteor.call 'log_term', tag, ->

    'click .vote_up': (e,t)->
        Docs.update @_id,
            $inc:points:1


    'click .vote_down': (e,t)->
        Docs.update @_id,
            $inc:points:-1

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





Template.home.helpers
    term_icon: ->
        console.log @
    selected_doc: ->
        # current_docs = Docs.find()
        # if Session.get('selected_doc_id') in current_docs.fetch()

        # Docs.findOne Session.get('selected_doc_id')
        doc_count = Docs.find().count()
        # if doc_count is 1
        Docs.find({})


    is_loading: -> Session.get('is_loading')

    tag_result_class: ->
        # ec = omega.emotion_color
        # console.log @
        # console.log omega.total_doc_result_count
        total_doc_result_count = Docs.find({}).count()
        console.log total_doc_result_count
        percent = @count/total_doc_result_count
        # console.log 'percent', percent
        # console.log typeof parseFloat(@relevance)
        # console.log typeof (@relevance*100).toFixed()
        whole = parseInt(percent*10)+1
        # console.log 'whole', whole

        # if whole is 0 then "#{ec} f5"
        if whole is 0 then "f5"
        else if whole is 1 then "f11"
        else if whole is 2 then "f12"
        else if whole is 3 then "f13"
        else if whole is 4 then "f14"
        else if whole is 5 then "f15"
        else if whole is 6 then "f16"
        else if whole is 7 then "f17"
        else if whole is 8 then "f18"
        else if whole is 9 then "f19"
        else if whole is 10 then "f20"

    # emotion_color: ->
    #     omega = Docs.findOne model:'omega_session'
    #     # omega.emotion_color
    #     # if omega.emotion_color is 'blue'
    #     #     'sadness'
    #     # else
    #     omega.emotion_color
    #
    #     # main_emotion = Docs.findOne({max_emotion_name:$exists:true}).max_emotion_name
    #     # console.log main_emotion
    #     # if main_emotion is 'anger'
    #     #     'green'
        # else if main_emotion is 'disgust'
        #     'teal'
        # else if main_emotion is 'sadness'
        #     'teal'
        # else if main_emotion is 'joy'
        #     'red'
    #     emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
    #
    #     omega = Docs.findOne model:'omega_session'
    #     current_most_emotion = ''
    #     current_max_emotion_count = 0
    #     results =
    #         Docs.find(_id:$in:omega.doc_result_ids)
    #     for emotion in emotion_list
    #         omega = Docs.findOne model:'omega_session'
    #         emotion_match = {}
    #         emotion_match.max_emotion_name = emotion
    #         found_emotions =
    #             Docs.find(emotion_match)
    #         Docs.update omega._id,
    #             $set:
    #                 "current_#{emotion}_count":found_emotions.count()
    #         if omega.current_most_emotion < found_emotions.count()
    #             Docs.update omega._id,
    #                 $set:
    #                     current_most_emotion:emotion
    #                     current_max_emotion_count: found_emotions.count()
    #
    #     console.log 'found emotions for ', emotion, found_emotions.count()
    #     console.log 'final', Docs.findOne model:'omega_session'

    connection: ->
        # console.log Meteor.status()
        Meteor.status()
    connected: -> Meteor.status().connected

    agg_tags: ->
        # console.log Session.get('current_query')
        if Session.get('current_query').length > 0
            Terms.find({}, sort:count:-1)
        else
            # doc_count = Docs.find().count()
            # console.log 'doc count', doc_count
            # if doc_count < 3
            #     Tags.find({count: $lt: doc_count})
            # else
            Tags.find()

    result_class: ->
        # if Template.instance().subscriptionsReady()
        #     ''
        # else
        #     'disabled'

    selected_tags: -> selected_tags.array()

    selected_tags_plural: -> selected_tags.array().length > 1

    searching: -> Session.get('searching')

    one_post: -> Docs.find().count() is 1

    two_posts: -> Docs.find().count() is 2
    three_posts: -> Docs.find().count() is 3
    four_posts: -> Docs.find().count() is 4
    five_posts: -> Docs.find().count() is 5
    six_posts: -> Docs.find().count() is 6
    seven_posts: -> Docs.find().count() is 7
    eight_posts: -> Docs.find().count() is 8
    nine_posts: -> Docs.find().count() is 9
    ten_posts: -> Docs.find().count() is 10
    more_than_ten: -> Docs.find().count() > 10
    one_result: ->
        Docs.find().count() is 1

    docs: ->
        # if selected_tags.array().length > 0
        cursor =
            Docs.find {
                model:['reddit','wikipedia']
            },
                sort:
                    points:-1
                    ups:-1
                # limit:10
        # console.log cursor.fetch()
        cursor

    term: ->
        console.log @
        Terms.findOne
            title:@valueOf()

    # home_subs_ready: ->
    #     Template.instance().subscriptionsReady()
    #
    # home_subs_ready: ->
    #     if Template.instance().subscriptionsReady()
    #         Session.set('global_subs_ready', true)
    #     else
    #         Session.set('global_subs_ready', false)
