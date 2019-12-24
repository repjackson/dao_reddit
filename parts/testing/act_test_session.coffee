if Meteor.isClient
    Router.route '/act_test_sessions', (->
        @layout 'layout'
        @render 'act_test_sessions'
        ), name:'act_test_sessions'
    Router.route '/act_test_session/:doc_id/view', (->
        @layout 'layout'
        @render 'act_test_session_view'
        ), name:'act_test_session_view'


    Template.timing.onRendered ->
        act_test_session = Docs.findOne Router.current().params.doc_id
        # console.log act_test_session
        sec_handle = Meteor.setInterval =>
            this_moment = moment()
            start_moment = moment(act_test_session.start_timestamp)

            Session.set('seconds_elapsed',this_moment.diff(start_moment, 'seconds'))
            Session.set('minutes_elapsed',this_moment.diff(start_moment, 'minutes'))
            if act_test_session.total_minute_duration <= Session.get('minutes_elapsed')
                # console.log Session.get('minutes_elapsed')
                # console.log act_test_session.total_minute_duration
                Meteor.call 'complete_act_test', Router.current().params.doc_id, sec_handle, ->
                Router.go "/act_test_session/#{act_test_session._id}/view"
                Meteor.clearInterval sec_handle
            # else
            #     console.log Session.get('minutes_elapsed')
            #     console.log act_test_session.total_minute_duration
        , 1000


    Template.timing.helpers
        test_start: ->
            act_test_session = Docs.findOne Router.current().params.doc_id
            moment(act_test_session.start_timestamp).fromNow()
        seconds_elapsed: ->
            act_test_session = Docs.findOne Router.current().params.doc_id
            now = Date.now()
            start_moment = moment(act_test_session.start_timestamp)

            Session.get('seconds_elapsed')
            # moment(act_test_session.start_timestamp).fromNow()
            # Template.instance().seconds_elapsed.get()
        minutes_elapsed: ->
            # (Template.instance().seconds_elapsed.get()/60).toFixed()
            # act_test_session = Docs.findOne Router.current().params.doc_id
            # now = Date.now()
            # start_moment = moment(act_test_session.start_timestamp)
            # minute_handle = Meteor.setInterval =>
            #     this_moment = moment()
            #     Session.set('minutes_elapsed',this_moment.diff(start_moment, 'minutes'))
            #     console.log Session.get('minutes_elapsed')
            # , 10000
            # if act_test_session.total_minute_duration <= Session.get('minutes_elapsed')
            #     Meteor.call 'complete_test', Router.current().params.doc_id, minute_handle, ->
            #     Router.go "/act_test_session/#{@_id}/view"
            #     Meteor.clearInterval minute_handle

            Session.get('minutes_elapsed')
        # time_elapsed: ->
        #     now = Date.now()
        #     act_test_session = Docs.findOne Router.current().params.doc_id
        #     act_test_session.start_timestamp-now

        minutes_left: ->
            act_test_session = Docs.findOne Router.current().params.doc_id
            act_test_session.total_minute_duration-Session.get('minutes_elapsed')




    Template.test_choice_selector.helpers
        choice_html: ->
            question = Template.parentData()
            # console.log question["choice_#{@answer}"]
            # console.log @
            # console.log question
            question["choice_#{@answer}"]
        select_choice_class: ->
            act_test_session = Docs.findOne Router.current().params.doc_id
            current_question = Docs.findOne(Session.get('current_question_id'))
            # console.log @
            existing_answer = _.findWhere(act_test_session.answers, {question_id:current_question._id})
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
            act_test_session = Docs.findOne Router.current().params.doc_id
            # console.log act_test_session
            Meteor.call 'act_select_choice', act_test_session._id, Session.get('current_question_id'), @answer







    Template.act_test_sessions.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'act_test_session'
    Template.act_test_sessions.helpers
        act_test_sessions: ->
            Docs.find
                model:'act_test_session'



    Template.act_test_session_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.act_test_session_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.act_test_session_view.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'test_question'
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.act_test_session_view.helpers
        test: ->
            Docs.findOne
                model:'test'
        act_test_sessions: ->
            Docs.find
                model:'act_test_session'
    Template.act_test_session_view.events
        'click .calc_act_test_session_total': ->
            console.log @
        'click .take_test': ->
            new_act_test_session_id = Docs.insert
                model:'test_act_test_session'
                act_test_session_id: Router.params.current().doc_id

            Router.go "/act_test_session/#{new_act_test_session_id}/edit"






if Meteor.isServer
    Meteor.publish 'act_test_session_reservations_by_id', (act_test_session_id)->
        Docs.find
            model:'reservation'
            act_test_session_id: act_test_session_id
    Meteor.publish 'act_test_sessions', (act_test_session_id)->
        Docs.find
            model:'act_test_session'
            act_test_session_id:act_test_session_id
    Meteor.publish 'test_from_act_test_session_id', (act_test_session_id)->
        act_test_session = Docs.findOne act_test_session_id
        Docs.find
            model:'test'
            _id: act_test_session.test_id
    Meteor.methods
        complete_act_test: (act_test_session_id, interval)->
            act_test_session = Docs.findOne act_test_session_id
            # console.log act_test_session
            # console.log interval
            Meteor.call 'calculate_act_test_session_results', act_test_session_id, (err,res)->
                # Router.go "/act_test_session/#{act_test_session_id}/view"

            # Meteor.clearInterval interval


        calc_act_test_session_stats: (act_test_session_id)->
            act_test_session = Docs.findOne act_test_session_id
            # console.log act_test_session
            question_count = act_test_session.questions_array.length
            answer_count = act_test_session.answers.length
            correct_count = _.where(act_test_session.answers, {first_choice_correct:true}).length
            incorrect_count = _.where(act_test_session.answers, {first_choice_correct:false}).length
            almost_correct_count = _.where(act_test_session.answers, {first_choice_correct:false, second_choice_correct:true}).length
            correct_percent = ((correct_count/question_count)*100).toFixed()
            Docs.update act_test_session_id,
                $set:
                    question_count:question_count
                    answer_count: answer_count
                    correct_count:correct_count
                    incorrect_count:incorrect_count
                    almost_correct_count:almost_correct_count
                    correct_percent:correct_percent



        calculate_act_test_session_results: (act_test_session_id)->
            act_test_session = Docs.findOne act_test_session_id
            # correct_answers = 0
            now = Date.now()
            moment_start = moment(act_test_session.start_timestamp)

            moment_end = moment(act_test_session.now)
            seconds_duration = moment_start.diff(moment_end, 'seconds')
            minutes_duration = moment_start.diff(moment_end, 'minutes')
            # console.log 'diff', seconds_duration
            average_minutes_per_question = minutes_duration/act_test_session.answer_count

            question_id_array = _.pluck(act_test_session.questions_array, 'question_id')
            # console.log 'qid array', question_id_array
            questions_tags = []
            for question_id in question_id_array
                question = Docs.findOne question_id
                if question.tags
                    for tag in question.tags
                        # console.log tag
                        questions_tags.push tag
                        # console.log questions_tags

            right_answers_array = _.where(act_test_session.answers, {first_choice_correct:true})
            right_ids = _.pluck right_answers_array, 'question_id'
            # console.log "right ids", right_ids
            # console.log 'qid array', right_id_array
            right_tags = []
            for right_id in right_ids
                right = Docs.findOne right_id
                if right.tags
                    for tag in right.tags
                        # console.log tag
                        right_tags.push tag
                        # console.log questions_tags
            wrong_answers_array = _.where(act_test_session.answers, {first_choice_correct:false})
            wrong_ids = _.pluck wrong_answers_array, 'question_id'
            # console.log "wrong ids", wrong_ids
            # console.log 'qid array', wrong_id_array
            wrong_tags = []
            for wrong_id in wrong_ids
                wrong = Docs.findOne wrong_id
                if wrong.tags
                    for tag in wrong.tags
                        # console.log tag
                        wrong_tags.push tag
                        # console.log questions_tags
            # console.log('questions tags', questions_tags)

            Docs.update act_test_session_id,
                $set:
                    right_tags: right_tags
                    wrong_tags: wrong_tags
                    questions_tags: questions_tags
                    question_id_array: question_id_array
                    finish_timestamp: now
                    average_minutes_per_question: Math.abs(average_minutes_per_question.toFixed())
                    seconds_duration: Math.abs(seconds_duration)
                    minutes_duration: Math.abs(minutes_duration)
            Meteor.call 'calc_act_test_session_stats', act_test_session_id, ->


Meteor.methods
    act_select_choice: (act_test_session_id, question_id, choice)->
        # console.log 'act_test_session id', act_test_session_id
        # console.log 'question id', question_id
        # console.log 'choice', choice
        question = Docs.findOne question_id
        act_test_session = Docs.findOne act_test_session_id
        choice_content = question["choice_#{choice}"]
        correct_choice = question.correct_choice is choice
        existing_choice_selected = Docs.findOne({
            _id:act_test_session_id
            "answers.question_id":question_id
            })
        if existing_choice_selected
            Docs.update {
                _id:act_test_session_id
                "answers.question_id":question_id
            }, {
                $set:
                    "answers.$.second_choice_letter":choice
                    "answers.$.second_choice_content":choice_content
                    "answers.$.second_choice_correct":correct_choice
            }
        else
            Docs.update {
                _id:act_test_session_id
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
        #         _id:act_test_session_id,
        #         "answers.question_id":question_id
        #     }, {
        #         $addToSet:
        #             "answers.$.selected_choice_id":choice._id
        #             "answers.$.selected_choice_content":choice.content
        #     }
        #
        #
