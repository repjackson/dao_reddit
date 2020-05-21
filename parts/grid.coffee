if Meteor.isClient
    Router.route '/grid', (->
        @layout 'layout'
        @render 'grid'
        ), name:'grid'

    Template.grid.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'section'
        @autorun -> Meteor.subscribe 'model_docs', 'al_message'


    Template.grid.events
        'keyup .add_al': (e,t)->
            if e.which is 13
                chat = t.$('.add_al').val()
                Docs.insert
                    model:'al_message'
                    body:chat
                t.$('.add_al').val('')

    Template.grid.helpers
        al_messages: ->
            Docs.find
                model:"al_message"

        sections: ->
            Docs.find {
                model:'section'
            },
                limit:1
                sort:title:-1
