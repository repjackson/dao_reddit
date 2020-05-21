if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'user_dashboard'

if Meteor.isClient
    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_stats', Router.current().params.username
    Template.profile.onRendered ->


    Template.profile.events
        'click .logout_other_clients': -> Meteor.logoutOtherClients()
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()


    Template.profile.helpers
        user: -> Meteor.users.findOne username:Router.current().params.username




if Meteor.isServer
    Meteor.methods
        recalc_user_stats: (username)->
            user = Meteor.users.findOne username:username
            found_stats = Docs.findOne
                model:'user_stats'
                user_id:user._id
            if found_stats
                fsd = found_stats
            else
                new_id =
                    Docs.insert
                        model:'user_stats'
                        user_id:user._id
                fsd = Docs.findOne new_id

            total_doc_count = Docs.find({}).count()
            total_item_count = Docs.find({model:'item'}).count()
            total_sales_count =
                Docs.find(
                    model:'item'
                    bought:true
                    _author_id:user._id
                    ).count()

            total_selling_count =
                Docs.find(
                    model:'item'
                    bought:$ne:true
                    _author_id:user._id
                    ).count()
            total_deposits =
                Docs.find(
                    model:'deposit'
                    _author_id:user._id
                )
            total_deposit_count =
                Docs.find(
                    model:'deposit'
                    _author_id:user._id
                ).count()

            total_deposit_amount = 0
            for deposit in total_deposits.fetch()
                total_deposit_amount += deposit.deposit_amount

            total_withdrawals =
                Docs.find(
                    model:'withdrawal'
                    _author_id:user._id
                )
            total_withdrawal_count =
                Docs.find(
                    model:'withdrawal'
                    _author_id:user._id
                ).count()

            total_withdrawal_amount = 0
            for withdrawal in total_withdrawals.fetch()
                total_withdrawal_amount += withdrawal.amount

            total_site_profit = total_deposit_amount-total_withdrawal_amount



            total_sales =
                Docs.find(
                    model:'item'
                    bought:true
                    _author_id:user._id
                )
            total_sale_count =
                Docs.find(
                    model:'item'
                    model:true
                    _author_id:user._id
                ).count()

            total_sale_amount = 0
            for sale in total_sales.fetch()
                total_sale_amount += sale.price



            total_purchases =
                Docs.find(
                    model:'item'
                    bought:true
                    buyer_id:user._id
                )
            total_purchase_count =
                Docs.find(
                    model:'item'
                    model:true
                    buyer_id:user._id
                ).count()

            total_purchase_amount = 0
            for purchase in total_purchases.fetch()
                total_purchase_amount += purchase.price





            Docs.update fsd._id,
                $set:
                    total_purchase_amount:total_purchase_amount
                    total_sale_amount:total_sale_amount
                    total_doc_count:total_doc_count
                    total_item_count:total_item_count
                    total_selling_count:total_selling_count
                    total_sales_count:total_sales_count
                    total_deposit_count: total_deposit_count
                    total_deposit_amount: total_deposit_amount
                    total_withdrawal_amount: total_withdrawal_amount
                    total_site_profit: total_site_profit
