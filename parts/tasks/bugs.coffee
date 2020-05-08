if Meteor.isClient
    Router.route '/bugs', (->
        @layout 'layout'
        @render 'bugs'
        ), name:'bugs'

    Template.bugs.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'bug'
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'bug')
        @autorun => Meteor.subscribe 'model_docs', 'bugs_stats'
        @autorun => Meteor.subscribe 'model_docs', 'bug'
        @autorun => Meteor.subscribe 'current_bugs'
    Template.bugs.events
        'click .refresh_bugs_stats': ->
            Meteor.call 'refresh_bugs_stats', ->
        'click .refresh_my_bugs_stats': ->
            Meteor.call 'refresh_my_bugs_stats', ->
        'click .select_bug': ->
            if Session.equals('selected_bug_id',@_id)
                Session.set 'selected_bug_id', null
            else
                Session.set 'selected_bug_id', @_id
        'click .new_bug': (e,t)->
            new_bug_id =
                Docs.insert
                    model:'bug'

            Session.set('editing_bug', true)
            Session.set('selected_bug_id', new_bug_id)
        'click .unselect_bug': ->
            Session.set('selected_bug_id', null)

    Template.selected_bug.events
        'click .delete_bug': ->
            if confirm 'delete bug?'
                Docs.remove @_id
                Session.set('selected_bug_id', null)
        'click .save_bug': ->
            Session.set('editing_bug', false)
        'click .edit_bug': ->
            Session.set('editing_bug', true)

    Template.selected_bug.helpers
        editing_bug: -> Session.get('editing_bug')

    Template.bugs.helpers
        bug_segment_class: ->
            if Session.equals('selected_bug_id', @_id) then 'inverted blue' else ''
        selected_bug_doc: ->
            Docs.findOne Session.get('selected_bug_id')
        current_bugs: ->
            Docs.find
                model:'bug'
                current:true
        bugs_stats_doc: ->
            Docs.findOne
                model:'bugs_stats'
        bugs: ->
            Docs.find
                model:'bug'


if Meteor.isServer
    Meteor.publish 'bugs_stats', ->
        Docs.find
            model: 'bugs_stats'

    Meteor.publish 'current_bugs', ->
        Docs.find
            model: 'bug'
            current:true

    Meteor.methods
        refresh_my_bugs_stats: ->
            site_bug_cursor =
                Docs.find(
                    model:'bug'
                )
            site_bug_count = site_bug_cursor.count()
            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            all_bugs_count =
                Docs.find({
                    model:'bug'
                    }).count()
            daily_sessions =
                Docs.find({
                    model:'bug'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_24_hours
                    })

            daily_hours = 0
            console.log 'my daily hours', daily_hours
            console.log 'my daily session count', daily_sessions.count()

            week_bugs_count =
                Docs.find({
                    model:'bug'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_bugs_count =
                Docs.find({
                    model:'bug'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_month
                    }).count()

            Meteor.users.update Meteor.userId(),
                $set:
                    daily_hours: daily_hours
                    # weekly_hours: weekly_hours
                    daily_sessions:daily_sessions.count()
                    # weekly_sessions:weekly_sessions.count()



        refresh_bugs_stats: ->
            site_bug_cursor =
                Docs.find(
                    model:'bug'
                )
            site_bug_count = site_bug_cursor.count()

            site_user_cursor =
                Meteor.users.find(
                )
            site_user_count = site_user_cursor.count()

            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            console.log past_24_hours
            all_bugs_count =
                Docs.find({
                    model:'bug'
                    }).count()
            day_bugs_count =
                Docs.find({
                    model:'bug'
                    _timestamp:
                        $gt:past_24_hours
                    }).count()
            week_bugs_count =
                Docs.find({
                    model:'bug'
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_bugs_count =
                Docs.find({
                    model:'bug'
                    _timestamp:
                        $gt:past_month
                    }).count()


            daily_sessions =
                Docs.find({
                    model:'bug'
                    _timestamp:
                        $gt:past_24_hours
                    })


            bugs_stats_doc =
                Docs.findOne
                    model:'bugs_stats'
            unless bugs_stats_doc
                gs_id = Docs.insert
                    model:'bugs_stats'
                bugs_stats_doc = Docs.findOne gs_id

            Docs.update bugs_stats_doc._id,
                $set:
                    total_bugs: all_bugs_count
                    day_bugs_count:day_bugs_count
                    week_bugs_count:week_bugs_count
                    month_bugs_count:month_bugs_count
