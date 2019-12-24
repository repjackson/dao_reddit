if Meteor.isClient
    Router.route '/questions', (->
        @layout 'layout'
        @render 'questions'
        ), name:'questions'
    Router.route '/question/:doc_id/edit', (->
        @layout 'layout'
        @render 'question_edit'
        ), name:'question_edit'
    Router.route '/question/:doc_id/view', (->
        @layout 'layout'
        @render 'question_view'
        ), name:'question_view'
    Router.route '/questions_stats', (->
        @layout 'layout'
        @render 'questions_stats'
        ), name:'questions_stats'




    Template.questions.onRendered ->
        # @autorun => Meteor.subscribe 'model_docs', 'choice'
        @autorun -> Meteor.subscribe('question_facet_docs',
            selected_question_tags.array()
            Session.get('view_answered')
            Session.get('view_unanswered')
            Session.get('view_correct')
            Session.get('view_incorrect')
        )
        Session.setDefault('view_mode', 'items')
    Template.questions.helpers
        questions: ->
            Docs.find
                model:'question'
        view_answered_class: -> if Session.equals('view_answered',true) then 'active' else ''
        view_unanswered_class: -> if Session.equals('view_unanswered',true) then 'active' else ''
        view_correct_class: -> if Session.equals('view_correct',true) then 'active' else ''
        view_incorrect_class: -> if Session.equals('view_incorrect',true) then 'active' else ''
        viewing_table: -> Session.equals('view_mode','table')
        viewing_grid: -> Session.equals('view_mode','grid')
        viewing_items: -> Session.equals('view_mode','items')
    Template.questions.events
        'click .add_question': ->
            new_question_id = Docs.insert
                model:'question'
                has_answer_limit: true
                answer_limit: 1
                question_type: 'boolean'
                boolean_type: 'yes_no'
            Router.go "/question/#{new_question_id}/edit"

        'click .view_question': ->
            Router.go "/question/#{@_id}/view"

        'click .view_answered': ->
            if Session.equals('view_answered',true)
                Session.set('view_answered', false)
            else
                Session.set('view_answered', true)
                Session.set('view_unanswered', false)
        'click .view_unanswered': ->
            if Session.equals('view_unanswered',true)
                Session.set('view_unanswered', false)
            else
                Session.set('view_unanswered', true)
                Session.set('view_answered', false)
        'click .view_correct': ->
            if Session.equals 'view_correct',true
                Session.set('view_correct', false)
            else
                Session.set('view_answered', true)
                Session.set('view_unanswered', false)
                Session.set('view_correct', true)
        'click .view_incorrect': ->
            if Session.equals 'view_incorrect',true
                Session.set('view_incorrect', false)
            else
                Session.set('view_answered', true)
                Session.set('view_unanswered', false)
                Session.set('view_incorrect', true)

    Template.change_view_mode.events
        'click .select_mode': ->
            Session.set('view_mode', @key)
    Template.change_view_mode.helpers
        view_mode_class: ->
            if Session.equals('view_mode', @key) then 'active' else ''






    Template.question_cloud.onCreated ->
        @autorun -> Meteor.subscribe('question_tags',
            selected_question_tags.array()
            Session.get('view_answered')
            Session.get('view_unanswered')
            Session.get('view_correct')
            Session.get('view_incorrect')
        )
        # @autorun -> Meteor.subscribe('model_docs', 'target')
    Template.question_cloud.helpers
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: ->
            Docs.findOne Session.get('selected_target_id')
        all_question_tags: ->
            question_count = Docs.find(model:'question').count()
            if 0 < question_count < 3 then Question_tags.find { count: $lt: question_count } else Question_tags.find({},{limit:42})
        selected_question_tags: -> selected_question_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key
    Template.question_cloud.events
        'click .unselect_target': -> Session.set('selected_target_id',null)
        'click .select_target': -> Session.set('selected_target_id',@_id)
        'click .select_question_tag': -> selected_question_tags.push @name
        'click .unselect_question_tag': -> selected_question_tags.remove @valueOf()
        'click #clear_question_tags': -> selected_question_tags.clear()


    Template.question_segment.onCreated ->
        # console.log @
        # @autorun => Meteor.subscribe('answer_sessions_from_question_id', @data._id)
        # @autorun => Meteor.subscribe('my_answer_from_question_id', @data._id)

    Template.question_segment.events
        'click .choose_true': ->
            Docs.insert
                complete: true
                model:'answer_session'
                boolean_choice:true
                question_id: @_id
            Docs.update @_id,
                $addToSet:
                    answered_user_ids: Meteor.userId()
        'click .choose_false': ->
            Docs.insert
                complete: true
                model:'answer_session'
                boolean_choice:false
                question_id: @_id
            Docs.update @_id,
                $addToSet:
                    answered_user_ids: Meteor.userId()

    Template.question_segment.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:@_id
        is_act: -> @question_type is 'act'
        is_multiple_choice: -> @question_type is 'multiple_choice'
        is_essay: -> @question_type is 'essay'
        is_number_test: -> @question_type is 'number'
        is_text_answer: -> @question_type is 'text'
        is_tagging_answer: -> @question_type is 'tagging'
        is_boolean_answer: -> @question_type is 'boolean'
        my_answer: ->
            Docs.findOne
                model:'answer_session'
                question_id: @_id
                _author_id: Meteor.userId()
        question_answers: ->
            Docs.findOne
                model:'answer_session'
                question_id: @_id





    Template.question_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.question_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_docs', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'dep'
    Template.question_edit.events
        'click .add_dep': ->
            new_dep_id = Docs.insert
                model:'dep'
                question_id: Router.current().params.doc_id

    Template.question_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:@_id
        deps: ->
            Docs.find
                model:'dep'
                question_id:Router.current().params.doc_id
        answer_segment_class:(input) ->
            # console.log input
            if @correct_choice is input then 'inverted green' else ''
            # Docs.find
            #     model:'dep'
            #     question_id:Router.current().params.doc_id
        # question_lookup_results: ->
        #     Docs.find({
        #         model:'question'
        #         title: {$regex:"#{title_query}", $options: 'i'}
        #         },{ limit:20 })
        is_act: -> @question_type is 'act'
        is_multiple_choice: -> @question_type is 'multiple_choice'
        is_essay: -> @question_type is 'essay'
        is_number_test: -> @question_type is 'number'
        is_text_answer: -> @question_type is 'text'
        is_tagging_answer: -> @question_type is 'tagging'
        is_boolean_answer: -> @question_type is 'boolean'


    Template.question_edit.events
        'click .add_choice': ->
            console.log @
            Docs.insert
                model:'choice'
                question_id:@_id





    Template.question_view.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'bounty'
        # @autorun => Meteor.subscribe 'model_docs', 'choice'
        @autorun => Meteor.subscribe 'answer_sessions_from_question_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.question_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.question_view.helpers
        can_answer: ->
            question = Docs.findOne Router.current().params.doc_id
            if question.has_answer_limit
                my_answer_count =
                    Docs.find(
                        model: 'answer_session'
                        _author_id: Meteor.userId()
                        question_id:Router.current().params.doc_id
                    ).count()
                # console.log my_answer_count
                if question.answer_limit > my_answer_count
                    true
                else
                    false
            else
                true

        choices: ->
            Docs.find
                model:'choice'
                question_id:@_id
        bounties: ->
            Docs.find
                model:'bounty'
                question_id:@_id
        my_answer: ->
            Docs.findOne
                model:'answer_session'
                question_id: Router.current().params.doc_id
        answer_sessions: ->
            Docs.find
                model:'answer_session'
                question_id: Router.current().params.doc_id
        can_accept: ->
            console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    question_id: Router.current().params.doc_id
            if my_answer_session
                console.log 'false'
                false
            else
                console.log 'true'
                true
        is_multiple_choice: -> @question_type is 'multiple_choice'
        is_essay: -> @question_type is 'essay'
        is_number_test: -> @question_type is 'number'
        is_text_answer: -> @question_type is 'text'

    Template.question_view.events
        'click .new_answer_session': ->
            # console.log @
            new_answer_session_id = Docs.insert
                model:'answer_session'
                start_timestamp: Date.now()
                question_id: Router.current().params.doc_id
            Router.go "/answer_session/#{new_answer_session_id}/edit"
        'click .offer_bounty': ->
            console.log @
            new_bounty_id = Docs.insert
                model:'bounty'
                question_id:@_id
            Router.go "/bounty/#{new_bounty_id}/edit"
        'click .accept': ->
            console.log @

        'click .calc_stats': ->
            Meteor.call 'calc_question_stats', Router.current().params.doc_id



    Template.questions_stats.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'questions_stats'
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.questions_stats.onRendered ->
    Template.questions_stats.helpers
        questions_stats_doc: ->
            Docs.findOne {
                model:'questions_stats'
                _author_id: Meteor.userId()
            }, _timestamp:1
        ranked_amount_stats: ->
            Docs.find {
                model:'questions_stats'
            }, sort: questions_session_count: -1

        ranked_percent_stats: ->
            Docs.find {
                model:'questions_stats'
            }, sort: average_correct_percent_amount: -1


    Template.questions_stats.events
        'click .recalc_questions_stats': ->
            console.log @
            Meteor.call 'recalc_questions_stats', Meteor.userId()





if Meteor.isServer
    Meteor.publish 'my_answer_from_question_id', (question_id)->
        Docs.find
            model:'answer_session'
            question_id:question_id
            _author_id: Meteor.userId()

    Meteor.publish 'question_docs', (question_id)->
        Docs.find
            question_id: question_id

    Meteor.publish 'answer_sessions_from_question_id', (question_id)->
        Docs.find
            model:'answer_session'
            question_id:question_id
    Meteor.publish 'questions', (product_id)->
        Docs.find
            model:'question'
            product_id:product_id
    Meteor.publish 'question_tags', (
        selected_question_tags
        view_answered
        view_unanswered
        view_correct
        view_incorrect
        )->
        self = @
        match = {}

        # console.log selected_question_tags
        # console.log view_answered
        # console.log view_unanswered
        # console.log view_correct
        # console.log view_incorrect
        if view_answered
            match.answered_user_ids = $in:[Meteor.userId()]
        if view_unanswered
            match.answered_user_ids = $nin:[Meteor.userId()]
        if view_correct
            match.correct_user_ids = $in:[Meteor.userId()]
        if view_incorrect
            match.incorrect_user_ids = $in:[Meteor.userId()]


        # if selected_target_id
        #     match.target_id = selected_target_id
        # selected_question_tags.push current_herd

        if selected_question_tags.length > 0 then match.tags = $all: selected_question_tags
        match.model = 'question'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_question_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'question_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'question_facet_docs', (
        selected_question_tags
        view_answered
        view_unanswered
        view_correct
        view_incorrect
        )->

        # console.log selected_question_tags
        # console.log view_answered
        # console.log view_unanswered
        # console.log view_correct
        # console.log view_incorrect
        # console.log filter
        self = @
        match = {}
        # if selected_target_id
        #     match.target_id = selected_target_id
        if view_answered
            match.answered_user_ids = $in:[Meteor.userId()]
        if view_unanswered
            match.answered_user_ids = $nin:[Meteor.userId()]
        if view_correct
            match.correct_user_ids = $in:[Meteor.userId()]
        if view_incorrect
            match.incorrect_user_ids = $in:[Meteor.userId()]

        # if filter is 'shop'
        #     match.active = true
        if selected_question_tags.length > 0 then match.tags = $all: selected_question_tags
        match.model = 'question'
        Docs.find match,
            sort:_timestamp:1
            # limit: 5



    Meteor.methods
        lookup_question: (title_query)->
            console.log 'searching for question', title_query
            Docs.find({
                title: {$regex:"#{title_query}", $options: 'i'}
                model:'question'
                },{limit:10}).fetch()


        recalc_questions_stats: (user_id)->
            console.log 'calc', user_id
            user = Meteor.users.findOne user_id
            questions_stats = Docs.findOne
                model:'questions_stats'
                _author_id: user_id
            unless questions_stats
                new_stats = Docs.insert
                    model:'questions_stats'
                questions_stats = Docs.findOne new_stats
            # user_count = Meteor.users.find().count()
            # teacher_count = Meteor.users.find(roles:$in:['teacher']).count()
            # donor_count = Meteor.users.find(roles:$in:['donor']).count()
            total_answers =
                Docs.find(
                    model:'answer_session'
                    _author_id: user_id
                )
            correct_answers_amount =
                Docs.find(
                    model:'answer_session'
                    _author_id: user_id
                    is_correct_answer: true
                ).count()
            incorrect_answers_amount =
                Docs.find(
                    model:'answer_session'
                    _author_id: user_id
                    is_correct_answer: false
                ).count()

            total_answers_amount = total_answers.count()
            # correct_answers_amount = 0
            # incorrect_answers_amount = 0
            # for answer in answer_sessions.fetch()
            #     correct_answers_amount += answer.correct_count
            #     incorrect_answers_amount += answer.incorrect_count
            #     answered_card_amount += answer.answered_count
            total_correct_percent_amount = 0
            for session in total_answers.fetch()
                total_correct_percent_amount += (session.correct_percent/100)
                # console.log 'correct percent', session.correct_percent
            # console.log 'total percent', total_correct_percent_amount
            # average_correct_percent_amount = (total_correct_percent_amount/questions_session_count)*100
            # console.log 'average percent', average_correct_percent_amount

            authored_question_amount =
                Docs.find(
                    model:'question'
                    _author_id: user_id
                ).count()


            Docs.update questions_stats._id,
                $set:
                    total_answers_amount:total_answers_amount
                    correct_answers_amount:correct_answers_amount
                    incorrect_answers_amount:incorrect_answers_amount
                    # total_answer_correct_percent:average_correct_percent_amount
                    authored_question_amount:authored_question_amount
                    # incorrect sessions
                    # cards praciced
                    # session # ranking
                    # average session correct %
                    # cards authored
                    # correct tag cloud
                    # incorrect tag cloud
                # .item #{correct_answers_amount} correct question amount
                # .item #{incorrect_answers_amount} incorrect question amount
                # .item #{total_answers_amount} answers
                # .item #{answer_count_ranking} session # ranking
                # .item #{total_answer_correct_percent}% total answer correct percent
                # .item #{questions_authored} questions authored
                # .item #{question_session_count} correct tag cloud
                # .item #{question_session_count} incorrect tag cloud



        calc_question_stats: (question_id)->
            question = Docs.findOne question_id
            answer_cursor = Docs.find(
                model:'answer_session'
                question_id:question_id
            )
            answer_count = answer_cursor.count()
            if question.question_type is 'multiple_choice'
                choice_cursor = Docs.find(
                    model:'choice'
                    question_id:question_id
                )
                answer_selections_array = []
                for choice in choice_cursor.fetch()
                    choice_answer_selections =  Docs.find(
                        model:'answer_session'
                        question_id:question_id
                        choice_selection_id: choice._id
                    )
                    choice_selection_count = choice_answer_selections.count()
                    console.log 'choice selection count', choice_selection_count
                    choice_percent = (choice_selection_count/answer_count).toFixed(2)*100
                    choice_calc_object = {
                        choice_id:choice._id
                        choice_content:choice.content
                        choice_selection_count:choice_selection_count
                        choice_percent:choice_percent
                    }
                    answer_selections_array.push choice_calc_object


                Docs.update question._id,
                    $set:
                        answer_selections: answer_selections_array
                        answer_count:answer_cursor.count()
                        choice_count:choice_cursor.count()
                if question.has_correct_answer
                    incorrect_count = 0
                    correct_count = 0
                    for answer_session in answer_cursor.fetch()
                        if answer_session.is_correct_answer
                            correct_count++
                        else
                            incorrect_count++
                    Docs.update question._id,
                        $set:
                            incorrect_count: incorrect_count
                            correct_count: correct_count

            if question.question_type is 'number'
                if question.single_answer
                    incorrect_count = 0
                    correct_count = 0
                    for answer_session in answer_cursor.fetch()
                        if answer_session.is_correct_answer
                            correct_count++
                        else
                            incorrect_count++
                    Docs.update question._id,
                        $set:
                            answer_count:answer_cursor.count()
                            incorrect_count: incorrect_count
                            correct_count: correct_count
            if question.question_type is 'text'
                console.log 'calculating text'
                if question.single_answer
                    incorrect_count = 0
                    correct_count = 0
                    for answer_session in answer_cursor.fetch()
                        if answer_session.is_correct_answer
                            correct_count++
                        else
                            incorrect_count++
                    Docs.update question._id,
                        $set:
                            answer_count:answer_cursor.count()
                            incorrect_count: incorrect_count
                            correct_count: correct_count
