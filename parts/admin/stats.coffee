if Meteor.isClient
    Router.route '/global_stats', -> @render 'global_stats'

    # Template.global_stats.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'global_stats'
    #
    # Template.global_stats.events
    #     'click .refresh_global_stats': ->
    #         Meteor.call 'refresh_global_stats', ->
    #
    # Template.global_stats.helpers
    #     global_stats: ->
    #         Docs.findOne {
    #             model:'global_stats'
    #         }, sort: _timestamp: -1
