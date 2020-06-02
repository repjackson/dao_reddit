Template.home.onCreated ->
    @autorun -> Meteor.subscribe('model_docs', 'home_section')
    @autorun -> Meteor.subscribe('model_docs', 'thought')
    @autorun -> Meteor.subscribe('model_docs', 'request')
    @autorun -> Meteor.subscribe('model_docs', 'offer')

Template.home.helpers
    home_sections: ->
        Docs.find {
            model:'home_section'
        }

    thoughts: ->
        Docs.find {
            model:'thought'
        }

    requests: ->
        Docs.find {
            model:'request'
        }

    offers: ->
        Docs.find {
            model:'offer'
        }

Template.home.events
    'click .need': ->
        new_request_id =
            Docs.insert
                model:'request'
        Router.go "/request/#{new_request_id}/edit"
    'click .add_section': ->
        Docs.insert
            model:'home_section'


    'keyup .add_thought': (e,t)->
        if e.which is 13
            thought = t.$('.add_thought').val().trim().toLowerCase()
            if thought.length > 0
                # console.log element_val, 'hi'
                parent = Template.parentData()
                new_thought_id =
                    Docs.insert
                        model:'thought'
                        body:thought
                t.$('.add_thought').val('')
