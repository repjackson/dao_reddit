if Meteor.isClient
    Router.route '/ph/:doc_id/view', (->
        @layout 'layout'
        @render 'ph_view'
        ), name:'ph_view'
    Router.route '/ph/:doc_id/edit', (->
        @layout 'layout'
        @render 'ph_edit'
        ), name:'ph_edit'


    Template.ph_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.ph_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc_matches', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.ph_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.ph_view.helpers
        matches: ->
            if @match_ids
                Docs.find
                    _id: $in:@match_ids
    Template.ph_view.events
        'click .clone': ->
            Swal.fire({
                title: "clone #{@title}"
                text: "this will copy content into a new doc"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    # food = Docs.findOne Router.current().params.doc_id
                    new_id =
                        Docs.insert
                            model:'ph'
                            title:@title
                            tags:@tags
                            price:@price
                            image_id:@image_id
                    Router.go "/ph/#{new_id}/edit"
            )

        'click .buy': ->
            if Meteor.userId()
                Swal.fire({
                    title: 'confirm purchase'
                    text: "this will charge you #{@price} credit"
                    icon: 'question'
                    showCancelButton: true,
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                }).then((result) =>
                    if result.value
                        # food = Docs.findOne Router.current().params.doc_id
                        Meteor.call 'purchase', @, =>
                            $('body').toast({
                                class:'success'
                                title: 'purchase confirmed',
                                message: "#{@title}"
                                showProgress: 'bottom',
                                classProgress: 'blue'

                            })
                )
            else
                Router.go "/login"


        'click .recalc_similar_phs': ->
            Meteor.call 'recalc_similar_phs', @, ->




if Meteor.isServer
    # Meteor.publish 'doc_matches', (doc_id)->
    #     doc = Docs.find doc_id
    #     Docs.find
    #         _id:$in:doc.match_ids
    Meteor.methods
        recalc_similar_phs:(ph)->
            console.log ph
            ph.tags
            all_phs =
                Docs.find
                    model:'ph'
            matches = []
            for this_ph in all_phs.fetch()
                union_count = _.union this_ph.tags, ph.tags
                console.log union_count
                if union_count.length > 0
                    matches.push {
                        _id:this_ph._id
                        count:union_count.length
                    }
            Docs.update ph._id,
                $set:matches:matches
