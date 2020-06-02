# if Meteor.isClient
#     Router.route '/map', (->
#         @layout 'layout'
#         @render 'map'
#         ), name:'map'
#
#     Template.home.onRendered ->
#         # L.Icon.Default.imagePath = '/packages/bevanhunt_leaflet/images/';
#         # map = L.map('map')
#         # L.tileLayer.provider('Stamen.Watercolor').addTo(map);
#         position = (pos)->
#             pos
#         if navigator.geolocation
#             # found =
#             #       position.coords.latitude + position.coords.longitude
#             console.log navigator.geolocation.getCurrentPosition(position)
#             # navigator.geolocation.watchPosition(showPosition)
#         else
#             console.log "Geolocation is not supported by this browser."
#
#
#     Template.map.events
#         # 'click #map': (e,t)->
#         #     console.log 'hi'
#         #     map = L.map('map', {
#         #         center: [51.505, -0.09],
#         #         zoom: 13
#         #     });
