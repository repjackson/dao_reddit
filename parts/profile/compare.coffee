if Meteor.isClient
    Router.route '/user/:username/comparison', (->
        @layout 'profile'
        @render 'profile_comparison'
        ), name:'profile_comparison'


    Template.profile_comparison.onCreated ->
        @autorun -> Meteor.subscribe('user_clouds', Router.current().params.username)
        @autorun -> Meteor.subscribe('overlap', selected_theme_tags.array(), Router.current().params.username, 'post')
        # @autorun -> Meteor.subscribe('overlap', selected_theme_tags.array(), Router.current().params.username, 'checkin')

    Template.profile_comparison.helpers
        user: -> Meteor.users.findOne username:Router.current().params.username

        user_authored_list: ->
            user = Meteor.users.findOne username:Router.current().params.username
            user.authored_list


        docs: ->
            Docs.find()


    Template.profile_comparison.events
        'click #calculate_user_clouds': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'generate_post_cloud', current_user._id
