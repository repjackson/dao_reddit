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
        @autorun => Meteor.subscribe 'doc_matches', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.item_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.item_view.helpers
        matches: ->
            if @match_ids
                Docs.find
                    _id: $in:@match_ids
    Template.item_view.events
        'click .clone': ->
            Swal.fire({
                title: "clone #{@title}"
                text: "this will copy content into a new doc"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    # food = Docs.findOne Router.current().params.doc_id
                    new_id =
                        Docs.insert
                            model:'item'
                            title:@title
                            tags:@tags
                            price:@price
                            image_id:@image_id
                    Router.go "/item/#{new_id}/edit"
            )

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
                        Meteor.call 'purchase', @, =>
                            $('body').toast({
                                class:'success'
                                title: 'purchase confirmed',
                                message: "#{@title}"
                                showProgress: 'bottom',
                                classProgress: 'blue'

                            })
                )
            else
                Router.go "/login"


        'click .recalc_similar_items': ->
            Meteor.call 'recalc_similar_items', @, ->


    Template.seller_card.helpers
        seller: ->
            # console.log @valueOf()
            item = Docs.findOne Router.current().params.doc_id
            res =
                Meteor.users.findOne
                    _id:@valueOf()
            # console.log res
            res


if Meteor.isServer
    Meteor.publish 'doc_matches', (doc_id)->
        doc = Docs.find doc_id
        Docs.find
            _id:$in:doc.match_ids
    Meteor.methods
        recalc_similar_items:(item)->
            console.log item
            item.tags
            all_items =
                Docs.find
                    model:'item'
            matches = []
            for this_item in all_items.fetch()
                union_count = _.union this_item.tags, item.tags
                console.log union_count
                if union_count.length > 0
                    matches.push {
                        _id:this_item._id
                        count:union_count.length
                    }
            Docs.update item._id,
                $set:matches:matches
