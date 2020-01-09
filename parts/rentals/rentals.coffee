Router.route '/rentals/', (->
    @layout 'layout'
    @render 'rentals'
    ), name:'rentals'

if Meteor.isClient
    Template.rentals.events
        'click .add_rental': ->
            new_rental_id =
                Docs.insert
                    model:'rental'
            Router.go "/rental/#{new_rental_id}/edit"
