Template.home.onCreated ->
    @autorun -> Meteor.subscribe('model_docs', 'home_section')

Template.home.helpers
    home_sections: ->
        Docs.find {
            model:'home_section'
        },

Template.home.events
    'click .add_section': ->
        Docs.insert
            model:'home_section'
