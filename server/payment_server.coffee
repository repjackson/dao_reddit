Future = Npm.require('fibers/future')

Meteor.methods
    STRIPE_single_charge: (data) ->
        console.log data
        if Meteor.isDevelopment
            Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
        else if Meteor.isProduction
            Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
        # account = Meteor.users.findOne(data.church)
        # #console.log(data)
        console.log '------------------------------------------------------'
        # console.log account
        # if !account.stripe
        #     retVal = error:
        #         error: 'Donation Failed'
        #         message: 'Not ready for donations, please contact your Organization.'
        #     return retVal
        # console.log account.stripe
        chargeCard = new Future
        # fee_addition = 0
        # # if account.profile.isJGFeesApply
        # #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
        # # else
        # #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
        # # #console.log(fee_addition);
        chargeData =
            amount: data.amount
            currency: 'usd'
            source: data.source
            # metadata:
            #     church: data.church
            #     givingCODE: data.givingCODE
            #     user: data.userID
            #     plan: data.plan
        #     description: account.profile.churchName
        #     application_fee: fee_addition
        #     destination: account.stripe.stripeId
        # if data.customer
        #     chargeData.customer = data.customer
        # else
        #     chargeData.metadata.givername = data.givername
        Stripe.charges.create chargeData, (error, result) ->
            if error
                chargeCard.return error: error
            else
                chargeCard.return result: result
            return
        newCharge = chargeCard.wait()
        console.log newCharge
        newCharge
