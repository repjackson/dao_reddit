if Meteor.isClient
    Template.ingredient_view.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                ingredient_ids: $in: [@_id]


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
