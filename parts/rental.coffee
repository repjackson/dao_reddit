if Meteor.isClient
    Router.route '/rental/:doc_id/view', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'


    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'rental_reservations_by_id', Router.current().params.doc_id
    Template.rental_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->

    Template.rental_view.events

    Template.rental_view.helpers
        reservations: ->
            Docs.find
                model:'reservation'
                rental_id:Router.current().params.doc_id


    Template.res_day_button.helpers
        create_res_class: ->

            # date_string =  moment().add(2, 'days').format('dddd, MMMM Do')
            # console.log moment().date()+2
            # # console.log moment().day()
            # console.log moment().month()
            found_res =
                Docs.findOne
                    model:'reservation'
                    rental_id:Router.current().params.doc_id
                    # day: moment().day()+@offset
                    month: moment().month()
                    date: moment().date()+@offset
            if found_res
                'disabled'
            else
                'green'
    Template.res_day_button.events
        'click .create_res': ->
            new_id =
                Docs.insert
                    model:'reservation'
                    rental_id:Router.current().params.doc_id
                    month: moment().month()
                    date: moment().date()+@offset



if Meteor.isClient
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'
    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id




if Meteor.isServer
    Meteor.publish 'rental_reservations_by_id', (rental_id)->
        Docs.find
            model:'reservation'
            rental_id: rental_id

    Meteor.publish 'rentals', (product_id)->
        Docs.find
            model:'rental'
            product_id:product_id

    Meteor.publish 'reservation_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
        # for reservation in reservations
            # console.log 'id', reservation._id
            # console.log reservation.paid_amount
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'reservation_slot', (moment_ob)->
        rentals_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            rentals.return.push date_string
        rentals_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


    Meteor.methods
        refresh_rental_stats: (rental_id)->
            rental = Docs.findOne rental_id
            # console.log rental
            reservations = Docs.find({model:'reservation', rental_id:rental_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_rental_hours = 0
            average_rental_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_rental_hours += parseFloat(res.hour_duration)

            average_rental_cost = total_earnings/reservation_count
            average_rental_duration = total_rental_hours/reservation_count

            Docs.update rental_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_rental_hours: total_rental_hours.toFixed(0)
                    average_rental_cost: average_rental_cost.toFixed(0)
                    average_rental_duration: average_rental_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header rental ranking #reservations
            # .ui.small.header rental ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg rental time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
