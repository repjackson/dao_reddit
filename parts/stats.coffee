if Meteor.isClient
    Router.route '/stats', (->
        @layout 'layout'
        @render 'stats'
        ), name:'stats'

    Template.stats.onCreated ->
        @autorun => Meteor.subscribe 'global_stats'
    Template.stats.events
        'click .refresh_global_stats': ->
            Meteor.call 'refresh_global_stats', ->

    Template.stats.helpers
        stats_doc: ->
            Docs.findOne
                model:'global_stats'



if Meteor.isServer
    Meteor.publish 'global_stats', ->
        Docs.find
            model: 'global_stats'

    Meteor.methods
        refresh_global_stats: ->
            site_test_cursor =
                Docs.find(
                    model:'test'
                )
            site_test_count = site_test_cursor.count()

            site_user_cursor =
                Meteor.users.find(
                )
            site_user_count = site_user_cursor.count()

            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            console.log past_24_hours
            all_tests_count =
                Docs.find({
                    model:'test'
                    }).count()
            day_tests_count =
                Docs.find({
                    model:'test'
                    _timestamp:
                        $gt:past_24_hours
                    }).count()
            week_tests_count =
                Docs.find({
                    model:'test'
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_tests_count =
                Docs.find({
                    model:'test'
                    _timestamp:
                        $gt:past_month
                    }).count()






            global_session_cursor = Docs.find
                model:'act_test_session'
            global_session_count = global_session_cursor.count()
            global_total_correct_percent = 0
            for session in global_session_cursor.fetch()
                if session.correct_percent
                    global_total_correct_percent += parseInt(session.correct_percent)

            global_stats_doc =
                Docs.findOne
                    model:'global_stats'
            unless global_stats_doc
                gs_id = Docs.insert
                    model:'global_stats'
                global_stats_doc = Docs.findOne gs_id

            console.log global_stats_doc

            global_average_correct_percent = global_total_correct_percent/global_session_count
            Docs.update global_stats_doc._id,
                $set:
                    global_average_correct_percent:global_average_correct_percent.toFixed()
                    total_sessions: global_session_count
                    test_amount:site_test_count
                    user_count:site_user_count
                    day_tests_count:day_tests_count
                    week_tests_count:week_tests_count
                    month_tests_count:month_tests_count
