if Meteor.isClient
    Router.route '/services', (->
        @layout 'layout'
        @render 'services'
        ), name:'services'
    Router.route '/service/:doc_id/edit', (->
        @layout 'layout'
        @render 'service_edit'
        ), name:'service_edit'
    Router.route '/service/:doc_id/view', (->
        @layout 'layout'
        @render 'service_view'
        ), name:'service_view'



    Template.service_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.service_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.service_edit.events
        'click .add_service_item': ->
            new_mi_id = Docs.insert
                model:'service_item'
            Router.go "/service/#{_id}/edit"
    Template.service_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                service_id:@_id
    Template.service_edit.events


    Template.service_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.service_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.service_view.helpers
        choices: ->
            Docs.find
                model:'choice'
                service_id:@_id
        can_accept: ->
            console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    service_id: Router.current().params.doc_id
            if my_answer_session
                console.log 'false'
                false
            else
                console.log 'true'
                true

    Template.service_view.events
        'click .purchase': ->
            console.log @





    Template.services.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'service'
    Template.services.helpers
        services: ->
            Docs.find
                model:'service'




    Template.services.events
        'click .add_service': ->
            new_service_id = Docs.insert
                model:'service'
            Router.go "/service/#{new_service_id}/edit"



    Template.service_stats.events
        'click .refresh_service_stats': ->
            Meteor.call 'refresh_service_stats', @_id




if Meteor.isServer
    Meteor.publish 'services', (service_id)->
        Docs.find
            model:'service'
            service_id:service_id

    Meteor.methods
        refresh_service_stats: (service_id)->
            service = Docs.findOne service_id
            # console.log service
            reservations = Docs.find({model:'reservation', service_id:service_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_service_hours = 0
            average_service_duration = 0

            # shorservice_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_service_hours += parseFloat(res.hour_duration)

            average_service_cost = total_earnings/reservation_count
            average_service_duration = total_service_hours/reservation_count

            Docs.update service_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_service_hours: total_service_hours.toFixed(0)
                    average_service_cost: average_service_cost.toFixed(0)
                    average_service_duration: average_service_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header service ranking #reservations
            # .ui.small.header service ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg service time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
