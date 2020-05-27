if Meteor.isClient
    Router.route '/redditors', (->
        @layout 'layout'
        @render 'redditors'
        ), name:'redditors'

    Router.route '/redditor/:handle', (->
        @layout 'layout'
        @render 'redditor_page'
        ), name:'redditor_page'



    Template.redditors.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000
    Template.redditors.onCreated ->
        @autorun => Meteor.subscribe 'redditors'
    Template.redditors.helpers
        redditors: ->
            Redditors.find( {},
            sort:submission_rank:1
            )


    Template.redditor_page.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000
    Template.redditor_page.onCreated ->
        @autorun => Meteor.subscribe 'redditor_by_handle', Router.current().params.handle
        @autorun => Meteor.subscribe 'redditor_submissions', Router.current().params.handle
    Template.redditor_page.helpers
        redditor: ->
            Redditors.findOne()
        submissions: ->
            Docs.find( {
                model:'reddit'
                author: Router.current().params.handle
                }, limit: 10
            )
    Template.redditor_page.events
        'click .pull_redditor': ->
            console.log @
            Meteor.call 'create_redditor', Router.current().params.handle, ->

        'click .refresh': ->
            console.log @
            Meteor.call 'calc_redditor_stats', Router.current().params.handle, ->


    Template.redditor_card.events
        'click .refresh': ->
            console.log @
            Meteor.call 'calc_redditor_stats', @handle, ->



if Meteor.isServer
    Meteor.publish 'redditors', ->
        Redditors.find()
    Meteor.publish 'redditor_submissions', (handle)->
        Docs.find(
            model:'reddit'
            author: handle
        )
    Meteor.publish 'redditor_by_handle', (handle)->
        Redditors.find(handle:handle)

    Meteor.methods
        create_redditor: (handle)->
            console.log handle
            found_redditor = Redditors.findOne(handle:handle)
            if found_redditor
                console.log 'found_redditor', found_redditor
            else
                Redditors.insert
                    handle:handle



        calc_redditor_stats: (handle)->
            console.log handle
            found_redditor = Redditors.findOne(handle:handle)
            # if found_redditor
            #     console.log 'found_redditor', found_redditor
            submission_count =
                Docs.find(
                    model:'reddit'
                    author:handle
                ).count()
            # console.log 'submission count', submission_count
            redditor_count =
                Redditors.find().count()
            # console.log 'redditor count', redditor_count
            redditor_index =
                Redditors.find({},
                    fields:
                        _id:1
                    sort:submission_count:-1
                ).fetch()

            # console.log 'index', redditor_index
            # values = _.values(redditor_index)
            # console.log 'values', values
            # element = {
            #     _id: found_redditor._id
            #     # submission_count: found_redditor.submission_count
            # }
            # console.log 'element', element

            # submission_rank =
            #     _.indexOf(values, element)

            redditor = Redditors.findOne({handle: handle})
            submission_rank =
                Redditors.find(
                    submission_count: {$gte: redditor.submission_count}
                ).count()
            console.log 'sub rank', submission_rank

            next_redditor = Redditors.find(
                {
                    _id: {$ne: redditor._id},
                    submission_count: {$gte: redditor.submission_count}
                },
                {
                    sort:
                        submission_count:1
                        handle:1
                    limit:-1
                }
            )
            previous_player = Redditors.find(
                {
                    _id: {$ne: redditor._id},
                    submission_count: {$lte: redditor.submission_count}
                },
                {
                    sort:
                        submission_count:-1
                        handle:-1
                    limit:-1
                }
            )
            match = {
                model:'reddit'
                author:handle
            }
            console.log 'redditor mathc', match
            redditor_tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: "tags": 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, title: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }

            tag_cloud = []
            redditor_tag_cloud.forEach Meteor.bindEnvironment((tag)=>
                console.log 'redditor tag', tag
                tag_cloud.push tag
                Redditors.update found_redditor._id,
                    $addToSet:
                        tag_cloud:tag
                        tag_list:tag.title
            )



            Redditors.update found_redditor._id,
                $set:
                    submission_count:submission_count
                    submission_rank: submission_rank
