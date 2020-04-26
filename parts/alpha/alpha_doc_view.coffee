if Meteor.isClient
    Router.route '/alpha/:doc_id/view', (->
        @layout 'layout'
        @render 'alpha_doc_view'
        ), name:'alpha_doc_view'


    Template.alpha_doc_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'block'
        @autorun => Meteor.subscribe 'model_docs', 'module'



    Template.module_view.helpers
        alpha_field_view: ->
            # console.log @
            "a#{@block_slug}_view"

    Template.alpha_doc_view.helpers
        blocks: ->
            Docs.find
                model:'block'

        modules: ->
            Docs.find
                model:'module'
                parent_id: Router.current().params.doc_id
