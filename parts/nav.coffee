if Meteor.isClient
    Template.nav.onRendered ->
        # Meteor.setTimeout ->
        #     $('.dropdown').dropdown(
        #         on:'click'
        #     )
        #     $('.ui.dropdown').dropdown(
        #         clearable:true
        #         action: 'activate'
        #         onChange: (text,value,$selectedItem)->
        #     )
        # , 1000
        Meteor.setTimeout ->
            $('.context.example .ui.sidebar')
                .sidebar({
                    context: $('.context.example .segment')
                    dimPage: false
                    transition:  'overlay'
                })
                .sidebar('attach events', '.context.example .menu .toggle_sidebar.item')
        , 1000

        Meteor.setTimeout ->
            $('.item').popup(
                preserve:true;
                hoverable:false;
            )
        , 1000

    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'model_docs', 'global_stats'
        # @autorun -> Meteor.subscribe 'model_docs', 'nav_item'
        @autorun -> Meteor.subscribe 'model_docs','alert'
        @autorun -> Meteor.subscribe 'all_users'
        # @autorun => Meteor.subscribe 'global_settings'
        @autorun => Meteor.subscribe 'my_cart'

        # @autorun -> Meteor.subscribe 'current_session'
        # @autorun -> Meteor.subscribe 'unread_messages'

    Template.nav.helpers
        subs_ready: -> Template.instance().subscriptionsReady()

        nav_items: ->
            Docs.find
                model:'nav_item'
        user_nav_button_class: ->
            if Meteor.user().handling_active
                'green'
            else
                ''
        alerts: ->
            Docs.find
                model:'alert'
        unread_alert_count: ->
            Docs.find(
                model:'alert'
                target_username: Meteor.user().username
                read_ids: $nin: [Meteor.userId()]
            ).count()

        role_models: ->
            if Meteor.user()
                if Meteor.user() and Meteor.user().roles
                    if 'dev' in Meteor.user().roles
                        Docs.find {
                            model:'model'
                        }, sort:title:1
                    else
                        Docs.find {
                            model:'model'
                            view_roles:$in:Meteor.user().roles
                        }, sort:title:1
            else
                Docs.find {
                    model:'model'
                    view_roles: $in:['public']
                }, sort:title:1

        models: ->
            Docs.find
                model:'model'

        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()

        cart_amount: ->
            cart_amount = Docs.find({
                model:'cart_item'
                _author_id:Meteor.userId()
            }).count()


        mail_icon_class: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()
            if unread_count then 'red' else ''


        alert_icon_class: ->
            unread_count = Docs.find({
                model:'alert'
                target_user_id:Meteor.userId()
            }).count()
            if unread_count then 'yellow' else 'outline'


        bookmarked_models: ->
            if Meteor.userId()
                Docs.find
                    model:'model'
                    bookmark_ids:$in:[Meteor.userId()]


        my_classrooms: ->
            if Meteor.userId()
                Docs.find
                    model:'classroom'
                    teacher_id:Meteor.userId()

    Template.sidebar.events
        'click .toggle_sidebar': ->
            console.log @
            $('.ui.sidebar')
                .sidebar('setting', 'transition', 'overlay')
                .sidebar('toggle')


    Template.nav.events
        'click .toggle_sidebar': ->
            $('.ui.sidebar')
                .sidebar('setting', 'transition', 'overlay')
                .sidebar('toggle')

        # 'mouseenter .item': (e,t)->
        #     $(e.currentTarget).closest('.item').transition('pulse', 500)
        'click .menu_dropdown': ->
            $('.menu_dropdown').dropdown(
                on:'hover'
            )

        'click .item': (e,t)->
            $(e.currentTarget).closest('.item').transition(
                animation: 'pulse'
                duration: 500
            )


        'click .new_act_test': ->
            new_session_id =
                Docs.insert
                    model:'test_session'
            Router.go "/test/#{new_session_id}/take"

        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'

        'click .set_models': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'model', ->
                Session.set 'loading', false

        'click .set_model': ->
            Session.set 'loading', true
            # Meteor.call 'log_view', @_id, ->
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false


        'click .spinning': ->
            Session.set 'loading', false






    Template.footer.events
        'click .shortcut_modal': ->
            $('.ui.shortcut.modal').modal('show')

    Template.footer_chat.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'footer_chat'
    Template.footer_chat.helpers
        chat_messages: ->
            Docs.find
                model:'footer_chat'
    Template.footer_chat.events
        'keyup .new_footer_chat_message': (e,t)->
            if e.which is 13
                new_message = $('.new_footer_chat_message').val()
                Docs.insert
                    model:'footer_chat'
                    text:new_message
                $('.new_footer_chat_message').val('')
        'click .remove_message': (e,t)->
            # if confirm 'remove message?'
            $(e.currentTarget).closest('.item').transition('fade right')
            Meteor.setTimeout =>
                Docs.remove @_id
            , 750

    # Template.mlayout.onCreated ->
    #     @autorun -> Meteor.subscribe 'me'


    Template.my_latest_activity.onCreated ->
        @autorun -> Meteor.subscribe 'my_latest_activity'
    Template.my_latest_activity.helpers
        my_latest_activity: ->
            Docs.find {
                model:'log_event'
                _author_id:Meteor.userId()
            },
                sort:_timestamp:-1
                limit:5


    Template.bug_reporter.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Session.get('reporting_bug_id')
    Template.bug_reporter.helpers
        reporting_bug: -> Session.get('reporting_bug_id')
        new_bug: -> Docs.findOne Session.get('reporting_bug_id')


    Template.bug_reporter.events
        'click .start_report': ->
            new_bug_id = Docs.insert
                model:'bug'
                url: window.location.href
                pathname: window.location.pathname
            Session.set 'reporting_bug_id', new_bug_id

        'click .cancel_bug': ->
            new_bug_id = Session.get('reporting_bug_id')
            Docs.remove new_bug_id
            Session.set 'reporting_bug_id', null

        'click .submit_report': ->
            console.log window.location.href
            bug_id = Session.get('reporting_bug_id')
            Session.set('reporting_bug_id', null)
            Docs.insert
                model:'alert'
                target_username:'dev'
                reference_doc_id: bug_id
                text: 'bug submitted'
                reference_model:'bug'
                reference_link: "/m/bug/#{bug_id}/view"
            $('body').toast({
                message: "bug reported"
                class:'info'
                position: 'bottom right'
            })




if Meteor.isServer
    Meteor.publish 'my_latest_activity', ->
        Docs.find {
            model:'log_event'
            _author_id: Meteor.userId()
        },
            limit:5
            sort:_timestamp:-1


    Meteor.publish 'bookmarked_models', ->
        if Meteor.userId()
            Docs.find
                model:'model'
                bookmark_ids:$in:[Meteor.userId()]


    Meteor.publish 'my_cart', ->
        if Meteor.userId()
            Docs.find
                model:'cart_item'
                _author_id:Meteor.userId()

    Meteor.publish 'unread_messages', (username)->
        if Meteor.userId()
            Docs.find {
                model:'message'
                to_username:username
                read_ids:$nin:[Meteor.userId()]
            }, sort:_timestamp:-1


    Meteor.publish 'me', ->
        Meteor.users.find @userId
