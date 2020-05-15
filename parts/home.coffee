if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'market'
        ), name:'home'
