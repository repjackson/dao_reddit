if Meteor.isClient
    Router.route '/thought/:doc_id/view', (->
        @layout 'layout'
        @render 'thought_view'
        ), name:'thought_view'
    Router.route '/thought/:doc_id/edit', (->
        @layout 'layout'
        @render 'thought_edit'
        ), name:'thought_edit'


    Template.thought_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.thought_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc_matches', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.thought_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.thought_view.helpers
        matches: ->
            if @match_ids
                Docs.find
                    _id: $in:@match_ids
    Template.thought_view.events
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
                            model:'thought'
                            title:@title
                            tags:@tags
                            price:@price
                            image_id:@image_id
                    Router.go "/thought/#{new_id}/edit"
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


        'click .recalc_similar_thoughts': ->
            Meteor.call 'recalc_similar_thoughts', @, ->


    Template.seller_card.helpers
        seller: ->
            # console.log @valueOf()
            thought = Docs.findOne Router.current().params.doc_id
            res =
                Meteor.users.findOne
                    _id:@valueOf()
            # console.log res
            res


if Meteor.isServer
    Meteor.publish 'doc_matches', (doc_id)->
        doc = Docs.find doc_id
        Docs.find
            _id:$in:doc.match_ids
    Meteor.methods
        recalc_similar_thoughts:(thought)->
            console.log thought
            thought.tags
            all_thoughts =
                Docs.find
                    model:'thought'
            matches = []
            for this_thought in all_thoughts.fetch()
                union_count = _.union this_thought.tags, thought.tags
                console.log union_count
                if union_count.length > 0
                    matches.push {
                        _id:this_thought._id
                        count:union_count.length
                    }
            Docs.update thought._id,
                $set:matches:matches
