if Meteor.isClient
    Template.home.onCreated ->
        # Session.setDefault 'layout_mode','list'
        # Session.setDefault 'sort_key','_timestamp'
        # Session.setDefault 'sort_direction', -1
        # Session.setDefault 'limit',10
        @autorun -> Meteor.subscribe('docs',
            selected_tags.array()
            # selected_authors.array()
            # Session.get('view_mode')
            # Session.get('current_query')
            # Session.get('limit')
            # Session.get('sort_key')
            # Session.get('sort_direction')
            )

    Template.home.helpers
        docs: ->
            Docs.find {
                model:'thought'
            },
                limit:1
                sort:_timestamp:-1

        # current_limit: -> Session.get('limit')
        # current_query: -> Session.get('current_query')
        # current_sort_key: -> Session.get('sort_key')
        # sorting_up: -> Session.equals('sort_direction',-1)
        # sortable_fields: ->
        #     [
        #         {
        #             title:'when'
        #             key:'_timestamp'
        #         }
        #         {
        #             title:'price'
        #             key:'price'
        #         }
        #     ]



    Template.home.events
        'click #add': ->
            new_id =
                Docs.insert
                    model:'thought'
            Router.go "/thought/#{new_id}/edit"


        # 'click .set_sort_key': ->
        #     # console.log @
        #     Session.set('sort_key',@key)

        # 'click .set_sort_direction': (e,t)->
        #     # console.log @
        #     # $(e.currentTarget).closest('.button').transition('pulse', 250)
        #
        #     if Session.get('sort_direction') is -1
        #         Session.set('sort_direction',1)
        #     else
        #         Session.set('sort_direction',-1)
        #
        #
        # 'click  .clear_query': (e,t)->
        #     Session.set('current_query', null)
        # 'keyup #search': _.throttle((e,t)->
        #     # query = $('#search').val()
        #     search = $('#search').val().toLowerCase()
        #     Session.set('current_query', search)
        #     # console.log Session.get('current_query')
        #     if e.which is 13
        #         if search.length > 0
        #             selected_tags.push search
        #             console.log 'search', search
        #             # Meteor.call 'log_term', search, ->
        #             $('#search').val('')
        #             Session.set('current_query', null)
        #             # # $('#search').val('').blur()
        #             # # $( "p" ).blur();
        #             # Meteor.setTimeout ->
        #             #     Session.set('dummy', !Session.get('dummy'))
        #             # , 10000
        # , 1000)




    Template.thought_item.helpers
        can_buy: ->
            Meteor.userId() isnt @_author_id

        has_enough: ->
            Meteor.user().credit > @price

    Template.thought_item.events
        'click .buy': ->
            if Meteor.userId()
                Swal.fire({
                    title: 'confirm purchase'
                    text: "this will charge you #{@price} credit"
                    icon: 'thought'
                    showCancelButton: true,
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                }).then((result) =>
                    if result.value
                        # food = Docs.findOne Router.current().params.doc_id
                        Meteor.call 'purchase', @, ->
                )
            else
                Router.go "/login"


        'click .cancel': ->
            Swal.fire({
                title: "confirm cancel of #{@title}?"
                text: "this will return #{@price} credit to buyer"
                icon: 'thought'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    Meteor.call 'cancel', @, ->
            )



    @selected_tags = new ReactiveArray []

    Template.cloud.onCreated ->
        @autorun -> Meteor.subscribe('tags',
            selected_tags.array()
            # selected_authors.array()
            # Session.get('view_mode')
            # Session.get('current_query')
        )
        Session.setDefault('view_mode', 'home')

    Template.cloud.helpers
        all_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()
        selected_tags: -> selected_tags.array()

        all_authors: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Authors.find { count: $lt: doc_count } else Authors.find()
        selected_authorss: -> selected_authors.array()


    Template.cloud.events
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()

        'click .select_author': -> selected_authors.push @name
        'click .unselect_author': -> selected_authors.remove @valueOf()
        'click #clear_authors': -> selected_authors.clear()


if Meteor.isServer
    Meteor.publish 'tags', (
        selected_tags
        selected_authors=[]
        view_mode
        current_query=''
        limit
    )->
        console.log 'selected username', selected_authors
        self = @
        match = {}
        if selected_authors.length > 0 then match._author_username = $all: selected_authors
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if current_query.length > 0 then match.title = {$regex:"#{current_query}", $options: 'i'}


        match.model = 'thought'
        if view_mode is 'home'
            match.bought = $ne:true
            match._author_id = $ne: Meteor.userId()
        if view_mode is 'bought'
            match.bought = true
            match.buyer_id = Meteor.userId()
        if view_mode is 'selling'
            match.bought = $ne:true
            match._author_id = Meteor.userId()
        if view_mode is 'sold'
            match.bought = true
            match._author_id = Meteor.userId()

        if limit
            console.log 'limit', limit
            calc_limit = limit
        else
            calc_limit = 20
        cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: calc_limit }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud

        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        authors = Docs.aggregate [
            { $match: match }
            { $project: "_author_username": 1 }
            { $group: _id: "$_author_username", count: $sum: 1 }
            { $match: _id: $nin: selected_authors }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud

        authors.forEach (author, i) ->
            self.added 'authors', Random.id(),
                name: author.name
                count: author.count
                index: i

        self.ready()


    Meteor.publish 'docs', (
        selected_tags
        # selected_authors
        # view_mode
        # current_query=''
        # doc_limit=10
        # doc_sort_key='_timestamp'
        # doc_sort_direction=1
        )->
        match = {model:'thought'}
        # if current_query.length > 0 then match.title = {$regex:"#{current_query}", $options: 'i'}
        # if view_mode is 'home'
        #     match.bought = $ne:true
        #     match._author_id = $ne: Meteor.userId()
        # if view_mode is 'bought'
        #     match.bought = true
        #     match.buyer_id = Meteor.userId()
        # if view_mode is 'selling'
        #     match.bought = $ne:true
        #     match._author_id = Meteor.userId()
        # if view_mode is 'sold'
        #     match.bought = true
        #     match._author_id = Meteor.userId()
        # console.log selected_tags
        console.log match
        # if doc_limit
        #     limit = doc_limit
        # else
        #     limit = 10
        # if doc_sort_key
        #     sort = doc_sort_key
        # if doc_sort_direction
        #     sort_direction = parseInt(doc_sort_direction)
        #     console.log sort_direction
        self = @
        if selected_tags.length > 0
            match.tags = $all: selected_tags
            # sort = 'ups'
            # match.source = $ne:'wikipedia'

        # if selected_authors.length > 0
        #     match._author_username = $all: selected_authors

        Docs.find match,
            # sort:"#{sort}":sort_direction
            sort:_timestamp:-1
            limit: 10
