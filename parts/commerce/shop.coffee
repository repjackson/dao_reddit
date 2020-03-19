if Meteor.isClient
    Router.route '/shop', (->
        @render 'shop'
        ), name:'shop'



    Template.shop.onCreated ->
        @autorun -> Meteor.subscribe 'shop_docs', selected_shop_tags.array()
        @autorun -> Meteor.subscribe 'model_docs', 'product'
        @autorun -> Meteor.subscribe 'products'

    Template.shop.events
        'click .add_product': ->
            new_id = Docs.insert
                model:'product'
            Router.go "/product/#{new_id}/edit"
    Template.shop.helpers
        products: ->
            Docs.find
                model:'product'
                product_id:Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'products', ->
        Docs.find
            model:'product'
