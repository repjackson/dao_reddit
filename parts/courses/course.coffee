if Meteor.isClient
    Router.route '/courses', (->
        @layout 'layout'
        @render 'courses'
        ), name:'courses'
    Router.route '/course/:doc_id/edit', (->
        @layout 'layout'
        @render 'course_edit'
        ), name:'course_edit'
    Router.route '/course/:doc_id/view', (->
        @layout 'layout'
        @render 'course_view'
        ), name:'course_view'


    Template.course_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.course_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'course_question'
        @autorun => Meteor.subscribe 'model_docs', 'course_question_choice'
    Template.course_edit.events
        'click .select_question': ->
            Session.set 'current_question_id', @_id
        'click .add_question': ->
            Docs.insert
                model:'course_question'
                course_id: Router.current().params.doc_id
        'click .add_choices': ->
            Docs.insert
                model:'course_question_choice'
                question_id: Session.get('current_question_id')
                course_id: Router.current().params.doc_id
    Template.course_edit.helpers
        question_button_class: ->
            if Session.equals('current_question_id', @_id) then 'blue' else ''
        course_questions: ->
            Docs.find
                model:'course_question'
                course_id: Router.current().params.doc_id
        current_question: ->
            Docs.findOne Session.get('current_question_id')
        question_choices: ->
            Docs.find {
                model:'course_question_choice'
                question_id: Session.get('current_question_id')
                course_id: Router.current().params.doc_id
            }, sort: number: 1



    Template.courses.onRendered ->
        @autorun -> Meteor.subscribe('course_facet_docs',
            selected_course_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )
    Template.courses.helpers
        courses: ->
            Docs.find
                model:'course'
    Template.courses.events
        'click .add_course': ->
            new_course_id = Docs.insert
                model:'course'
            Router.go "/course/#{new_course_id}/edit"




    Template.course_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'course_question'
        @autorun => Meteor.subscribe 'model_docs', 'module'
    Template.course_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.course_view.helpers
        courses: ->
            Docs.find
                model:'course'
        course_sessions: ->
            Docs.find
                model:'test_session'
                course_id: Router.current().params.doc_id
        modules: ->
            Docs.find
                model:'module'
                course_id: Router.current().params.doc_id
        students: ->
            course = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: course.student_ids
    Template.course_view.events
        'click .add_module': ->
            course_id = Router.current().params.doc_id
            new_module_id = Docs.insert
                model:'module'
                course_id: course_id
            Router.go "/module/#{new_module_id}/edit"

        'click .calc_course_total': ->
            Meteor.call 'calc_course_total', @_id


    Template.enroll_button.helpers
        enrolled: ->
            course = Docs.findOne Router.current().params.doc_id
            if course.student_ids and Meteor.userId() in course.student_ids
                true
            else
                false
    Template.enroll_button.events
        'click .enroll': ->
            if confirm 'enroll?'
                Docs.update Router.current().params.doc_id,
                    $addToSet:
                        student_ids: Meteor.userId()

        'click .unenroll': ->
            if confirm 'unenroll?'
                Docs.update Router.current().params.doc_id,
                    $pull:
                        student_ids: Meteor.userId()

    Template.course_cloud.onCreated ->
        @autorun -> Meteor.subscribe('course_tags',
            selected_course_tags.array()
            Session.get('selected_target_id')
            )
        # @autorun -> Meteor.subscribe('model_docs', 'target')
    Template.course_cloud.helpers
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: ->
            Docs.findOne Session.get('selected_target_id')
        all_course_tags: ->
            course_count = Docs.find(model:'course').count()
            if 0 < course_count < 3 then Course_tags.find { count: $lt: course_count } else Course_tags.find({},{limit:42})
        selected_course_tags: -> selected_course_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key
    Template.course_cloud.events
        'click .unselect_target': -> Session.set('selected_target_id',null)
        'click .select_target': -> Session.set('selected_target_id',@_id)
        'click .select_course_tag': -> selected_course_tags.push @name
        'click .unselect_course_tag': -> selected_course_tags.remove @valueOf()
        'click #clear_course_tags': -> selected_course_tags.clear()




if Meteor.isServer
    Meteor.publish 'course_tags', (selected_course_tags, selected_target_id)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd
        self = @
        match = {}

        if selected_target_id
            match.target_id = selected_target_id
        # selected_course_tags.push current_herd

        if selected_course_tags.length > 0 then match.tags = $all: selected_course_tags
        match.model = 'course'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_course_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'course_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'course_facet_docs', (selected_course_tags, selected_target_id)->
        # user = Meteor.users.findOne @userId
        console.log selected_course_tags
        # console.log filter
        self = @
        match = {}
        if selected_target_id
            match.target_id = selected_target_id


        # if filter is 'shop'
        #     match.active = true
        if selected_course_tags.length > 0 then match.tags = $all: selected_course_tags
        match.model = 'course'
        Docs.find match, sort:_timestamp:-1

    Meteor.publish 'course_reservations_by_id', (course_id)->
        Docs.find
            model:'reservation'
            course_id: course_id

    Meteor.publish 'courses', (course_id)->
        Docs.find
            model:'course'
            course_id:course_id


    Meteor.methods
        refresh_course_stats: (course_id)->
            course = Docs.findOne course_id
            # console.log course
            reservations = Docs.find({model:'reservation', course_id:course_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_course_hours = 0
            average_course_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_course_hours += parseFloat(res.hour_duration)

            average_course_cost = total_earnings/reservation_count
            average_course_duration = total_course_hours/reservation_count

            Docs.update course_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_course_hours: total_course_hours.toFixed(0)
                    average_course_cost: average_course_cost.toFixed(0)
                    average_course_duration: average_course_duration.toFixed(0)
