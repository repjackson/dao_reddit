if Meteor.isClient
    Router.route '/model/edit/:doc_id/', (->
        @layout 'model_edit_layout'
        @render 'model_edit_dashboard'
        ), name:'model_edit_dashboard'
    Router.route '/model/edit/:doc_id/fields', (->
        @layout 'model_edit_layout'
        @render 'model_edit_fields'
        ), name:'model_edit_fields'
    Router.route '/model/edit/:doc_id/modules', (->
        @layout 'model_edit_layout'
        @render 'model_edit_modules'
        ), name:'model_edit_modules'
    Router.route '/model/edit/:doc_id/permissions', (->
        @layout 'model_edit_layout'
        @render 'model_edit_permissions'
        ), name:'model_edit_permissions'


    Template.model_edit_layout.onCreated ->
        @autorun -> Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields_from_id', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug

    Template.field_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000





    Template.model_edit_fields.helpers
        fields: ->
            Docs.find {
                model:'field'
                parent_id: Router.current().params.doc_id
            }, sort:rank:1

    Template.model_edit_layout.events
        'click #delete_model': (e,t)->
            if confirm 'delete model?'
                Docs.remove Router.current().params.doc_id, ->
                    Router.go "/"

        'click .add_field': ->
            Docs.insert
                model:'field'
                parent_id: Router.current().params.doc_id
                view_roles: ['dev', 'admin', 'user', 'public']
                edit_roles: ['dev', 'admin', 'user']

    Template.field_edit.helpers
        is_ref: -> @field_type in ['single_doc', 'multi_doc','children']
        is_user_ref: -> @field_type in ['single_user', 'multi_user']



    # Template.model_edit.events
    #     'click #delete_model': ->
    #         if confirm 'Confirm delete doc'
    #             Docs.remove @_id
    #             Router.go "/m/model"
