if Meteor.isClient
    Router.route '/', (->
        @render 'items'
        ), name:'items'


    Template.items.onCreated ->
        Session.setDefault ''
        @autorun -> Meteor.subscribe('docs',
            selected_tags.array()
            Session.get('view_mode')
            Session.get('current_query')
            )





    Template.items.helpers
        docs: ->
            Docs.find
                model:'item'

        current_query: -> Session.get('current_query')

    Template.items.events
        'click  .clear_query': (e,t)->
            Session.set('current_query', null)
        'keyup #search': _.throttle((e,t)->
            # query = $('#search').val()
            search = $('#search').val().toLowerCase()
            Session.set('current_query', search)
            # console.log Session.get('current_query')
            if e.which is 13
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




    Template.item_item.helpers
        can_buy: ->
            Meteor.userId() isnt @_author_id

        has_enough: ->
            Meteor.user().credit > @price

    Template.item_item.events
        'click .buy': ->
            if Meteor.userId()
                if confirm "confirm purchase of #{@price}"
                    Meteor.call 'purchase', @, ->
            else
                Router.go "/login"


        'click .cancel': ->
            if confirm "confirm cancel of #{@price}"
                Meteor.call 'cancel', @, ->




    Template.item_card.helpers
        can_buy: ->
            Meteor.userId() isnt @_author_id

        has_enough: ->
            Meteor.user().credit > @price

    Template.item_card.events
        'click .buy': ->
            if Meteor.userId()
                if confirm "confirm purchase of #{@price}"
                    Meteor.call 'purchase', @, ->
            else
                Router.go "/login"


        'click .cancel': ->
            if confirm "confirm cancel of #{@price}"
                Meteor.call 'cancel', @, ->






    @selected_tags = new ReactiveArray []

    Template.cloud.onCreated ->
        @autorun -> Meteor.subscribe('tags',
            selected_tags.array()
            Session.get('view_mode')
            Session.get('current_query')
        )
        Session.setDefault('view_mode', 'market')

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


if Meteor.isServer
    Meteor.publish 'tags', (
        selected_tags
        view_mode
        current_query=''
        limit
    )->
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if current_query.length > 0 then match.title = {$regex:"#{current_query}", $options: 'i'}


        match.model = 'item'
        if view_mode is 'market'
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

        self.ready()
