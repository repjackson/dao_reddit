if Meteor.isClient
    Router.route '/shop', (->
        @render 'shop'
        ), name:'shop'



    Template.shop.onCreated ->
        @autorun -> Meteor.subscribe 'shop_docs', selected_shop_tags.array()
    Template.shop.helpers
        shop_items: ->
            Docs.find
                model:'rental'
                product_id:Router.current().params.doc_id
