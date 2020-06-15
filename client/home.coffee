Template.home.onCreated ->
    Session.setDefault('current_query', '')
    Session.setDefault('dummy', true)
    # @autorun => @subscribe 'omega_results', Session.get('dummy')
    @autorun => @subscribe 'omega_doc'
    # @autorun => @subscribe 'tags',
    #     selected_tags.array()
    #     Session.get('current_query')
    #     Session.get('dummy')
    # @autorun => @subscribe 'docs',
    #     selected_tags.array()

Template.tone.events
    # 'click .upvote_sentence': ->
    'click .tone_item': ->
        # console.log @
        omega  = Docs.findOne model:'omega_session'
        # selected_doc =
        #     Docs.findOne _id:omega.selected_doc_id
        if @weight is 3
            Meteor.call 'reset_sentence', omega.selected_doc_id, @, ->
        else
            Meteor.call 'upvote_sentence', omega.selected_doc_id, @, ->
    'click .downvote_sentence': ->
        # console.log @
        omega  = Docs.findOne model:'omega_session'
        # selected_doc =
        #     Docs.findOne _id:omega.selected_doc_id
        Meteor.call 'downvote_sentence', omega.selected_doc_id, @, ->

Template.home.events
    # 'click .lightbulb': (e,t)->
    #     omega  = Docs.findOne model:'omega_session'
    #     Docs.update omega._id,
    #         $set:
    #             dark_mode:!omega.dark_mode
    #     Session.set('dummy',!Session.get('dummy'))

    'click .refresh_agg': (e,t)->
        # $(e.currentTarget).closest('.button').transition('pulse', 1000)
        Session.set('is_loading',true)
        Meteor.call 'agg_omega', ->
            Session.set('is_loading',false)
            Session.set('dummy',!Session.get('dummy'))
            Meteor.call 'get_top_emotion', ->
        omega  = Docs.findOne model:'omega_session'
        console.log omega
    # 'click .pick_dao': (e,t)->
    #     # selected_tags.push 'dao'
    #     # $(e.currentTarget).closest('.button').transition('pulse', 1000)
    #     omega  = Docs.findOne model:'omega_session'
    #     if omega
    #         Docs.update omega._id,
    #             $set:selected_tags:['dao']
    #     Session.set('is_loading',true)
    #     Meteor.call 'agg_omega', ->
    #
    #         Session.set('is_loading',false)
    #         Session.set('dummy',!Session.get('dummy'))

    'click .result': (e,t)->
        # $(e.currentTarget).closest('.button').transition('pulse', 1000)

        # console.log @
        # if selected_tags.array().length is 1
        #     Meteor.call 'call_wiki', search, ->
        # $('.hi .result')
        #     .transition({
        #         animation : 'scale'
        #         reverse   : 'auto'
        #         interval  : 20
        #     })

        Meteor.call 'log_term', @title, ->
        # selected_tags.push @title
        omega  = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $addToSet:
                selected_tags:@title

        $('#search').val('')
        Meteor.call 'call_wiki', @title, ->
        # Session.set('current_query', '')
        # Session.set('searching', false)
        Docs.update omega._id,
            $set:
                current_query:''
                searching:false
        Session.set('is_loading',true)
        Meteor.call 'agg_omega', ->
            Session.set('is_loading',false)
            Session.set('dummy',!Session.get('dummy'))
            Meteor.call 'get_top_emotion', ->

        Meteor.call 'search_reddit', selected_tags.array(), ->
        Meteor.setTimeout ->
            Meteor.call 'agg_omega', ->
            Session.set('dummy', !Session.get('dummy'))
        , 7000
    'click .get_top_emotion': ->
        Meteor.call 'get_top_emotion', ->
        # queries.push @title
    'click .call_visual': ->
        Meteor.call 'call_visual', @_id, (err,res)->
            console.log res
        # queries.push @title

    'click .select_query': ->
        omega  = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $addToSet:
                queries:@title
        Session.set('is_loading',true)
        Meteor.call 'agg_omega', ->
            Session.set('is_loading',false)
            Session.set('dummy',!Session.get('dummy'))
        Meteor.setTimeout ->
            Meteor.call 'agg_omega', ->
            Session.set('dummy', !Session.get('dummy'))
        , 6000

    'click .unselect_tag': ->
        # selected_tags.remove @valueOf()
        omega  = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $pull:
                selected_tags:@valueOf()
        Session.set('is_loading',true)
        Meteor.call 'agg_omega', ->
            Session.set('is_loading',false)
            Session.set('dummy',!Session.get('dummy'))
            Meteor.call 'get_top_emotion', ->
        Meteor.setTimeout ->
            Meteor.call 'agg_omega', ->
                Session.set('dummy',!Session.get('dummy'))
                Meteor.call 'get_top_emotion', ->

            # Session.set('dummy', !Session.get('dummy'))
        , 6000

        # console.log selected_tags.array()
        # if selected_tags.array().length is 1
        #     Meteor.call 'call_wiki', search, ->

        # if selected_tags.array().length > 0
        # if omega.selected_tags.length > 0
        #     Meteor.call 'search_reddit', omega.selected_tags, ->
        #         Session.set('dummy', !Session.get('dummy'))

    # 'click .refresh_tags': ->

    'click .clear_selected_tags': ->
        # Session.set('current_query','')
        # selected_tags.clear()
        omega  = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $set:
                selected_tags:[]
                current_query:''
        Meteor.call 'agg_omega', ->
    # 'keyup #search': _.throttle((e,t)->
    'keyup #search': (e,t)->
        omega  = Docs.findOne model:'omega_session'
        query = $('#search').val()
        # Docs.update omega._id,
        #     $set:current_query:query
        # Session.set('current_query', query)
        # console.log Session.get('current_query')
        if e.which is 13
            search = $('#search').val().trim().toLowerCase()
            if search.length > 0
                # selected_tags.push search
                omega  = Docs.findOne model:'omega_session'
                Docs.update omega._id,
                    $set:
                        current_query:''
                    $addToSet:
                        selected_tags:search
                if search is 'dark'
                    alert 'dark'
                    Docs.update omega._id,
                        $set:
                            dark_mode:true

                # console.log 'search', search
                Meteor.call 'call_wiki', search, ->
                # Meteor.call 'search_reddit', selected_tags.array(), ->
                Meteor.call 'search_reddit', omega.selected_tags, ->
                Meteor.call 'log_term', search, ->
                $('#search').val('')
                # Session.set('current_query', '')
                Docs.update omega._id,
                    $set:
                        current_query:''
                # # $('#search').val('').blur()
                # # $( "p" ).blur();
                Meteor.call 'agg_omega'
                Meteor.setTimeout ->
                    Meteor.call 'agg_omega', ->
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



Template.home.helpers
    selected_doc: ->
        omega = Docs.findOne model:'omega_session'
        Docs.findOne omega.selected_doc_id
    is_loading: ->
        Session.get('is_loading')
    omega_dark_mode_class: ->
        omega = Docs.findOne model:'omega_session'
        if omega
            omega.dark_mode
            if omega.dark_mode
                # console.log 'hi dark'
                'dark_mode'
            else
                # console.log 'hi light'
                ''
    tag_result: ->
        omega = Docs.findOne model:'omega_session'
        ec = omega.emotion_color
        # console.log @
        # console.log omega.total_doc_result_count
        percent = @count/omega.total_doc_result_count
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

    emotion_color: ->
        omega = Docs.findOne model:'omega_session'
        # omega.emotion_color
        # if omega.emotion_color is 'blue'
        #     'sadness'
        # else
        omega.emotion_color

        # main_emotion = Docs.findOne({max_emotion_name:$exists:true}).max_emotion_name
        # console.log main_emotion
        # if main_emotion is 'anger'
        #     'green'
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
    connected: ->
        Meteor.status().connected
    # tags: ->
    #     # console.log Session.get('current_query')
    #     omega = Docs.findOne model:'omega_session'
    #     # console.log omega.current_query, 'omega current query'
    #     # if Session.get('current_query').length > 0
    #     if omega.current_query.length > 0
    #         Terms.find({}, sort:count:-1)
    #     else
    #         doc_count = Docs.find().count()
    #         # console.log 'doc count', doc_count
    #         if doc_count < 3
    #             Tags.find({count: $lt: doc_count})
    #         else
    #             Tags.find()

    result_class: ->
        # if Template.instance().subscriptionsReady()
        #     ''
        # else
        #     'disabled'

    selected_tags: ->
        selected_tags.array()
        omega  = Docs.findOne model:'omega_session'
        omega.selected_tags
        # Docs.update omega._id,
        #     $addToSet:
        #         selected_tags:search

    selected_tags_plural: ->
        selected_tags.array().length > 1
        omega  = Docs.findOne model:'omega_session'
        omega.selected_tags.length > 1

    searching: -> Session.get('searching')

    one_post: ->
        Docs.find().count() is 1
    # omega_doc_results: ->
    #     # if selected_tags.array().length > 0
    #     cursor =
    #         Docs.find {
    #             # model:'reddit'
    #         },
    #             sort:ups:-1
    #             limit:2
    #     # console.log cursor.fetch()
    #     cursor


    # docs: ->
    #     # if selected_tags.array().length > 0
    #     cursor =
    #         Docs.find {
    #             # model:'reddit'
    #         },
    #             sort:ups:-1
    #             limit:3
    #     # console.log cursor.fetch()
    #     cursor


    # home_subs_ready: ->
    #     Template.instance().subscriptionsReady()
    #
    # home_subs_ready: ->
    #     if Template.instance().subscriptionsReady()
    #         Session.set('global_subs_ready', true)
    #     else
    #         Session.set('global_subs_ready', false)
