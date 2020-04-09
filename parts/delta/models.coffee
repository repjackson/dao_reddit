if Meteor.isClient
    Router.route '/model/edit/:doc_id', -> @render 'model_edit'



    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), Router.current().params.model_slug

    Template.model_view.helpers
        current_model: ->
            Router.current().params.model_slug
        model: ->
            Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

        model_docs: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

            Docs.find
                model:model.slug

        model_doc: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            "#{model.slug}_view"

        fields: ->
            Docs.find { model:'field' }, sort:rank:1
                # parent_id: Router.current().params.doc_id

    Template.model_view.events
        'click .add_child': ->
            model = Docs.findOne slug:Router.current().params.model_slug
            console.log model
            # new_id = Docs.insert
            #     model: Router.current().params.model_slug
            # Router.go "/edit/#{new_id}"

    Template.model_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'child_docs', Router.current().params.doc_id


    Template.model_edit.helpers
        model: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id

        fields: ->
            Docs.find {
                model:'field'
                parent_id: Router.current().params.doc_id
            }, sort:rank:1

    Template.model_edit.events
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

if Meteor.isServer
    Meteor.publish 'model', (slug)->
        Docs.find
            model:'model'
            slug:slug

    Meteor.publish 'model_fields_from_slug', (slug)->
        model = Docs.findOne
            model:'model'
            slug:slug
        Docs.find
            model:'field'
            parent_id:model._id

    Meteor.publish 'model_fields_from_id', (model_id)->
        model = Docs.findOne model_id
        Docs.find
            model:'field'
            parent_id:model._id
