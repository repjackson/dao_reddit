Template.post.helpers
    view_detail: -> Session.get('view_detail')
    post_header_class: ->
        if @doc_sentiment_label is 'positive'
            if @doc_sentiment_score > .5
                'green'
            else
                'blue'
        else if @doc_sentiment_label is 'negative'
            if @doc_sentiment_score < -.5
                'red'
            else
                'orange'
Template.post.events
    'click .pick_location': ->
        current_queries.push @valueOf()
        selected_locations.push @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000

    'click .pick_company': ->
        current_queries.push @valueOf()
        selected_companies.push @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000

    'click .pick_person': ->
        current_queries.push @valueOf()
        selected_people.push @valueOf()
        Meteor.call 'search_reddit', current_queries.array()
        Meteor.setTimeout ->
            Session.set('sort_up', !Session.get('sort_up'))
        , 4000
