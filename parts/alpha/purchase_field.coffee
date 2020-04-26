if Meteor.isClient
    Template.apurchase_edit.events
        'blur .inventory': (e,t)->
            val = parseInt t.$('.inventory').val()
            page_doc = Docs.findOne Router.current().params.doc_id
            Docs.update page_doc._id,
                $set:_inventory:val

        'blur .price': (e,t)->
            val = parseInt t.$('.price').val()
            page_doc = Docs.findOne Router.current().params.doc_id
            Docs.update page_doc._id,
                $set:_price:val

    Template.apurchase_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'order'
    Template.apurchase_view.helpers
        orders: ->
            Docs.find
                model:'order'
                product_id:Router.current().params.doc_id
    Template.apurchase_view.events
        'click .cancel': (e,t)->
            if confirm 'cancel?'
                page_doc = Docs.findOne Router.current().params.doc_id
                Meteor.users.update Meteor.userId(),
                    $inc:
                        credit: page_doc._price
                Meteor.users.update page_doc._author_id,
                    $inc:
                        credit: -page_doc._price
                Docs.update page_doc._id,
                    $inc:
                        _inventory: 1
                Docs.remove @_id


        'click .buy': (e,t)->
            if confirm 'buy?'
                page_doc = Docs.findOne Router.current().params.doc_id
                Meteor.users.update Meteor.userId(),
                    $inc:
                        credit: -page_doc._price
                Meteor.users.update page_doc._author_id,
                    $inc:
                        credit: page_doc._price
                Docs.update page_doc._id,
                    $inc:
                        _inventory: -1
                Docs.insert
                    model:'order'
                    product_id: page_doc._id
                    purchase_price:page_doc.price
                    buyer_id: Meteor.userId()
                    buyer_username: Meteor.user().username
                    seller_id: page_doc._author_id
                    seller_username: page_doc._author_username
