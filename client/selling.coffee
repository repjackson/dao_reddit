Router.route '/selling', (->
    @render 'selling'
    ), name:'selling'


Template.selling.onCreated ->
    @autorun -> Meteor.subscribe('docs',
        selected_tags.array()
        'selling'
        )


Template.selling.helpers
    docs: ->
        Docs.find
            model:'item'


Template.selling_item.helpers
    can_buy: ->
        Meteor.userId() isnt @_author_id

    has_enough: ->
        Meteor.user().credit > @price


Template.selling_item.events
    'click .cancel': ->
        if confirm "confirm cancel of #{@price}"
            Meteor.call 'cancel', @, ->
