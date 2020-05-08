if Meteor.isClient
    Router.route '/class/:doc_id/edit', (->
        @layout 'layout'
        @render 'class_edit'
        ), name:'class_edit'
    Router.route '/class/:doc_id/view', (->
        @layout 'layout'
        @render 'class_view'
        ), name:'class_view'

    Template.class_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.class_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'class_module'

    Template.class_view.helpers
        class_modules: ->
            Docs.find
                model:'class_module'
    Template.class_view.events
        'click .add_module': ->
            Docs.insert
                model:'class_module'
                class_id: Router.current().params.doc_id
