if Meteor.isClient
    Router.route '/ingredients', (->
        @layout 'layout'
        @render 'ingredients'
        ), name:'ingredients'
    Router.route '/ingredient/:doc_id/edit', (->
        @layout 'layout'
        @render 'ingredient_edit'
        ), name:'ingredient_edit'
    Router.route '/ingredient/:doc_id/view', (->
        @layout 'layout'
        @render 'ingredient_view'
        ), name:'ingredient_view'


    Template.ingredients.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'
    Template.ingredients.onCreated ->

        # @autorun => Meteor.subscribe 'model_docs', 'ingredient'

    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.ingredient_view.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                ingredient_ids: $in: [@_id]
    Template.ingredients.helpers
        ingredients: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'ingredient'
            }, sort:title:1

    Template.ingredients.events
        'click .add_ingredient': ->
            new_ingredient_id =
                Docs.insert
                    model:'ingredient'
            Router.go("/ingredient/#{new_ingredient_id}/edit")





# if Meteor.isServer
#     Meteor.publish 'asset_reservations', (asset_id)->
#         asset = Docs.findOne asset_id
#         Docs.find
#             model:'reservation'
#             parent_id:asset_id
#     #     # console.log model
#     #     # console.log skip
#     #     Docs.find {
#     #         model:model
#     #     }
