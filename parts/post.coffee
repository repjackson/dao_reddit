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




    Template.post_cloud.onCreated ->
        @autorun -> Meteor.subscribe('post_tags',
            selected_post_tags.array()
        )
        # @autorun -> Meteor.subscribe('model_docs', 'target')
    Template.post_cloud.helpers
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: -> Docs.findOne Session.get('selected_target_id')
        all_post_tags: ->
            post_count = Docs.find(model:'post').count()
            if 0 < post_count < 3 then Post_tags.find { count: $lt: post_count } else Post_tags.find({},{limit:100})
        selected_post_tags: -> selected_post_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key
    Template.post_cloud.events
        'click .select_post_tag': -> selected_post_tags.push @name
        'click .unselect_post_tag': -> selected_post_tags.remove @valueOf()
        'click #clear_post_tags': -> selected_post_tags.clear()






    Template.posts.onRendered ->
        @autorun -> Meteor.subscribe 'post_facet_docs', selected_post_tags.array()
    Template.posts.helpers
        posts: ->
            Docs.find
                model:'post'




    Template.posts.events
        'click .add_post': ->
            new_post_id = Docs.insert
                model:'post'
            Router.go "/post/#{new_post_id}/edit"



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


    Meteor.publish 'post_tags', (
        selected_post_tags
        )->
        self = @
        match = {}


        if selected_post_tags.length > 0 then match.tags = $all: selected_post_tags
        match.model = 'post'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_post_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'post_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'post_facet_docs', (
        selected_post_tags
        )->

        self = @
        match = {}
        # if selected_target_id
        #     match.target_id = selected_target_id
        if selected_post_tags.length > 0 then match.tags = $all: selected_post_tags
        match.model = 'post'
        Docs.find match,
            sort:_timestamp:1
            # limit: 5
