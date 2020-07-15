@selected_tags = new ReactiveArray []
@selected_subreddits = new ReactiveArray []
@selected_authors = new ReactiveArray []
@selected_domains = new ReactiveArray []
@selected_emotions = new ReactiveArray []

Template.admin.helpers
    doc_count: ->
        Docs.find().count()


Template.agg_tag.onCreated ->
    # console.log @
    @autorun => @subscribe 'term', @data.title
# Template.search_term.onCreated ->
#     # console.log @
#     @autorun => @subscribe 'term', @data.title

Template.home.onCreated ->
    Session.setDefault('current_query', '')
    # Session.setDefault('dummy', true)
    @autorun => @subscribe 'terms',
        selected_tags.array()
    @autorun => @subscribe 'tag_results',
        selected_tags.array()
        # selected_subreddits.array()
        # selected_domains.array()
        # selected_authors.array()
        # selected_emotions.array()
        Session.get('current_query')
        Session.get('searching')
        # Session.get('dummy')
        Session.get('date_setting')
    @autorun => @subscribe 'doc_results',
        selected_tags.array()
        # Session.get('current_query')

        # selected_subreddits.array()
        # selected_domains.array()
        # selected_authors.array()
        # selected_emotions.array()
        Session.get('date_setting')

Template.tone.events
    # 'click .upvote_sentence': ->
    'click .tone_item': ->
        # console.log @
        doc_id = Docs.findOne()._id
        if @weight is 3
            Meteor.call 'reset_sentence', doc_id, @, ->
        else
            Meteor.call 'upvote_sentence', doc_id, @, ->

Template.search_term.helpers
    term: ->
        # console.log @
        Terms.findOne
            title:@title
Template.agg_tag.helpers
    term: ->
        # console.log @
        Terms.findOne
            title:@title
    tag_result_class: ->
        # console.log 'active_term class', @
        term =
            Terms.findOne title:@title
        if term
            # console.log 'found term emotion', term
            if term.max_emotion_name
                if term.max_emotion_name is 'anger'
                    'red invert circular'
                else if term.max_emotion_name is 'sadness'
                    'blue invert circular'
                else if term.max_emotion_name is 'joy'
                    'green invert circular'
                else if term.max_emotion_name is 'disgust'
                    'orange invert circular'
                else if term.max_emotion_name is 'fear'
                    'grey invert circular'


Template.agg_tag.events
    'click .result': (e,t)->
        Meteor.call 'log_term', @title, ->
        selected_tags.push @title
        $('#search').val('')
        Meteor.call 'call_wiki', @title, ->
        Meteor.call 'calc_term', @title, ->
        Meteor.call 'omega', @title, ->
        Session.set('current_query', '')
        Session.set('searching', false)

        Meteor.call 'search_reddit', selected_tags.array(), ->
        # Meteor.setTimeout ->
        #     Session.set('dummy', !Session.get('dummy'))
        # , 7000
    # 'click .call_visual': ->
    #     Meteor.call 'call_visual', @_id, (err,res)->
    #         console.log res

Template.home.events
    'click .select_query': ->
        selected_tags.push @title
        Meteor.call 'search_reddit', selected_tags.array(), ->
        $('#search').val('')
        Session.set('current_query', '')
        Session.set('searching', false)

Template.home.events
    'click .set_today': -> Session.set('date_setting','today')
    'click .set_yesterday': -> Session.set('date_setting','yesterday')
    'click .set_this_month': -> Session.set('date_setting','set_this_month')
    'click .set_all_time': -> Session.set('date_setting','all_time')
    'click .unselect_tag': ->
        selected_tags.remove @valueOf()
        console.log selected_tags.array()
        if selected_tags.array().length is 1
            Meteor.call 'call_wiki', selected_tags.array(), ->
            Meteor.call 'calc_term', @title, ->

        if selected_tags.array().length > 0
            Meteor.call 'search_reddit', selected_tags.array(), ->
                Session.set('dummy', !Session.get('dummy'))

    # 'click .select_subreddit': ->
    #     selected_subreddits.push @title
    # 'click .unselect_subreddit': ->
    #     selected_subreddits.remove @valueOf()
    #     # console.log selected_tags.array()
    #
    'click .select_domain': ->
        selected_domains.push @title
    'click .unselect_domain': ->
        selected_domains.remove @valueOf()
        # console.log selected_tags.array()
    #
    'click .select_emotion': ->
        selected_emotions.push @title
    'click .unselect_emotion': ->
        selected_emotions.remove @valueOf()
        # console.log selected_tags.array()

    # 'click .refresh_tags': ->

    'click .clear_selected_tags': ->
        Session.set('current_query','')
        selected_tags.clear()
    # 'keyup #search': _.throttle((e,t)->
    'keydown #search': (e,t)->
        query = $('#search').val()
        if query.length > 0
            Session.set('searching', true)
        else
            Session.set('searching', false)
        Session.set('current_query', query)
        # if query.length > 0
        # console.log Session.get('current_query')
        if e.which is 13
            search = $('#search').val().trim().toLowerCase()
            if search.length > 0
                selected_tags.push search
                console.log 'search', search

                Meteor.call 'call_wiki', search, =>
                    Meteor.call 'calc_term', @title, ->
                    Meteor.call 'omega', @title, ->

                Meteor.call 'search_reddit', selected_tags.array(), ->
                Meteor.call 'log_term', search, ->

                $('#search').val('')
                Session.set('current_query', '')
                Session.set('searching', false)
                # Meteor.setTimeout ->
                #     Session.set('dummy', !Session.get('dummy'))
                # , 6000
    # , 200)

    # 'keydown #search': _.throttle((e,t)->
    #     if e.which is 8
    #         search = $('#search').val()
    #         if search.length is 0
    #             last_val = selected_tags.array().slice(-1)
    #             console.log last_val
    #             $('#search').val(last_val)
    #             selected_tags.pop()
    #             Meteor.call 'search_reddit', selected_tags.array(), ->
    # , 1000)

    'click .reconnect': -> Meteor.reconnect()

    'click .toggle_tag': (e,t)-> selected_tags.push @valueOf()
    'click .toggle_domain': (e,t)-> selected_domains.push @domain
    'click .toggle_subreddit': (e,t)-> selected_subreddits.push @subreddit

    'keyup .add_tag': (e,t)->
        # Session.set('current_query', query)
        # console.log Session.get('current_query')
        if e.which is 13
            tag = $(e.currentTarget).closest('.add_tag').val().trim().toLowerCase()
            console.log 'tag', tag
            # search = $('#search').val()
            if tag.length > 0
                # selected_tags.push search
                Docs.update @_id,
                    $addToSet:
                        tags:tag
                        user_tags:tag
                $(e.currentTarget).closest('.add_tag').val('')
                # # console.log 'search', search
                Meteor.call 'call_wiki', tag, =>
                    Meteor.call 'log_term', tag, ->

    'click .vote_up': (e,t)->
        Docs.update @_id,
            $inc:points:1

    'click .vote_down': (e,t)->
        Docs.update @_id,
            $inc:points:-1

    'click .print_me': (e,t)->
        console.log @
    'click .pull_post': (e,t)->
        # console.log @
        Meteor.call 'get_reddit_post', @_id, @reddit_id, =>
        # Meteor.call 'agg_omega', ->

    'click .call_watson': ->
        if @rd and @rd.selftext_html
            dom = document.createElement('textarea')
            # dom.innerHTML = doc.body
            dom.innerHTML = @rd.selftext_html
            console.log 'innner html', dom.value
            # return dom.value
            Docs.update @_id,
                $set:
                    parsed_selftext_html:dom.value
        Meteor.call 'call_watson', @_id, 'url', 'url', ->
        # Meteor.call 'agg_omega', ->





Template.home.helpers
    active_term_class: ->
        # console.log 'active_term class', @
        term =
            Terms.findOne title:@valueOf()
        if term
            # console.log 'found term emotion', term
            if term.max_emotion_name
                if term.max_emotion_name is 'anger'
                    'red invert'
                else if term.max_emotion_name is 'sadness'
                    'blue invert'
                else if term.max_emotion_name is 'joy'
                    'green invert'
                else if term.max_emotion_name is 'disgust'
                    'orange invert'
                else if term.max_emotion_name is 'fear'
                    'grey invert'

    curent_date_setting: -> Session.get('date_setting')

    term_icon: ->
        console.log @
    doc_results: ->
        current_docs = Docs.find()
        # if Session.get('selected_doc_id') in current_docs.fetch()
        # console.log current_docs.fetch()
        # Docs.findOne Session.get('selected_doc_id')
        doc_count = Docs.find().count()
        # if doc_count is 1
        Docs.find({})


    is_loading: -> Session.get('is_loading')

    tag_result_class: ->
        # ec = omega.emotion_color
        # console.log @
        # console.log omega.total_doc_result_count
        total_doc_result_count = Docs.find({}).count()
        console.log total_doc_result_count
        percent = @count/total_doc_result_count
        # console.log 'percent', percent
        # console.log typeof parseFloat(@relevance)
        # console.log typeof (@relevance*100).toFixed()
        whole = parseInt(percent*10)+1
        # console.log 'whole', whole

        # if whole is 0 then "#{ec} f5"
        if whole is 0 then "f5"
        else if whole is 1 then "f11"
        else if whole is 2 then "f12"
        else if whole is 3 then "f13"
        else if whole is 4 then "f14"
        else if whole is 5 then "f15"
        else if whole is 6 then "f16"
        else if whole is 7 then "f17"
        else if whole is 8 then "f18"
        else if whole is 9 then "f19"
        else if whole is 10 then "f20"


    connection: ->
        # console.log Meteor.status()
        Meteor.status()
    connected: -> Meteor.status().connected

    # subreddit_results: ->
    #     Subreddits.find({},
    #         limit:10
    #         sort:
    #             count:-1
    #     )
    # selected_subreddits: -> selected_subreddits.array()

    emotion_results: ->
        Emotion_results.find({},
            limit:10
            sort:
                count:-1
        )
    selected_emotions: -> selected_emotions.array()

    domain_results: ->
        Domain_results.find({},
            limit:10
            sort:
                count:-1
        )
    selected_domains: -> selected_domains.array()

    terms: ->
        Terms.find({},
            limit:20
            sort:
                count:-1
        )
    agg_tags: ->
        # doc_count = Docs.find().count()
        # console.log 'doc count', doc_count
        # if doc_count < 3
        #     Tags.find({count: $lt: doc_count})
        # else
        unless Session.get('searching')
            unless Session.get('current_query').length > 0
                Tags.find({})

    result_class: ->
        if Template.instance().subscriptionsReady()
            ''
        else
            'disabled'

    selected_tags: -> selected_tags.array()

    selected_tags_plural: -> selected_tags.array().length > 1

    searching: ->
        console.log 'searching?', Session.get('searching')
        Session.get('searching')

    one_post: -> Docs.find().count() is 1

    two_posts: -> Docs.find().count() is 2
    three_posts: -> Docs.find().count() is 3
    four_posts: -> Docs.find().count() is 4
    # five_posts: -> Docs.find().count() is 5
    # six_posts: -> Docs.find().count() is 6
    # seven_posts: -> Docs.find().count() is 7
    # eight_posts: -> Docs.find().count() is 8
    # nine_posts: -> Docs.find().count() is 9
    # ten_posts: -> Docs.find().count() is 10
    # more_than_ten: -> Docs.find().count() > 10
    more_than_four: -> Docs.find().count() > 4
    one_result: ->
        Docs.find().count() is 1

    docs: ->
        # if selected_tags.array().length > 0
        cursor =
            Docs.find {
                model:['reddit','wikipedia']
            },
                sort:
                    points:-1
                    ups:-1
                # limit:10
        # console.log cursor.fetch()
        cursor

    term: ->
        # console.log @
        Terms.findOne
            title:@valueOf()

    home_subs_ready: ->
        Template.instance().subscriptionsReady()
    #
    # home_subs_ready: ->
    #     if Template.instance().subscriptionsReady()
    #         Session.set('global_subs_ready', true)
    #     else
    #         Session.set('global_subs_ready', false)
