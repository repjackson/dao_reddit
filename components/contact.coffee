if Meteor.isClient
    Router.route '/contact/', (->
        @layout 'layout'
        @render 'contact'
        ), name:'contact'

    Template.contact.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'contact_submission'

    Template.contact.helpers
        contact_submissions: ->
            Docs.find
                model:'contact_submission'
    Template.contact.events
        'click .submit_message': ->
            message = $('.message').val()
            console.log message
            Docs.insert
                model:'contact_submission'
                message:message
