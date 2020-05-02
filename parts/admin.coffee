if Meteor.isClient
    Router.route '/admin', (->
        @layout 'layout'
        @render 'admin'
        ), name:'admin'
    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        @autorun => Meteor.subscribe 'model_docs', 'stats'

    Template.admin.helpers
        global_stats: ->
            Docs.findOne
                model:'stats'
        withdrawals: ->
            Docs.find
                model:'withdrawal'

    Template.admin.events
        'click .refresh_stats': ->
            Meteor.call 'refresh_global_stats', ->



if Meteor.isServer
    Meteor.methods
        refresh_global_stats: ->
            found_stats = Docs.findOne
                model:'stats'
            if found_stats
                fsd = found_stats
            else
                new_id =
                    Docs.insert
                        model:'stats'
                fsd = Docs.findOne new_id

            total_doc_amount = Docs.find({}).count()
            total_item_amount = Docs.find({model:'item'}).count()
            total_sales_amount =
                Docs.find(
                    model:'item'
                    bought:true
                    ).count()

            total_selling_amount =
                Docs.find(
                    model:'item'
                    bought:$ne:true
                    ).count()

            Docs.update fsd._id,
                $set:
                    total_doc_amount:total_doc_amount
                    total_item_amount:total_item_amount
                    total_selling_amount:total_selling_amount
                    total_sales_amount:total_sales_amount
