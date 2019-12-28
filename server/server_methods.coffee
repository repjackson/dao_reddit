Meteor.methods
    increment_view: (doc_id)->
        Docs.update doc_id,
            $inc:views:1

    create_delta: ->
        # console.log @
        Docs.insert
            model:'model'
            slug:'model'


    import_tests: ->
        # myobject = HTTP.get(Meteor.absoluteUrl("/public/tests.json")).data;
        myjson = JSON.parse(Assets.getText("tests.json"));
        console.log myjson


    add_user: (username)->
        options = {}
        options.username = username

        res= Accounts.createUser options
        if res
            return res
        else
            Throw.new Meteor.Error 'err creating user'

    change_username:  (user_id, new_username) ->
        user = Meteor.users.findOne user_id
        Accounts.setUsername(user._id, new_username)
        return "Updated Username to #{new_username}."


    add_email: (user_id, new_email) ->
        Accounts.addEmail(user_id, new_email);
        Accounts.sendVerificationEmail(user_id, new_email)
        return "Updated Email to #{new_email}"

    remove_email: (user_id, email)->
        # user = Meteor.users.findOne username:username
        Accounts.removeEmail user_id, email



    verify_email: (user_id, email)->
        user = Meteor.users.findOne user_id
        console.log 'sending verification', user.username
        Accounts.sendVerificationEmail(user_id, email)

    validate_email: (email) ->
        re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        re.test String(email).toLowerCase()


    notify_message: (message_id)->
        message = Docs.findOne message_id
        if message
            to_user = Meteor.users.findOne message.to_user_id

            message_link = "https://www.goldrun.online/user/#{to_user.username}/messages"

        	Email.send({
                to:["<#{to_user.emails[0].address}>"]
                from:"relay@goldrun.online"
                subject:"Gold Run Message alert from #{message._author_username}"
                html: "<h3> #{message._author_username} sent you the message:</h3>"+"<h2> #{message.body}.</h2>"+
                    "<br><h4>View your messages here:<a href=#{message_link}>#{message_link}</a>.</h4>"
            })

    checkout_students: ()->
        now = Date.now()
        # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()
        checkedin_sessions = Docs.find(
            model:'healthclub_session',
            active:true
            garden_key:$ne:true
            ).fetch()


        for session in checkedin_sessions
            # checkedin_doc =
            #     Docs.findOne
            #         user_id:student._id
            #         model:'healthclub_checkin'
            #         active:true
            diff = now-session._timestamp
            minute_difference = diff/1000/60
            if minute_difference>60
                # Meteor.users.update(student._id,{$set:healthclub_checkedin:false})
                Docs.update session._id,
                    $set:
                        active:false
                        logout_timestamp:Date.now()
                # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()

    check_student_status: (user_id)->
        user = Meteor.users.findOne user_id



    checkout_user: (user_id)->
        Meteor.users.update user_id,
            $set:
                healthclub_checkedin:false
        checkedin_doc =
            Docs.findOne
                user_id:user_id
                model:'healthclub_checkin'
                active:true
        if checkedin_doc
            Docs.update checkedin_doc._id,
                $set:
                    active:false
                    logout_timestamp:Date.now()

        Docs.insert
            model:'log_event'
            parent_id:user_id
            object_id:user_id
            user_id:user_id
            body: "#{@first_name} #{@last_name} checked out."



    lookup_user: (username_query, role_filter)->
        if role_filter
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                roles:$in:[role_filter]
                },{limit:10}).fetch()
        else
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                },{limit:10}).fetch()

    lookup_user_by_code: (healthclub_code)->
        unless isNaN(healthclub_code)
            Meteor.users.findOne({
                healthclub_code:healthclub_code
                })

    lookup_doc: (guest_name, model_filter)->
        Docs.find({
            model:model_filter
            guest_name: {$regex:"#{guest_name}", $options: 'i'}
            },{limit:10}).fetch()

    lookup_project: (project_title)->
        Docs.find({
            model:'project'
            title: {$regex:"#{project_title}", $options: 'i'}
            }).fetch()

    # lookup_username: (username_query)->
    #     found_users =
    #         Docs.find({
    #             model:'person'
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             }).fetch()
    #     found_users

    # lookup_first_name: (first_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             first_name: {$regex:"#{first_name}", $options: 'i'}
    #             }).fetch()
    #     found_people
    #
    # lookup_last_name: (last_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             last_name: {$regex:"#{last_name}", $options: 'i'}
    #             }).fetch()
    #     found_people


    set_password: (user_id, new_password)->
        Accounts.setPassword(user_id, new_password)


    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    send_enrollment_email: (user_id, email)->
        user = Meteor.users.findOne(user_id)
        console.log 'sending enrollment email to username', user.username
        Accounts.sendEnrollmentEmail(user_id)
