if Meteor.isClient
    Router.route '/alpha', (->
        @layout 'layout'
        @render 'alpha'
        ), name:'alpha'
    Router.route '/alpha/:doc_id/edit', (->
        @layout 'layout'
        @render 'alpha_edit'
        ), name:'alpha_edit'
    Router.route '/alpha/:doc_id/view', (->
        @layout 'layout'
        @render 'alpha_view'
        ), name:'alpha_view'


    Template.alpha_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'block'
        @autorun => Meteor.subscribe 'model_docs', 'module'

    Template.alpha_edit.onCreated ->
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




    Template.module_view.helpers
        alpha_field_view: ->
            console.log @
            "a#{@block_slug}_view"

    Template.alpha_view.helpers
        blocks: ->
            Docs.find
                model:'block'

        modules: ->
            Docs.find
                model:'module'
                parent_id: Router.current().params.doc_id


    Template.alpha_edit.helpers
        blocks: ->
            Docs.find
                model:'block'

        modules: ->
            Docs.find
                model:'module'
                parent_id: Router.current().params.doc_id


    Template.alpha_edit.events
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




    Template.alpha.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'alpha'
    Template.alpha.helpers
        alpha_docs: ->
            Docs.find
                model:'alpha'
    Template.alpha.events
        'click .add_alpha': ->
            new_id =
                Docs.insert
                    model:'alpha'
            Router.go "/alpha/#{new_id}/edit"



    Template.block_editor.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'block'
    Template.block_editor.events
        'click .add_block': ->
            Docs.insert
                model:'block'
    Template.block_editor.helpers
        blocks: ->
            Docs.find
                model:'block'


if Meteor.isServer
    Meteor.publish 'blocks', ->
        Docs.find
            model:'block'
