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


# if Meteor.isClient
#     # console.log $
#     $.cloudinary.config
#         cloud_name:"facet"
#
# if Meteor.isServer
#     Cloudinary.config
#         cloud_name: 'facet'
#         api_key: Meteor.settings.cloudinary_key
#         api_secret: Meteor.settings.cloudinary_secret


# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true


Docs.helpers
    author: -> Meteor.users.findOne @_author_id
    when: -> moment(@_timestamp).fromNow()
    ten_tags: -> if @tags then @tags[..10]
    from_user: ->
        if @from_user_id
            Meteor.users.findOne @from_user_id
    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Meteor.users.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Meteor.users.findOne downvoter_id
                downvoters.push downvoter
            downvoters


Meteor.users.helpers
    name: ->
        if @nickname
            "#{@nickname}"
        else if @first_name and @last_name
            "#{@first_name} #{@last_name}"
        else
            "#{@username}"
    five_tags: -> if @tags then @tags[..4]

Meteor.methods
    add_facet_filter: (alpha_id, key, filter)->
        if key is '_keys'
            new_facet_ob = {
                key:filter
                filters:[]
                res:[]
            }
            Docs.update { _id:alpha_id },
                $addToSet: facets: new_facet_ob
        Docs.update { _id:alpha_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter

        Meteor.call 'afum', alpha_id, (err,res)->


    # add_facet_filter: (delta_id, key, filter)->
    #     if key is '_keys'
    #         new_facet_ob = {
    #             key:filter
    #             filters:[]
    #             res:[]
    #         }
    #         Docs.update { _id:delta_id },
    #             $addToSet: facets: new_facet_ob
    #     Docs.update { _id:delta_id, "facets.key":key},
    #         $addToSet: "facets.$.filters": filter
    #
    #     Meteor.call 'fum', delta_id, (err,res)->
    #
    #
    remove_facet_filter: (alpha_id, key, filter)->
        if key is '_keys'
            Docs.update { _id:alpha_id },
                $pull:facets: {key:filter}
        Docs.update { _id:alpha_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'afum', alpha_id, (err,res)->


    # remove_facet_filter: (delta_id, key, filter)->
    #     if key is '_keys'
    #         Docs.update { _id:delta_id },
    #             $pull:facets: {key:filter}
    #     Docs.update { _id:delta_id, "facets.key":key},
    #         $pull: "facets.$.filters": filter
    #     Meteor.call 'fum', delta_id, (err,res)->
    #
    #
    upvote: (doc)->
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        points:2
                        upvotes:1
                        downvotes:-1
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        upvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        upvotes:1
                        points:1
            Meteor.users.update doc._author_id,
                $inc:karma:1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:1
                    anon_upvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:1

    downvote: (doc)->
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $inc:
                        points:1
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        downvotes:1
            Meteor.users.update doc._author_id,
                $inc:karma:-1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:-1
                    anon_downvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:-1

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
