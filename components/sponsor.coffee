if Meteor.isClient
    Router.route '/sponsor/', (->
        @layout 'layout'
        @render 'sponsor'
        ), name:'sponsor'

    Template.sponsor.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'sponsorship'
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_400,w_400/forest_sm.png'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # product = Docs.findOne Router.current().params.doc_id
                sponsor_amount = parseInt $('.sponsor_amount').val()*100
                message = prompt 'sponsorship message (optional)'
                # email = prompt 'email for receipt (optional)'
                charge =
                    amount: sponsor_amount
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    receipt_email: email
                Meteor.call 'sponsor', charge, (error, response) =>
                    if error then alert error.reason, 'danger'
                    else
                        # alert 'payment received', 'success'
                        Docs.insert
                            model:'sponsorship'
                            amount:sponsor_amount/100
                            message:message
                            # receipt_email: email
    	)

    Template.sponsor.helpers
        sponsorships: ->
            Docs.find {
                model:'sponsorship'
            }, _timestamp:1
    Template.sponsor.events
        'click .start_sponsorship': ->
            sponsorship_amount = parseInt $('.sponsor_amount').val()*100
            Template.instance().checkout.open
                name: 'forest prime'
                # email:Meteor.user().emails[0].address
                # description: 'mmm sponsorship'
                amount: sponsorship_amount
