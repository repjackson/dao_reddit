if Meteor.isClient
    Router.route '/shop', (->
        @render 'shop'
        ), name:'shop'



    Template.shop.onCreated ->
        @autorun -> Meteor.subscribe 'shop_docs', selected_shop_tags.array()
    Template.shop.events
        'click .add_product': ->
            new_id = Docs.insert
                model:'product'
            Router.go "/product/#{new_id}/edit"
    Template.shop.helpers
        shop_items: ->
            Docs.find
                model:'rental'
                product_id:Router.current().params.doc_id
