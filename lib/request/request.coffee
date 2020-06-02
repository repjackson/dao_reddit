if Meteor.isClient
    Router.route '/request/:doc_id/view', (->
        @layout 'layout'
        @render 'request_view'
        ), name:'request_view'
    Router.route '/request/:doc_id/edit', (->
        @layout 'layout'
        @render 'request_edit'
        ), name:'request_edit'


    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.request_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc_matches', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.request_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.request_edit.events
        # 'blur .request_text': (e,t)->
        #     request_text = t.$('.request_text').val().trim()
        #     Docs.update Router.current().params.doc_id,
        #         $set:title:request_text
        #     t.$('.request_text').val('')

        # 'keyup .new_element': (e,t)->
        #     if e.which is 13
        #         element_val = t.$('.new_element').val().trim()
        #         Docs.update Router.current().params.doc_id,
        #             $addToSet:tags:element_val
        #         t.$('.new_element').val('')

        # 'click .remove_element': (e,t)->
        #     element = @valueOf()
        #     field = Template.currentData()
        #     Docs.update Router.current().params.doc_id,
        #         $pull:tags:element
        #     t.$('.new_element').focus()
        #     t.$('.new_element').val(element)

    Template.request_view.events

    # Template.author_card.helpers
    #     author: ->
    #         # console.log @valueOf()
    #         request = Docs.findOne Router.current().params.doc_id
    #         res =
    #             Meteor.users.findOne
    #                 _id:@valueOf()
    #         # console.log res
    #         res


if Meteor.isServer
    Meteor.publish 'doc_matches', (doc_id)->
        doc = Docs.find doc_id
        Docs.find
            _id:$in:doc.match_ids
    Meteor.methods
        recalc_similar_requests:(request)->
            console.log request
            request.tags
            all_requests =
                Docs.find
                    model:'request'
            matches = []
            for this_request in all_requests.fetch()
                union_count = _.union this_request.tags, request.tags
                console.log union_count
                if union_count.length > 0
                    matches.push {
                        _id:this_request._id
                        count:union_count.length
                    }
            Docs.update request._id,
                $set:matches:matches
