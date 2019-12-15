if Meteor.isClient
    Router.route '/answer_sessions', (->
        @layout 'layout'
        @render 'answer_sessions'
        ), name:'answer_sessions'
    Router.route '/answer_session/:doc_id/edit', (->
        @layout 'layout'
        @render 'answer_session_edit'
        ), name:'answer_session_edit'
    Router.route '/answer_session/:doc_id/view', (->
        @layout 'layout'
        @render 'answer_session_view'
        ), name:'answer_session_view'



    Template.answer_session_edit.onRendered ->

    Template.answer_session_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_from_answer_session', Router.current().params.doc_id
    Template.answer_session_edit.onRendered ->
    Template.answer_session_edit.events
        'click .cancel_answer_session': ->
            if confirm 'cancel answer?'
                Docs.remove @_id
                Router.go "/question/#{@question_id}/view"
        'click .submit_answer': ->
            # if confirm 'submit?'
            Docs.update Router.current().params.doc_id,
                $set: submit_timestamp: Date.now()
            Session.set 'loading', true
            Meteor.call 'calculate_answer', Router.current().params.doc_id, ->
                Session.set 'loading', false
            # (href="/answer_session/#{_id}/view" title='save')
        'keyup .new_tag': (e,t)->
            if e.which is 13
                tag = t.$('.new_tag').val().trim().toLowerCase()
                question = Docs.findOne Router.current().params.doc_id
                Docs.update question._id,
                    $addToSet:tags:tag
                t.$('.new_tag').val('')

        'click .remove_tag': (e,t)->
            tag = @valueOf()
            answer_session = Docs.findOne Router.current().params.doc_id

            Docs.update answer_session._id,
                $pull: tags: element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)




    Template.answer_session_edit.helpers
        matching_tags_amount: ->
            # console.log @
            answer_session = Docs.findOne Router.current().params.doc_id
            question = Docs.findOne answer_session.question_id
            union_set = _.intersection answer_session.tags, question.required_answer_tags
            # console.log union_set
            union_set.length
        matching_tags_percent: ->
            # console.log @
            answer_session = Docs.findOne Router.current().params.doc_id
            question = Docs.findOne answer_session.question_id
            union_set = _.intersection answer_session.tags, question.required_answer_tags
            # console.log union_set
            result = (union_set.length / question.required_answer_tags.length).toFixed(2)*100
        choice_select_class: ->
            classes = ''
            answer_session = Docs.findOne Router.current().params.doc_id
            if answer_session.complete
                classes+='disabled'
            if answer_session.choice_selection_id is @_id
                classes+='active'
            classes
        has_answered: ->
            # console.log @
            # console.log Template.parentData()
            answer_session = Docs.findOne Router.current().params.doc_id
            question = Docs.findOne
                model:'question'
                _id:answer_session.question_id
            @answer

    Template.answer_session_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_from_answer_session', Router.current().params.doc_id
    Template.answer_session_view.events
    Template.answer_session_view.helpers
        parent_question: ->
            answer_session = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                model:'question'
                _id:answer_session.question_id


    Template.answer_sessions.onRendered ->
        # @autorun => Meteor.subscribe 'model_docs', 'answer_session'
    Template.answer_sessions.helpers
        answer_sessions: ->
            Docs.find
                model:'answer_session'
    Template.answer_sessions.events
        'click .add_answer_session': ->
            new_answer_session_id = Docs.insert
                model:'answer_session'
            Router.go "/answer_session/#{new_answer_session_id}/edit"




if Meteor.isServer
    Meteor.publish 'answer_sessions', (product_id)->
        Docs.find
            model:'answer_session'
            product_id:product_id

    Meteor.publish 'question_from_answer_session', (answer_session_id)->
        answer_session = Docs.findOne answer_session_id
        Docs.find
            model:'question'
            _id:answer_session.question_id



    Meteor.methods
        calculate_answer: (answer_session_id)->
            console.log answer_session_id
            answer_session = Docs.findOne answer_session_id
            question = Docs.findOne answer_session.question_id

            console.log 'question', question
            switch question.question_type
                when 'text'
                    if question.has_correct_answer
                        console.log 'required answer', question.required_answer
                        console.log 'given answer', answer_session.text_answer
                        if answer_session.text_answer is question.required_answer
                            console.log 'true'
                            Docs.update answer_session_id,
                                $set:
                                    is_correct_answer: true
                                    complete: true
                            Docs.update question._id,
                                $addToSet:
                                    correct_user_ids: Meteor.userId()
                                    answered_user_ids: Meteor.userId()
                        else
                            Docs.update answer_session_id,
                                $set:
                                    is_correct_answer: false
                                    complete: true
                            Docs.update question._id,
                                $addToSet:
                                    incorrect_user_ids: Meteor.userId()
                                    answered_user_ids: Meteor.userId()
                    else
                        Docs.update answer_session_id,
                            $set:
                                complete: true
                        Docs.update question._id,
                            $addToSet:
                                answered_user_ids: Meteor.userId()
                when 'tagging'
                    Docs.update answer_session_id,
                        $set:
                            complete: true
                    Docs.update question._id,
                        $addToSet:
                            answered_user_ids: Meteor.userId()
