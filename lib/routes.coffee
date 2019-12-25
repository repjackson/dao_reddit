Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

# Router.onBeforeAction(force_loggedin, {
#   # only: ['admin']
#   except: [
#     'register'
#     'login'
#   ]
# });


# Router.route '/user/:username', -> @render 'user'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'profile_layout', 'user_section'

Router.route '/forgot_password', -> @render 'forgot_password'

Router.route '/settings', -> @render 'settings'
