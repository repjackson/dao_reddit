if Meteor.isClient
    Router.route '/reddit', (->
        @layout 'layout'
        @render 'reddit'
        ), name:'reddit'

    Template.reddit.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'thought'
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'thought')
        @autorun => Meteor.subscribe 'model_docs', 'reddit'
        @autorun => Meteor.subscribe 'current_reddit'
    Template.reddit.events
        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    unless val.length is 0
                        selected_tags.push val.toString()
                        $('#search').val ''
                        Session.set 'loading', true
                        Meteor.call 'search_reddit', selected_tags.array(), ->
                            Session.set 'loading', false
                        # Meteor.call "call_wiki", val.toString(), ->


    Template.selected_thought.events
        'click .delete_thought': ->
            if confirm 'delete thought?'
                Docs.remove @_id
                Session.set('selected_thought_id', null)
        'click .save_thought': ->
            Session.set('editing_thought', false)
        'click .edit_thought': ->
            Session.set('editing_thought', true)

    Template.selected_thought.helpers
        editing_thought: -> Session.get('editing_thought')

    Template.reddit.helpers

        thought_segment_class: ->
            if Session.equals('selected_thought_id', @_id) then 'inverted blue' else ''
        selected_thought_doc: ->
            Docs.findOne Session.get('selected_thought_id')
        current_reddit: ->
            Docs.find
                model:'thought'
                current:true
        reddit_stats_doc: ->
            Docs.findOne
                model:'reddit_stats'
        reddit_posts: ->
            Docs.find
                model:'reddit'


if Meteor.isServer
    Meteor.publish 'reddit_stats', ->
        Docs.find
            model: 'reddit_stats'

    Meteor.publish 'current_reddit', ->
        Docs.find
            model: 'thought'
            current:true

    Meteor.methods
        refresh_my_reddit_stats: ->
            site_thought_cursor =
                Docs.find(
                    model:'thought'
                )
            site_thought_count = site_thought_cursor.count()
            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            all_reddit_count =
                Docs.find({
                    model:'thought'
                    }).count()
            daily_sessions =
                Docs.find({
                    model:'thought'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_24_hours
                    })

            daily_hours = 0
            console.log 'my daily hours', daily_hours
            console.log 'my daily session count', daily_sessions.count()

            week_reddit_count =
                Docs.find({
                    model:'thought'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_reddit_count =
                Docs.find({
                    model:'thought'
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



        refresh_reddit_stats: ->
            site_thought_cursor =
                Docs.find(
                    model:'thought'
                )
            site_thought_count = site_thought_cursor.count()

            site_user_cursor =
                Meteor.users.find(
                )
            site_user_count = site_user_cursor.count()

            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            console.log past_24_hours
            all_reddit_count =
                Docs.find({
                    model:'thought'
                    }).count()
            day_reddit_count =
                Docs.find({
                    model:'thought'
                    _timestamp:
                        $gt:past_24_hours
                    }).count()
            week_reddit_count =
                Docs.find({
                    model:'thought'
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_reddit_count =
                Docs.find({
                    model:'thought'
                    _timestamp:
                        $gt:past_month
                    }).count()


            daily_sessions =
                Docs.find({
                    model:'thought'
                    _timestamp:
                        $gt:past_24_hours
                    })


            reddit_stats_doc =
                Docs.findOne
                    model:'reddit_stats'
            unless reddit_stats_doc
                gs_id = Docs.insert
                    model:'reddit_stats'
                reddit_stats_doc = Docs.findOne gs_id

            Docs.update reddit_stats_doc._id,
                $set:
                    total_reddit: all_reddit_count
                    day_reddit_count:day_reddit_count
                    week_reddit_count:week_reddit_count
                    month_reddit_count:month_reddit_count
