if Meteor.isClient
    Router.route '/reddit', (->
        @layout 'layout'
        @render 'reddit'
        ), name:'reddit'

    Template.reddit.onCreated ->
        # @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'model_docs', 'global_stats'
        @autorun -> Meteor.subscribe 'model_docs', 'reddit'

    Template.reddit.helpers
        reddit_posts: ->
            Docs.find
                model:'reddit'
    Template.reddit.events
        'click .import_subreddit': ->
            subreddit = $('.subreddit').val()
            Meteor.call 'pull_subreddit', subreddit
        'keyup .subreddit': (e,t)->
            if e.which is 13
                subreddit = $('.subreddit').val()
                Meteor.call 'pull_subreddit', subreddit
        'keyup #search': (e,t)->
            if e.which is 13
                search = $('#search').val()
                Meteor.call 'search_reddit', search
        'click .import_site': ->
            site = $('.site').val()
            Meteor.call 'import_site', site
