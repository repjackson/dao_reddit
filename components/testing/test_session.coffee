if Meteor.isClient
    Router.route '/test_sessions', (->
        @layout 'layout'
        @render 'test_sessions'
        ), name:'test_sessions'
    Router.route '/test_session/:doc_id/edit', (->
        @layout 'layout'
        @render 'test_session_edit'
        ), name:'test_session_edit'
    Router.route '/test_session/:doc_id/view', (->
        @layout 'layout'
        @render 'test_session_view'
        ), name:'test_session_view'


    Template.test_session_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.test_session_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'test_from_test_session_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'question'
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.test_session_edit.events
        'click .recalc_test_session_stats': ->
            Meteor.call 'calc_test_session_stats', Router.current().params.doc_id, ->

        'click .cancel_session': ->
            if confirm 'cancel session?'
                Docs.remove Router.current().params.doc_id
                Router.go '/tests'

        'click .generate_test': ->
            Session.set 'generating', true
            test_session_id = Router.current().params.doc_id
            Meteor.call 'generate_test', Router.current().params.doc_id, =>
                test_session = Docs.findOne test_session_id
                console.log test_session.questions_array
                first_question = _.findWhere(test_session.questions_array, {question_number:1})
                console.log first_question
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
            console.log 'current question ob', current_question_ob
            next_question_number = parseInt((current_question_ob.question_number)+1)
            next_question_ob = _.findWhere(test_session.questions_array, {question_number:next_question_number})
            console.log next_question_number
            console.log next_question_ob
            $('.question_column')
                .transition('fade left', 500)
                .transition('fade left', 500)

            Session.set('current_question_id', next_question_ob.question_id)
            # Session.set('current_question_id', next_question._id)

        'click .finish': ->
            Meteor.call 'calculate_test_session_results', Router.current().params.doc_id, (err,res)->
                Router.go "/test_session/#{Router.current().params.doc_id}/view"

    Template.test_session_edit.helpers
        generating: -> Session.get 'generating'
        test_session_choice_class: ->
            test_session = Docs.findOne Router.current().params.doc_id
            choice_selected = Docs.findOne({
                _id:test_session._id
                "answers.question_id":Session.get('current_question_id')
                "answers.selected_choice_id":@_id
            })
            if choice_selected
                "active"
            else
                ""
        question_answered: ->
            test_session = Docs.findOne Router.current().params.doc_id
            choice_selected = Docs.findOne({
                _id:test_session._id
                "answers.question_id":Session.get('current_question_id')
                })
        is_last_question: ->
            test_session = Docs.findOne Router.current().params.doc_id
            question_count = test_session.questions_array.length
            last_question_ob = _.findWhere(test_session.questions_array, {question_number:question_count})
            # console.log last_question_ob
            if Session.equals('current_question_id', last_question_ob.question_id) then true else false

        question_button_class: ->
            test_session = Docs.findOne Router.current().params.doc_id
            answer_ob = _.findWhere(test_session.answers, {question_id:@question_id})
            # console.log answer_ob
            if Session.equals('current_question_id', @question_id)
                'active'
            else if answer_ob
                # console.log 'answer', answer_ob
                if answer_ob.first_choice_correct
                    'green'
                else if answer_ob.second_choice_correct
                    'orange'
                else
                    'red'
            else
                'basic'

        questions_array: ->
            test_session = Docs.findOne Router.current().params.doc_id

        test_questions: ->
            test_session = Docs.findOne Router.current().params.doc_id
            question_ids = _.pluck(test_session.questions,'question_id')
            Docs.find
                model:'question'
                _id: $in:question_ids
        test: ->
            Docs.findOne
                model:'test'
        current_question: ->
            Docs.findOne Session.get('current_question_id')
        choices: ->
            Docs.find {
                model:'choice'
                question_id: Session.get('current_question_id')
                # test_session_id: Router.current().params.doc_id
            }, sort: number: 1




    Template.test_choice_selector.helpers
        choice_html: ->
            question = Template.parentData()
            # console.log question["choice_#{@answer}"]
            # console.log @
            # console.log question
            question["choice_#{@answer}"]
        select_choice_class: ->
            test_session = Docs.findOne Router.current().params.doc_id
            current_question = Docs.findOne(Session.get('current_question_id'))
            # console.log @
            existing_answer = _.findWhere(test_session.answers, {question_id:current_question._id})
            if existing_answer
                # console.log 'existing answer', existing_answer
                if @answer is existing_answer.first_choice_letter
                    # "orange"
                    if existing_answer.first_choice_correct
                        "inverted green"
                    else
                        "secondary inverted yellow"
                else if existing_answer.first_choice_correct
                    "disabled"
                else if @answer is existing_answer.second_choice_letter
                    if existing_answer.second_choice_correct
                        "inverted green"
                    else
                        "inverted orange"
                else if existing_answer.first_choice_letter and existing_answer.second_choice_letter
                    'disabled'

            else
                # console.log 'no existing answer'
                ''

    Template.test_choice_selector.events
        'click .select_choice': ->
            # console.log @
            # console.log Template.currentData()
            # console.log Template.parentData()
            test_session = Docs.findOne Router.current().params.doc_id
            # console.log test_session
            Meteor.call 'act_select_choice', test_session._id, Session.get('current_question_id'), @answer







    Template.test_sessions.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'test_session'
    Template.test_sessions.helpers
        test_sessions: ->
            Docs.find
                model:'test_session'



    Template.test_session_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.test_session_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.test_session_view.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'test_test_session'
        @autorun => Meteor.subscribe 'model_docs', 'test_question'
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.test_session_view.helpers
        test: ->
            Docs.findOne
                model:'test'
        test_sessions: ->
            Docs.find
                model:'test_session'
    Template.test_session_view.events
        'click .calc_test_session_total': ->
            console.log @
        'click .take_test': ->
            new_test_session_id = Docs.insert
                model:'test_test_session'
                test_session_id: Router.params.current().doc_id

            Router.go "/test_session/#{new_test_session_id}/edit"






if Meteor.isServer
    Meteor.publish 'test_session_reservations_by_id', (test_session_id)->
        Docs.find
            model:'reservation'
            test_session_id: test_session_id
    Meteor.publish 'test_sessions', (test_session_id)->
        Docs.find
            model:'test_session'
            test_session_id:test_session_id
    Meteor.publish 'test_from_test_session_id', (test_session_id)->
        test_session = Docs.findOne test_session_id
        Docs.find
            model:'test'
            _id: test_session.test_id
    Meteor.methods
        calc_test_session_stats: (test_session_id)->
            test_session = Docs.findOne test_session_id
            console.log test_session
            question_count = test_session.questions_array.length
            answer_count = test_session.answers.length
            correct_count = _.where(test_session.answers, {first_choice_correct:true}).length
            incorrect_count = _.where(test_session.answers, {first_choice_correct:false}).length
            almost_correct_count = _.where(test_session.answers, {first_choice_correct:false, second_choice_correct:true}).length
            correct_percent = ((correct_count/question_count)*100).toFixed()
            Docs.update test_session_id,
                $set:
                    question_count:question_count
                    answer_count: answer_count
                    correct_count:correct_count
                    incorrect_count:incorrect_count
                    almost_correct_count:almost_correct_count
                    correct_percent:correct_percent

        generate_test: (test_id)->
            test = Docs.findOne test_id
            if test.question_count
                questions = Docs.find({
                    model:'question'
                }, limit:test.question_count).fetch()
                questions_array = []
                question_number = 1
                for question in questions
                    questions_array.push {
                        question_id: question._id
                        question_number: question_number
                        }
                    question_number++
            Docs.update test._id,
                $set:
                    questions_array: questions_array
                    generated: true



        calculate_test_session_results: (test_session_id)->
            test_session = Docs.findOne test_session_id
            # correct_answers = 0
            now = Date.now()
            moment_start = moment(test_session._timestamp)
            moment_end = moment(test_session.now)
            seconds_duration = moment_start.diff(moment_end, 'seconds')
            minutes_duration = moment_start.diff(moment_end, 'minutes')
            console.log 'diff', seconds_duration
            average_minutes_per_question = minutes_duration/test_session.answer_count
            Docs.update test_session_id,
                $set:
                    finish_timestamp: now
                    average_minutes_per_question: Math.abs(average_minutes_per_question.toFixed())
                    seconds_duration: Math.abs(seconds_duration)
                    minutes_duration: Math.abs(minutes_duration)
            Meteor.call 'calc_test_session_stats', test_session_id, ->


Meteor.methods
    act_select_choice: (test_session_id, question_id, choice)->
        # console.log 'test_session id', test_session_id
        # console.log 'question id', question_id
        # console.log 'choice', choice
        question = Docs.findOne question_id
        test_session = Docs.findOne test_session_id
        choice_content = question["choice_#{choice}"]
        correct_choice = question.correct_choice is choice
        existing_choice_selected = Docs.findOne({
            _id:test_session_id
            "answers.question_id":question_id
            })
        if existing_choice_selected
            Docs.update {
                _id:test_session_id
                "answers.question_id":question_id
            }, {
                $set:
                    "answers.$.second_choice_letter":choice
                    "answers.$.second_choice_content":choice_content
                    "answers.$.second_choice_correct":correct_choice
            }
        else
            Docs.update {
                _id:test_session_id
            }, {
                $addToSet:
                    answers:
                        question_id:question_id
                        first_choice_letter:choice
                        first_choice_content:choice_content
                        first_choice_correct: correct_choice
                        first_choice_timestamp: Date.now()
            }


        # Docs.update {
        #         _id:test_session_id,
        #         "answers.question_id":question_id
        #     }, {
        #         $addToSet:
        #             "answers.$.selected_choice_id":choice._id
        #             "answers.$.selected_choice_content":choice.content
        #     }
        #
        #
