if Meteor.isClient
    Router.route '/module_modules', (->
        @layout 'layout'
        @render 'module_modules'
        ), name:'module_modules'
    Router.route '/module/:doc_id/edit', (->
        @layout 'layout'
        @render 'module_edit'
        ), name:'module_edit'
    Router.route '/module/:doc_id/view', (->
        @layout 'layout'
        @render 'module_view'
        ), name:'module_view'


    Template.module_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.module_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'module_question'
        @autorun => Meteor.subscribe 'model_docs', 'module_question_choice'
    Template.module_edit.events
        'click .select_question': ->
            Session.set 'current_question_id', @_id
        'click .add_question': ->
            Docs.insert
                model:'module_question'
                module_id: Router.current().params.doc_id
        'click .add_choices': ->
            Docs.insert
                model:'module_question_choice'
                question_id: Session.get('current_question_id')
                module_id: Router.current().params.doc_id
    Template.module_edit.helpers
        question_button_class: ->
            if Session.equals('current_question_id', @_id) then 'blue' else ''
        module_questions: ->
            Docs.find
                model:'module_question'
                module_id: Router.current().params.doc_id
        current_question: ->
            Docs.findOne Session.get('current_question_id')
        question_choices: ->
            Docs.find {
                model:'module_question_choice'
                question_id: Session.get('current_question_id')
                module_id: Router.current().params.doc_id
            }, sort: number: 1



    Template.module_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'module_question'
        @autorun => Meteor.subscribe 'model_docs', 'section'
        @autorun => Meteor.subscribe 'course_from_module_id', Router.current().params.doc_id
    Template.module_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.module_view.helpers
        module_modules: ->
            Docs.find
                model:'module'
        module_sessions: ->
            Docs.find
                model:'test_session'
                module_id: Router.current().params.doc_id
        module_sections: ->
            Docs.find
                model:'section'
                module_id: Router.current().params.doc_id
        completed_students: ->
            module = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: module.student_ids

    Template.module_view.events
        'click .add_section': ->
            new_section_id = Docs.insert
                model:'section'
                module_id: Router.current().params.doc_id
                answers: []
            Router.go "/section/#{new_section_id}/edit"

        'click .calc_module_stats': ->
            Meteor.call 'calc_module_total', @_id

        'click .goto_course': (e,t)->
            module = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.grid').transition('fade up', 500)

            Meteor.setTimeout ->
                Router.go "/course/#{module.course_id}/view"
            , 500



if Meteor.isServer
    Meteor.publish 'course_from_module_id', (module_id)->
        module = Docs.findOne module_id
        Docs.find
            model:'course'
            _id: module.course_id

    Meteor.publish 'module_modules', (module_id)->
        Docs.find
            model:'module'
            module_id:module_id


    Meteor.methods
        refresh_module_stats: (module_id)->
            module = Docs.findOne module_id
            # console.log module
            reservations = Docs.find({model:'reservation', module_id:module_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_module_hours = 0
            average_module_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_module_hours += parseFloat(res.hour_duration)

            average_module_cost = total_earnings/reservation_count
            average_module_duration = total_module_hours/reservation_count

            Docs.update module_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_module_hours: total_module_hours.toFixed(0)
                    average_module_cost: average_module_cost.toFixed(0)
                    average_module_duration: average_module_duration.toFixed(0)
