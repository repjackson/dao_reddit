if Meteor.isClient
    Router.route '/alpha/:doc_id/edit', (->
        @layout 'layout'
        @render 'alpha_doc_edit'
        ), name:'alpha_doc_edit'
    Template.alpha_doc_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'block'
        @autorun => Meteor.subscribe 'model_docs', 'module'

    Template.module_edit.helpers
        alpha_field_edit: ->
            console.log @
            "a#{@block_slug}_edit"
        viewing_module: ->
            Session.equals('expand_module', @_id)

    Template.module_edit.events
        'click .toggle_section': ->
            if Session.equals('expand_module', @_id)
                Session.set('expand_module', null)
            else
                Session.set('expand_module', @_id)
    Template.alpha_doc_edit.helpers
        blocks: ->
            Docs.find
                model:'block'

        modules: ->
            Docs.find
                model:'module'
                parent_id: Router.current().params.doc_id


    Template.alpha_doc_edit.events
        'click .print_this': ->
            console.log @

        'click .add_module': ->
            Docs.insert
                model:'module'
                parent_id: Router.current().params.doc_id
                block_slug:@slug
                block_title:@title
                block_id:@_id

        'click .remove_module': ->
            if confirm 'delete?'
                Docs.remove @_id
