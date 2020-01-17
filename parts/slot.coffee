if Meteor.isClient
    # Router.route '/slots', (->
    #     @layout 'layout'
    #     @render 'slots'
    #     ), name:'slots'

    Template.slot_view.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'slot'
        @autorun => Meteor.subscribe 'model_docs', 'bid'
        # @autorun => Meteor.subscribe 'model_docs', 'slots_stats'
        @autorun => Meteor.subscribe 'model_docs', 'slots_stats'
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id


    Template.slot_view.events
        'click .bid': ->
            new_bid_id =
                Docs.insert
                    model:'bid'
                    tutor_session_id: Router.current().params.doc_id
            Session.set('editing_bid', new_bid_id)


        'click .buy_it_now': ->
            if confirm "buy it now for #{@buy_it_now_price}"
                Docs.update @_id,
                    $set: closed: true
                Meteor.users.update @_author_id,
                    $inc: credit: @buy_it_now_price
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -@buy_it_now_price
                Docs.insert
                    model:'log_event'
                    parent_id: Router.current().params.doc_id
                    text: "#{Meteor.user().username} bought the slot for #{@buy_it_now_price}."


    Template.bid_small.events
        'click .cancel_bid': ->
            if confirm 'cancel bid?  this will refund amount to your balance'
                # console.log @
                Meteor.users.update Meteor.userId(),
                    $inc: credit: @bid_amount
                Docs.remove @_id


        'click .accept_bid': ->
            if confirm "accept bid by #{@_author_username}?"
                # console.log @
                Docs.update @_id,
                    $set: accepted: true
                Docs.update Router.current().params.doc_id,
                    $set: closed: true

        'click .unaccept_bid': ->
            if confirm "unaccept bid by #{@_author_username}?"
                # console.log @
                Docs.update @_id,
                    $set: accepted: false
                Docs.update Router.current().params.doc_id,
                    $set: closed: false

        'click .submit_bid': ->
            if confirm "submit bid of #{@bid_amount}?"
                # console.log @
                Docs.update @_id,
                    $set: submitted: true
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -@amount
                Docs.insert
                    model:'log_event'
                    parent_id: Router.current().params.doc_id
                    text: "#{Meteor.user().username} submitted bid for #{@bid_amount}."


    Template.bid_small.helpers
        is_auction_owner: ->
            auction = Docs.findOne Router.current().params.doc_id
            Meteor.userId() and auction._author_id is Meteor.userId()




    Template.slot_view.helpers
        log_events: ->
            Docs.find
                model:'log_event'
        your_bid: ->
            Docs.findOne
                model:'bid'
                _author_id: Meteor.userId()
        editing_bid_doc: ->
            Docs.findOne
                model:'bid'
                _id: Session.get('editing_bid')
        editing_bid: ->
            Session.equals 'editing_bid', @_id
        bids: ->
            Docs.find
                model:'bid'

        top_bid: ->
            Docs.findOne {
                model:'bid'
            }, sort: bid_amount:-1
