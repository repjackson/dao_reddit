
# PrettyEmail.options =
#   from: 'admin@henry-health.com'
#   logoUrl: 'https://henry-health.com/wp-content/uploads/2018/05/xHenryHealth-LogoREV_clr.png.pagespeed.ic.BMtMqydFa0.png'
#   companyName: 'Henry Health'
#   companyUrl: 'http://henry-health.com'
#   companyAddress: '2231 Crystal Drive, Suite 1000, Arlington, VA, 22202'
#   companyTelephone: '+2023503372'
#   companyEmail: 'admin@henry-health.com'
#   siteName: 'Henry Health'


Accounts.emailTemplates.siteName = 'dao';
Accounts.emailTemplates.from = 'dao <noreply@dao.af>';
#
# Accounts.emailTemplates.enrollAccount.subject = (user) => {
#   return `Welcome to Awesome Town, ${user.profile.name}`;
# };
#
# Accounts.emailTemplates.enrollAccount.text = (user, url) => {
#   return 'You have been selected to participate in building a better future!'
#     + ' To activate your account, simply click the link below:\n\n'
#     + url;
# };
#
# Accounts.emailTemplates.resetPassword.from = () => {
#   // Overrides the value set in `Accounts.emailTemplates.from` when resetting
#   // passwords.
#   return 'AwesomeSite Password Reset <no-reply@example.com>';
# };
Accounts.emailTemplates.verifyEmail =
   subject: -> "dao activation"
   text: (user, url)-> "hi #{user.username}.\n please verify your e-mail by clicking here: #{url}.\n\n If you did not request this verification, please ignore this email. If you feel something is wrong, please contact support: admin@dao.af."


Accounts.urls.verifyEmail = (token)->
    Meteor.absoluteUrl("verify-email/" + token)

Accounts.urls.resetPassword = (token)->
    Meteor.absoluteUrl('reset_password/' + token);



Meteor.methods
    test_email: ->
        Accounts.sendVerificationEmail Meteor.userId()
        Accounts.sendResetPasswordEmail Meteor.userId()
        Accounts.sendEnrollmentEmail Meteor.userId()


    send_password_reset_email: (user_id)->
        Accounts.sendResetPasswordEmail new_user_id



Mailer.config
    from: 'dao <admin@dao.af>',     # Default 'From:' address. Required.
    replyTo: 'dao <admin@dao.af>',  # Defaults to `from`.
    routePrefix: 'emails',              # Route prefix.
    baseUrl: "process.env.ROOT_URL",      # The base domain to build absolute link URLs from in the emails.
    testEmail: "repjackson@gmail.com",                    # Default address to send test emails to.
    logger: console                     # Injected logger (see further below)
    silent: false,                      # If set to `true`, any `Logger.info` calls won't be shown in the console to reduce clutter.
    addRoutes: false                    # Add routes for previewing and sending emails. Defaults to `true` in development.
    # addRoutes: process.env.NODE_ENV is 'development' # Add routes for previewing and sending emails. Defaults to `true` in development.
    language: 'html'                    # The template language to use. Defaults to 'html', but can be anything Meteor SSR supports (like Jade, for instance).
    plainText: true                     # Send plain text version of HTML email as well.
    plainTextOpts: {}                   # Options for `html-to-text` module. See all here: https://www.npmjs.com/package/html-to-text


Mailer.init
    templates: Templates        # Required. A key-value hash where the keys are the template names. See more below.
    helpers: {}          # Global helpers available for all templates.
    layout: false         # Global layout template.


Meteor.methods
    send_admin_enrollment_email: (new_user_id)->
        # console.log new_user_id
        new_user = Meteor.users.findOne new_user_id
        # console.log new_user
        Accounts.sendVerificationEmail(new_user_id)

        new_user = Meteor.users.findOne new_user_id
        Mailer.send
            to: ['EJ <repjackson@gmail.com>']          # 'To: ' address. Required.
            subject: 'new dao enrollment'                     # Required.
            template: 'admin_enrollment_email'               # Required.
            replyTo: 'dao admin <admin@dao.af>'      # Override global 'ReplyTo: ' option.
            from: 'dao admin <admin@dao.af>'         # Override global 'From: ' option.
            # cc: 'Name <name@domain.com>'           # Optional.
            # bcc: 'Name <name@domain.com>'          # Optional.
            data: {new_user:new_user}               # Optional. Render your email with a data object.
            attachments: []                         # Optional. Attach files using a mailcomposer format as an array of objects.
                                                    # Read more here: http://docs.meteor.com/#/full/email_send and here: https://github.com/nodemailer/mailcomposer/blob/7c0422b2de2dc61a60ba27cfa3353472f662aeb5/README.md#add-attachments

    notify_message: (chat_id)->
        # console.log new_user_id
        chat = Docs.findOne chat_id
        to_user = Meteor.users.findOne chat.to_user_id
        # console.log to_user
        # if user.emails and user.emails[0] then console.log user.emails[0]
        # to: ['dao admin <admin@dao.af>',"#{to_user.username} <#{to_user.emails[0].address}>"]          # 'To: ' address. Required.
        Mailer.send
            to: ['dao admin <eric@dao.af>']          # 'To: ' address. Required.
            subject: 'dao message'                     # Required.
            template: 'chat_template'               # Required.
            replyTo: 'dao admin <admin@dao.af>'      # Override global 'ReplyTo: ' option.
            from: 'dao admin <admin@dao.af>'         # Override global 'From: ' option.
            # cc: 'Name <name@domain.com>'           # Optional.
            # bcc: 'Name <name@domain.com>'          # Optional.
            data: {chat:chat}               # Optional. Render your email with a data object.
            attachments: []                         # Optional. Attach files using a mailcomposer format as an array of objects.


                                                    # Read more here: http://docs.meteor.com/#/full/email_send and here: https://github.com/nodemailer/mailcomposer/blob/7c0422b2de2dc61a60ba27cfa3353472f662aeb5/README.md#add-attachments
    notify_purchase: (item_id)->
        # console.log new_user_id
        item = Docs.findOne user_id
        # console.log user
        if user.emails and user.emails[0] then console.log user.emails[0]
        Mailer.send
            to: ['dao admin <admin@dao.af>',"#{user.username} <#{user.emails[0].address}>"]          # 'To: ' address. Required.
            subject: 'Gold Run Rules and Regulations Signature Receipt'                     # Required.
            template: 'purchase_receipt'               # Required.
            replyTo: 'dao admin <admin@dao.af>'      # Override global 'ReplyTo: ' option.
            from: 'dao admin <admin@dao.af>'         # Override global 'From: ' option.
            # cc: 'Name <name@domain.com>'           # Optional.
            # bcc: 'Name <name@domain.com>'          # Optional.
            data: {item:item}               # Optional. Render your email with a data object.
            attachments: []                         # Optional. Attach files using a mailcomposer format as an array of objects.
                                                    # Read more here: http://docs.meteor.com/#/full/email_send and here: https://github.com/nodemailer/mailcomposer/blob/7c0422b2de2dc61a60ba27cfa3353472f662aeb5/README.md#add-attachments
