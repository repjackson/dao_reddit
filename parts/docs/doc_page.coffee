if Meteor.isClient
    Router.route '/doc/:doc_id/view', (->
        @layout 'layout'
        @render 'doc_page'
        ), name:'doc_page'



    Template.doc_page.onCreated ->
        # @autorun => Meteor.subscribe('doc', Router.current().params.doc_id)
        # Meteor.subscribe 'doc', Router.current().params.doc_id
        Meteor.subscribe 'current_doc', Router.current().params.doc_id
        Meteor.subscribe 'users'
        console.log @

    Template.doc_page.events
        'click .call_watson': ->
            Meteor.call 'call_watson', @_id, 'url', 'url'
        'click .call_watson_image': ->
            Meteor.call 'call_watson', @_id, 'url', 'image'
        'click .print_me': ->
            console.log @
        'click .pull_tone': ->
            Meteor.call 'call_tone', @_id, 'url', 'text', ->



if Meteor.isServer
    Meteor.publish 'current_doc', (doc_id)->
        Docs.find doc_id
