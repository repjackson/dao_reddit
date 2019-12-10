if Meteor.isClient
    Router.route '/ideas', (->
        @layout 'admin_layout'
        @render 'ideas'
        ), name:'ideas'

    Template.ideas.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'idea'

    Template.ideas.helpers
        ideas: ->
            Docs.find {
                model:'idea'
            }, _timestamp:1


    Template.ideas.events
        'click .add_idea': ->
            new_idea_id =
                Docs.insert
                    model:'idea'
            Session.set 'editing', new_idea_id



        'click .edit': ->
            Session.set 'editing_id', @_id
        'click .save': ->
            Session.set 'editing_id', null
