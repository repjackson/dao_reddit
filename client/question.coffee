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



    Template.questions.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe('question_facet_docs',
            selected_question_tags.array()
        )
        Session.setDefault('view_mode', 'items')
    Template.questions.helpers
        questions: ->
            Docs.find
                model:'question'
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


    Template.question_cloud.onCreated ->
        @autorun -> Meteor.subscribe('question_tags',
            selected_question_tags.array()
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


    Template.question_small.onCreated ->
        # console.log @
        # @autorun => Meteor.subscribe('answer_sessions_from_question_id', @data._id)
        # @autorun => Meteor.subscribe('my_answer_from_question_id', @data._id)

    Template.question_small.events

    Template.question_small.helpers
        question: -> @question
        my_answer: ->
            Docs.findOne
                model:'answer_session'
                question_id: @_id
                _author_id: Meteor.userId()




    Template.question_edit.onRendered ->
    Template.question_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_docs', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'dep'




    Template.question_view.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'bounty'
        # @autorun => Meteor.subscribe 'model_docs', 'choice'
        @autorun => Meteor.subscribe 'answer_sessions_from_question_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.question_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.question_view.helpers
        question: -> @question
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

        my_answer: ->
            Docs.findOne
                model:'answer_session'
                question_id: Router.current().params.doc_id
        answer_sessions: ->
            Docs.find
                model:'answer_session'
                question_id: Router.current().params.doc_id

    Template.question_view.events
        'click .new_answer_session': ->
            # console.log @
            new_answer_session_id = Docs.insert
                model:'answer_session'
                start_timestamp: Date.now()
                question_id: Router.current().params.doc_id
            Router.go "/answer_session/#{new_answer_session_id}/edit"

        'click .calc_stats': ->
            Meteor.call 'calc_question_stats', Router.current().params.doc_id





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
        )->
        self = @
        match = {}

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
        )->

        self = @
        match = {}
        if selected_question_tags.length > 0 then match.tags = $all: selected_question_tags
        match.model = 'question'
        Docs.find match,
            sort:_timestamp:1
            # limit: 5



    Meteor.methods
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
            total_answers =
                Docs.find(
                    model:'answer_session'
                    _author_id: user_id
                )
            total_answers_amount = total_answers.count()
            total_correct_percent_amount = 0
            for session in total_answers.fetch()
                total_correct_percent_amount += (session.correct_percent/100)

            authored_question_amount =
                Docs.find(
                    model:'question'
                    _author_id: user_id
                ).count()


            Docs.update questions_stats._id,
                $set:
                    total_answers_amount:total_answers_amount
                    # total_answer_correct_percent:average_correct_percent_amount
                    authored_question_amount:authored_question_amount



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
