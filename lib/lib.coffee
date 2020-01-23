@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Organizations = new Meteor.Collection 'organizations'
@People = new Meteor.Collection 'people'
@Authors = new Meteor.Collection 'authors'
@Companies = new Meteor.Collection 'companies'
@Concepts = new Meteor.Collection 'concepts'
@Keywords = new Meteor.Collection 'keywords'
@Subreddits = new Meteor.Collection 'subreddits'
@Locations = new Meteor.Collection 'locations'
@Categories = new Meteor.Collection 'categories'
@Timestamp_tags = new Meteor.Collection 'timestamp_tags'

# @Question_tags = new Meteor.Collection 'question_tags'
# @Test_tags = new Meteor.Collection 'test_tags'
# @Post_tags = new Meteor.Collection 'post_tags'
# @Course_tags = new Meteor.Collection 'course_tags'
# @Rental_tags = new Meteor.Collection 'rental_tags'



Docs.before.insert (userId, doc)->
    doc._author_id = Meteor.userId()
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    doc._author_id = Meteor.userId()
    if Meteor.user()
        doc._author_username = Meteor.user().username

    # doc.points = 0
    # doc.downvoters = []
    # doc.upvoters = []
    return



Docs.helpers
    # author: -> Meteor.users.findOne @_author_id
    when: -> moment(@_timestamp).fromNow()
    ten_tags: -> if @tags then @tags[..10]
    from_user: ->
        if @from_user_id
            Meteor.users.findOne @from_user_id

Meteor.methods
    rename_key:(old_key,new_key,parent)->
        Docs.update parent._id,
            $pull:_keys:old_key
        Docs.update parent._id,
            $addToSet:_keys:new_key
        Docs.update parent._id,
            $rename:
                "#{old_key}": new_key
                "_#{old_key}": "_#{new_key}"

if Meteor.isServer
    Meteor.publish 'doc', (id)->
        doc = Docs.findOne id
        user = Meteor.users.findOne id
        if doc
            Docs.find id
        else if user
            Meteor.users.find id
    Meteor.publish 'docs', (selected_tags, filter, limit)->
        # user = Meteor.users.findOne @userId
        # console.log selected_tags
        # console.log filter
        self = @
        match = {}
        # if Meteor.user()
        #     unless Meteor.user().roles and 'dev' in Meteor.user().roles
        #         match.view_roles = $in:Meteor.user().roles
        # else
        #     match.view_roles = $in:['public']

        # if filter is 'shop'
        #     match.active = true
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if filter then match.model = filter

        Docs.find match,
            sort:_timestamp:-1
            limit: limit
