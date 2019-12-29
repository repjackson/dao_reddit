if Meteor.isClient
    Template.edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun -> Meteor.subscribe 'schema', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'type', 'field'

    Template.edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 2000

    Template.edit.helpers
        viewing_full: -> Session.get('viewing_full')
    Template.edit.events
        'click .toggle': (e,t)->
            Session.set('viewing_full', !Session.get('viewing_full'))
        'click .delete_doc': ->
            if confirm 'confirm delete'
                Docs.remove @_id
                Router.go '/'


    Template.key_segment.onCreated ->
        @viewing_full = new ReactiveVar false

    Template.key_segment.helpers
        viewing_full: -> Template.instance().viewing_full.get()


    Template.key_segment.events
        'click .toggle': (e,t)->
            t.viewing_full.set !t.viewing_full.get()


    Template.field_menu.helpers
        fields: ->
            [
                {
                    title:'text'
                    slug:'text'
                    icon:'i cursor'
                }
                {
                    title:'number'
                    slug:'number'
                    icon:'hashtag'
                }
                {
                    title:'html'
                    slug:'html'
                    icon:'html'
                }
                {
                    title:'image'
                    slug:'image'
                    icon:'image'
                }
                {
                    title:'image link'
                    slug:'image_link'
                    icon:'image'
                }
                {
                    title:'link'
                    slug:'link'
                    icon:'linkify'
                }
                {
                    title:'array'
                    slug:'array'
                    icon:'list'
                }
                {
                    title:'boolean'
                    slug:'boolean'
                    icon:'checkmark'
                }
                {
                    title:'textarea'
                    slug:'textarea'
                    icon:'content'
                }
                {
                    title:'float'
                    slug:'float'
                    icon:'hashtag'
                }
                {
                    title:'date'
                    slug:'date'
                    icon:'calendar'
                }
                {
                    title:'youtube'
                    slug:'youtube'
                    icon:'youtube'
                }
                {
                    title:'price'
                    slug:'price'
                    icon:'price'
                }
                {
                    title:'link'
                    slug:'link'
                    icon:'link'
                }
            ]


    Template.field_menu.events
        'click .add_field': ->
            console.log @
            Docs.update Router.current().params.doc_id,
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
