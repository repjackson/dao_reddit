if Meteor.isClient
    Router.route '/bounties', (->
        @layout 'layout'
        @render 'bounties'
        ), name:'bounties'
    Router.route '/bounty/:doc_id/edit', (->
        @layout 'layout'
        @render 'bounty_edit'
        ), name:'bounty_edit'
    Router.route '/bounty/:doc_id/view', (->
        @layout 'layout'
        @render 'bounty_view'
        ), name:'bounty_view'



    Template.bounty_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.bounty_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.bounty_edit.events
        'click .add_bounty_item': ->
            new_mi_id = Docs.insert
                model:'bounty_item'
            Router.go "/bounty/#{_id}/edit"


    Template.bounty_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.bounty_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.bounty_view.events
        'click .add_question': ->
            new_question_id = Docs.insert
                model:'question'
                bounty_id:Router.current().params.doc_id
            Router.go "/question/#{new_question_id}/edit"



    Template.bounties.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'bounty'
    Template.bounties.helpers
        bounties: ->
            Docs.find
                model:'bounty'




    Template.bounties_view_template.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'bounty'
    Template.bounties_view_template.helpers
        bounties: ->
            Docs.find
                model:'bounty'
    Template.bounties_view_template.events
        'click .take_bounty': ->
            console.log @



    Template.question_widget.onRendered ->
        # console.log @data
        @autorun => Meteor.subscribe 'doc', @data.question_id
    Template.question_widget.helpers
        parent_question: ->
            console.log @
            Docs.findOne
                model:'question'
                _id: @question_id
    Template.question_widget.events
        'click .take_bounty': ->
            console.log @




    Template.bounties.events
        'click .add_bounty': ->
            new_bounty_id = Docs.insert
                model:'bounty'
            Router.go "/bounty/#{new_bounty_id}/edit"



    Template.bounty_stats.events
        'click .refresh_bounty_stats': ->
            Meteor.call 'refresh_bounty_stats', @_id




if Meteor.isServer
    Meteor.publish 'bounties', (product_id)->
        Docs.find
            model:'bounty'
            product_id:product_id

    Meteor.methods
        refresh_bounty_stats: (bounty_id)->
            bounty = Docs.findOne bounty_id
            # console.log bounty
            reservations = Docs.find({model:'reservation', bounty_id:bounty_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_bounty_hours = 0
            average_bounty_duration = 0

            # shorbounty_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_bounty_hours += parseFloat(res.hour_duration)

            average_bounty_cost = total_earnings/reservation_count
            average_bounty_duration = total_bounty_hours/reservation_count

            Docs.update bounty_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_bounty_hours: total_bounty_hours.toFixed(0)
                    average_bounty_cost: average_bounty_cost.toFixed(0)
                    average_bounty_duration: average_bounty_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header bounty ranking #reservations
            # .ui.small.header bounty ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg bounty time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
