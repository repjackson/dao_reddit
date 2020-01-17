if Meteor.isClient
    Router.route '/finance', (->
        @layout 'layout'
        @render 'finance'
        ), name:'finance'


    Template.finance.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'finance_stats'
        @autorun => Meteor.subscribe 'model_docs', 'bid'

    Template.finance.helpers
        top_bid: ->
            finance_stats_doc =
                Docs.findOne
                    model:'finance_stats'
            Docs.findOne
                _id:finance_stats_doc.highest_bid_id


        finance_stats: ->
            Docs.findOne
                model:'finance_stats'

    Template.finance.events
        'click .give_credits': ->
            amount = prompt('how much')
            if amount
                Meteor.call 'give_credits', amount, Meteor.userId()

        'click .refresh_finance_stats': ->
            Meteor.call 'refresh_finance_stats', ->



if Meteor.isServer
    Meteor.methods
        give_credits: (amount, giver_id, receiver_id)->
            console.log amount
            console.log giver_id
            console.log receiver_id



        refresh_finance_stats: ->
            site_slot_cursor =
                Docs.find(
                    model:'slot'
                )
            site_slot_count = site_slot_cursor.count()

            site_user_cursor =
                Meteor.users.find(
                )
            site_user_count = site_user_cursor.count()

            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            console.log past_24_hours
            all_slots_count =
                Docs.find({
                    model:'slot'
                    }).count()
            all_bids_count =
                Docs.find({
                    model:'bid'
                    }).count()
            day_slots_count =
                Docs.find({
                    model:'slot'
                    _timestamp:
                        $gt:past_24_hours
                    }).count()
            week_slots_count =
                Docs.find({
                    model:'slot'
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_slots_count =
                Docs.find({
                    model:'slot'
                    _timestamp:
                        $gt:past_month
                    }).count()


            highest_bid =
                Docs.findOne({
                    model:'bid'
                }, sort:bid_amount:-1)

            console.log highest_bid



            finance_session_cursor = Docs.find
                model:'act_slot_session'
            finance_session_count = finance_session_cursor.count()
            finance_total_correct_percent = 0
            for session in finance_session_cursor.fetch()
                if session.correct_percent
                    finance_total_correct_percent += parseInt(session.correct_percent)

            finance_stats_doc =
                Docs.findOne
                    model:'finance_stats'
            unless finance_stats_doc
                gs_id = Docs.insert
                    model:'finance_stats'
                finance_stats_doc = Docs.findOne gs_id

            console.log finance_stats_doc

            finance_average_correct_percent = finance_total_correct_percent/finance_session_count
            Docs.update finance_stats_doc._id,
                $set:
                    finance_average_correct_percent:finance_average_correct_percent.toFixed()
                    slot_count: all_slots_count
                    bid_count: all_bids_count
                    highest_bid_id: highest_bid._id
                    slot_amount:site_slot_count
                    user_count:site_user_count
                    day_slots_count:day_slots_count
                    week_slots_count:week_slots_count
                    month_slots_count:month_slots_count
