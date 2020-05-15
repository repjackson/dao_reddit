@selected_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []


Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'

if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'market'
        ), name:'home'
