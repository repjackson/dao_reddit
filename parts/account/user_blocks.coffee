if Meteor.isClient
    # Router.route '/user/:username/orders', (->
    #     @layout 'profile_layout'
    #     @render 'user_following'
    #     ), name:'user_following'



    Template.user_following.onCreated ->
        @autorun => Meteor.subscribe 'all_users'
    Template.user_following.events
        'click .follow': ->
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update user._id,
                $addToSet: followed_by_ids: Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $addToSet: following_ids:user._id
        'click .unfollow': ->
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update user._id,
                $pull: followed_by_ids: Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $pull: following_ids:user._id
    Template.user_following.helpers
        follow_button_class: ->
            user = Meteor.users.findOne username:Router.current().params.username
            following = Meteor.userId() and Meteor.userId() in user.following_ids
            if following then 'grey' else 'basic'
        following: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.userId() and Meteor.userId() in user.following_ids
        followers: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                _id: $in: user.following_ids
