if Meteor.isClient
    Template.edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun -> Meteor.subscribe 'schema', Router.current().params._id
        @autorun -> Meteor.subscribe 'type', 'field'


    Template.edit.events
        'click .toggle_complete': (e,t)->
            Docs.update Router.current().params._id,
                $set:complete:!@complete
        'click .delete_doc': ->
            if confirm 'Confirm Delete'
                Docs.remove @_id
                Router.go '/'


    Template.field_menu.helpers
        fields: ->
            Docs.find
                type:'field'


    Template.field_menu.events
        'click .add_field': ->
            console.log @
            Docs.update Router.current().params._id,
                $push:
                    fields: @slug
                    _keys: "new_#{@slug}"
                $set:
                    "_new_#{@slug}": { field:@slug }

    Template.field_edit.events
        'blur .change_key': (e,t)->
            old_string = @valueOf()
            # console.log old_string
            new_key = t.$('.change_key').val()
            parent = Template.parentData()
            current_keys = Template.parentData()._keys

            Meteor.call 'rename_key', old_string, new_key, parent


        'click .remove_field': ->
            key_name = @valueOf()
            console.log @
            console.log Template.currentData()
            parent = Template.parentData()
            field = parent["_#{key_name}"].field
            if confirm "Remove #{key_name}?"
                Docs.update parent._id,
                    $unset:
                        "#{key_name}": 1
                        "_#{key_name}": 1
                    $pull:
                        _keys: key_name
                        fields:field


    Template.field_edit.helpers
        key: -> @valueOf()

        meta: ->
            key_string = @valueOf()
            parent = Template.parentData()
            parent["_#{key_string}"]

        context: ->
            # console.log @
            {key:@valueOf()}


        field_edit: ->
            # console.log @
            # console.log Template.parentData(2)
            # console.log Template.parentData(3)
            meta = Template.parentData(2)["_#{@key}"]
            # console.log meta
            # console.log "#{meta.field}_edit"
            "#{meta.field}_edit"
