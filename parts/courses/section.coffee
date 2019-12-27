if Meteor.isClient
    Router.route '/section_sections', (->
        @layout 'layout'
        @render 'section_sections'
        ), name:'section_sections'
    Router.route '/section/:doc_id/edit', (->
        @layout 'layout'
        @render 'section_edit'
        ), name:'section_edit'
    Router.route '/section/:doc_id/view', (->
        @layout 'layout'
        @render 'section_view'
        ), name:'section_view'


    Template.section_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.section_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'section_question'
        @autorun => Meteor.subscribe 'model_docs', 'section_question_choice'
        @autorun => Meteor.subscribe 'model_docs', 'part'
    Template.section_edit.events
        'click .select_question': ->
            Session.set 'current_question_id', @_id
        'click .add_question': ->
            Docs.insert
                model:'section_question'
                section_id: Router.current().params.doc_id
        'click .add_choices': ->
            Docs.insert
                model:'section_question_choice'
                question_id: Session.get('current_question_id')
                section_id: Router.current().params.doc_id

    Template.add_part.events
        'click .add_part': ->
            console.log @
            part_count =
                Docs.find({
                    model:'part'
                    section_id: Router.current().params.doc_id
                    }).count()
            Docs.insert
                model:'part'
                number:part_count++
                part_type:@type
                section_id: Router.current().params.doc_id



    Template.section_edit.helpers
        question_button_class: ->
            if Session.equals('current_question_id', @_id) then 'blue' else ''

        section_parts: ->
            Docs.find {
                model:'part'
                section_id: Router.current().params.doc_id
            }, sort: number: 1
        section_questions: ->
            Docs.find
                model:'section_question'
                section_id: Router.current().params.doc_id
        current_question: ->
            Docs.findOne Session.get('current_question_id')
        question_choices: ->
            Docs.find {
                model:'section_question_choice'
                question_id: Session.get('current_question_id')
                section_id: Router.current().params.doc_id
            }, sort: number: 1





    Template.section_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'section'
        @autorun => Meteor.subscribe 'sections_from_module_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'part'
    Template.section_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->

    Template.section_view.helpers
        part_template: ->
            console.log @
            "#{@part_type}_view"
        part_data: ->
            {
                key:'text'
                direct:true
            }
        can_proceed: ->
            true
        section_sessions: ->
            Docs.find
                model:'test_session'
                section_id: Router.current().params.doc_id
        section_sections: ->
            Docs.find
                model:'section_section'
                section_id: Router.current().params.doc_id
        students: ->
            section = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: section.student_ids

    Template.section_view.events
        'click .goto_module': (e,t)->
            section = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.grid').transition('fade up', 500)
            Meteor.setTimeout ->
                Router.go "/module/#{section.module_id}/view"
            , 500

        'click .take_test': ->
            new_session_id = Docs.insert
                model:'test_session'
                section_id: Router.current().params.doc_id
                answers: []
            Router.go "/session/#{new_session_id}/edit"
        'click .calc_section_total': ->
            Meteor.call 'calc_section_total', @_id






if Meteor.isServer
    Meteor.publish 'section_reservations_by_id', (section_id)->
        Docs.find
            model:'reservation'
            section_id: section_id

    Meteor.publish 'sections_from_module_id', (module_id)->
        module = Docs.findOne module_id
        Docs.find
            model:'section'
            _id: module_id

    Meteor.publish 'section_sections', (section_id)->
        Docs.find
            model:'section'
            section_id:section_id


    Meteor.methods
        refresh_section_stats: (section_id)->
            section = Docs.findOne section_id
            # console.log section
            reservations = Docs.find({model:'reservation', section_id:section_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_section_hours = 0
            average_section_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_section_hours += parseFloat(res.hour_duration)

            average_section_cost = total_earnings/reservation_count
            average_section_duration = total_section_hours/reservation_count

            Docs.update section_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_section_hours: total_section_hours.toFixed(0)
                    average_section_cost: average_section_cost.toFixed(0)
                    average_section_duration: average_section_duration.toFixed(0)
