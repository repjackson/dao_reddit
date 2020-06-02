if Meteor.isServer
    Meteor.publish 'members', (tribe_id)->
        Meteor.users.find
            _id:$in:@member_ids

    Meteor.publish 'tribe_by_slug', (tribe_slug)->
        Docs.find
            model:'tribe'
            slug:tribe_slug
