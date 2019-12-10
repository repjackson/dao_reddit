if Meteor.isClient
    Router.route '/user/:user_id', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'
    Router.route '/user/:user_id/about', (->
        @layout 'profile_layout'
        @render 'user_about'
        ), name:'user_about'
    Router.route '/user/:user_id/connections', (->
        @layout 'profile_layout'
        @render 'user_connections'
        ), name:'user_connections'
    Router.route '/user/:user_id/finance', (->
        @layout 'profile_layout'
        @render 'user_finance'
        ), name:'user_finance'
    Router.route '/user/:user_id/karma', (->
        @layout 'profile_layout'
        @render 'user_karma'
        ), name:'user_karma'
    Router.route '/user/:user_id/payment', (->
        @layout 'profile_layout'
        @render 'user_payment'
        ), name:'user_payment'
    Router.route '/user/:user_id/fiq', (->
        @layout 'profile_layout'
        @render 'user_fiq'
        ), name:'user_fiq'
    Router.route '/user/:user_id/contact', (->
        @layout 'profile_layout'
        @render 'user_contact'
        ), name:'user_contact'
    Router.route '/user/:user_id/brain', (->
        @layout 'profile_layout'
        @render 'user_brain'
        ), name:'user_brain'
    Router.route '/user/:user_id/stats', (->
        @layout 'profile_layout'
        @render 'user_stats'
        ), name:'user_stats'
    Router.route '/user/:user_id/votes', (->
        @layout 'profile_layout'
        @render 'user_votes'
        ), name:'user_votes'
    Router.route '/user/:user_id/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:user_id/jobs', (->
        @layout 'profile_layout'
        @render 'user_jobs'
        ), name:'user_jobs'
    Router.route '/user/:user_id/requests', (->
        @layout 'profile_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/user/:user_id/feed', (->
        @layout 'profile_layout'
        @render 'user_feed'
        ), name:'user_feed'
    Router.route '/user/:user_id/tags', (->
        @layout 'profile_layout'
        @render 'user_tags'
        ), name:'user_tags'
    Router.route '/user/:user_id/tasks', (->
        @layout 'profile_layout'
        @render 'user_tasks'
        ), name:'user_tasks'
    Router.route '/user/:user_id/transactions', (->
        @layout 'profile_layout'
        @render 'user_transactions'
        ), name:'user_transactions'
    Router.route '/user/:user_id/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:user_id/bookmarks', (->
        @layout 'profile_layout'
        @render 'user_bookmarks'
        ), name:'user_bookmarks'
    Router.route '/user/:user_id/documents', (->
        @layout 'profile_layout'
        @render 'user_documents'
        ), name:'user_documents'
    Router.route '/user/:user_id/social', (->
        @layout 'profile_layout'
        @render 'user_social'
        ), name:'user_social'
    Router.route '/user/:user_id/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:user_id/passages', (->
        @layout 'profile_layout'
        @render 'user_passages'
        ), name:'user_passages'
    Router.route '/user/:user_id/questions', (->
        @layout 'profile_layout'
        @render 'user_questions'
        ), name:'user_questions'
    Router.route '/user/:user_id/awards', (->
        @layout 'profile_layout'
        @render 'user_awards'
        ), name:'user_awards'
    Router.route '/user/:user_id/events', (->
        @layout 'profile_layout'
        @render 'user_events'
        ), name:'user_events'


    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_id', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.user_id
        # @autorun -> Meteor.subscribe 'student_stats', Router.current().params.user_id
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        Session.setDefault 'view_side', false

    Template.profile_layout.helpers
        route_slug: -> "user_#{@slug}"
        user: -> Meteor.users.findOne Router.current().params.user_id
        user_sections: ->
            Docs.find {
                model:'user_section'
            }, sort:title:1
        student_classrooms: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'classroom'
                student_ids: $in: [user._id]

        ssd: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.findOne
                model:'student_stats'
                user_id:user._id
        view_side: -> Session.get 'view_side'
        main_column_class: ->
            if Session.get 'view_side'
                'fourteen wide column'
            else
                'sixteen wide column'
    Template.user_dashboard.helpers
        ssd: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.findOne
                model:'student_stats'
                user_id:user._id
        student_classrooms: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'classroom'
                student_ids: $in: [user._id]
        user_events: ->
            Docs.find {
                model:'classroom_event'
            }, sort: _timestamp: -1
        user_credits: ->
            Docs.find {
                model:'classroom_event'
                event_type:'credit'
            }, sort: _timestamp: -1
        user_debits: ->
            Docs.find {
                model:'classroom_event'
                event_type:'debit'
            }, sort: _timestamp: -1
        user_models: ->
            user = Meteor.users.findOne Router.current().params.user_id
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
        'click .recalc_student_stats': -> Meteor.call 'recalc_student_stats', Router.current().params.user_id
        'click .set_delta_model': -> Meteor.call 'set_delta_facets', @slug, null, true
        'click .logout_other_clients': -> Meteor.logoutOtherClients()
        'click .logout': ->
            Router.go '/login'
            Meteor.logout()




    Template.user_sessions_small.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', Router.current().params.user_id, 'test_session'
    Template.user_sessions_small.onRendered ->
    Template.user_sessions_small.helpers
        sessions: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'test_session'
                _author_id: user._id




    Template.user_bookmarks_small.onCreated ->
        @autorun -> Meteor.subscribe 'user_bookmarks', Router.current().params.user_id
    Template.user_bookmarks_small.onRendered ->
    Template.user_bookmarks_small.helpers
        bookmarks: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                _id:$in:user.bookmark_ids





    Template.user_questions.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', Router.current().params.user_id, 'question'
    Template.user_questions.onRendered ->
    Template.user_questions.helpers
        questions: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'question'
                _author_id: user._id







if Meteor.isServer
    Meteor.publish 'user_bookmarks', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            _id:$in:user.bookmark_ids

    Meteor.publish 'user_model_docs', (user_id, model)->
        # user = Meteor.users.findOne user_id
        Docs.find
            model:model
            _author_id:user_id

    Meteor.publish 'user_events', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'classroom_event'
            user_id:user._id

    Meteor.publish 'student_stats', (user_id)->
        user = Meteor.users.findOne user_id
        if user
            Docs.find
                model:'student_stats'
                user_id:user._id


    Meteor.methods
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
                model:'classroom_event'
                event_type:'debit'
                user_id:user_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'classroom_event'
                event_type:'credit'
                user_id:user_id})
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
