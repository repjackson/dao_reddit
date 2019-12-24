if Meteor.isClient
    Template.test_pool_selector.events
        'click .select_test_pool_type': ->
            test_session = Docs.findOne Router.current().params.doc_id
            Docs.update test_session._id,
                $set: test_pool: @key
            Meteor.call 'calc_question_pool', Router.current().params.doc_id

    Template.test_pool_selector.helpers
        test_pool_class: ->
            test_session = Docs.findOne Router.current().params.doc_id
            if test_session.test_pool is "#{@key}" then 'active' else ''


    Template.test_session_edit.events
        'click .recalc_test_session_stats': ->
            Meteor.call 'calc_test_session_stats', Router.current().params.doc_id, ->
        'click .cancel_session': ->
            if confirm 'cancel session?'
                Docs.remove Router.current().params.doc_id
                Router.go '/tests'
        'click .generate_test': ->
            Session.set 'generating', true
            Session.set 'seconds_elapsed', 0
            Session.set 'minutes_elapsed', 0
            test_session_id = Router.current().params.doc_id
            Meteor.call 'generate_test', Router.current().params.doc_id, =>
                test_session = Docs.findOne test_session_id
                # console.log test_session.questions_array
                first_question = _.findWhere(test_session.questions_array, {question_number:1})
                # console.log first_question
                Session.set 'current_question_id', first_question.question_id
                Session.set 'generating', false
        'click .select_question': ->
            Session.set 'current_question_id', @question_id
        'click .choose_choice': ->
            Meteor.call 'act_select_choice', Router.current().params.doc_id, Session.get('current_question_id'), @_id
        'click .proceed': ->
            test_session_id = Router.current().params.doc_id
            test_session = Docs.findOne test_session_id
            current_question = Docs.findOne Session.get('current_question_id')
            current_question_ob = _.findWhere(test_session.questions_array, {question_id:Session.get('current_question_id')})
            # console.log 'current question ob', current_question_ob
            next_question_number = parseInt((current_question_ob.question_number)+1)
            next_question_ob = _.findWhere(test_session.questions_array, {question_number:next_question_number})
            # console.log next_question_number
            # console.log next_question_ob
            # Meteor.call 'proceed', test_session_id, ->
            Meteor.call 'mark_answered', Session.get('current_question_id'), ->
            $('.question_column').transition('fade left', 250)

            Session.set('current_question_id', next_question_ob.question_id)
            $('.question_column').transition('fade left', 250)
            # Session.set('current_question_id', next_question._id)

        'click .finish': ->
            Meteor.call 'calculate_test_session_results', Router.current().params.doc_id, (err,res)->
                Router.go "/test_session/#{Router.current().params.doc_id}/view"



if Meteor.isServer
    Meteor.methods
        mark_answered: (question_id)->
            Docs.update question_id,
                $addToSet:
                    answered_user_ids: Meteor.userId()
        proceed: (test_session_id)->
            Docs.update current_question._id,
                $addToSet: answered_user_ids: Meteor.userId()



        calc_question_pool: (doc_id)->
            test_session = Docs.findOne doc_id
            console.log test_session
            user = Meteor.users.findOne test_session._author_id
            unanswered_questions =
                Docs.find
                    model:'question'
                    answered_user_ids: $nin: [user._id]
            correct_questions =
                Docs.find
                    model:'question'
                    correct_ids: $in: [user._id]
            incorrect_questions =
                Docs.find
                    model:'question'
                    incorrect_ids: $in: [user._id]
            unanswered_count = unanswered_questions.count()
            correct_count = correct_questions.count()
            incorrect_count = incorrect_questions.count()
            Docs.update doc_id,
                $set:
                    unanswered_count: unanswered_count
                    correct_count: correct_count
                    incorrect_count: incorrect_count


        generate_test: (test_session_id)->
            test_session = Docs.findOne test_session_id
            user = Meteor.users.findOne test_session._author_id

            # console.log test
            match = {}
            match.model = 'question'
            # if test_session.test_pool is 'all'
            if test_session.test_pool is 'unanswered'
                match.answered_user_ids = $nin: [user._id]
            if test_session.test_pool is 'correct'
                match.correct_ids = $in: [user._id]
            if test_session.test_pool is 'incorrect'
                match.incorrect_ids = $in: [user._id]

            if test_session.question_count
                questions =
                    Docs.find( match,
                        limit:test_session.question_count
                    ).fetch()
                questions_array = []
                question_number = 1
                for question in questions
                    questions_array.push {
                        question_id: question._id
                        question_number: question_number
                        }
                    question_number++
            Docs.update test_session._id,
                $set:
                    questions_array: questions_array
                    generated: true
                    start_timestamp: Date.now()
