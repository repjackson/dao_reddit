@selected_tags = new ReactiveArray []
@selected_timestamp_tags = new ReactiveArray []

Router.route '/', (->
    @redirect('/m/model');
)

Template.body.events
    'click a': ->
        $('.global_container')
        .transition('fade out', 250)
        .transition('fade in', 250)


    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1
