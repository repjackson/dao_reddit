Router.route '/tribe/:doc_id/edit', -> @render 'tribe_edit'

if Meteor.isClient
    Template.tribe_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'tribe_options', Router.current().params.doc_id
    Template.tribe_edit.events
        'click .add_option': ->
            Docs.insert
                model:'tribe_option'
                ballot_id: Router.current().params.doc_id
    Template.tribe_edit.helpers
        options: ->
            Docs.find
                model:'tribe_option'
