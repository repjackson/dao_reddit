if Meteor.isClient
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'schema', Router.current().params.doc_id
        # @autorun -> Meteor.subscribe 'model_docs', 'model'
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'model'


    Template.detect.events
        'click .detect_fields': ->
            # console.log @
            Meteor.call 'detect_fields', @_id

    Template.home.helpers
        home_models: ->
            Docs.find {
                model:'model'
                view_home:true
            }, sort: title: 1


    Template.home.events
        'click .calc_similar': ->
            console.log @
            Meteor.call 'calc_similar', @_id

    Template.key_view.helpers
        key: -> @valueOf()

        meta: ->
            key_string = @
