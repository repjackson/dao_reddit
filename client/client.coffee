@selected_tags = new ReactiveArray []
@selected_question_tags = new ReactiveArray []
@selected_post_tags = new ReactiveArray []
@selected_test_tags = new ReactiveArray []
@selected_course_tags = new ReactiveArray []
@selected_event_tags = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0




# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
# $(document).ready ()=>
#     $(@).mousemove((e)->
#         $("#light").css
#             "top": e.pageY - 250
#             "left": e.pageX - 250
#     ).mousedown (e)->
#         switch (e.which)
#             when 1
#                 $("#light").toggleClass("light-off");
#                 console.log('left Mouse button pressed.');
#                 break;
#             when 2
#                 console.log('Middle Mouse button pressed.');
#                 break;
#             when 3
#                 console.log('Right Mouse button pressed.');
#                 break;
#             else
#                 console.log('You have a strange Mouse!');



Template.body.events
    # 'click a': ->
    #     $('.global_container')
    #     .transition('fade out', 250)
    #     .transition('fade in', 500)

    # 'click .result': ->
    #     $('.global_container')
    #     .transition('fade out', 250)
    #     .transition('fade in', 250)

    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1


Session.setDefault 'invert', false
Template.registerHelper 'loading_checkin', () -> Session.get 'loading_checkin'
Template.registerHelper 'parent', () -> Template.parentData()
Template.registerHelper 'parent_doc', () ->
    Docs.findOne @parent_id
    # Template.parentData()
Template.registerHelper 'product', () ->
    Docs.findOne @product_id
    # Template.parentData()
Template.registerHelper 'gs', () ->
    Docs.findOne
        model:'global_stats'
Template.registerHelper 'is_odd', -> @number % 2 isnt 0


Template.registerHelper 'question', () ->
    Docs.findOne @question_id

Template.registerHelper 'display_mode', -> Session.get('display_mode',true)
Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'is_author', -> @_author_id is Meteor.userId()
Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'fixed', (input) ->
    if input
        input.toFixed(2)
Template.registerHelper 'int', (input) -> input.toFixed(0)
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
Template.registerHelper 'last_initial', (user) ->
    @last_name[0]+'.'

Template.registerHelper 'csd', () ->
    if Router.current().params.doc_id
        Docs.findOne
            model:'classroom_stats'
            classroom_id:Router.current().params.doc_id
    else
        Docs.findOne
            model:'classroom_stats'
            classroom_id:@_id

Template.registerHelper 'first_letter', (user) ->
    @first_name[..0]+'.'
Template.registerHelper 'first_initial', (user) ->
    @first_name[..2]+'.'
    # moment(input).fromNow()
Template.registerHelper 'logging_out', () -> Session.get 'logging_out'

Template.registerHelper 'upvote_class', () ->
    if Meteor.userId()
        if @upvoter_ids and Meteor.userId() in @upvoter_ids then '' else 'outline'
    else ''
Template.registerHelper 'downvote_class', () ->
    if Meteor.userId()
        if @downvoter_ids and Meteor.userId() in @downvoter_ids then '' else 'outline'
    else ''

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")


Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'

Template.registerHelper 'hsd', () ->
    Docs.findOne
        model:'home_stats'

Template.registerHelper 'course', () ->
    Docs.findOne
        _id:@course_id

Template.registerHelper 'author', () -> Meteor.users.findOne @_author_id
Template.registerHelper 'target_user', () -> Meteor.users.findOne @user_id
Template.registerHelper 'is_text', () ->
    # console.log @field_type
    @field_type is 'text'

Template.registerHelper 'fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        match = {}
        # if Meteor.user()
        #     match.view_roles = $in:Meteor.user().roles
        match.model = 'field'
        match.parent_id = model._id
        # console.log model
        cur = Docs.find match,
            sort:rank:1
        # console.log cur.fetch()
        cur

Template.registerHelper 'edit_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            edit_roles:$in:Meteor.user().roles
        }, sort:rank:1

Template.registerHelper 'sortable_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            sortable:true
        }, sort:rank:1

Template.registerHelper 'answer_segment_class', () ->
    if @correct then '' else ''


Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', () ->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'current_model', (input) ->
    Docs.findOne
        model:'model'
        slug: Router.current().params.model_slug

Template.registerHelper 'in_list', (key) ->
    if Meteor.userId()
        if Meteor.userId() in @["#{key}"] then true else false


# Template.registerHelper 'is_admin', () ->
#     Meteor.user() and Meteor.user().admin

Template.registerHelper 'is_current_admin', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','admin'], Meteor.user().roles) then true else false
        if 'admin' in Meteor.user().current_roles then true else false
Template.registerHelper 'is_admin', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','admin'], Meteor.user().roles) then true else false
        if 'admin' in Meteor.user().roles then true else false




Template.registerHelper 'is_current_staff', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
        if 'staff' in Meteor.user().current_roles then true else false
Template.registerHelper 'is_staff', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
        if 'staff' in Meteor.user().roles then true else false



Template.registerHelper 'is_teacher', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
        if 'teacher' in Meteor.user().roles then true else false
Template.registerHelper 'is_current_teacher', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
        if 'teacher' in Meteor.user().current_roles then true else false

Template.registerHelper 'is_student', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
        if 'student' in Meteor.user().roles then true else false
Template.registerHelper 'is_current_student', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
        if 'student' in Meteor.user().current_roles then true else false


Template.registerHelper 'is_dev', () ->
    if Meteor.user() and Meteor.user().roles
        if 'dev' in Meteor.user().roles then true else false


# Template.registerHelper 'is_handler', () ->
#     if Meteor.user() and Meteor.user().roles
#         if 'handler' in Meteor.user().roles then true else false
Template.registerHelper 'is_student', () ->
    if Meteor.user() and Meteor.user().roles
        if 'student' in Meteor.user().roles then true else false

Template.registerHelper 'is_student', () ->
    if Meteor.user() and Meteor.user().roles
        if 'student' in Meteor.user().roles then true else false
Template.registerHelper 'is_current_student', () ->
    if Meteor.user() and Meteor.user().roles
        if 'student' in Meteor.user().current_roles then true else false

Template.registerHelper 'is_student_or_user', () ->
    if Meteor.user() and Meteor.user().roles
        # console.log _.intersection(Meteor.user().roles, ['student','user']).length
        if _.intersection(Meteor.user().roles, ['student','user']).length then true else false

Template.registerHelper 'is_staff_or_manager', () ->
    if Meteor.user() and Meteor.user().roles
        # console.log _.intersection(Meteor.user().roles, ['student','user']).length
        if _.intersection(Meteor.user().roles, ['manager','staff']).length then true else false


Template.registerHelper 'part_is_article', () -> @part_type is 'article'
Template.registerHelper 'part_is_question', () -> @part_type is 'question'
Template.registerHelper 'part_is_image', () -> @part_type is 'image'
Template.registerHelper 'part_is_video', () -> @part_type is 'video'
Template.registerHelper 'part_is_html', () -> @part_type is 'html'
Template.registerHelper 'part_is_math', () -> @part_type is 'math'
Template.registerHelper 'part_is_text', () -> @part_type is 'text'
Template.registerHelper 'part_is_textarea', () -> @part_type is 'textarea'

Template.registerHelper 'section_parts', () ->
    Docs.find
        model:'part'
        section_id: @_id




Template.registerHelper 'user_is_student', () -> if @roles and 'student' in @roles then true else false
Template.registerHelper 'user_is_teacher', () -> if @roles and 'teacher' in @roles then true else false
Template.registerHelper 'user_is_staff', () -> if @roles and 'staff' in @roles then true else false
Template.registerHelper 'user_is_admin', () -> if @roles and 'admin' in @roles then true else false
Template.registerHelper 'user_is_student', () -> if @roles and 'student' in @roles then true else false
Template.registerHelper 'user_is_handler', () -> if @roles and 'handler' in @roles then true else false
Template.registerHelper 'user_is_student_or_teacher', () -> if @roles and _.intersection(@roles,['student','teacher']) then true else false

Template.registerHelper 'is_eric', () -> if Meteor.userId() and Meteor.userId() in ['K77p8B9jpXbTz6nfD'] then true else false

Template.registerHelper 'current_user', () ->  Meteor.users.findOne Router.current().params.user_id
Template.registerHelper 'is_current_user', () ->
    if Meteor.userId() is Router.current().params.user_id
        true
    else
        if Meteor.user().roles and 'dev' in Meteor.user().roles
            true
        else
            false
Template.registerHelper 'view_template', -> "#{@field_type}_view"
Template.registerHelper 'edit_template', -> "#{@field_type}_edit"
Template.registerHelper 'is_model', -> @model is 'model'


# Template.body.events
#     'click .toggle_sidebar': -> $('.ui.sidebar').sidebar('toggle')

Template.registerHelper 'is_editing', () -> Session.equals 'editing_id', @_id
Template.registerHelper 'editing_doc', () ->
    Docs.findOne Session.get('editing_id')

Template.registerHelper 'can_edit', () ->
    if Meteor.user()
        Meteor.userId() is @_author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

Template.registerHelper 'current_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    user = Meteor.users.findOne Router.current().params.doc_id
    # console.log doc
    # console.log user
    if doc then doc else if user then user

Template.registerHelper 'page_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    if doc then doc

Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)
    if @direct
        parent = Template.parentData()
    else if parent5 and parent5._id
        # console.log 'p5', parent5
        # if parent5._id
        parent = Template.parentData(5)
    else if parent6 and parent6._id
        # console.log 'p6', parent6
        # if parent6._id
        parent = Template.parentData(6)
    # console.log parent
    # console.log Template.parentData(2)
    # console.log Template.parentData(3)
    # console.log Template.parentData(4)
    # console.log Template.parentData(5)
    # console.log Template.parentData(6)
    # console.log Template.parentData(7)
    # parent = Template.parentData(6)
    if parent
        # console.log parent["#{@key}"]
        parent["#{@key}"]


Template.registerHelper 'sorted_field_values', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)
    if @direct
        parent = Template.parentData()
    else if parent5._id
        parent = Template.parentData(5)
    else if parent6._id
        parent = Template.parentData(6)
    if parent
        _.sortBy parent["#{@key}"], 'number'


Template.registerHelper 'in_dev', () -> Meteor.isDevelopment

Template.registerHelper 'calculated_size', (metric) ->
    # console.log metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log whole

    if whole is 2 then 'f2'
    else if whole is 3 then 'f3'
    else if whole is 4 then 'f4'
    else if whole is 5 then 'f5'
    else if whole is 6 then 'f6'
    else if whole is 7 then 'f7'
    else if whole is 8 then 'f8'
    else if whole is 9 then 'f9'
    else if whole is 10 then 'f10'

Template.registerHelper 'in_dev', () -> Meteor.isDevelopment





Template.registerHelper 'small_bricks', () ->
    # console.log @model
    if @model
        model = Docs.findOne
            type:'model'
            slug:@model
    else if @roles
        model = Docs.findOne
            type:'model'
            slug:$in:@roles
        # tribe:'dao'
    # if @model in ['field', 'brick','model','tribe','page','block']
    # else
    #     if Router.current().params.username
    #         model = Docs.findOne
    #             type:'model'
    #             user_model:true
    #             slug:@model
    #     else
    #         model = Docs.findOne
    #             type:'model'
    #             slug:@model
    #             tribe:Router.current().params.tribe_slug

    Docs.find {
        type:'brick'
        field:$in:['text','single_doc','multi_doc','boolean','color_icon','number',]
        parent_id:model._id
        # view_roles: $in:Meteor.user().roles
    }, sort:rank:1


Template.registerHelper 'big_bricks', () ->
    # console.log @model
    # if @model in ['field', 'brick','model','tribe','page','block']
    if @model
        model = Docs.findOne
            type:'model'
            slug:@model
    else if @roles
        model = Docs.findOne
            type:'model'
            slug:$in:@roles
    Docs.find {
        type:'brick'
        parent_id:model._id
        field:$nin:['text','single_doc','multi_doc','boolean','color_icon','number']
        # view_roles: $in:Meteor.user().roles
    }, sort:rank:1

#
# Template.registerHelper 'children', ->
#     Docs.find
#         parent_id:@_id
#         # view_roles:$in:Meteor.user().roles





Template.registerHelper 'bricks', () ->
    # console.log @model
    if @model
        model = Docs.findOne
            type:'model'
            slug:@model
    else if @roles
        model = Docs.findOne
            type:'model'
            slug:$in:@roles
    # else
    #     # console.log 'looking for', @model
    #     if Router.current().params.username
    #         model = Docs.findOne
    #             type:'model'
    #             user_model:true
    #             slug:@model
    #     else
    #         model = Docs.findOne
    #             type:'model'
    #             slug:@model
    #             tribe:Router.current().params.tribe_slug
    #     # console.log @model, model

    Docs.find {
        type:'brick'
        parent_id:model._id
        # view_roles: $in:Meteor.user().roles
        # field:$nin:['text','single_doc','multi_doc','boolean']
    }, sort:rank:1
    # if 'dev' in Meteor.user().roles
    # else
    #     Docs.find {
    #         type:'brick'
    #         parent_id:model._id
    #         view_roles: $in:Meteor.user().roles
    #         # field:$nin:['text','single_doc','multi_doc','boolean']
    #     }, sort:rank:1
