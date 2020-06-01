if Meteor.isClient
    Router.route '/user/:username/friends', (->
        @layout 'profile'
        @render 'user_friends'
        ), name:'user_friends'

    Template.user_friends.helpers
        friends: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                _id: $in: user.friend_ids
        payments: ->

    Template.user_friends.events
        'click .add_credit': ->
            amount = parseInt $('.deposit_amount').val()
            amount_100x = parseInt amount*100
            calculated_amount = amount_100x*1.02+20
            Template.instance().checkout.open
                name: 'dao deposit'
                # email:Meteor.user().emails[0].address
                description: 'dao'
                amount: calculated_amount
            # Docs.insert
            #     model:'deposit'
            #     amount: amount
            # Meteor.users.update Meteor.userId(),
            #     $inc: credit: amount


if Meteor.isServer
    Meteor.publish 'user_friends', (username)->
        user = Meteor.users.findOne username:Router.current().params.username
        Meteor.users.find
            _id: $in: user.friend_ids
