if Meteor.isClient
    Router.route '/alerts/', (->
        @layout 'layout'
        @render 'alerts'
        ), name:'alerts'
    Template.alerts.onCreated ->
        @autorun => Meteor.subscribe 'my_alerts'
        @autorun => Meteor.subscribe 'model_docs', 'alert'
    Template.alerts.helpers
        alerts: ->
            Docs.find {
                model:'alert'
            }, _timestamp:1
    Template.alerts.events
        'click .mark_all_read': ->
            Docs.find
                model:'alert'


    Template.alert.events
        'click .mark_read': ->
            Docs.update @_id,
                $addToSet:
                    reader_ids: Meteor.userId()


if Meteor.isServer
    Meteor.publish 'my_alerts', ->
        Docs.find
            model:'alert'
            user_id: Meteor.userId()



if Meteor.isClient
    Template.alerts.onRendered ->
        Meteor.setTimeout ->
            # $('.dropdown').dropdown(
            #     on:'click'
            # )
            $('.ui.dropdown').dropdown(
                clearable:true
                action: 'activate'
                onChange: (text,value,$selectedItem)->
                    )
        , 1000

    Template.alerts.helpers
        my_alerts: ->
            Docs.find
                model:'alert'
                target_username: Meteor.user().username
        alerts: ->
            Docs.find
                model:'alert'



    Template.alerts.events
        'click .submit_message': ->
            message = $('.message').val()
            console.log message
            Docs.insert
                model:'alerts'
                message:message
