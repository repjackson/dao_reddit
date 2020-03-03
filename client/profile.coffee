Router.route '/profile', (->
    @layout 'layout'
    @render 'profile'
    ), name:'profile'
