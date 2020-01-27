Template.post.helpers
    view_detail: -> Session.get('view_detail')
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
