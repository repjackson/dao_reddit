Router.route '/sold', (->
    @render 'sold'
    ), name:'sold'




Template.sold.onCreated ->
    @autorun -> Meteor.subscribe('docs',
        selected_tags.array()
        'sold'
        )


Template.sold.helpers
    docs: ->
        Docs.find
            model:'item'


Template.sold_item.helpers
    can_buy: ->
        Meteor.userId() isnt @_author_id

    has_enough: ->
        Meteor.user().credit > @price


Template.sold_item.events
    'click .buy': ->
        if Meteor.userId()
            if confirm "confirm purchase of #{@price}"
                Meteor.call 'purchase', @, ->
        else
            Router.go "/login"


    'click .cancel': ->
        if confirm "confirm cancel of #{@price}"
            Meteor.call 'cancel', @, ->
