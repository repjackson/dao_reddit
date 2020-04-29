Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'all_users'

Template.home.onCreated ->
    @autorun -> Meteor.subscribe('docs',
        selected_tags.array()
        Session.get('view_mode')
        )

Template.nav.events
    'click #add': ->
        new_id =
            Docs.insert
                model:'item'
        Router.go "/item/#{new_id}/edit"


Template.home.helpers
    docs: ->
        Docs.find
            model:'item'


Template.item.helpers
    can_buy: ->
        Meteor.userId() isnt @_author_id


Template.item.events
    'click .buy': ->
        if confirm 'confirm'
            Docs.update @_id,
                $set:
                    bought:true
                    bought_timestamp:Date.now()
                    buyer_id:Meteor.userId()
                    buyer_username:Meteor.user().username
            Meteor.users.update Meteor.userId(),
                $inc:karma:-1
            Meteor.users.update @_author_id,
                $inc:karma:1
