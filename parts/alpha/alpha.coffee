if Meteor.isClient
    Router.route '/alpha', (->
        @layout 'layout'
        @render 'alpha'
        ), name:'alpha'


    Template.alpha.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'alpha'
        @autorun => Meteor.subscribe 'model_docs', 'alpha_session'
    Template.alpha.helpers
        alpha_docs: ->
            Docs.find
                model:'alpha'
    Template.alpha.events
        'click .add_alpha_doc': ->
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
