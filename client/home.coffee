if Meteor.isClient
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array())

    Template.home.helpers
        docs: ->
            Docs.find
                model:'rental'

        tag_cloud_class: ->
