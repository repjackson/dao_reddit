if Meteor.isClient
    Template.view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'schema', Router.current().params.doc_id


    Template.detect.events
        'click .detect_fields': ->
            # console.log @
            Meteor.call 'detect_fields', @_id

    Template.key_view.helpers
        key: -> @valueOf()

        meta: ->
            key_string = @valueOf()
            parent = Template.parentData()
            parent["_#{key_string}"]

        context: ->
            # console.log @
            {key:@valueOf()}


        field_view: ->
            # console.log @
            key_string = @valueOf()
            meta = Template.parentData(2)["_#{@key}"]
            "#{meta.field}_view"
