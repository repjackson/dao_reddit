if Meteor.isClient
    Router.route '/tests', (->
        @layout 'layout'
        @render 'tests'
        ), name:'tests'
    Router.route '/test/:doc_id/edit', (->
        @layout 'layout'
        @render 'test_edit'
        ), name:'test_edit'
    Router.route '/test/:doc_id/view', (->
        @layout 'layout'
        @render 'test_view'
        ), name:'test_view'



    Template.test_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.test_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.test_edit.events
        'click .add_test_item': ->
            new_mi_id = Docs.insert
                model:'test_item'
            Router.go "/test/#{_id}/edit"


    Template.test_edit.helpers
        test_questions: ->
            Docs.find
                _id: $in: @question_ids





    Template.test_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.test_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.test_view.helpers
        sessions: ->
            Docs.find
                model:'test_session'
                test_id: Router.current().params.doc_id
    Template.test_view.events
        'click .add_question': ->
            new_question_id = Docs.insert
                model:'question'
                test_id:Router.current().params.doc_id
            Router.go "/question/#{new_question_id}/edit"

        'click .take_test': ->
            console.log @
            Session.set 'current_question_id', null
            new_session_id = Docs.insert
                model:'test_session'
                test_id:Router.current().params.doc_id
                question_count: 10
            Router.go "/session/#{new_session_id}/"



    Template.tests.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'test'
        @autorun => Meteor.subscribe 'model_docs', 'test_session'
    Template.tests.helpers
        tests: ->
            Docs.find
                model:'test'
        test_sessions: ->
            Docs.find {
                model:'test_session'
            }, sort: _timestamp: -1
    Template.tests.events
        'click .take_forest_test': ->
            Session.set 'current_question_id', null
            new_ts_id = Docs.insert
                model:'test_session'
                question_count:10
                generated:false
            Router.go "/test_session/#{new_ts_id}/edit"


        'click .view_test': ->
            Router.go "/test_session/#{@_id}/view"

        'click .refresh_user_stats': ->
            Meteor.call 'refresh_user_stats', Meteor.userId()


        'click .add_test': ->
            new_test_id = Docs.insert
                model:'test'
            Router.go "/test/#{new_test_id}/edit"





if Meteor.isServer
    Meteor.publish 'tests', (product_id)->
        Docs.find
            model:'test'
            product_id:product_id

    Meteor.methods
        refresh_user_stats: (user_id)->
            user = Meteor.users.findOne user_id
            user_session_cursor = Docs.find
                _author_id: Meteor.userId()
                model:'test_session'
            user_session_count = user_session_cursor.count()
            total_correct_percent = 0
            for session in user_session_cursor.fetch()
                console.log session.correct_percent
                if session.correct_percent
                    total_correct_percent += parseInt(session.correct_percent)


            console.log total_correct_percent
            user_average_correct_percent = total_correct_percent/user_session_count
            Meteor.users.update user_id,
                $set:
                    total_session_amount:user_session_count
                    average_correct_percent:user_average_correct_percent.toFixed()





            global_session_cursor = Docs.find
                model:'test_session'
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

            global_average_correct_percent = global_total_correct_percent/global_session_count
            Docs.update global_stats_doc._id,
                $set:
                    global_average_correct_percent:global_average_correct_percent.toFixed()
                    total_sessions: global_session_count
