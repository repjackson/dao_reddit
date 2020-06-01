if Meteor.isClient
    Router.route '/user/:username/posts', (->
        @layout 'profile'
        @render 'user_posts'
        ), name:'user_posts'

    Template.user_posts.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'post'


    Template.user_posts.events
        'click .add_posts': ->
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
            #     $inc: posts: amount


        'click .initial_withdrawal': ->
            withdrawal_amount = parseInt $('.withdrawal_amount').val()
            if confirm "initiate withdrawal for #{withdrawal_amount}?"
                Docs.insert
                    model:'withdrawal'
                    amount: withdrawal_amount
                    status: 'started'
                    complete: false
                Meteor.users.update Meteor.userId(),
                    $inc: posts: -withdrawal_amount

        'click .cancel_withdrawal': ->
            if confirm "cancel withdrawal for #{@amount}?"
                Docs.remove @_id
                Meteor.users.update Meteor.userId(),
                    $inc: posts: @amount



    Template.user_posts.helpers
        posts: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'post'
                _author_id: user._id

        owner_earnings: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'reservation'
                _author_id:user.user_id
                complete:true
        payments: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'payment'
                _author_id: user._id
            }, sort:_timestamp:-1
        deposits: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'deposit'
                _author_id: user._id
            }, sort:_timestamp:-1
        withdrawals: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'withdrawal'
                _author_id: user._id
            }, sort:_timestamp:-1
        received_reservations: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'reservation'
                _author_id: user._id
            }, sort:_timestamp:-1
        purchased_reservations: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'reservation'
                _author_id: user._id
            }, sort:_timestamp:-1
