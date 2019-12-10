if Meteor.isClient
    Router.route '/learn', (->
        @layout 'layout'
        @render 'learn'
        ), name:'learn'
    Router.route '/learn/math', (->
        @layout 'layout'
        @render 'learn_math'
        ), name:'learn_math'
    Router.route '/learn/science', (->
        @layout 'layout'
        @render 'learn_science'
        ), name:'learn_science'
    Router.route '/learn/reading', (->
        @layout 'layout'
        @render 'learn_reading'
        ), name:'learn_reading'
    Router.route '/learn/english', (->
        @layout 'layout'
        @render 'learn_english'
        ), name:'learn_english'






    Template.learn.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'course'
    Template.learn.helpers
        questions: ->
            Docs.find
                model:'question'
    Template.learn.events
        'click .add_course': ->
            new_course_id = Docs.insert
                model:'course'
            Router.go "/course/#{new_course_id}/edit"
