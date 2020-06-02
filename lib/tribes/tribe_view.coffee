Router.route '/tribe/:tribe_slug', (->
    @layout 'tribe_layout'
    @render 'tribe_dashboard'
    ), name:'tribe_dashboard'
Router.route '/tribe/:tribe_slug/members', (->
    @layout 'tribe_layout'
    @render 'tribe_members'
    ), name:'tribe_members'
Router.route '/tribe/:tribe_slug/credit', (->
    @layout 'tribe_layout'
    @render 'tribe_credit'
    ), name:'tribe_credit'
Router.route '/tribe/:tribe_slug/meals', (->
    @layout 'tribe_layout'
    @render 'tribe_meals'
    ), name:'tribe_meals'
Router.route '/tribe/:tribe_slug/dishes', (->
    @layout 'tribe_layout'
    @render 'tribe_dishes'
    ), name:'tribe_dishes'
Router.route '/tribe/:tribe_slug/voting', (->
    @layout 'tribe_layout'
    @render 'tribe_voting'
    ), name:'tribe_voting'
Router.route '/tribe/:tribe_slug/events', (->
    @layout 'tribe_layout'
    @render 'tribe_events'
    ), name:'tribe_events'
Router.route '/tribe/:tribe_slug/food', (->
    @layout 'tribe_layout'
    @render 'tribe_food'
    ), name:'tribe_food'
Router.route '/tribe/:tribe_slug/products', (->
    @layout 'tribe_layout'
    @render 'tribe_products'
    ), name:'tribe_products'
Router.route '/tribe/:tribe_slug/services', (->
    @layout 'tribe_layout'
    @render 'tribe_services'
    ), name:'tribe_services'
Router.route '/tribe/:tribe_slug/stats', (->
    @layout 'tribe_layout'
    @render 'tribe_stats'
    ), name:'tribe_stats'
Router.route '/tribe/:tribe_slug/transactions', (->
    @layout 'tribe_layout'
    @render 'tribe_transactions'
    ), name:'tribe_transactions'
Router.route '/tribe/:tribe_slug/messages', (->
    @layout 'tribe_layout'
    @render 'tribe_messages'
    ), name:'tribe_messages'
Router.route '/tribe/:tribe_slug/posts', (->
    @layout 'tribe_layout'
    @render 'tribe_posts'
    ), name:'tribe_posts'
Router.route '/tribe/:tribe_slug/settings', (->
    @layout 'tribe_layout'
    @render 'tribe_settings'
    ), name:'tribe_settings'



if Meteor.isClient
    Template.tribe_layout.onCreated ->
        @autorun => Meteor.subscribe 'tribe_by_slug', Router.current().params.tribe_slug
        # @autorun => Meteor.subscribe 'children', 'tribe_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'tribe_dishes', Router.current().params.tribe_slug
    Template.tribe_layout.helpers
        current_tribe: ->
            Docs.findOne
                model:'tribe'
                slug: Router.current().params.tribe_slug

    Template.tribe_dashboard.events
        'click .refresh_tribe_stats': ->
            Meteor.call 'calc_tribe_stats', Router.current().params.tribe_slug, ->
        # 'click .join': ->
        #     Docs.update
        #         model:'tribe'
        #         _author_id: Meteor.userId()
        # 'click .tribe_leave': ->
        #     my_tribe = Docs.findOne
        #         model:'tribe'
        #         _author_id: Meteor.userId()
        #         ballot_id: Router.current().params.doc_id
        #     if my_tribe
        #         Docs.update my_tribe._id,
        #             $set:value:'no'
        #     else
        #         Docs.insert
        #             model:'tribe'
        #             ballot_id: Router.current().params.doc_id
        #             value:'no'


if Meteor.isServer
    Meteor.publish 'tribe_dishes', (tribe_slug)->
        tribe = Docs.findOne
            model:'tribe'
            slug:tribe_slug
        Docs.find
            model:'dish'
            _id: $in: tribe.dish_ids
