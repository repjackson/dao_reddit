if Meteor.isClient
    Router.route '/reservation/:doc_id/view', (->
        @render 'reservation_view'
        ), name:'reservation_view'

    # Template.kiosk_reservation_view.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.reservation_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id


    Template.reservation_events.onCreated ->
        @autorun => Meteor.subscribe 'log_events', Router.current().params.doc_id
    Template.reservation_events.helpers
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id


    Template.rental_stats.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000




if Meteor.isServer
    Meteor.publish 'log_events', (parent_id)->
        Docs.find
            model:'log_event'
            parent_id:parent_id

    Meteor.publish 'reservations_by_product_id', (product_id)->
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'rental_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        if reservation
            Docs.find
                model:'rental'
                _id: reservation.rental_id

    Meteor.publish 'owner_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        rental =
            Docs.findOne
                model:'rental'
                _id: reservation.rental_id

        Meteor.users.find
            _id: rental.owner_username

    Meteor.publish 'handler_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        rental =
            Docs.findOne
                model:'rental'
                _id: reservation.rental_id

        Meteor.users.find
            _id: rental.handler_username

    Meteor.methods
        calc_reservation_stats: ->
            reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            unless reservation_stat_doc
                new_id = Docs.insert
                    model:'reservation_stats'
                reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            console.log reservation_stat_doc
            total_count = Docs.find(model:'reservation').count()
            submitted_count = Docs.find(model:'reservation', submitted:true).count()
            current_count = Docs.find(model:'reservation', current:true).count()
            unsubmitted_count = Docs.find(model:'reservation', submitted:$ne:true).count()
            Docs.update reservation_stat_doc._id,
                $set:
                    total_count:total_count
                    submitted_count:submitted_count
                    current_count:current_count
