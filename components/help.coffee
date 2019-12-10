if Meteor.isClient
    Router.route '/help/', (->
        @layout 'layout'
        @render 'help'
        ), name:'help'

    Template.help.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'help_document'
        @autorun => Meteor.subscribe 'model_docs', 'ticket'

    Template.help.helpers
        help_document: ->
            Docs.find {
                model:'donation'
            }, _timestamp:1
        tickets: ->
            Docs.find {
                model:'ticket'
            }, _timestamp:1
            
    Template.help.events
