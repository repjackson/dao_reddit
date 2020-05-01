if Meteor.isClient
    Router.route '/admin', (->
        @layout 'layout'
        @render 'admin'
        ), name:'admin'
    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'

    Template.admin.helpers
        withdrawals: ->
            Docs.find
                model:'withdrawal'
