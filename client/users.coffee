Router.route '/users', (->
    @render 'users'
    ), name:'users'


Template.users.onCreated ->
    @autorun -> Meteor.subscribe('all_users',
        selected_tags.array()
        )

Template.users.helpers
    users: ->
        Meteor.users.find()


Template.user_item.helpers
    can_buy: ->
        Meteor.userId() isnt @_author_id

    has_enough: ->
        Meteor.user().credit > @price


Template.user_item.events
    'click .buy': ->
        if Meteor.userId()
            if confirm "confirm purchase of #{@price}"
                Meteor.call 'purchase', @, ->
        else
            Router.go "/login"


    'click .cancel': ->
        if confirm "confirm cancel of #{@price}"
            Meteor.call 'cancel', @, ->






if Meteor.isClient
    @selected_tags = new ReactiveArray []

    Template.user_cloud.onCreated ->
        @autorun -> Meteor.subscribe('tags',
            selected_tags.array()
            Session.get('view_mode')
        )
        Session.setDefault('view_mode', 'users')

    Template.user_cloud.helpers
        all_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        selected_tags: ->
            # model = 'event'
            # console.log "selected_#{model}_tags"
            selected_tags.array()


    Template.user_cloud.events
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()

        'click #add': ->
            Meteor.call 'add', (err,id)->
                FlowRouter.go "/edit/#{id}"


if Meteor.isServer
    Meteor.publish 'tags', (
        selected_tags,
        view_mode
        limit
    )->
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.model = 'item'
        if view_mode is 'users'
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
