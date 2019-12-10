if Meteor.isClient
    Router.route '/admin/', (->
        @layout 'admin_layout'
        @render 'latest_activity'
        ), name:'admin'
    Router.route '/dev_blog/', (->
        @layout 'admin_layout'
        @render 'dev_blog'
        ), name:'dev_blog'

    Template.admin_layout.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'admin_post'
        @autorun => Meteor.subscribe 'admins'

    Template.admin_layout.helpers
        admins: ->
            Meteor.users.find
                admin:true
        admin_posts: ->
            Docs.find {
                model:'admin_post'
            }, _timestamp:1


    Template.latest_activity.onCreated ->
        @autorun -> Meteor.subscribe 'latest_activity'
    Template.latest_activity.helpers
        latest_activity: ->
            Docs.find {
                model:'log_event'
            },
                sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'admins', ->
        Meteor.users.find
            admin:true

    Meteor.publish 'latest_activity', ->
        Docs.find {
            model:'log_event'
        },
            limit:20
            sort:_timestamp:-1
