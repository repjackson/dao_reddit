if Meteor.isClient
    Template.model_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug


    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    # Template.model_edit.events
    #     'click #delete_model': ->
    #         if confirm 'Confirm delete doc'
    #             Docs.remove @_id
    #             Router.go "/m/model"

    Template.field_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.field_edit.helpers
        is_ref: -> @field_type in ['single_doc', 'multi_doc','children']
        is_user_ref: -> @field_type in ['single_user', 'multi_user']

    Template.model_doc_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug


    Template.model_doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        # console.log Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'upvoters', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'downvoters', Router.current().params.doc_id

    Template.model_doc_edit.helpers
        template_exists: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            if Template["#{current_model}_edit"]
                # console.log 'true'
                return true
            else
                # console.log 'false'
                return false
        model_template: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            "#{current_model}_edit"

    Template.model_doc_view.helpers
        template_exists: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            if Template["#{current_model}_view"]
                # console.log 'true'
                return true
            else
                # console.log 'false'
                return false
        model_template: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            "#{current_model}_view"

    Template.model_doc_edit.events
        'click #delete_doc': ->
            if confirm 'Confirm delete doc'
                Docs.remove @_id
                Router.go "/m/#{@model}"

    Template.model_doc_view.events
        'click .back_to_model': ->
            Session.set 'loading', true
            current_model = Router.current().params.model_slug
            Meteor.call 'set_facets', current_model, ->
                Session.set 'loading', false
            Router.go "/m/#{current_model}"
