Router.route '/bought', (->
    @render 'bought'
    ), name:'bought'


Template.bought.onCreated ->
    @autorun -> Meteor.subscribe('docs',
        selected_tags.array()
        'bought'
        )


Template.bought.helpers
    docs: ->
        Docs.find
            model:'item'


Template.bought_item.helpers
    can_buy: ->
        Meteor.userId() isnt @_author_id

    has_enough: ->
        Meteor.user().credit > @price


Template.bought_item.events
    'click .cancel': ->
        if confirm "confirm cancel of #{@price}"
            Meteor.call 'cancel', @, ->
