if Meteor.isClient
    Template.alpha_card.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Template.currentData()._id

    Template.alpha_card.helpers
        result: ->
            # console.log @
            Docs.findOne @_id

        doc_modules: ->
            Docs.find
                model:'module'
                parent_id:@_id

    Template.alpha_card_module_view.helpers
        alpha_field_view: ->
            # console.log @
            "a#{@block_slug}_view"

    Template.alpha_card_module_view.helpers
        module_value: ->
            module = @
            alpha_doc = Template.parentData()
            alpha_doc["#{@doc_key}"]
