if Meteor.isClient
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'


    Template.user_messages.onCreated ->
        @autorun => Meteor.subscribe 'user_messages', Router.current().params.username

    Template.user_messages.events
        'click .offer_new_meal': ->
            new_meal_id =
                Docs.insert
                    model:'meal'
                    published:false
            Router.go("/meal/#{new_meal_id}/edit")

        'keyup .new_message': (e,t)->
            if e.which is 13
                user = Meteor.users.findOne username:Router.current().params.username
                message = t.$('.new_message').val()
                Docs.insert
                    from_user_id: Meteor.userId()
                    to_user_id:user._id
                    model:'message'
                    body:message
                t.$('.new_message').val('')


    Template.user_messages.helpers
        user_messages: ->
            user = Meteor.users.findOne username:Router.current().params.username
            # console.log user
            Docs.find
                model:'message'
                to_user_id:user._id


    Template.user_message.events
        'click .remove_message': (e,t)->
            Swal.fire({
                title: 'confirm delete'
                text: @body
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    $(e.currentTarget).closest('.smoothed').transition(
                        animation: 'fly right'
                        duration: 1000
                        onComplete: ()=>
                            Meteor.setTimeout =>
                                Docs.remove @_id
                                Swal.fire(
                                    'message deleted',
                                    ''
                                    'success'
                                )
                            , 1000
                    )
            )

                # swal "Submission Removed", "",'success'
                # return


    Template.user_message.helpers
        message_segment_class: ->
            # if @read_by_ids and Meteor.userId() in @read_by_ids
            if @read
                'basic'
            else
                ''



    Template.mark_read_button.helpers
        # is_read: ->
        #     # if @read_by_ids and Meteor.userId() in @read_by_ids
        #     if @read
        #         true
        #     else
        #         false



    Template.mark_read_button.events
        'click .mark_unread': ->
            Docs.update @_id,
                # $pull:
                #     read_by_ids: Meteor.userId()
                $set:
                    read: false
                    read_timestamp:null

        'click .mark_read': ->
            Docs.update @_id,
                # $addToSet:
                #     read_by_ids: Meteor.userId()
                $set:
                    read:true
                    read_timestamp:Date.now()


if Meteor.isServer
    Meteor.publish 'user_messages', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'message'
            to_user_id:user._id
