if Meteor.isClient
    Router.route '/badges', (->
        @layout 'layout'
        @render 'badges'
        ), name:'badges'
    Router.route '/badge/:doc_id/edit', (->
        @layout 'layout'
        @render 'badge_edit'
        ), name:'badge_edit'

    Template.badge_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id



    Template.badges.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'badge'
        @autorun => Meteor.subscribe 'all_users'

    Template.badges.helpers
        global_stats: ->
            Docs.findOne
        users: ->
            Meteor.users.find({credit:$gt:1},
                sort:credit:-1)

    Template.badges.events
        'click .add_badge': ->
            new_id =
                Docs.insert
                    model:'badge'
            Router.go "/badge/#{new_id}/edit"


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
