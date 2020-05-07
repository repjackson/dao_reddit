if Meteor.isClient
    Router.route '/grid', (->
        @layout 'layout'
        @render 'grid'
        ), name:'grid'
    Template.grid.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'plugin'

    Template.grid.helpers
        installed_plugins: ->
            Docs.find
                model:'plugin'

    Template.grid.events
        'click .add_plugin': ->
            new_id =
                Docs.insert
                    model:'plugin'
            Router.go "/plugin/#{new_id}/edit"



# if Meteor.isServer
#     Meteor.methods
        # refresh_global_stats: ->
        #     found_stats = Docs.findOne
        #         model:'stats'
        #     if found_stats
        #         fsd = found_stats
        #     else
        #         new_id =
        #             Docs.insert
        #                 model:'stats'
        #         fsd = Docs.findOne new_id
        #
        #     total_doc_count = Docs.find({}).count()
        #     total_item_count = Docs.find({model:'item'}).count()
        #     total_sales_count =
        #         Docs.find(
        #             model:'item'
        #             bought:true
        #             ).count()
        #
        #     total_selling_count =
        #         Docs.find(
        #             model:'item'
        #             bought:$ne:true
        #             ).count()
        #     total_deposits =
        #         Docs.find(
        #             model:'deposit'
        #         )
        #     total_deposit_count =
        #         Docs.find(
        #             model:'deposit'
        #         ).count()
        #
        #     total_deposit_amount = 0
        #     for deposit in total_deposits.fetch()
        #         total_deposit_amount += deposit.deposit_amount
        #
        #     total_withdrawals =
        #         Docs.find(
        #             model:'withdrawal'
        #         )
        #     total_withdrawal_count =
        #         Docs.find(
        #             model:'withdrawal'
        #         ).count()
        #
        #     total_withdrawal_amount = 0
        #     for withdrawal in total_withdrawals.fetch()
        #         total_withdrawal_amount += withdrawal.amount
        #
        #     total_site_profit = total_deposit_amount-total_withdrawal_amount
        #
        #     Docs.update fsd._id,
        #         $set:
        #             total_doc_count:total_doc_count
        #             total_item_count:total_item_count
        #             total_selling_count:total_selling_count
        #             total_sales_count:total_sales_count
        #             total_deposit_count: total_deposit_count
        #             total_deposit_amount: total_deposit_amount
        #             total_withdrawal_amount: total_withdrawal_amount
        #             total_site_profit: total_site_profit
