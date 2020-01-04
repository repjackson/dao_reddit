if Meteor.isClient
    Template.take_act_test.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000
    Template.take_act_test.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'test_from_test_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'act_question'
    Template.take_act_test.events
        'click .complete_test': ->
            if confirm 'complete test?'
                test_session = Docs.findOne Router.current().params.doc_id
                correct_count = _.where(test_session.answers, {correct_choice:true}).length
                incorrect_count = _.where(test_session.answers, {correct_choice:false}).length
                dont_know_count = _.where(test_session.answers, {selected_answer:'?'}).length
                answer_count = test_session.answers.length
                test_session = Docs.findOne Router.current().params.doc_id
                total_count =
                    Docs.find(
                        model:'act_question'
                        test_id:test_session.test_id
                    ).count()
                console.log total_count
                correct_percent = ((correct_count/total_count)*100).toFixed()
                act_score = parseInt(35*correct_percent/100)
                answer_percent = ((answer_count/total_count)*100).toFixed()
                Docs.update test_session._id,
                    $set:
                        total_count:total_count
                        answer_count:answer_count
                        correct_count:correct_count
                        incorrect_count:incorrect_count
                        dont_know_count:dont_know_count
                        correct_percent:correct_percent
                        answer_percent:answer_percent
                        act_score:act_score
                        complete:true
                test_session = Docs.findOne Router.current().params.doc_id
                console.log test_session


    Template.take_act_test.helpers
        # first_row: -> [0..28]
        # second_row: -> [28..40]
        single_digit: ->
            @number < 10
        test_questions: ->
            test_session = Docs.findOne Router.current().params.doc_id
            Docs.find {
                model:'act_question'
                # test_section: test_session.current_section
                test_id: test_session.test_id
            }, sort:number:1

        test: ->
            test_session = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                _id: test_session.test_id

    Template.select_act_choice.helpers
        choice_class: ->
            result = ''
            # console.log @
            test_session = Docs.findOne Router.current().params.doc_id
            parent = Template.parentData()
            # console.log parent
            selected_choice =
                _.findWhere(test_session.answers, {question_id:parent._id, selected_answer:@key})
            if selected_choice
                if test_session.hardcore
                    if test_session.complete
                        result += ' disabled'
                        if selected_choice.correct_choice
                            result += ' green'
                        else
                            result += ' red'
                    else
                        result += ' active'
                else
                    if selected_choice.correct_choice
                        result += ' green'
                    else
                        result += ' red'
                console.log selected_choice
            if test_session.complete
                result += ' disabled'

            result



    Template.select_act_choice.events
        'click .select_choice': ->
            # console.log @
            parent = Template.parentData()
            test_session_id = Router.current().params.doc_id
            Meteor.call 'select_act_choice', @key, parent._id, test_session_id, ->
