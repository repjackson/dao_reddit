if Meteor.isServer
    Meteor.publish 'timecard', (user_id)->
        # if user_id
        #     Docs.find
        #         _author_id: user_id
        #         model: 'timecard'
        # else
        Docs.find
            _author_id: Meteor.userId()
            model: 'timecard'

    Meteor.methods
        'check_in_user': () ->
            user_id = Meteor.userId()
            user = Meteor.users.findOne Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $set: checked_in: true
            Docs.insert
                model: 'timecard'
                timestamp: new Date()
                tags: ['timecard', user.name, 'in', Date.now()]
            Meteor.call 'calculate_user_totals', Meteor.userId()


        'check_out_user': (user_id) ->
            user = Meteor.users.findOne(Meteor.userId())
            user_id = Meteor.userId()

            Meteor.users.update Meteor.userId(),
                $set: checked_in: false
            Docs.insert
                model: 'timecard'
                timestamp: new Date()
                tags: ['timecard', user.name, 'out', Date.now()]
            Meteor.call 'calculate_user_totals', Meteor.userId()

        'calculate_user_totals': ()->
            user = Meteor.users.findOne user_id
            user_id = Meteor.userId()
            now = new Date()
            this_month = now.getMonth() + 1

            match = {}
            # match._author_id = user_id
            match.model = 'timecard'
            # match.tags = $in: ['in']
            console.log 'running user totals'
            console.log match
            console.log Docs.find(match).fetch().length
            options = { explain:true }
            pipe =  [
                { $match: match }
                { $project:
                    # year: $year: '$_timestamp'
                    month: $month: '$timestamp'
                    day: $dayOfMonth: '$timestamp'
                    # hour: $hour: '$timestamp'
                    # minutes: $minute: '$timestamp'
                    # seconds: $second: '$timestamp'
                    # milliseconds: $millisecond: '$timestamp'
                    # dayOfYear: $dayOfYear: '$timestamp'
                    # dayOfWeek: $dayOfWeek: '$timestamp'
                    # week: $week: '$timestamp'
                }
                { $match: month: this_month }
                #
                # # { $group: _id: '$month', count: $sum: 1 }
                { $group: _id: '$day', count: $sum: 1 }

            ]
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # res = {}
            # if agg
            #     agg.toArray()

            console.log agg.toArray()

            monthly_day_usage = agg.length

            # Meteor.users.update user_id,
            #     $set: monthly_day_usage: monthly_day_usage
