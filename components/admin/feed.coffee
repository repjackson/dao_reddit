if Meteor.isClient
    Router.route '/feed', (->
        @layout 'admin_layout'
        @render 'feed'
        ), name:'feed'

    Template.feed.onCreated ->
        @autorun -> Meteor.subscribe('model_docs', 'feed_event'
        )

    Template.feed.helpers
        feed: ->
            Docs.find {
                model:'feed_event'
            }, _timestamp:1


    Template.feed.events
        'click .add_feed_event': ->
            new_feed_event_id =
                Docs.insert
                    model:'feed_event'
            Session.set 'editing', new_feed_event_id

        'click .edit': ->
            Session.set 'editing_id', @_id
        'click .save': ->
            Session.set 'editing_id', null
