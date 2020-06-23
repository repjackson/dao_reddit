@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Terms = new Meteor.Collection 'terms'
@Subreddits = new Meteor.Collection 'subreddits'
@Authors = new Meteor.Collection 'authors'
@Domains = new Meteor.Collection 'domain'

Meteor.methods
    upvote_sentence: (doc_id, sentence)->
        console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $inc: { "tone.result.sentences_tone.$.weight": 1 } }
        )

    reset_sentence: (doc_id, sentence)->
        console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $set: { "tone.result.sentences_tone.$.weight": -2 } }
        )


    downvote_sentence: (doc_id, sentence)->
        console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $inc: { "tone.result.sentences_tone.$.weight": -1 } }
        )




Docs.before.insert (userId, doc)->
    # if Meteor.user()
    #     doc._author_id = Meteor.userId()
    #     doc._author_username = Meteor.user().username
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


    doc.points = 0


    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    return
