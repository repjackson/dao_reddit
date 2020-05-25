if Meteor.isClient
    Router.route '/post/:doc_id/view', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'


    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc_matches', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.post_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.post_edit.events
        'blur .post_text': (e,t)->
            post_text = t.$('.post_text').val().trim()
            Docs.update Router.current().params.doc_id,
                $set:title:post_text
            t.$('.post_text').val('')

        'keyup .new_element': (e,t)->
            if e.which is 13
                element_val = t.$('.new_element').val().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                t.$('.new_element').val('')

        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_element').focus()
            t.$('.new_element').val(element)

    Template.post_view.events

    Template.author_card.helpers
        author: ->
            # console.log @valueOf()
            post = Docs.findOne Router.current().params.doc_id
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
        recalc_similar_posts:(post)->
            console.log post
            post.tags
            all_posts =
                Docs.find
                    model:'post'
            matches = []
            for this_post in all_posts.fetch()
                union_count = _.union this_post.tags, post.tags
                console.log union_count
                if union_count.length > 0
                    matches.push {
                        _id:this_post._id
                        count:union_count.length
                    }
            Docs.update post._id,
                $set:matches:matches
