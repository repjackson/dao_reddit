if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'
    Router.route '/user/:username/about', (->
        @layout 'profile_layout'
        @render 'user_about'
        ), name:'user_about'
    Router.route '/user/:username/finance', (->
        @layout 'profile_layout'
        @render 'user_finance'
        ), name:'user_finance'
    Router.route '/user/:username/cart', (->
        @layout 'profile_layout'
        @render 'user_cart'
        ), name:'user_cart'
    Router.route '/user/:username/payment', (->
        @layout 'profile_layout'
        @render 'user_payment'
        ), name:'user_payment'
    Router.route '/user/:username/feed', (->
        @layout 'profile_layout'
        @render 'user_feed'
        ), name:'user_feed'
    Router.route '/user/:username/transactions', (->
        @layout 'profile_layout'
        @render 'user_transactions'
        ), name:'user_transactions'
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/bookmarks', (->
        @layout 'profile_layout'
        @render 'user_bookmarks'
        ), name:'user_bookmarks'
    Router.route '/user/:username/social', (->
        @layout 'profile_layout'
        @render 'user_social'
        ), name:'user_social'
    Router.route '/user/:username/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:username/orders', (->
        @layout 'profile_layout'
        @render 'user_orders'
        ), name:'user_orders'


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
        user_finances: ->
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
        'click .profile_image': (e,t)->
            $(e.currentTarget).closest('.profile_image').transition(
                animation: 'jiggle'
                duration: 750
            )
        'click .logout_other_clients': -> Meteor.logoutOtherClients()
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
