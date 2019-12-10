if Meteor.isClient
    Router.route '/sessions', (->
        @layout 'layout'
        @render 'sessions'
        ), name:'sessions'
    Router.route '/session/:doc_id/edit', (->
        @layout 'layout'
        @render 'session_edit'
        ), name:'session_edit'
    Router.route '/session/:doc_id/view', (->
        @layout 'layout'
        @render 'session_view'
        ), name:'session_view'


    Template.session_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.session_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'passage_from_session_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'passage_question'
        @autorun => Meteor.subscribe 'model_docs', 'passage_question_choice'
    Template.session_edit.events
        'click .select_question': ->
            Session.set 'current_question_id', @_id
        'click .choose_choice': ->
            Meteor.call 'select_choice', Router.current().params.doc_id, Session.get('current_question_id'), @_id
        'click .proceed': ->
            current_question = Docs.findOne Session.get('current_question_id')
            next_question_number = parseInt((current_question.number)+1)
            next_question =
                Docs.findOne
                    model:'passage_question'
                    number:next_question_number
            console.log next_question_number
            console.log Session.get('current_question_id')
            Session.set('current_question_id', next_question._id)
        'click .finish': ->
            Meteor.call 'calculate_session_results', Router.current().params.doc_id, (err,res)->
                Router.go "/session/#{Router.current().params.doc_id}/view"
    Template.session_edit.helpers
        session_choice_class: ->
            session = Docs.findOne Router.current().params.doc_id
            choice_selected = Docs.findOne({
                _id:session._id
                "answers.question_id":Session.get('current_question_id')
                "answers.selected_choice_id":@_id
            })
            if choice_selected
                "active"
            else
                ""
        question_answered: ->
            session = Docs.findOne Router.current().params.doc_id
            choice_selected = Docs.findOne({
                _id:session._id
                "answers.question_id":Session.get('current_question_id')
                })

        is_last_question: ->
            session = Docs.findOne Router.current().params.doc_id
            last_question = Docs.findOne({
                model:'passage_question'
                passage_id: session.passage_id
                }, sort:number:-1)
            # console.log last_question
            if Session.equals('current_question_id', last_question._id) then true else false
        question_button_class: ->
            if Session.equals('current_question_id', @_id) then 'active' else ''
        passage_questions: ->
            session = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'passage_question'
                passage_id: session.passage_id
        passage: ->
            Docs.findOne
                model:'passage'
        current_question: ->
            Docs.findOne Session.get('current_question_id')
        question_choices: ->
            Docs.find {
                model:'passage_question_choice'
                question_id: Session.get('current_question_id')
                # session_id: Router.current().params.doc_id
            }, sort: number: 1






    Template.sessions.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'session'
    Template.sessions.helpers
        sessions: ->
            Docs.find
                model:'session'



    Template.session_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.session_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.session_view.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'test_session'
        @autorun => Meteor.subscribe 'model_docs', 'passage_question'
        @autorun => Meteor.subscribe 'model_docs', 'passage_question_choice'
    Template.session_view.helpers
        passage: ->
            Docs.findOne
                model:'passage'
        sessions: ->
            Docs.find
                model:'session'
    Template.session_view.events
        'click .calc_passage_total': ->
            console.log @
        'click .take_test': ->
            new_session_id = Docs.insert
                model:'test_session'
                session_id: Router.params.current().doc_id

            Router.go "/session/#{new_session_id}/edit"






if Meteor.isServer
    Meteor.publish 'session_reservations_by_id', (session_id)->
        Docs.find
            model:'reservation'
            session_id: session_id

    Meteor.publish 'sessions', (session_id)->
        Docs.find
            model:'session'
            session_id:session_id


    Meteor.publish 'passage_from_session_id', (session_id)->
        session = Docs.findOne session_id
        Docs.find
            model:'passage'
            _id: session.passage_id


    Meteor.methods
        # calc_passage_total: (session_id)->
        calc_passage_total: (passage_id)->
            console.log 'passage_id', passage_id
            passage = Docs.findOne passage_id
            question = Docs.findOne
                _id: passage.passage_id
            console.log 'question', question
            console.log 'session',session
            passages = Docs.find(
                model:'passage'
                _id: passage.passage._id
            ).fetch()
            passage_questions = Docs.find(
                model:'passage_question'
                passage_id: passage._id
            )
            passage_sessions = Docs.find(
                model:'test_session'
                passage_id: passage_id
            )
            session_count = passage_sessions.count()
            for session in passage_sessions.fetch()
                console.log session.correct_percent

            console.log passage_sessions.fetch()
            Docs.update passage._id,
                $set:
                    question_count:passage_questions.count()



        calculate_session_results: (session_id)->
            session = Docs.findOne session_id
            passage = Docs.findOne session.passage_id
            passage_questions =
                Docs.find(
                    model:'passage_question'
                    passage_id: passage._id
                ).fetch()
            passage_question_count =
                Docs.find(
                    model:'passage_question'
                    passage_id: passage._id
                ).count()
            correct_answers = 0
            answers = session.answers
            choices =
                Docs.find(
                    model:'passage_question_choice'
                ).fetch()
            console.log choices
            for question in passage_questions
                console.log question
                chosen_answer = _.where(answers, {question_id:question._id})
                right_answer =
                    Docs.findOne
                        model:'passage_question_choice'
                        question_id: question._id
                        correct: true
                console.log 'right_answer', right_answer
                # right_answer = _.where(answers, {question_id:question._id})
                console.log chosen_answer[0]

                if right_answer._id is chosen_answer[0].selected_choice_id
                    correct_answers++
                    Docs.update session_id,
                        $set: correct_answers: correct_answers
                    console.log 'right answer'
                else
                    console.log 'wrong answer'
                correct_answers = if correct_answers then correct_answers else 0
                correct_percent =
                    correct_answers / passage_question_count
                Docs.update session_id,
                    $set:
                        correct_answers: correct_answers
                        question_count:passage_question_count
                        correct_percent: correct_percent

        select_choice: (session_id, question_id, choice_id)->
            console.log 'session id', session_id
            console.log 'question id', question_id
            console.log 'choice id', choice_id
            choice = Docs.findOne choice_id
            existing_choice_selected = Docs.findOne({
                _id:session_id
                "answers.question_id":question_id
                })
            if existing_choice_selected
                Docs.update {
                    _id:session_id
                    "answers.question_id":question_id
                }, {
                    $set:
                        "answers.$.selected_choice_id":choice._id
                        "answers.$.selected_choice_number":choice.number
                        "answers.$.selected_choice_content":choice.content
                }
            else
                Docs.update {
                    _id:session_id
                }, {
                    $addToSet:
                        answers:
                            question_id:question_id
                            selected_choice_id:choice._id
                            selected_choice_number:choice.number
                            selected_choice_content:choice.content
                }


            # Docs.update {
            #         _id:session_id,
            #         "answers.question_id":question_id
            #     }, {
            #         $addToSet:
            #             "answers.$.selected_choice_id":choice._id
            #             "answers.$.selected_choice_content":choice.content
            #     }
            #
            #


        refresh_session_stats: (session_id)->
            session = Docs.findOne session_id
            # console.log session
            reservations = Docs.find({model:'reservation', session_id:session_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_session_hours = 0
            average_session_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_session_hours += parseFloat(res.hour_duration)

            average_session_cost = total_earnings/reservation_count
            average_session_duration = total_session_hours/reservation_count

            Docs.update session_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_session_hours: total_session_hours.toFixed(0)
                    average_session_cost: average_session_cost.toFixed(0)
                    average_session_duration: average_session_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header session ranking #reservations
            # .ui.small.header session ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg session time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
