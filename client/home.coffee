@selected_tags = new ReactiveArray []

Template.home.onCreated ->
    @autorun -> Meteor.subscribe('posts',
        selected_tags.array()
        selected_authors.array()
        Session.get('view_mode')
        Session.get('current_query')
        )

Template.home.helpers
    current_query: -> Session.get('current_query')
    posts: ->
        Docs.find {
            model:'post'
        },
            limit:20
            sort:_timestamp:-1

    one_post: ->
        Docs.find({
            model:'post'
        }).count() is 1


Template.home.events
    'click #add': ->
        new_id =
            Docs.insert
                model:'post'
        Router.go "/post/#{new_id}/edit"
    #
    'click  .clear_query': (e,t)-> Session.set('current_query', null)

    'keyup #search': _.throttle((e,t)->
        # query = $('#search').val()
        search = $('#search').val().toLowerCase()
        Session.set('current_query', search)
        # console.log Session.get('current_query')
        if e.which is 13
            if search.length > 0
                selected_tags.push search
                console.log 'search', search
                # Meteor.call 'log_term', search, ->
                $('#search').val('')
                Session.set('current_query', null)
                # # $('#search').val('').blur()
                # # $( "p" ).blur();
                # Meteor.setTimeout ->
                #     Session.set('dummy', !Session.get('dummy'))
                # , 10000
    , 500)





Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        selected_authors.array()
        Session.get('view_mode')
        Session.get('current_query')
    )
    Session.setDefault('view_mode', 'home')

Template.cloud.helpers
    all_tags: ->
        post_count = Docs.find().count()
        if 0 < post_count < 3 then Tags.find { count: $lt: post_count } else Tags.find({},limit:20)
    selected_tags: -> selected_tags.array()

    all_authors: ->
        post_count = Docs.find().count()
        if 0 < post_count < 3 then Authors.find { count: $lt: post_count } else Authors.find()
    selected_authorss: -> selected_authors.array()


Template.cloud.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()

    'click .select_author': -> selected_authors.push @name
    'click .unselect_author': -> selected_authors.remove @valueOf()
    'click #clear_authors': -> selected_authors.clear()
