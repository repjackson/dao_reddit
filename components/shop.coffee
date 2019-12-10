if Meteor.isClient
    Router.route '/shop', (->
        @layout 'layout'
        @render 'shop'
        ), name:'shop'
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'
    Router.route '/product/:doc_id/view', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'



    Template.product_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.product_edit.events
        'click .add_product_item': ->
            new_mi_id = Docs.insert
                model:'product_item'
            Router.go "/product/#{_id}/edit"
    Template.product_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                product_id:@_id
    Template.product_edit.events


    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.product_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.product_view.helpers
        choices: ->
            Docs.find
                model:'choice'
                product_id:@_id
        can_accept: ->
            console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    product_id: Router.current().params.doc_id
            if my_answer_session
                console.log 'false'
                false
            else
                console.log 'true'
                true

    Template.product_view.events
        'click .purchase': ->
            console.log @





    Template.shop.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.shop.helpers
        products: ->
            Docs.find
                model:'product'




    Template.shop.events
        'click .add_product': ->
            new_product_id = Docs.insert
                model:'product'
            Router.go "/product/#{new_product_id}/edit"



    Template.product_stats.events
        'click .refresh_product_stats': ->
            Meteor.call 'refresh_product_stats', @_id




if Meteor.isServer
    Meteor.publish 'shop', (product_id)->
        Docs.find
            model:'product'
            product_id:product_id

    Meteor.methods
        refresh_product_stats: (product_id)->
            product = Docs.findOne product_id
            # console.log product
            reservations = Docs.find({model:'reservation', product_id:product_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_product_hours = 0
            average_product_duration = 0

            # shorproduct_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_product_hours += parseFloat(res.hour_duration)

            average_product_cost = total_earnings/reservation_count
            average_product_duration = total_product_hours/reservation_count

            Docs.update product_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_product_hours: total_product_hours.toFixed(0)
                    average_product_cost: average_product_cost.toFixed(0)
                    average_product_duration: average_product_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header product ranking #reservations
            # .ui.small.header product ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg product time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
