if Meteor.isClient
    Template.nav.onCreated ->
        # @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'model_docs', 'global_stats'

    Template.add_to_cart.events
        'click .add_to_cart': ->
            product = Docs.findOne Router.current().params.doc_id
            console.log @
            Docs.insert
                model:'cart_item'
                product_id: product._id
            $('body').toast({
                message: "added to cart"
                class:'success'
                position: 'top right'
            })
