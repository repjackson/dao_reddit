if Meteor.isClient
    Router.route '/map', (->
        @layout 'layout'
        @render 'map'
        ), name:'map'

    Template.map.events
        'click #map': (e,t)->
            console.log 'hi'
            map = L.map('map', {
                center: [51.505, -0.09],
                zoom: 13
            });
