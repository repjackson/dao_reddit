@selected_tags = new ReactiveArray []
@selected_timestamp_tags = new ReactiveArray []

Router.route '/', (->
    @redirect('/m/model');
)

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
