if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'


Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'home'
    loadingTemplate: 'splash'
    trackPageView: false

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

# Router.onBeforeAction(force_loggedin, {
#     # only: ['admin']
#     except: [
#         'home'
#         'register'
#         'login'
#         'verify-email'
#     ]
#     })



Router.route '*', -> @render 'home'
