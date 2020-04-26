if Meteor.isClient
    Template.alpha.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'my_alpha_session'
        @autorun -> Meteor.subscribe 'model_docs', 'block'
        @autorun -> Meteor.subscribe 'model_docs', 'module'

        Session.set 'loading', true
        Meteor.call 'set_afacets', ->
            Session.set 'loading', false
    # Template.alpha.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.alpha.helpers
        current_alpha_session: ->
            Docs.findOne
                model:'alpha_session'

        table_header_column: ->
            console.log @


        model_fields: ->
            alpha_session = Docs.findOne model:'alpha_session'
            model = Docs.findOne model:'model'
            Docs.find
                model:'field'
                parent_id: model._id
        query_class:->
            alpha_session = Docs.findOne model:'alpha_session'
            if alpha_session
                if alpha_session.search_query
                    'focus'
                else
                    'small'
        current_alpha_session_model: ->
            alpha_session = Docs.findOne model:'alpha_session'
            model = Docs.findOne model:'model'
            console.log 'alpha_session',alpha_session
            console.log 'model',model


        sorting_up: ->
            alpha_session = Docs.findOne model:'alpha_session'
            if alpha_session
                if alpha_session.sort_direction is 1 then true

        selected_tags: -> selected_tags.list()
        view_mode_template: ->
            # console.log @
            alpha_session = Docs.findOne model:'alpha_session'
            if alpha_session
                "alpha_session_#{alpha_session.view_mode}"

        sorted_facets: ->
            current_alpha_session =
                Docs.findOne
                    model:'alpha_session'
            if current_alpha_session
                # console.log _.sortBy current_alpha_session.facets,'rank'
                _.sortBy current_alpha_session.facets,'rank'

        global_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        single_doc: ->
            false
            # alpha_session = Docs.findOne model:'alpha_session'
            # count = alpha_session.result_ids.length
            # if count is 1 then true else false



    Template.alpha.events
        'click .toggle_sort_column': ->
            console.log @
            alpha_session = Docs.findOne model:'alpha_session'
            console.log alpha_session


        'click .clear_query': ->
            # console.log @
            alpha_session = Docs.findOne model:'alpha_session'
            Docs.update alpha_session._id,
                $unset:search_query:1
            Session.set 'loading', true
            Meteor.call 'afum', alpha_session._id, ->
                Session.set 'loading', false

        'click .set_sort_key': ->
            # console.log @
            alpha_session = Docs.findOne model:'alpha_session'
            Docs.update alpha_session._id,
                $set:sort_key:@key
            Session.set 'loading', true
            Meteor.call 'afum', alpha_session._id, ->
                Session.set 'loading', false

        'click .set_sort_direction': (e,t)->
            # console.log @
            # $(e.currentTarget).closest('.button').transition('pulse', 250)

            alpha_session = Docs.findOne model:'alpha_session'
            if alpha_session.sort_direction is -1
                Docs.update alpha_session._id,
                    $set:sort_direction:1
            else
                Docs.update alpha_session._id,
                    $set:sort_direction:-1
            Session.set 'loading', true
            Meteor.call 'afum', alpha_session._id, ->
                Session.set 'loading', false

        'click .create_alpha_session': (e,t)->
            Docs.insert
                model:'alpha_session'
                view_mode:'list'

        'click .print_alpha_session': (e,t)->
            alpha_session = Docs.findOne model:'alpha_session'
            console.log alpha_session

        'click .reset': ->
            model_slug =  Router.current().params.model_slug
            Session.set 'loading', true
            Meteor.call 'set_afacets', model_slug, true, ->
                Session.set 'loading', false

        'click .delete_alpha_session': (e,t)->
            alpha_session = Docs.findOne model:'alpha_session'
            if alpha_session
                if confirm "delete  #{alpha_session._id}?"
                    Docs.remove alpha_session._id

        # 'mouseenter .add_model_doc': (e,t)->
    	# 	$(e.currentTarget).addClass('spinning')

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            alpha_session = Docs.findOne model:'alpha_session'
            Docs.update alpha_session._id,
                $set:search_query:query
            Session.set 'loading', true
            Meteor.call 'afum', alpha_session._id, ->
                Session.set 'loading', false

            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    selected_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)




    # Template.toggle_visible_field.events
    #     'click .toggle_visibility': ->
    #         console.log @
    #         alpha_session = Docs.findOne model:'alpha_session'
    #         console.log 'viewable fields', alpha_session.viewable_fields
    #         if @_id in alpha_session.viewable_fields
    #             Docs.update alpha_session._id,
    #                 $pull:viewable_fields: @_id
    #         else
    #             Docs.update alpha_session._id,
    #                 $addToSet: viewable_fields: @_id

    # Template.toggle_visible_field.helpers
    #     field_visible: ->
    #         alpha_session = Docs.findOne model:'alpha_session'
    #         @_id in alpha_session.viewable_fields

    Template.set_alpha_limit.events
        'click .set_limit': ->
            # console.log @
            alpha_session = Docs.findOne model:'alpha_session'
            Docs.update alpha_session._id,
                $set:limit:@amount
            Session.set 'loading', true
            Meteor.call 'afum', alpha_session._id, ->
                Session.set 'loading', false

    Template.set_view_mode.events
        'click .set_view_mode': ->
            # console.log @
            alpha_session = Docs.findOne model:'alpha_session'
            Docs.update alpha_session._id,
                $set:view_mode:@title
            Session.set 'loading', true
            Meteor.call 'afum', alpha_session._id, ->
                Session.set 'loading', false





    Template.afacet.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1500

    Template.afacet.events
        # 'click .ui.accordion': ->
        #     $('.accordion').accordion()

        'click .toggle_selection': ->
            alpha_session = Docs.findOne model:'alpha_session'
            facet = Template.currentData()

            Session.set 'loading', true
            if facet.filters and @name in facet.filters
                Meteor.call 'remove_afacet_filter', alpha_session._id, facet.key, @name, ->
                    Session.set 'loading', false
            else
                Meteor.call 'add_afacet_filter', alpha_session._id, facet.key, @name, ->
                    Session.set 'loading', false

        'keyup .add_filter': (e,t)->
            # console.log @
            if e.which is 13
                alpha_session = Docs.findOne model:'alpha_session'
                facet = Template.currentData()
                if @field_type is 'number'
                    filter = parseInt t.$('.add_filter').val()
                else
                    filter = t.$('.add_filter').val()
                Session.set 'loading', true
                Meteor.call 'aadd_facet_filter', alpha_session._id, facet.key, filter, ->
                    Session.set 'loading', false
                t.$('.add_filter').val('')




    Template.afacet.helpers
        filtering_res: ->
            alpha_session = Docs.findOne model:'alpha_session'
            filtering_res = []
            if @key is '_keys'
                @res
            else
                for filter in @res
                    if filter.count < alpha_session.total
                        filtering_res.push filter
                    else if filter.name in @filters
                        filtering_res.push filter
                filtering_res
        toggle_value_class: ->
            facet = Template.parentData()
            alpha_session = Docs.findOne model:'alpha_session'
            if Session.equals 'loading', true
                 'disabled basic'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else 'basic'




if Meteor.isServer
    Meteor.publish 'my_alpha_session', ->
        if Meteor.userId()
            Docs.find
                _author_id:Meteor.userId()
                model:'alpha_session'
        else
            Docs.find
                _author_id:null
                model:'alpha_session'

    Meteor.methods
        calc_alpha_meta: (adoc_id)->
            alpha_doc = Docs.findOne adoc_id
            modules =
                Docs.find(
                    model:'module'
                    parent_id:adoc_id
                ).fetch()
            doc_keys = _.pluck(modules, 'doc_key')
            doc_field_types = _.pluck(modules, 'block_slug')
            console.log modules
            Docs.update adoc_id,
                $set:
                    _key_list:doc_keys
