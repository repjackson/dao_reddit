# if Meteor.isClient
#     Template.docs.onCreated ->
#         Session.setDefault 'view_images', true
#         Session.setDefault 'view_videos', true
#         Session.setDefault 'view_articles', true
#         Session.setDefault 'view_tweets', true
#         Session.setDefault 'view_mode', 'list'
#         Session.setDefault 'doc_sort_key', 'ups'
#         Session.setDefault 'doc_sort_label', 'upvotes'
#         Session.setDefault 'doc_limit', 5
#
#     # Template.body.events
#     #     'keydown':(e,t)->
#     #         # console.log e.keyCode
#     #         # console.log e.keyCode
#     #         if e.keyCode is 27
#     #             console.log 'hi'
#     #             # console.log 'hi'
#     #             Session.set('current_query', null)
#     #             selected_tags.clear()
#     #             $('#search').val('')
#     #             $('#search').blur()
#     #
#     Template.docs.onCreated ->
#         @autorun => @subscribe 'results',
#             selected_tags.array()
#             selected_authors.array()
#             selected_subreddits.array()
#             selected_timestamp_tags.array()
#             Session.get('current_query')
#             Session.get('dummy')
#             Session.get('doc_limit')
#             Session.get('doc_sort_key')
#             Session.get('doc_sort_direction')
#             Session.get('view_images')
#             Session.get('view_videos')
#             Session.get('view_articles')
#         @autorun => @subscribe 'docs',
#             selected_tags.array()
#             Session.get('view_images')
#             Session.get('view_videos')
#             Session.get('view_articles')
#             Session.get('doc_limit')
#             Session.get('doc_sort_key')
#             Session.get('doc_sort_direction')
#
#         @autorun => @subscribe 'all_redditors'
#
#
#
#     Template.docs.events
#         # 'click .toggle_dark': ->
#         #     Meteor.users.update Meteor.userId(),
#         #         $set: dark_mode: !Meteor.user().dark_mode
#         # 'click .toggle_menu': ->
#         #     Session.set('view_menu', !Session.get('view_menu'))
#         'click .calc_leaderboard': ->
#             # console.log @
#             # console.log selected_tags.array()
#             Meteor.call 'calc_leaders', selected_tags.array(), (err,res)->
#                 console.log res
#
#         'click .toggle_images': -> Session.set('view_images', !Session.get('view_images'))
#         'click .toggle_videos': -> Session.set('view_videos', !Session.get('view_videos'))
#         'click .toggle_articles': -> Session.set('view_articles', !Session.get('view_articles'))
#
#         'click .result': (event,template)->
#             # console.log @
#             if selected_tags.array().length is 1
#                 Meteor.call 'call_wiki', search, ->
#             Meteor.call 'log_term', @title, ->
#             selected_tags.push @title
#             $('#search').val('')
#             Meteor.call 'call_wiki', @title, ->
#             Session.set('current_query', null)
#             Session.set('searching', false)
#             Meteor.call 'search_reddit', selected_tags.array(), ->
#             Meteor.setTimeout ->
#                 Session.set('dummy', !Session.get('dummy'))
#             , 10000
#         'click .select_query': -> queries.push @title
#         'click .unselect_tag': ->
#             selected_tags.remove @valueOf()
#             # console.log selected_tags.array()
#             if selected_tags.array().length is 1
#                 Meteor.call 'call_wiki', search, ->
#
#             if selected_tags.array().length > 0
#                 Meteor.call 'search_reddit', selected_tags.array(), ->
#
#         'click .refresh_tags': ->
#             Session.set('dummy', !Session.get('dummy'))
#
#         'click .clear_selected_tags': ->
#             Session.set('current_query',null)
#             selected_tags.clear()
#
#         'keyup #search': _.throttle((e,t)->
#             query = $('#search').val()
#             Session.set('current_query', query)
#             # console.log Session.get('current_query')
#             if e.which is 13
#                 search = $('#search').val().trim().toLowerCase()
#                 if search.length > 0
#                     selected_tags.push search
#                     console.log 'search', search
#                     Meteor.call 'call_wiki', search, ->
#                     Meteor.call 'search_reddit', selected_tags.array(), ->
#                     Meteor.call 'log_term', search, ->
#                     $('#search').val('')
#                     Session.set('current_query', null)
#                     # # $('#search').val('').blur()
#                     # # $( "p" ).blur();
#                     Meteor.setTimeout ->
#                         Session.set('dummy', !Session.get('dummy'))
#                     , 10000
#         , 1000)
#
#         'click .calc_doc_count': ->
#             Meteor.call 'calc_doc_count', ->
#
#         'click .create_redditor': ->
#             Meteor.call 'create_redditor', @title, ->
#
#         'click .calc_redditor': ->
#             Meteor.call 'calc_redditor_stats', @handle, ->
#
#         'click .calc_post': ->
#             console.log @
#             # Meteor.call 'get_reddit_post', (@_id)->
#
#
#         # 'keydown #search': _.throttle((e,t)->
#         #     if e.which is 8
#         #         search = $('#search').val()
#         #         if search.length is 0
#         #             last_val = selected_tags.array().slice(-1)
#         #             console.log last_val
#         #             $('#search').val(last_val)
#         #             selected_tags.pop()
#         #             Meteor.call 'search_reddit', selected_tags.array(), ->
#         # , 1000)
#
#         'click .reconnect': ->
#             Meteor.reconnect()
#
#         'click .goto_redditor': ->
#             Router.go "/redditor/#{@title}"
#
#         'click .set_sort_direction': ->
#             if Session.get('doc_sort_direction') is -1
#                 Session.set('doc_sort_direction', 1)
#             else
#                 Session.set('doc_sort_direction', -1)
#
#
#     Template.docs.helpers
#         sorting_up: ->
#             parseInt(Session.get('doc_sort_direction')) is 1
#
#         view_images_class: -> if Session.get('view_images') then 'white' else 'grey'
#         view_videos_class: -> if Session.get('view_videos') then 'white' else 'grey'
#         view_articles_class: -> if Session.get('view_articles') then 'white' else 'grey'
#         view_tweets_class: -> if Session.get('view_tweets') then 'white' else 'grey'
#         connection: ->
#             console.log Meteor.status()
#             Meteor.status()
#         connected: ->
#             Meteor.status().connected
#         invert_class: ->
#             if Meteor.user()
#                 if Meteor.user().dark_mode
#                     'invert'
#         view_menu: -> Session.get('view_menu')
#         tags: ->
#             if Session.get('current_query') and Session.get('current_query').length > 1
#                 Terms.find({}, sort:count:-1)
#             else
#                 doc_count = Docs.find().count()
#                 # console.log 'doc count', doc_count
#                 if doc_count < 3
#                     Tags.find({count: $lt: doc_count})
#                 else
#                     Tags.find()
#
#         result_class: ->
#             if Template.instance().subscriptionsReady()
#                 ''
#             else
#                 'disabled'
#
#         selected_tags: -> selected_tags.array()
#         selected_tags_plural: -> selected_tags.array().length > 1
#         searching: -> Session.get('searching')
#
#         one_post: ->
#             Docs.find().count() is 1
#         docs: ->
#             # if selected_tags.array().length > 0
#             Docs.find {
#                 model:'reddit'
#             },
#                 sort: "#{Session.get('doc_sort_key')}":parseInt(Session.get('doc_sort_direction'))
#                 limit:Session.get('doc_limit')
#
#         home_subs_ready: ->
#             Template.instance().subscriptionsReady()
#
#         home_subs_ready: ->
#             if Template.instance().subscriptionsReady()
#                 Session.set('global_subs_ready', true)
#             else
#                 Session.set('global_subs_ready', false)
#
#
#
#         redditor_leaders: ->
#             # if selected_tags.array().length > 0
#             Redditor_leaders.find {
#                 # model:'reddit'
#             },
#                 sort: count:-1
#                 # limit:1
#
#         subreddit_results: ->
#             # if selected_tags.array().length > 0
#             Subreddits.find {
#                 # model:'reddit'
#             },
#                 sort: count:-1
#                 # limit:1
#
#         timestamp_tags: ->
#             # if selected_tags.array().length > 0
#             Timestamp_tags.find {
#                 # model:'reddit'
#             },
#                 sort: count:-1
#                 # limit:1
#
#         redditor: ->
#             Redditors.findOne
#                 handle:@title
#
#         doc_limit: ->
#             Session.get('doc_limit')
#
#         current_doc_sort_label: ->
#             Session.get('doc_sort_label')
#
#
#         result_cloud: ->
#             console.log @
#
#     Template.set_doc_limit.events
#         'click .set_limit': ->
#             console.log @
#             Session.set('doc_limit', @amount)
#
#     Template.set_doc_sort_key.events
#         'click .set_sort': ->
#             console.log @
#             Session.set('doc_sort_key', @key)
#             Session.set('doc_sort_label', @label)
#
#     Template.session_edit_value_button.events
#         'click .set_session_value': ->
#             # console.log @key
#             # console.log @value
#             Session.set(@key, @value)
#
#     Template.session_edit_value_button.helpers
#         calculated_class: ->
#             res = ''
#             # console.log @
#             if @classes
#                 res += @classes
#             if Session.equals(@key,@value)
#                 res += ' active'
#             # console.log res
#             res
