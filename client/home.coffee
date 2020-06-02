Template.home.onCreated ->
    @autorun -> Meteor.subscribe('model_docs', 'home_section')
    @autorun -> Meteor.subscribe('model_docs', 'thought')

Template.home.helpers
    home_sections: ->
        Docs.find {
            model:'home_section'
        },

    thoughts: ->
        Docs.find {
            model:'thought'
        },

Template.home.events
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
