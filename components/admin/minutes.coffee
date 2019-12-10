# Router.route '/tasks', -> @render 'tasks'
Router.route '/minutes', (->
    @layout 'admin_layout'
    @render 'minutes'
    ), name:'minutes'

Router.route '/minute/:doc_id/view', -> @render 'minute_view'
Router.route '/minute/:doc_id/edit', -> @render 'minute_edit'


if Meteor.isClient
    Template.minutes.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'minute'

    Template.minute_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'project'
        @autorun => Meteor.subscribe 'users_by_role', 'board_member'
        @autorun => Meteor.subscribe 'minute_updates', Router.current().params.doc_id

    Template.minute_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 3000
    Template.minute_edit.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'project'
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'users_by_role', 'board_member'
        @autorun => Meteor.subscribe 'minute_updates', Router.current().params.doc_id

    Template.minute_view.helpers
        board_members: ->
            Meteor.users.find
                roles:$in:['board_member']
        old_business_updates: ->
            Docs.find
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'old'
        need_for_direction_updates: ->
            Docs.find
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'need_for_direction'

        new_business_updates: ->
            Docs.find
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'new'

    Template.minute_edit.helpers
        board_members: ->
            Meteor.users.find
                roles:$in:['board_member']
        old_business_updates: ->
            Docs.find
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'old'
        need_for_direction_updates: ->
            Docs.find
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'need_for_direction'
        new_business_updates: ->
            Docs.find
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'new'

    Template.minute_edit.events
        'click .call_to_order': ->
            console.log @
            # Docs.update Router.current().params.doc_id,
            Docs.update @_id,
                $set:
                    called_to_order:true
                    called_to_order_timestamp: Date.now()
        'click .add_need_for_direction_update': ->
            current_minute = Docs.findOne(Router.current().params.doc_id)
            # console.log 'current minute', current_minute
            Docs.insert
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'need_for_direction'
                update_date: current_minute.meeting_date
        'click .add_old_business_update': ->
            current_minute = Docs.findOne(Router.current().params.doc_id)
            # console.log 'current minute', current_minute
            Docs.insert
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'old'
                update_date: current_minute.meeting_date
        'click .add_new_business_update': ->
            current_minute = Docs.findOne(Router.current().params.doc_id)
            # console.log 'current minute', current_minute
            Docs.insert
                model:'project_update'
                minute_id: Router.current().params.doc_id
                business_type:'new'
                update_date: current_minute.meeting_date

    Template.minutes.helpers
        minutes: ->
            Docs.find {
                model:'minute'
            }, sort:meeting_date:-1
    Template.minutes.events
        'click .add_minute': ->
            new_id = Docs.insert
                model:'minute'
            Router.go "/minute/#{new_id}/edit"




if Meteor.isServer
    Meteor.publish 'minute_updates', (minute_id)->
        Docs.find
            model:'project_update'
            minute_id: minute_id
