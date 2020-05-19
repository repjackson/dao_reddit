if Meteor.isClient
    Router.route '/fact/:doc_id/view', (->
        @layout 'layout'
        @render 'fact_view'
        ), name:'fact_view'
    Router.route '/fact/:doc_id/edit', (->
        @layout 'layout'
        @render 'fact_edit'
        ), name:'fact_edit'


    Template.fact_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.fact_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc_matches', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.fact_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.fact_view.helpers
        matches: ->
            if @match_ids
                Docs.find
                    _id: $in:@match_ids
    Template.fact_view.events
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
                            model:'fact'
                            title:@title
                            tags:@tags
                            price:@price
                            image_id:@image_id
                    Router.go "/fact/#{new_id}/edit"
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


        'click .recalc_similar_facts': ->
            Meteor.call 'recalc_similar_facts', @, ->


    Template.seller_card.helpers
        seller: ->
            # console.log @valueOf()
            fact = Docs.findOne Router.current().params.doc_id
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
        recalc_similar_facts:(fact)->
            console.log fact
            fact.tags
            all_facts =
                Docs.find
                    model:'fact'
            matches = []
            for this_fact in all_facts.fetch()
                union_count = _.union this_fact.tags, fact.tags
                console.log union_count
                if union_count.length > 0
                    matches.push {
                        _id:this_fact._id
                        count:union_count.length
                    }
            Docs.update fact._id,
                $set:matches:matches
