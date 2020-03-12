if Meteor.isClient
    Router.route '/calendar/', (->
        @layout 'layout'
        @render 'calendar'
        ), name:'calendar'
#
#     Template.calendar.onCreated ->
#         @autorun => Meteor.subscribe 'model_docs', 'donation'
#         if Meteor.isDevelopment
#             pub_key = Meteor.settings.public.stripe_test_publishable
#         else if Meteor.isProduction
#             pub_key = Meteor.settings.public.stripe_live_publishable
#         Template.instance().checkout = StripeCheckout.configure(
#             key: pub_key
#             image: 'https://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/mmmlogo.png'
#             locale: 'auto'
#             # zipCode: true
#             token: (token) ->
#                 # product = Docs.findOne Router.current().params.doc_id
#                 calendar_amount = parseInt $('.calendar_amount').val()*100
#                 message = prompt 'donation message (optional)'
#                 email = prompt 'email for receipt (optional)'
#                 charge =
#                     amount: calendar_amount
#                     currency: 'usd'
#                     source: token.id
#                     description: token.description
#                     receipt_email: email
#                 Meteor.call 'calendar', charge, (error, response) =>
#                     if error then alert error.reason, 'danger'
#                     else
#                         # alert 'payment received', 'success'
#                         Docs.insert
#                             model:'donation'
#                             amount:calendar_amount/100
#                             message:message
#                             receipt_email: email
#     	)
#
    Template.calendar.helpers
        events: ->
            Docs.find {
                model:'donation'
            }, _timestamp:1
    Template.calendar.events
        'click .start_donation': ->
            donation_amount = parseInt $('.calendar_amount').val()*100
            Template.instance().checkout.open
                name: 'forest calendar'
                # email:Meteor.user().emails[0].address
                # description: 'mmm donation'
                amount: donation_amount
