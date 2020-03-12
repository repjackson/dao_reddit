if Meteor.isClient
    Router.route '/post/:doc_id/view', (->
        @layout 'layout'
        @render 'post_page'
        ), name:'post_page'



    Template.post_page.onCreated ->
        # @autorun => Meteor.subscribe('doc', Router.current().params.doc_id)
        # Meteor.subscribe 'doc', Router.current().params.doc_id
        Meteor.subscribe 'current_doc', Router.current().params.doc_id
        Meteor.subscribe 'users'
        console.log @


if Meteor.isServer
    Meteor.publish 'current_doc', (doc_id)->
        Docs.find doc_id
