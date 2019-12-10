if Meteor.isClient
    Template.profile_layout.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'thought'

    Template.user_brain.events
        'click .add_thought': ->
            new_thought_id = Docs.insert
                model:'thought'
            Session.set 'editing_id', new_thought_id
    Template.user_brain.helpers
        thoughts: ->
            Docs.find
                model:'thought'
        editing_thought: ->



    Template.user_fiq.events
        'click .recalc_fiq': ->
            Meteor.call 'recalc_fiq', Router.current().params.user_id
    Template.user_fiq.helpers
        thoughts: ->
            Docs.find
                model:'thought'
        editing_thought: ->


if Meteor.isServer
    Meteor.methods
        recalc_fiq: (user_id)->
            console.log user_id
            answer_count =
                Docs.find(
                    model:'answer_session'
                    _author_id: user_id
                ).count()
            fiq = answer_count
            Meteor.users.update user_id,
                $set:
                    answer_count: answer_count
                    fiq: fiq
