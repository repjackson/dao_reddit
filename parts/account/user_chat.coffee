if Meteor.isClient
    Router.route '/user/:username/chat', (->
        @layout 'profile_layout'
        @render 'user_chats'
        ), name:'user_chats'


    Template.user_chats.onCreated ->
        @autorun => Meteor.subscribe 'user_chat', Router.current().params.username

    Template.user_chats.events
        'keyup .new_chat': (e,t)->
            if e.which is 13
                user = Meteor.users.findOne username:Router.current().params.username
                chat = t.$('.new_chat').val()
                Docs.insert
                    from_user_id: Meteor.userId()
                    to_user_id:user._id
                    model:'chat'
                    body:chat
                t.$('.new_chat').val('')


    Template.user_chats.helpers
        user_chats: ->
            user = Meteor.users.findOne username:Router.current().params.username
            # console.log user
            Docs.find
                model:'chat'
                to_user_id:user._id


    Template.user_chat.events
        'click .remove_chat': (e,t)->
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
                                # Swal.fire(
                                #     'chat deleted',
                                #     ''
                                #     'success'
                                # )
                            , 1000
                    )
            )

                # swal "Submission Removed", "",'success'
                # return


    Template.user_chat.helpers
        chat_segment_class: ->
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



    Template.notify_chat.events
        'click .notify': ->
            # console.log 'notifying', @
            Meteor.call 'notify_message', (@_id), ->


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
    Meteor.publish 'user_chat', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'chat'
            to_user_id:user._id
