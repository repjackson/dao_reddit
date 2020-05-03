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
    Router.route '/user/:username/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:username/orders', (->
        @layout 'profile_layout'
        @render 'user_orders'
        ), name:'user_orders'



if Meteor.isClient
    Template.user_orders.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'order'
    Template.user_orders.events

    Template.user_orders.helpers
        orders: ->
            Docs.find
                model:'order'
                _author_id:Meteor.userId()


    Template.order_segment.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data.product_id


    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_stats', Router.current().params.username
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000

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


    Template.profile_layout.events
        'click .logout_other_clients': -> Meteor.logoutOtherClients()
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()






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

            Docs.update fsd._id,
                $set:
                    total_doc_count:total_doc_count
                    total_item_count:total_item_count
                    total_selling_count:total_selling_count
                    total_sales_count:total_sales_count
                    total_deposit_count: total_deposit_count
                    total_deposit_amount: total_deposit_amount
                    total_withdrawal_amount: total_withdrawal_amount
                    total_site_profit: total_site_profit
