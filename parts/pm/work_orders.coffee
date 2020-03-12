Router.route '/work_orders', (->
    @render 'work_orders'
    ), name:'work_orders'
Router.route '/work_order/:doc_id/view', (->
    @render 'work_order_view'
    ), name:'work_order_view'
Router.route '/work_order/:doc_id/edit', (->
    @render 'work_order_edit'
    ), name:'work_order_edit'


if Meteor.isClient
    Template.work_orders.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'work_order'
        @autorun => Meteor.subscribe 'model_docs', 'work_order_stats'

    Template.work_order_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work_order_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work_orders.helpers
        wos_doc: ->
            Docs.findOne
                model:'work_order_stats'
        work_orders: ->
            Docs.find
                model:'work_order'
    Template.work_orders.events
        'click .add_work_order': ->
            new_id = Docs.insert
                model:'work_order'
            Router.go "/work_order/#{new_id}/edit"

    Template.work_order_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.work_order_history.helpers
        work_order_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id


    Template.wo_subscription.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.wo_subscription.events
        'click .subscribe': ->
            Docs.insert
                model:'log_event'
                log_type:'subscribe'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} subscribed to work order."


    Template.wo_time.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.wo_time.events
        'click .mark_complete': ->
            if confirm 'mark complete?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        complete:true
                        complete_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type:'complete'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} marked work order complete."


if Meteor.isServer
    Meteor.methods
        calc_work_order_stats: ->
            work_order_stat_doc = Docs.findOne(model:'work_order_stats')
            unless work_order_stat_doc
                new_id = Docs.insert
                    model:'work_order_stats'
                work_order_stat_doc = Docs.findOne(model:'work_order_stats')
            console.log work_order_stat_doc
            total_count = Docs.find(model:'work_order').count()
            complete_count = Docs.find(model:'work_order', complete:true).count()
            incomplete_count = Docs.find(model:'work_order', complete:$ne:true).count()
            Docs.update work_order_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
