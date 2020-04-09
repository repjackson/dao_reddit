if Meteor.isClient
    Router.route '/reservations', (->
        @layout 'layout'
        @render 'reservations'
        ), name:'reservations'


    Template.reservations.onCreated ->
        @autorun => Meteor.subscribe 'docs', 'reservation'

        # @autorun => Meteor.subscribe 'model_docs', 'reservation'

    # Template.reservation_view.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # Template.reservation_edit.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.reservations.helpers
        reservations: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'reservation'
            }, sort:title:1


    # Template.reservation_reviews.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'review'
    # Template.reservation_reviews.helpers
    #     can_leave_review: ->
    #         found_review =
    #             Docs.findOne
    #                 _author_id:Meteor.userId()
    #                 model:'review'
    #                 parent_id:Router.current().params.doc_id
    #         if found_review then false else true
    #     reviews: ->
    #         Docs.find
    #             model: 'review'
    #             parent_id:Router.current().params.doc_id
    #


    Template.reservations.onCreated ->
        @autorun => Meteor.subscribe 'asset_reservations', Router.current().params.doc_id
        @editing = new ReactiveVar false
    Template.reservations.events
        'click .new_reservation': ->
            Docs.insert
                model:'reservation'
                parent_id:Router.current().params.doc_id

        'click .toggle_editing': (e,t)->
            t.editing.set !t.editing.get()

    Template.reservations.helpers
        taken_slots: ->
            asset = Docs.findOne Router.current().params.doc_id
            reservation_count = Docs.find(model:'reservation').count()
        money_earned: ->
            asset = Docs.findOne Router.current().params.doc_id
            reservation_count = Docs.find(model:'reservation').count()
            asset.slot_price*reservation_count
        available_slots: ->
            asset = Docs.findOne Router.current().params.doc_id
            reservation_count = Docs.find(model:'reservation').count()
            asset.slots_available - reservation_count
            # console.log asset.slots_available
        is_editing: -> Template.instance().editing.get()
        my_reservation: ->
            Docs.findOne
                _author_id:Meteor.userId()
                model:'reservation'
                parent_id:Router.current().params.doc_id

        can_reserve: ->
            found_reservation =
                Docs.findOne
                    _author_id:Meteor.userId()
                    model:'reservation'
                    parent_id:Router.current().params.doc_id
            if found_reservation then false else true
        existing_reservation: ->
            found_reservation =
                Docs.findOne
                    _author_id:Meteor.userId()
                    model:'reservation'
                    parent_id:Router.current().params.doc_id
        reservations: ->
            Docs.find
                model: 'reservation'
                parent_id:Router.current().params.doc_id




    # Template.model_scroller.onCreated ->
    #     @skip = new ReactiveVar 0
    #     @autorun => Meteor.subscribe 'model_docs_with_skip', @data.model, @skip.get()
    # Template.model_scroller.helpers
    #     user_results: -> Template.instance().user_results.get()
    #     current_doc: ->
    #         # console.log @model
    #         Docs.findOne {
    #             model:@model
    #         }, skip: Template.instance().skip.get()
    #         # }
    #     model_doc_template: ->
    #         # console.log "#{@model}_doc_view"
    #         "#{@model}_doc_view"
    #
    #     can_go_left: ->
    #         Template.instance().skip.get() > 0
    #     can_go_right: ->
    #         count = Docs.find(model:@model).count()
    #         # console.log count
    #         Template.instance().skip.get() < count-1
    #
    #
    # Template.model_scroller.events
    #     'click .go_to_model': ->
    #         # console.log @
    #         Session.set 'loading', true
    #         Meteor.call 'set_facets', @model, ->
    #             Session.set 'loading', false
    #         # Router.go "/m/#{@model}"
    #     'click .go_left': ->
    #         current_skip = Template.instance().skip.get()
    #         unless current_skip is 0
    #             Template.instance().skip.set(current_skip-1)
    #     'click .go_right': ->
    #         current_skip = Template.instance().skip.get()
    #         Template.instance().skip.set(current_skip+1)





if Meteor.isServer
    Meteor.publish 'asset_reservations', (asset_id)->
        asset = Docs.findOne asset_id
        Docs.find
            model:'reservation'
            parent_id:asset_id
    #     # console.log model
    #     # console.log skip
    #     Docs.find {
    #         model:model
    #     }
