if Meteor.isClient
    Template.remove_button.events
        'click .remove_doc': ->
            if confirm 'remove?'
                Docs.remove @_id
