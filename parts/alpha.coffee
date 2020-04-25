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

    Template.alpha_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'alpha'
        @autorun => Meteor.subscribe 'model_docs', 'block'
        @autorun => Meteor.subscribe 'model_docs', 'module'

    Template.module.helpers
        alpha_field: ->
            console.log @
            "a#{@block_slug}_edit"

    Template.alpha_edit.helpers
        blocks: ->
            Docs.find
                model:'block'

        modules: ->
            Docs.find
                model:'module'
                parent_id: Router.current().params.doc_id


    Template.alpha_edit.events
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
