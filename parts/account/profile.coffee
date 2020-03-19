if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'
    Router.route '/user/:username/about', (->
        @layout 'profile_layout'
        @render 'user_about'
        ), name:'user_about'
    Router.route '/user/:username/finance', (->
        @layout 'profile_layout'
        @render 'user_finance'
        ), name:'user_finance'
    Router.route '/user/:username/tutoring', (->
        @layout 'profile_layout'
        @render 'user_tutoring'
        ), name:'user_tutoring'
    Router.route '/user/:username/groups', (->
        @layout 'profile_layout'
        @render 'user_groups'
        ), name:'user_groups'
    Router.route '/user/:username/upvotes', (->
        @layout 'profile_layout'
        @render 'user_upvotes'
        ), name:'user_upvotes'
    Router.route '/user/:username/downvotes', (->
        @layout 'profile_layout'
        @render 'user_downvotes'
        ), name:'user_downvotes'
    Router.route '/user/:username/karma', (->
        @layout 'profile_layout'
        @render 'user_karma'
        ), name:'user_karma'
    Router.route '/user/:username/cart', (->
        @layout 'profile_layout'
        @render 'user_cart'
        ), name:'user_cart'
    Router.route '/user/:username/payment', (->
        @layout 'profile_layout'
        @render 'user_payment'
        ), name:'user_payment'
    Router.route '/user/:username/contact', (->
        @layout 'profile_layout'
        @render 'user_contact'
        ), name:'user_contact'
    Router.route '/user/:username/brain', (->
        @layout 'profile_layout'
        @render 'user_brain'
        ), name:'user_brain'
    Router.route '/user/:username/stats', (->
        @layout 'profile_layout'
        @render 'user_stats'
        ), name:'user_stats'
    Router.route '/user/:username/votes', (->
        @layout 'profile_layout'
        @render 'user_votes'
        ), name:'user_votes'
    Router.route '/user/:username/jobs', (->
        @layout 'profile_layout'
        @render 'user_jobs'
        ), name:'user_jobs'
    Router.route '/user/:username/requests', (->
        @layout 'profile_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/user/:username/feed', (->
        @layout 'profile_layout'
        @render 'user_feed'
        ), name:'user_feed'
    Router.route '/user/:username/tags', (->
        @layout 'profile_layout'
        @render 'user_tags'
        ), name:'user_tags'
    Router.route '/user/:username/tasks', (->
        @layout 'profile_layout'
        @render 'user_tasks'
        ), name:'user_tasks'
    Router.route '/user/:username/transactions', (->
        @layout 'profile_layout'
        @render 'user_transactions'
        ), name:'user_transactions'
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/bookmarks', (->
        @layout 'profile_layout'
        @render 'user_bookmarks'
        ), name:'user_bookmarks'
    Router.route '/user/:username/documents', (->
        @layout 'profile_layout'
        @render 'user_documents'
        ), name:'user_documents'
    Router.route '/user/:username/social', (->
        @layout 'profile_layout'
        @render 'user_social'
        ), name:'user_social'
    Router.route '/user/:username/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:username/tests', (->
        @layout 'profile_layout'
        @render 'user_tests'
        ), name:'user_tests'
    Router.route '/user/:username/passages', (->
        @layout 'profile_layout'
        @render 'user_passages'
        ), name:'user_passages'
    Router.route '/user/:username/questions', (->
        @layout 'profile_layout'
        @render 'user_questions'
        ), name:'user_questions'
    Router.route '/user/:username/awards', (->
        @layout 'profile_layout'
        @render 'user_awards'
        ), name:'user_awards'
    Router.route '/user/:username/events', (->
        @layout 'profile_layout'
        @render 'user_events'
        ), name:'user_events'
    Router.route '/user/:username/mentorship', (->
        @layout 'profile_layout'
        @render 'user_mentorship'
        ), name:'user_mentorship'


    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.username
        @autorun -> Meteor.subscribe 'model_docs', 'test'
        # @autorun -> Meteor.subscribe 'student_stats', Router.current().params.username
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        Meteor.setTimeout ->
            $('.progress').progress();
        , 2000


        Session.setDefault 'view_side', false

    Template.profile_layout.helpers
        route_slug: -> "user_#{@slug}"
        user: -> Meteor.users.findOne username:Router.current().params.username
        user_sections: ->
            Docs.find {
                model:'user_section'
            }, sort:title:1
        student_classrooms: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'classroom'
                student_ids: $in: [user._id]
        ssd: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'student_stats'
                user_id:user._id
        view_side: -> Session.get 'view_side'
        main_column_class: ->
            if Session.get 'view_side'
                'fourteen wide column'
            else
                'sixteen wide column'

    Template.user_dashboard.events
        'click .recalc_user_cloud': ->
            Meteor.call 'recalc_user_cloud', Router.current().params.username, ->
        'click .calc_test_sessions': ->
            Meteor.call 'calc_test_sessions', Router.current().params.username, ->
        'click .recalc_user_act_stats': ->
            Meteor.call 'recalc_user_act_stats', Router.current().params.username, ->

    Template.user_dashboard.helpers
        ssd: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'student_stats'
                user_id:user._id
        student_classrooms: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'classroom'
                student_ids: $in: [user._id]
        user_events: ->
            Docs.find {
                model:'log_event'
            }, sort: _timestamp: -1
        # user_finances: ->
        #     Docs.find {
        #         model:'log_event'
        #         event_type:'credit'
        #     }, sort: _timestamp: -1
        # user_debits: ->
        #     Docs.find {
        #         model:'log_event'
        #         event_type:'debit'
        #     }, sort: _timestamp: -1
        user_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.profile_layout.events
        'click .profile_image': (e,t)->
            $(e.currentTarget).closest('.profile_image').transition(
                animation: 'jiggle'
                duration: 750
            )
        'click .toggle_size': -> Session.set 'view_side', !Session.get('view_side')
        'click .recalc_student_stats': -> Meteor.call 'recalc_student_stats', Router.current().params.username
        'click .set_delta_model': -> Meteor.call 'set_delta_facets', @slug, null, true
        'click .logout_other_clients': -> Meteor.logoutOtherClients()
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()




    Template.user_sessions_small.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', Router.current().params.username, 'test_session'
    Template.user_sessions_small.onRendered ->
    Template.user_sessions_small.events
        # 'click .delete_session': ->
        #     if confirm 'Confirm delete session?'
        #         Docs.remove @_id
    Template.user_sessions_small.helpers
        sessions: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'test_session'
                _author_id: user._id





    Template.user_session.events
        'click .delete_session': (e,t)->
            console.log @
            # $(e.currentTarget).closest('.ui.basic.modal').modal('show')
            $('.ui.basic.modal').modal({
                closable: false
                onDeny: ->
                    # window.alert('Wait not yet!')
                    # false
                onApprove: =>
                    # window.alert('Approved!')
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    Meteor.setTimeout =>
                        Docs.remove @_id
                    , 1000
                }).modal('show')

            # if confirm 'Confirm delete session?'








    Template.user_alerts_small.helpers
        alerts: ->
            Docs.find
                model:'alert'



    Template.user_bookmarks_small.onCreated ->
        @autorun -> Meteor.subscribe 'user_bookmarks', Router.current().params.username
    Template.user_bookmarks_small.onRendered ->
    Template.user_bookmarks_small.helpers
        bookmarks: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                _id:$in:user.bookmark_ids





    Template.user_questions.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', Router.current().params.username, 'question'
    Template.user_questions.onRendered ->
    Template.user_questions.helpers
        questions: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'question'
                _author_id: user._id
                has_correct_answer:true








if Meteor.isServer
    Meteor.publish 'user_bookmarks', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            _id:$in:user.bookmark_ids

    Meteor.publish 'user_model_docs', (user_id, model)->
        # user = Meteor.users.findOne user_id
        Docs.find
            model:model
            _author_id:username

    Meteor.publish 'user_events', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'log_event'
            user_id:user._id

    Meteor.publish 'student_stats', (user_id)->
        user = Meteor.users.findOne user_id
        if user
            Docs.find
                model:'student_stats'
                user_id:user._id


    Meteor.methods
        calc_test_sessions: (user_id)->
            user = Meteor.users.findOne user_id
            now = Date.now()
            console.log now
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            console.log past_24_hours
            all_sessions_count =
                Docs.find({
                    model:'test_session'
                    _author_id:username
                    }).count()
            todays_sessions_count =
                Docs.find({
                    model:'test_session'
                    _author_id:username
                    _timestamp:
                        $gt:past_24_hours
                    }).count()
            weeks_sessions_count =
                Docs.find({
                    model:'test_session'
                    _author_id:username
                    _timestamp:
                        $gt:past_week
                    }).count()
            months_sessions_count =
                Docs.find({
                    model:'test_session'
                    _author_id:username
                    _timestamp:
                        $gt:past_month
                    }).count()
            console.log 'all session count', all_sessions_count
            console.log 'today sessions count', todays_sessions_count
            Meteor.users.update user_id,
                $set:
                    all_sessions_count:all_sessions_count
                    todays_sessions_count: todays_sessions_count
                    weeks_sessions_count: weeks_sessions_count
                    months_sessions_count: months_sessions_count

            # this_week = moment().startOf('isoWeek')
            # this_week = moment().startOf('isoWeek')


        recalc_user_act_stats: (user_id)->
            user = Meteor.users.findOne user_id
            test_session_cursor =
                Docs.find
                    model:'test_session'
                    _author_id: user_id
            site_test_cursor =
                Docs.find(
                    model:'test'
                )
            site_test_count = site_test_cursor.count()
            answered_tests = 0
            for test in site_test_cursor.fetch()
                user_test_session =
                    Docs.findOne
                        model:'test_session'
                        test_id: test._id
                        _author_id:username
                if user_test_session
                    answered_tests++
            console.log 'answered tests', answered_tests
            global_section_percent = 0

            session_count = test_session_cursor.count()
            for section in ['english', 'math', 'science', 'reading']
                section_test_cursor =
                    Docs.find {
                        model:'test'
                        tags: $in: [section]
                    }
                section_count = section_test_cursor.count()
                section_tests = section_test_cursor.fetch()
                section_test_ids = []
                for section_test in section_tests
                    section_test_ids.push section_test._id

                # console.log section
                # console.log section_test_ids
                user_section_test_sessions =
                    Docs.find {
                        model:'test_session'
                        test_id: $in: section_test_ids
                        _author_id: user_id
                    }
                # console.log user_section_test_sessions.fetch()
                user_section_test_session_count = user_section_test_sessions.count()
                total_section_average = 0
                for test_session in user_section_test_sessions.fetch()
                    if test_session.correct_percent
                        total_section_average += parseInt(test_session.correct_percent)
                user_section_average = total_section_average/user_section_test_session_count
                # console.log 'user section average', section, user_section_average
                if user_section_average
                    Meteor.users.update user_id,
                        $set:
                            "#{section}_average": user_section_average.toFixed()
                    global_section_percent += user_section_average
                else
                    Meteor.users.update user_id,
                        $set:
                            "#{section}_average": 0
            site_percent_complete = parseInt((answered_tests/site_test_count)*100)
            global_section_average = global_section_percent/4



            Meteor.users.update user_id,
                $set:
                    session_count:session_count
                    site_percent_complete:site_percent_complete
                    global_section_average:global_section_average.toFixed()


            section_average_ranking =
                Meteor.users.find(
                    {},
                    sort:
                        global_section_average: -1
                    fields:
                        username: 1
                ).fetch()
            section_average_ranking_ids = _.pluck section_average_ranking, '_id'

            console.log 'section average ranking', section_average_ranking
            console.log 'section average ranking ids', section_average_ranking_ids
            my_rank = _.indexOf(section_average_ranking_ids, user_id)+1
            console.log 'my rank', my_rank
            Meteor.users.update user_id,
                $set:
                    global_section_average_rank:my_rank


            # average_english_percent
            # average_math_percent
            # average_science_percent
            # average_reading_percent


        recalc_user_cloud: (user_id)->
            user = Meteor.users.findOne user_id
            test_session_cursor =
                Docs.find
                    model:'test_session'
                    _author_id: user_id
                    right_tags: $exists: true
            all_right_tags = []
            all_wrong_tags = []
            right_tag_list = []
            wrong_tag_list = []
            right_tag_cloud = []
            wrong_tag_cloud = []

            for test_session in test_session_cursor.fetch()
                for right_tag in test_session.right_tags
                    unless right_tag in right_tag_list
                        right_tag_list.push right_tag
                    all_right_tags.push right_tag
                    tag_object = _.findWhere(right_tag_cloud, {tag: right_tag})
                    # console.log tag_object
                    if tag_object
                        index_of_tag = _.indexOf(right_tag_cloud, tag_object)
                        # console.log 'index of tag', index_of_tag
                        tag_count = tag_object.count
                        # console.log tag_count
                        # console.log 'inc', tag_count++
                        right_tag_cloud[index_of_tag] = {
                            tag:right_tag
                            count:tag_count+1
                        }
                    else
                        tag_object = {
                            tag:right_tag
                            count: 1
                        }
                        right_tag_cloud.push tag_object
                for wrong_tag in test_session.wrong_tags
                    unless wrong_tag in wrong_tag_list
                        wrong_tag_list.push wrong_tag
                    all_wrong_tags.push wrong_tag
                    tag_object = _.findWhere(wrong_tag_cloud, {tag: wrong_tag})
                    # console.log tag_object
                    if tag_object
                        index_of_tag = _.indexOf(wrong_tag_cloud, tag_object)
                        # console.log 'index of tag', index_of_tag
                        tag_count = tag_object.count
                        # console.log tag_count
                        # console.log 'inc', tag_count++
                        wrong_tag_cloud[index_of_tag] = {
                            tag:wrong_tag
                            count:tag_count+1
                        }
                    else
                        tag_object = {
                            tag:wrong_tag
                            count: 1
                        }
                        wrong_tag_cloud.push tag_object
            # console.log right_tag_cloud
            right_tag_cloud =  _.sortBy(right_tag_cloud, 'count')
            wrong_tag_cloud = _.sortBy(wrong_tag_cloud, 'count')
            right_tag_cloud = right_tag_cloud.reverse()
            wrong_tag_cloud = wrong_tag_cloud.reverse()
            right_tag_cloud = right_tag_cloud[..10]
            wrong_tag_cloud = wrong_tag_cloud[..10]
            # right_tag_cloud = _.countBy(all_right_tags, (tag)-> tag)
            # wrong_tag_cloud = _.countBy(all_wrong_tags, (tag)-> tag)

            Meteor.users.update user_id,
                $set:
                    right_tag_list:right_tag_list
                    wrong_tag_list:wrong_tag_list
                    right_tag_cloud:right_tag_cloud
                    wrong_tag_cloud:wrong_tag_cloud



        recalc_student_stats: (user_id)->
            user = Meteor.users.findOne user_id
            unless user
                user = Meteor.users.findOne username
            user_id = user._id
            # console.log classroom
            student_stats_doc = Docs.findOne
                model:'student_stats'
                user_id: user_id

            unless student_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'student_stats'
                    user_id: user_id
                student_stats_doc = Docs.findOne new_stats_doc_id

            debits = Docs.find({
                model:'log_event'
                event_type:'debit'
                _author_username:username})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'log_event'
                event_type:'credit'
                _author_username:username})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            student_balance = total_credit_amount-total_debit_amount

            # average_credit_per_student = total_credit_amount/student_count
            # average_debit_per_student = total_debit_amount/student_count


            Docs.update student_stats_doc._id,
                $set:
                    credit_count: credit_count
                    debit_count: debit_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    student_balance: student_balance
