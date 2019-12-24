if Meteor.isClient
    Template.finance.events
        'click .give_credits': ->
            amount = prompt('how much')
            if amount
                Meteor.call 'give_credits', amount, Meteor.userId()


if Meteor.isServer
    Meteor.methods
        give_credits: (amount, giver_id, receiver_id)->
            console.log amount
            console.log giver_id
            console.log receiver_id
