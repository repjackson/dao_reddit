if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'
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
        # @autorun -> Meteor.subscribe 'model_docs', 'test'
        # @autorun -> Meteor.subscribe 'student_stats', Router.current().params.username
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000

    Template.profile_layout.helpers
        user: -> Meteor.users.findOne username:Router.current().params.username

    Template.user_dashboard.events
        'click .recalc_user_stats': ->
            Meteor.call 'recalc_user_stats', Router.current().params.username, ->

    Template.user_dashboard.helpers
        user_stats_doc: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'student_stats'
                user_id:user._id
        user_credits: ->
            Docs.find {
                model:'log_event'
                event_type:'credit'
            }, sort: _timestamp: -1
        user_debits: ->
            Docs.find {
                model:'log_event'
                event_type:'debit'
            }, sort: _timestamp: -1


    Template.profile_layout.events
        'click .logout_other_clients': -> Meteor.logoutOtherClients()
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
