if Meteor.isClient
    Router.route '/stats', (->
        @layout 'layout'
        @render 'stats'
        ), name:'stats'

    Template.stats.onCreated ->
        @autorun => @subscribe 'stats'
        @autorun => @subscribe 'all_users'

    Template.stats.helpers
        users: ->
            Meteor.users.find()
        ssd: ->
            Docs.findOne
                model:'stats'
    Template.stats.events
        'click .calc_site_stats': ->
            Meteor.call 'calc_site_stats', ->



if Meteor.isServer
    Meteor.publish 'all_users', ->
        Meteor.users.find()
    Meteor.publish 'stats', ->
        Docs.find
            model:'stats'
    Meteor.methods
        'calc_site_stats': ->
            site_stats_doc =
                Docs.findOne
                    model:'stats'
            unless site_stats_doc
                ssd_id =
                    Docs.insert
                        model:'stats'
            else
                ssd_id = site_stats_doc._id

            total_user_count = Meteor.users.find().count()
            total_doc_count = Docs.find().count()
            total_term_count = Terms.find().count()
            Docs.update ssd_id,
                $set:
                    total_user_count: total_user_count
                    total_doc_count: total_doc_count
                    total_term_count: total_term_count
