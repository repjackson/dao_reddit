if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/credit', (->
        @layout 'profile_layout'
        @render 'user_credit'
        ), name:'user_credit'
    Router.route '/user/:username/feed', (->
        @layout 'profile_layout'
        @render 'user_feed'
        ), name:'user_feed'
    Router.route '/user/:username/sales', (->
        @layout 'profile_layout'
        @render 'user_sales'
        ), name:'user_sales'
    Router.route '/user/:username/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:username/purchases', (->
        @layout 'profile_layout'
        @render 'user_purchases'
        ), name:'user_purchases'



if Meteor.isClient
    Template.user_sales.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'item'
    Template.user_sales.events

    Template.user_sales.helpers
        sales: ->
            Docs.find
                model:'item'
                bought:true
                _author_id:Meteor.userId()
    Template.sale_segment.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data.product_id




    Template.user_purchases.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'item'
    Template.user_purchases.events

    Template.user_purchases.helpers
        purchased_today: ->
            now = Date.now()
            day = 60**60*24
            last_day = now-day
            yesterday_purchases =
                Docs.find
                    model:'item'
                    bought:true
                    bought_timestamp:$gte:last_day
            fetched = yesterday_purchases.fetch()
            res = 0
            for purchase in fetched
                res += purchase.price
            res

        purchased_yesterday: ->
            now = Date.now()
            day = 60*60*24
            last_day = now-day
            yesterday_purchases =
                Docs.find
                    model:'item'
                    bought:true
                    bought_timestamp:$lte:last_day
            fetched = yesterday_purchases.fetch()
            res = 0
            for purchase in fetched
                res += purchase.price
            res


        purchased_this_week: ->
            now = Date.now()
            week = 60*60*24*7
            last_week = now-week
            weekly_purchases =
                Docs.find
                    model:'item'
                    bought:true
                    bought_timestamp:$lte:last_week
            fetched = weekly_purchases.fetch()
            res = 0
            for purchase in fetched
                res += purchase.price
            res


        purchased_this_month: ->
            now = Date.now()
            month = 60*60*24*30
            last_month = now-month
            weekly_purchases =
                Docs.find
                    model:'item'
                    bought:true
                    bought_timestamp:$lte:now
            fetched = weekly_purchases.fetch()
            res = 0
            for purchase in fetched
                res += purchase.price
            res


        purchases: ->
            Docs.find {
                model:'item'
                bought:true
                buyer_id:Meteor.userId()
            },
                sort:bought_timestamp:-1
    Template.purchase_segment.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data.product_id









    Template.profile_layout.helpers
        user: -> Meteor.users.findOne username:Router.current().params.username
    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'user_stats'
    Template.user_dashboard.events
        'click .recalc_user_stats': ->
            Meteor.call 'recalc_user_stats', Router.current().params.username, ->

    Template.user_dashboard.helpers
        user_stats_doc: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'user_stats'
                user_id:user._id
        user_credits: ->
            Docs.find {
                model:'item'
                bought:true
                _author_id:Meteor.userId()
            }, sort: bought_timestamp: -1
        user_debits: ->
            Docs.find {
                model:'item'
                bought:true
                buyer_id:Meteor.userId()
            }, sort: bought_timestamp: -1






    Template.last_bought.helpers
        last_bought: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'item'
                bought:true
                buyer_id:user._id
    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'item'
    Template.user_dashboard.events
        'click .recalc_user_stats': ->
            Meteor.call 'recalc_user_stats', Router.current().params.username, ->










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
