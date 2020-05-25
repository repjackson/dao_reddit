mailgun = require('mailgun-js')
# DOMAIN = 'whatscookin.at'


Meteor.methods
    send_mail:(to_user, subject)->
        mg = mailgun(
            apiKey: Meteor.settings.private.mailgun_key
            domain: 'mg.whatscookin.at')
        # mg = mailgun(
        #     apiKey: Meteor.settings.private.mailgun_key
        #     domain: Meteor.settings.private.mailgun_url)
        if to_user
            to = to_user
        else
            to = "repjackson"


        data =
            from: 'dao <admin@dao.af>'
            to: 'repjackson@gmail.com'
            subject: 'Hello'
            text: ''
        mg.messages().send data, (err, body)->
            if err
                console.log 'err', err
            else
                console.log 'body', body
