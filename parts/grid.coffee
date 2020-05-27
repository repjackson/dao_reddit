if Meteor.isClient
    Router.route '/grid', (->
        @layout 'layout'
        @render 'grid'
        ), name:'grid'

    Template.grid.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'grid_session'
        @autorun => Meteor.subscribe 'model_docs', 'grid_stats'
    Template.grid.events
        'click .refresh_grid_stats': ->
            Meteor.call 'refresh_grid_stats', ->
        'click .refresh_my_grid_stats': ->
            Meteor.call 'refresh_my_grid_stats', ->

    Template.grid.helpers
        grid_stats_doc: ->
