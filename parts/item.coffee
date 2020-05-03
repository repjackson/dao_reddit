if Meteor.isClient
    Router.route '/item/:doc_id/edit', (->
        @layout 'layout'
        @render 'item_edit'
        ), name:'item_edit'
    Template.item_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Router.route '/item/:doc_id/view', (->
        @layout 'layout'
        @render 'item_view'
        ), name:'item_view'


    Template.item_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.item_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.item_view.events
        'click .clone': ->
            if confirm 'clone this item?'
                new_id =
                    Docs.insert
                        model:'item'
                        tags:@tags
                        price:@price
                        image_id:@image_id
                Router.go "/item/#{new_id}/edit"


        'click .buy': ->
            if Meteor.userId()
                Swal.fire({
                    title: 'confirm purchase'
                    text: "this will charge you #{@price} credit"
                    icon: 'question'
                    showCancelButton: true,
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                }).then((result) =>
                    if result.value
                        # food = Docs.findOne Router.current().params.doc_id
                        Meteor.call 'purchase', @, ->
                )
            else
                Router.go "/login"





    Template.seller_card.helpers
        seller: ->
            console.log @valueOf()
            item = Docs.findOne Router.current().params.doc_id
            res =
                Meteor.users.findOne
                    _id:@valueOf()
            console.log res
            res
