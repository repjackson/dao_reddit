# Router.route '/tasks', -> @render 'tasks'
Router.route '/tribes/', -> @render 'tribes'
Router.route '/tribe/:doc_id/view', -> @render 'tribe_view'
Router.route '/tribe/:doc_id/edit', -> @render 'tribe_edit'


if Meteor.isClient
    Template.tribes.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'tribe'

    Template.tribe_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.tribe_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.tribe_card_template.onCreated ->
        @autorun => Meteor.subscribe 'children', 'tribe_update', @data._id
    Template.tribe_card_template.helpers
        updates: ->
            Docs.find
                model:'tribe_update'
                parent_id: @_id


    Template.tribe_view.onCreated ->
        @autorun => Meteor.subscribe 'children', 'tribe_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'members', Router.current().params.doc_id
    Template.tribe_view.helpers
        options: ->
            Docs.find
                model:'tribe_option'
        tribes: ->
            Docs.find
                model:'tribe'
                ballot_id: Router.current().params.doc_id

    Template.tribe_view.events
        'click .join': ->
            Docs.update
                model:'tribe'
                _author_id: Meteor.userId()
        'click .tribe_leave': ->
            my_tribe = Docs.findOne
                model:'tribe'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_tribe
                Docs.update my_tribe._id,
                    $set:value:'no'
            else
                Docs.insert
                    model:'tribe'
                    ballot_id: Router.current().params.doc_id
                    value:'no'

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


    Template.tribes.helpers
        tribes: ->
            Docs.find
                model:'tribe'
        latest_comments: ->
            Docs.find {
                model:'comment'
                parent_model:'tribe'
            },
                limit:5
                sort:_timestamp:-1
        tribe_stats_doc: ->
            Docs.findOne
                model:'tribe_stats'

    Template.tribes.events
        'click .add_tribe': ->
            new_id = Docs.insert
                model:'tribe'
            Router.go "/tribe/#{new_id}/edit"

        'click .recalc_tribes': ->
            Meteor.call 'recalc_tribes', ->

    Template.latest_tribe_updates.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'tribe_update'

    Template.latest_tribe_updates.helpers
        latest_updates: ->
            Docs.find {
                model:'tribe_update'
            },
                limit:5
                sort:_timestamp:-1






if Meteor.isServer
    Meteor.publish 'members', (tribe_id)->
        Meteor.users.find
            _id:$in:@member_ids
