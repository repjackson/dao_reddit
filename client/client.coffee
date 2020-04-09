@selected_tags = new ReactiveArray []
@selected_shop_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []
@selected_subreddits = new ReactiveArray []
@selected_timestamp_tags = new ReactiveArray []

@selected_covid_tags = new ReactiveArray []
# Accounts.ui.config
#     passwordSignupFields: 'USERNAME_ONLY'

Router.route '/', (->
    @layout 'layout'
    @render 'docs'
    ), name:'docs'

Template.body.events
    'click a': ->
        $('.global_container')
        .transition('fade out', 250)
        .transition('fade in', 500)

    # 'click .result': ->
    #     $('.global_container')
    #     .transition('fade out', 250)
    #     .transition('fade in', 250)

    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1

# Template.registerHelper 'my_cart_items', () ->
#     found_items =
#         Docs.find
#             model:'cart_item'
#             _author_id: Meteor.userId()
#     console.log 'found items count', found_items.fetch()
#     found_items


Template.sidebar.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context.example .ui.sidebar')
                    .sidebar({
                        context: $('.context.example .bottom.segment')
                        dimPage: false
                        transition:  'push'
                    })
                    .sidebar('attach events', '.context.example .menu .toggle_sidebar.item')
            , 500
