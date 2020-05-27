if Meteor.isClient
    Router.route '/user/:username/orders', (->
        @layout 'profile'
        @render 'user_orders'
        ), name:'user_orders'


    Template.user_orders.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'order'
        @autorun => Meteor.subscribe 'model_docs', 'dish'
        @autorun => Meteor.subscribe 'model_docs', 'meal'


    Template.user_orders.onRendered ->

    Template.user_orders.helpers
    Template.user_orders.events
        'click .create_order': ->
            new_order_id =
                Docs.insert
                    model:'order'
            Router.go("/order/#{new_order_id}/edit")
