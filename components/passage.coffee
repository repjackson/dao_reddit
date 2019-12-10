if Meteor.isClient
    Router.route '/passages', (->
        @layout 'layout'
        @render 'passages'
        ), name:'passages'
    Router.route '/passage/:doc_id/edit', (->
        @layout 'layout'
        @render 'passage_edit'
        ), name:'passage_edit'
    Router.route '/passage/:doc_id/view', (->
        @layout 'layout'
        @render 'passage_view'
        ), name:'passage_view'


    Template.passage_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.passage_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'passage_question'
        @autorun => Meteor.subscribe 'model_docs', 'passage_question_choice'
    Template.passage_edit.events
        'click .select_question': ->
            Session.set 'current_question_id', @_id
        'click .split_passage': ->
            Meteor.call 'split_passage', Router.current().params.doc_id
        'click .add_question': ->
            Docs.insert
                model:'passage_question'
                passage_id: Router.current().params.doc_id
        'click .add_choices': ->
            Docs.insert
                model:'passage_question_choice'
                question_id: Session.get('current_question_id')
                passage_id: Router.current().params.doc_id

    Template.passage_edit.helpers
        question_button_class: ->
            if Session.equals('current_question_id', @_id) then 'blue' else ''
        passage_questions: ->
            Docs.find
                model:'passage_question'
                passage_id: Router.current().params.doc_id
        current_question: ->
            Docs.findOne Session.get('current_question_id')
        question_choices: ->
            Docs.find {
                model:'passage_question_choice'
                question_id: Session.get('current_question_id')
                passage_id: Router.current().params.doc_id
            }, sort: number: 1



    Template.passages.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'passage'
    Template.passages.helpers
        passages: ->
            Docs.find
                model:'passage'
    Template.passages.events
        'click .add_passage': ->
            new_passage_id = Docs.insert
                model:'passage'
            Router.go "/passage/#{new_passage_id}/edit"




    Template.passage_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'passage_question'
        @autorun => Meteor.subscribe 'model_docs', 'passage_question_choice'
        @autorun => Meteor.subscribe 'model_docs', 'test_session'
        @autorun => Meteor.subscribe 'model_docs', 'passage'
    Template.passage_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.passage_view.helpers
        passages: ->
            Docs.find
                model:'passage'
        passage_sessions: ->
            Docs.find
                model:'test_session'
                passage_id: Router.current().params.doc_id
        passage_questions: ->
            Docs.find
                model:'passage_question'
                passage_id: Router.current().params.doc_id
        current_question: ->
            Docs.findOne Session.get('current_question_id')
        question_choices: ->
            Docs.find {
                model:'passage_question_choice'
                question_id: Session.get('current_question_id')
                passage_id: Router.current().params.doc_id
            }, sort: number: 1
    Template.passage_view.events
        'click .take_test': ->
            new_session_id = Docs.insert
                model:'test_session'
                passage_id: Router.current().params.doc_id
                answers: []
            Router.go "/session/#{new_session_id}/edit"

        'click .calc_passage_total': ->
            Meteor.call 'calc_passage_total', @_id





if Meteor.isServer
    Meteor.publish 'passage_reservations_by_id', (passage_id)->
        Docs.find
            model:'reservation'
            passage_id: passage_id

    Meteor.publish 'passages', (passage_id)->
        Docs.find
            model:'passage'
            passage_id:passage_id


    Meteor.methods
        refresh_passage_stats: (passage_id)->
            passage = Docs.findOne passage_id
            # console.log passage
            reservations = Docs.find({model:'reservation', passage_id:passage_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_passage_hours = 0
            average_passage_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_passage_hours += parseFloat(res.hour_duration)

            average_passage_cost = total_earnings/reservation_count
            average_passage_duration = total_passage_hours/reservation_count

            Docs.update passage_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_passage_hours: total_passage_hours.toFixed(0)
                    average_passage_cost: average_passage_cost.toFixed(0)
                    average_passage_duration: average_passage_duration.toFixed(0)




        split_passage: (doc_id)->
            # characters 56
            doc = Docs.findOne doc_id
            str = doc.passage_text
            words = doc.passage_text.split ' '
            passage_text_array = (str.match(/.{1,56}/g));

            lines = []
            line_number = 0
            this_line = ''
            for word in words
                if this_line.length < 50
                    this_line += word+' '
                else
                    lines[line_number] = this_line
                    console.log this_line, this_line.length
                    line_number++
                    this_line = ''
            console.log 'lines', lines

            Docs.update doc_id,
                $set: passage_text_array: lines
