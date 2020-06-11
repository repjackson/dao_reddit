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

Template.home.events
    'click .lightbulb': (e,t)->
        omega  = Docs.findOne model:'omega_session'
        Docs.update omega._id,
            $set:
                dark_mode:!omega.dark_mode
        Session.set('dummy',!Session.get('dummy'))

    'click .refresh_agg': (e,t)->
        # $(e.currentTarget).closest('.button').transition('pulse', 1000)
        Session.set('is_loading',true)
        Meteor.call 'agg_omega', ->
            Session.set('is_loading',false)
            Session.set('dummy',!Session.get('dummy'))
        omega  = Docs.findOne model:'omega_session'
        console.log omega
    'click .pick_dao': (e,t)->
        # selected_tags.push 'dao'
        # $(e.currentTarget).closest('.button').transition('pulse', 1000)
        omega  = Docs.findOne model:'omega_session'
        if omega
            Docs.update omega._id,
                $set:selected_tags:['dao']
        Session.set('is_loading',true)
        Meteor.call 'agg_omega', ->
            Session.set('is_loading',false)
            Session.set('dummy',!Session.get('dummy'))

    'click .result': (e,t)->
        # $(e.currentTarget).closest('.button').transition('pulse', 1000)

        # console.log @
        # if selected_tags.array().length is 1
        #     Meteor.call 'call_wiki', search, ->
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

        Meteor.call 'search_reddit', selected_tags.array(), ->
        Meteor.setTimeout ->
            Meteor.call 'agg_omega', ->
            Session.set('dummy', !Session.get('dummy'))
        , 6000
    'click .select_query': ->
        # queries.push @title
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
        Meteor.setTimeout ->
            Meteor.call 'agg_omega', ->
                Session.set('dummy',!Session.get('dummy'))

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
    is_loading: ->
        Session.get('is_loading')
    omega_dark_mode_class: ->
        omega = Docs.findOne model:'omega_session'
        omega.dark_mode
        if omega.dark_mode
            # console.log 'hi dark'
            'dark_mode'
        else
            # console.log 'hi light'
            ''
    connection: ->
        console.log Meteor.status()
        Meteor.status()
    connected: ->
        Meteor.status().connected
    tags: ->
        console.log Session.get('current_query')
        omega = Docs.findOne model:'omega_session'
        console.log omega.current_query, 'omega current query'
        # if Session.get('current_query').length > 0
        if omega.current_query.length > 0
            Terms.find({}, sort:count:-1)
        else
            doc_count = Docs.find().count()
            # console.log 'doc count', doc_count
            if doc_count < 3
                Tags.find({count: $lt: doc_count})
            else
                Tags.find()

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
