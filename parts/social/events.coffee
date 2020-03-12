if Meteor.isClient
    Router.route '/events', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'
    # Router.route '/events/', (->
    #     @render 'my_events'
    #     ), name:'my_events'
    Router.route '/event/:doc_id/view', (->
        @render 'event_view'
        ), name:'event_view'
    Router.route '/event/:doc_id/edit', (->
        @render 'event_edit'
        ), name:'event_edit'




    Template.events.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'events_session'
        @autorun => Meteor.subscribe 'model_docs', 'events_stats'
    Template.events.events
        'click .refresh_events_stats': ->
            Meteor.call 'refresh_events_stats', ->
        'click .refresh_my_events_stats': ->
            Meteor.call 'refresh_my_events_stats', ->

    Template.events.helpers
        events_stats_doc: ->
            Docs.findOne
                model:'events_stats'
        events_sessions: ->
            Docs.find
                model:'events_session'


if Meteor.isClient
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'events_stats', ->
        Docs.find
            model: 'events_stats'

    Meteor.methods
        refresh_my_events_stats: ->
            site_events_session_cursor =
                Docs.find(
                    model:'events_session'
                )
            site_events_session_count = site_events_session_cursor.count()
            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            all_events_sessions_count =
                Docs.find({
                    model:'events_session'
                    _author_id: Meteor.userId()
                    }).count()
            daily_sessions =
                Docs.find({
                    model:'events_session'
                    _author_id: Meteor.userId()
                    _eventsstamp:
                        $gt:past_24_hours
                    })

            daily_hours = 0
            for session in daily_sessions.fetch()
                start_moment = moment(session.start_dateevents)
                end_moment = moment(session.end_dateevents)
                hour_difference = end_moment.diff(start_moment, 'hours')
                Docs.update session._id,
                    $set:
                        hour_difference:hour_difference
                daily_hours += hour_difference

            console.log 'my daily hours', daily_hours
            console.log 'my daily session count', daily_sessions.count()

            week_events_sessions_count =
                Docs.find({
                    model:'events_session'
                    _author_id: Meteor.userId()
                    _eventsstamp:
                        $gt:past_week
                    }).count()
            month_events_sessions_count =
                Docs.find({
                    model:'events_session'
                    _author_id: Meteor.userId()
                    _eventsstamp:
                        $gt:past_month
                    }).count()

            Meteor.users.update Meteor.userId(),
                $set:
                    daily_hours: daily_hours
                    # weekly_hours: weekly_hours
                    daily_sessions:daily_sessions.count()
                    # weekly_sessions:weekly_sessions.count()



        refresh_events_stats: ->
            site_events_session_cursor =
                Docs.find(
                    model:'events_session'
                )
            site_events_session_count = site_events_session_cursor.count()

            site_user_cursor =
                Meteor.users.find(
                )
            site_user_count = site_user_cursor.count()

            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            console.log past_24_hours
            all_events_sessions_count =
                Docs.find({
                    model:'events_session'
                    }).count()
            day_events_sessions_count =
                Docs.find({
                    model:'events_session'
                    _eventsstamp:
                        $gt:past_24_hours
                    }).count()
            week_events_sessions_count =
                Docs.find({
                    model:'events_session'
                    _eventsstamp:
                        $gt:past_week
                    }).count()
            month_events_sessions_count =
                Docs.find({
                    model:'events_session'
                    _eventsstamp:
                        $gt:past_month
                    }).count()





            daily_sessions =
                Docs.find({
                    model:'events_session'
                    _eventsstamp:
                        $gt:past_24_hours
                    })

            total_hours_today = 0
            for session in daily_sessions.fetch()
                start_moment = moment(session.start_dateevents)
                end_moment = moment(session.end_dateevents)
                hour_difference = end_moment.diff(start_moment, 'hours')
                Docs.update session._id,
                    $set:
                        hour_difference:hour_difference
                total_hours_today += hour_difference

            # console.log 'my daily hours', daily_hours
            # console.log 'my daily session count', daily_sessions.count()




            events_stats_doc =
                Docs.findOne
                    model:'events_stats'
            unless events_stats_doc
                gs_id = Docs.insert
                    model:'events_stats'
                events_stats_doc = Docs.findOne gs_id

            Docs.update events_stats_doc._id,
                $set:
                    global_average_correct_percent:global_average_correct_percent.toFixed()
                    total_sessions: all_events_sessions_count
                    user_count:site_user_count
                    total_hours_today: daily_hours
                    day_events_sessions_count:day_events_sessions_count
                    week_events_sessions_count:week_events_sessions_count
                    month_events_sessions_count:month_events_sessions_count
