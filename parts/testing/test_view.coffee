if Meteor.isClient
    Template.test_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'act_test_session'
    Template.test_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.test_view.helpers
        sessions: ->
            Docs.find {
                model:'act_test_session'
                test_id: Router.current().params.doc_id
            }, sort: correct_percent:-1
    Template.test_view.events
        # 'click .add_question': ->
        #     new_question_id = Docs.insert
        #         model:'question'
        #         test_id:Router.current().params.doc_id
        #     Router.go "/question/#{new_question_id}/edit"

        'click .refresh_test_stats': ->
            Meteor.call 'refresh_test_stats', Router.current().params.doc_id, ->

        'click .take_test': ->
            # console.log @
            Session.set 'current_question_id', null
            new_session_id = Docs.insert
                model:'act_test_session'
                test_id:Router.current().params.doc_id
            # Router.go "/test_session/#{new_session_id}/description"
            Router.go "/test_session/#{new_session_id}/take"

if Meteor.isServer
    Meteor.methods
        refresh_test_stats: (test_id)->
            test = Docs.findOne test_id
            session_cursor =
                Docs.find(
                    model:'act_test_session'
                    test_id: test_id
                )
            session_count = session_cursor.count()

            total_correct_percent = 0
            total_correct_count = 0
            total_incorrect_count = 0
            for session in session_cursor.fetch()
                if session.correct_percent
                    total_correct_percent += parseInt(session.correct_percent)
                if session.correct_count
                    total_correct_count += parseInt(session.correct_count)
                if session.incorrect_count
                    total_incorrect_count += parseInt(session.incorrect_count)

            total_average = total_correct_percent/session_count
            incorrect_average = total_incorrect_count/session_count
            correct_average = total_correct_count/session_count

            comment_count =
                Docs.find(
                    model:'comment'
                    parent_id:test_id
                ).count()



            Docs.update test_id,
                $set:
                    session_count: session_count
                    total_average: total_average
                    correct_average: parseInt(correct_average)
                    incorrect_average: parseInt(incorrect_average)
                    comment_count: comment_count
