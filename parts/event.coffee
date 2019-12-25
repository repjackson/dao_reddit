if Meteor.isClient
    Router.route '/events', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'
    Router.route '/event/:doc_id/edit', (->
        @layout 'layout'
        @render 'event_edit'
        ), name:'event_edit'
    Router.route '/event/:doc_id/view', (->
        @layout 'layout'
        @render 'event_view'
        ), name:'event_view'



    Template.event_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.event_edit.events
        'click .add_event_item': ->
            new_mi_id = Docs.insert
                model:'event_item'
            Router.go "/event/#{_id}/edit"
    Template.event_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                event_id:@_id
    Template.event_edit.events


    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.event_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.event_view.helpers
        choices: ->
            Docs.find
                model:'choice'
                event_id:@_id
        can_accept: ->
            console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    event_id: Router.current().params.doc_id
            if my_answer_session
                console.log 'false'
                false
            else
                console.log 'true'
                true

    Template.event_view.events
        'click .purchase': ->
            console.log @




    Template.event_cloud.onCreated ->
        @autorun -> Meteor.subscribe('event_tags',
            selected_event_tags.array()
        )
        # @autorun -> Meteor.subscribe('model_docs', 'target')
    Template.event_cloud.helpers
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: -> Docs.findOne Session.get('selected_target_id')
        all_event_tags: ->
            event_count = Docs.find(model:'event').count()
            if 0 < event_count < 3 then Post_tags.find { count: $lt: event_count } else Post_tags.find({},{limit:100})
        selected_event_tags: -> selected_event_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key
    Template.event_cloud.events
        'click .select_event_tag': -> selected_event_tags.push @name
        'click .unselect_event_tag': -> selected_event_tags.remove @valueOf()
        'click #clear_event_tags': -> selected_event_tags.clear()






    Template.events.onRendered ->
        @autorun -> Meteor.subscribe 'event_facet_docs', selected_event_tags.array()
    Template.events.helpers
        events: ->
            Docs.find
                model:'event'




    Template.events.events
        'click .add_event': ->
            new_event_id = Docs.insert
                model:'event'
            Router.go "/event/#{new_event_id}/edit"



    Template.event_stats.events
        'click .refresh_event_stats': ->
            Meteor.call 'refresh_event_stats', @_id




if Meteor.isServer
    Meteor.publish 'events', (event_id)->
        Docs.find
            model:'event'
            event_id:event_id

    Meteor.methods
        refresh_event_stats: (event_id)->
            event = Docs.findOne event_id
            # console.log event
            reservations = Docs.find({model:'reservation', event_id:event_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_event_hours = 0
            average_event_duration = 0

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_event_hours += parseFloat(res.hour_duration)

            average_event_cost = total_earnings/reservation_count
            average_event_duration = total_event_hours/reservation_count

            Docs.update event_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_event_hours: total_event_hours.toFixed(0)
                    average_event_cost: average_event_cost.toFixed(0)
                    average_event_duration: average_event_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header event ranking #reservations
            # .ui.small.header event ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg event time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date


    Meteor.publish 'event_tags', (
        selected_event_tags
        )->
        self = @
        match = {}


        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        match.model = 'event'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_event_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'event_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'event_facet_docs', (
        selected_event_tags
        )->

        self = @
        match = {}
        # if selected_target_id
        #     match.target_id = selected_target_id
        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        match.model = 'event'
        Docs.find match,
            sort:_timestamp:1
            # limit: 5
