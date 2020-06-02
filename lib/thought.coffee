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
    Template.thought_edit.events
        # 'blur .thought_text': (e,t)->
        #     thought_text = t.$('.thought_text').val().trim()
        #     Docs.update Router.current().params.doc_id,
        #         $set:title:thought_text
        #     t.$('.thought_text').val('')

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

    Template.thought_view.events

    # Template.author_card.helpers
    #     author: ->
    #         # console.log @valueOf()
    #         thought = Docs.findOne Router.current().params.doc_id
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
