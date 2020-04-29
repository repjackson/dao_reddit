if Meteor.isClient
    Router.route '/register', (->
        @layout 'layout'
        @render 'register'
        ), name:'register'









    Template.register.onCreated ->
        Session.set 'email', null
    Template.register.events
        'keyup .first_name': ->
            first_name = $('.first_name').val()
            Session.set 'first_name', first_name
        'keyup .last_name': ->
            last_name = $('.last_name').val()
            Session.set 'last_name', last_name
        'keyup .email': ->
            email = $('.email').val()
            Session.set 'email', email
            email = $('.email').val()
            Meteor.call 'validate_email', email, (err,res)->
                console.log res
                if res is true
                    Session.set 'email_status', 'valid'
                else
                    Session.set 'email_status', 'invalid'


        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'

        'blur .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'

        'click .register': (e,t)->
            username = $('.username').val()
            # email = $('.email').val()
            password = $('.password').val()
            # if Session.equals 'enter_mode', 'register'
            # if confirm "register #{username}?"
            # Meteor.call 'validate_email', email, (err,res)->
            #     console.log res
            options = {
                username:username
                password:password
            }
            # options = {
            #     email:email
            #     password:password
            #     }
            Meteor.call 'create_user', options, (err,res)=>
                console.log res
                # Meteor.users.update res,
                #     $addToSet: roles: 'teacher'
                Meteor.loginWithPassword username, password, (err,res)=>
                    if err
                        alert err.reason
                        # if err.error is 403
                        #     Session.set 'message', "#{username} not found"
                        #     Session.set 'enter_mode', 'register'
                        #     Session.set 'username', "#{username}"
                    else
                        # Meteor.users.update Meteor.userId(),
                        #     $set:
                        #         first_name: Session.get('first_name')
                        #         last_name: Session.get('last_name')
                        # new_classroom_id = Docs.insert
                        #     model: 'classroom'
                        #     teacher_id: Meteor.userId()
                        #     teacher_username: Meteor.user().username
                        #     bonus_amount: 1
                        #     fines_amount: 1
                        # Router.go "/build_classroom/#{new_classroom_id}/info"
                        # Meteor.call 'generate_transaction_types', new_classroom_id, ->
                        Router.go '/'
            # else
            #     Meteor.loginWithPassword username, password, (err,res)=>
            #         if err
            #             if err.error is 403
            #                 Session.set 'message', "#{username} not found"
            #                 Session.set 'enter_mode', 'register'
            #                 Session.set 'username', "#{username}"
            #         else
            #             Router.go '/'


    Template.register.helpers
        can_register: ->
            # Session.get('first_name') and Session.get('last_name') and Session.get('email')
            Session.get('username')

        email: -> Session.get 'email'
        username: -> Session.get 'username'
        # first_name: -> Session.get 'first_name'
        # last_name: -> Session.get 'last_name'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
        email_valid: ->
            Session.equals 'email_status', 'valid'
        email_invalid: ->
            Session.equals 'email_status', 'invalid'

if Meteor.isServer
    Meteor.methods
        set_user_password: (user, password)->
            result = Accounts.setPassword(user._id, password)
            console.log result
            result

        # verify_email: (email)->
        #     (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email))





        lookup_student_code: (input)->
            console.log 'looking up student code', input
            found_user = Meteor.users.findOne
                student_code: input
            if found_user
                found_user
            else
                null


        lookup_parent_code: (input)->
            console.log 'looking up parent code', input
            found_user = Meteor.users.findOne
                parent_code: input
            if found_user
                found_user
            else
                null


        create_user: (options)->
            console.log 'creating user', options
            Accounts.createUser options

        can_submit: ->
            username = Session.get 'username'
            email = Session.get 'email'
            password = Session.get 'password'
            password2 = Session.get 'password2'
            if username and email
                if password.length > 0 and password is password2
                    true
                else
                    false


        find_username: (username)->
            res = Accounts.findUserByUsername(username)
            if res
                # console.log res
                unless res.disabled
                    return res

        new_demo_user: ->
            current_user_count = Meteor.users.find().count()

            options = {
                username:"user#{current_user_count}"
                password:"user#{current_user_count}"
                }

            create = Accounts.createUser options
            new_user = Meteor.users.findOne create
            return new_user
