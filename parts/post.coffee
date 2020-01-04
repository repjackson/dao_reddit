if Meteor.isClient
    Router.route '/posts', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'
    Router.route '/post/:doc_id/view', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'

    Template.posts.onRendered ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'post', 42
    Template.posts.helpers
        posts: ->
            Docs.find
                model:'post'
        selected_post_doc: ->
            Docs.findOne Session.get('selected_post_id')


    Template.post_card.helpers
        post_card_class: ->
            if Session.equals('selected_post_id', @_id) then 'inverted blue' else ''

    Template.post_card.events
        'click .post_card': ->
            if Session.equals('selected_post_id',@_id)
                Session.set 'selected_post_id', null
            else
                Session.set 'selected_post_id', @_id

    Template.posts.events
        'click .add_post': ->
            new_post_id = Docs.insert
                model:'post'
            Router.go "/post/#{new_post_id}/edit"



    Template.selected_post.events
        'click .delete_post': ->
            if confirm 'delete post?'
                Docs.remove @_id
                Session.set('selected_post_id', null)
        'click .save_post': ->
            Session.set('editing_post', false)
        'click .edit_post': ->
            Session.set('editing_post', true)
    Template.selected_post.helpers
        editing_post: -> Session.get('editing_post')




    Template.post_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.events
        'click .add_post_item': ->
            new_mi_id = Docs.insert
                model:'post_item'
            Router.go "/post/#{_id}/edit"
    Template.post_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                post_id:@_id
    Template.post_edit.events


    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.post_view.helpers
        choices: ->
            Docs.find
                model:'choice'
                post_id:@_id
        can_accept: ->
            console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    post_id: Router.current().params.doc_id
            if my_answer_session
                console.log 'false'
                false
            else
                console.log 'true'
                true

    Template.post_view.events
        'click .purchase': ->
            console.log @





    Template.post_stats.events
        'click .refresh_post_stats': ->
            Meteor.call 'refresh_post_stats', @_id




if Meteor.isServer
    Meteor.publish 'posts', (post_id)->
        Docs.find
            model:'post'
            post_id:post_id

    Meteor.methods
        refresh_post_stats: (post_id)->
            post = Docs.findOne post_id
            # console.log post
            reservations = Docs.find({model:'reservation', post_id:post_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_post_hours = 0
            average_post_duration = 0

            # shorpost_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_post_hours += parseFloat(res.hour_duration)

            average_post_cost = total_earnings/reservation_count
            average_post_duration = total_post_hours/reservation_count

            Docs.update post_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_post_hours: total_post_hours.toFixed(0)
                    average_post_cost: average_post_cost.toFixed(0)
                    average_post_duration: average_post_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header post ranking #reservations
            # .ui.small.header post ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg post time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
