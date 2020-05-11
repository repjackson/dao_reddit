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

    Template.question_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'answer'
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.question_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'choice'
        @autorun => Meteor.subscribe 'model_docs', 'answer'

    Template.question_edit.events
        'click .add_choice': ->
            Docs.insert
                model:'choice'
                question_id:Router.current().params.doc_id
    Template.question_view.events
        'click .choose_choice': ->
            Docs.insert
                model:'answer'
                question_id:Router.current().params.doc_id
                choice_text:@text
                choice_id:@_id
        'click .refresh_question_stats': ->
            Meteor.call 'calc_question_stats', Router.current().params.doc_id


    Template.question_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:Router.current().params.doc_id


    Template.question_view.helpers
        choice_answer_count: ->
            Docs.find(
                model:'answer'
                choice_id:@_id
            ).count()
        choices: ->
            Docs.find
                model:'choice'
                question_id:Router.current().params.doc_id
        your_answer: ->
            Docs.findOne
                model:'answer'
                question_id:Router.current().params.doc_id
                _author_id:Meteor.userId()
        answers: ->
            Docs.find
                model:'answer'
                question_id:Router.current().params.doc_id



    Template.questions.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'question'
        @autorun => Meteor.subscribe 'all_users'

    Template.questions.helpers
        questions: ->
            Docs.find
                model:'question'
        users: ->
            Meteor.users.find({credit:$gt:1},
                sort:credit:-1)

    Template.questions.events
        'click .add_question': ->
            new_id =
                Docs.insert
                    model:'question'
            Router.go "/question/#{new_id}/edit"


if Meteor.isServer
    Meteor.methods
        refresh_question_stats: (question_id)->
            question = Docs.findOne question_id

            choices =
                Docs.find
                    model:'choice'
                    question_id:question_id

            answers =
                Docs.find
                    model:'answer'
                    question_id:question_id

            Docs.update question_id,
                $set:
                    total_doc_count:total_doc_count
                    total_item_count:total_item_count
                    total_selling_count:total_selling_count
