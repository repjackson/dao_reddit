if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'


    Template.home.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'site_section'
        @autorun => Meteor.subscribe 'model_docs', 'course_question_choice'
    Template.home.events
    Template.home.helpers
        site_sections: ->
            Docs.find
                model:'site_section'
