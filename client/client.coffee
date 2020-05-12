@selected_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []



window.addEventListener('load', ()->
    if (window.Notification and Notification.permission isnt "granted")
        Notification.requestPermission((status)->
            if Notification.permission isnt status
                Notification.permission = status
    ))



Template.layout.onCreated ->
    Session.setDefault 'view_chat', false
Template.layout.onRendered ->
Template.layout.helpers
    view_chat: -> Session.get('view_chat')


Template.admin_footer.onCreated ->

Template.admin_footer.helpers
    doc_count: ->
        Docs.find().count()


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
