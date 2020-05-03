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
    Template.item_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
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
