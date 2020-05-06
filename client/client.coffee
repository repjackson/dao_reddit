@selected_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []

Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    @autorun => Meteor.subscribe 'alerts'

Template.nav.events
    'click #add': ->
        new_id =
            Docs.insert
                model:'item'
        Router.go "/item/#{new_id}/edit"



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
