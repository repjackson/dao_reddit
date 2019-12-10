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

Router.onBeforeAction(force_loggedin, {
  # only: ['admin']
  except: [
    'register'
    'login'
    'home'
    'chat'
    'profiles'
    'shop'
    'learn'
    'course_view'
    'product_view'
    'courses'
    'page'
    'delta'
    'sponsorship'
    'team'
    'questions'
    'tests'
    'classrooms'
    'choose_persona'
    'new_teacher'
    'choose_personas'
    'student_connect'
    'parent_connect'
    'new_student'
    'new_business'
    'classroom_view'
    'contact'
    'school_view'
    'parents'
    'donate'
    'teachers'
    'shop'
    'schools'
    'donors'
    'forgot_password'
    'reset_password'
    'doc_view'
    'verify-email'
    'download_rules_pdf'
  ]
});

Router.route "/add_guest/:new_guest_id", -> @render 'add_guest'

Router.route '/inbox', -> @render 'inbox'
Router.route '/stats', -> @render 'stats'

Router.route('enroll', {
    path: '/enroll-account/:token'
    template: 'reset_password'
    onBeforeAction: ()=>
        Meteor.logout()
        Session.set('_resetPasswordToken', this.params.token)
        @subscribe('enrolledUser', this.params.token).wait()
})


Router.route('verify-email', {
    path:'/verify-email/:token',
    onBeforeAction: ->
        console.log @
        # Session.set('_resetPasswordToken', this.params.token)
        # @subscribe('enrolledUser', this.params.token).wait()
        console.log @params
        Accounts.verifyEmail(@params.token, (err) =>
            if err
                console.log err
                alert err
                @next()
            else
                # alert 'email verified'
                # @next()
                Router.go "/verification_confirmation/"
        )
})



# Router.route '/user/:username', -> @render 'user'
Router.route '/verification_confirmation', -> @render 'verification_confirmation'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'profile_layout', 'user_section'
Router.route '/add_student', (->
    @layout 'layout'
    @render 'add_student'
    ), name:'add_student'

Router.route '/forgot_password', -> @render 'forgot_password'

Router.route '/settings', -> @render 'settings'
Router.route '/sign_rules/:doc_id/:username', -> @render 'rules_signing'
Router.route '/sign_guidelines/:doc_id/:username', -> @render 'guidelines_signing'
Router.route '/sign_waiver/:receipt_id', -> @render 'sign_waiver'

Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'

Router.route '/download_rules_pdf/:username', (->
    @render 'download_rules_pdf'
    ), name: 'download_rules_pdf'


# Router.route '/', -> @redirect '/m/classroom'
# Router.route '/', -> @redirect "/user/#{Meteor.user().username}"
# Router.route '/', -> @render 'home'
Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'
