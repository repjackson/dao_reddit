if Meteor.isClient
    Router.route '/flashcards', (->
        @layout 'layout'
        @render 'flashcards'
        ), name:'flashcards'
    Router.route '/flashcard_stats', (->
        @layout 'layout'
        @render 'flashcard_stats'
        ), name:'flashcard_stats'
    Router.route '/flashcard/:doc_id/edit', (->
        @layout 'layout'
        @render 'flashcard_edit'
        ), name:'flashcard_edit'
    Router.route '/flashcard/:doc_id/view', (->
        @layout 'layout'
        @render 'flashcard_view'
        ), name:'flashcard_view'
    Router.route '/flashcard_session/:doc_id/edit', (->
        @layout 'layout'
        @render 'flashcard_session_edit'
        ), name:'flashcard_session_edit'
    Router.route '/flashcard_session/:doc_id/view', (->
        @layout 'layout'
        @render 'flashcard_session_view'
        ), name:'flashcard_session_view'

    Template.flashcards.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'flashcard'
        @autorun -> Meteor.subscribe 'model_docs', 'flashcard_session'
    Template.flashcards.onRendered ->
    Template.flashcards.helpers
        flashcards: ->
            Docs.find {
                model:'flashcard'
            }, _timestamp:1
        my_sessions: ->
            Docs.find {
                model:'flashcard_session'
            }, _timestamp:1
    Template.flashcards.events
        'click .add_flashcard': ->
            new_flashcard_id =
                Docs.insert
                    model:'flashcard'
            Session.set 'editing', new_flashcard_id
        # 'click .shape': ->
        #     $('.shape').shape('flip right');
        'click .new_flashcard_session': ->
            new_fc_session_id =
                Docs.insert
                    model:'flashcard_session'
                    answered_card_ids: []
                    correct_card_ids: []
                    incorrect_card_ids: []
            Router.go("/flashcard_session/#{new_fc_session_id}/edit")






    Template.flashcard_session_edit.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'flashcard'
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.flashcard_session_edit.onRendered ->
        # Meteor.setTimeout ->
        #     $('.shape').shape();
        # , 1000
        Session.set('can_proceed', false)
        Session.set('viewing_front', true)
    Template.flashcard_session_edit.helpers
        viewing_front: ->
            Session.get('viewing_front')
        current_card_id: ->
            Session.get('current_card_id')
        current_card: ->
            if Session.get('current_card_id')
                Docs.findOne Session.get('current_card_id')
            else
                current_card = Docs.findOne {
                    model:'flashcard'
                }
                Session.set('current_card_id', current_card._id)
                Docs.findOne Session.get('current_card_id')

        can_proceed: ->
            Session.equals('can_proceed', true)
    Template.flashcard_session_edit.events
        'click .flip_card': ->
            $('.card').transition('scale right', 400)
            $('.card').transition('scale right', 400)
            Session.set('can_proceed', true)
            Session.set('viewing_front', !Session.get('viewing_front'))
            # Session.set('viewing_front', false)
            # $('.shape').shape('flip over');
        # 'click .shape': ->
        #     Session.set('can_proceed', true)
        #     $('.shape').shape('flip over');
        'click .cancel_session': ->
            if confirm 'cancel session?'
                Docs.remove Router.current().params.doc_id
                Router.go '/flashcards'
        'click .mark_correct': ->
            Session.set('viewing_front', true)
            current_card_id = Session.get('current_card_id')
            session = Docs.findOne Router.current().params.doc_id
            Docs.update session._id,
                $addToSet:
                    answered_card_ids: current_card_id
                    correct_card_ids: current_card_id
            next_card =
                Docs.findOne
                    model:'flashcard'
                    _id: $nin: session.answered_card_ids
            Session.set 'current_card_id', next_card._id
            Session.set('can_proceed', false)

            # $('.shape').shape('set default side');
            $('body').toast({
                class: 'success'
                message: 'marked correct'
            })



        'click .mark_incorrect': ->
            Session.set('viewing_front', true)
            current_card_id = Session.get('current_card_id')
            session = Docs.findOne Router.current().params.doc_id
            Docs.update session._id,
                $addToSet:
                    answered_card_ids: current_card_id
                    incorrect_card_ids: current_card_id
            next_card =
                Docs.findOne
                    model:'flashcard'
                    _id: $nin: session.answered_card_ids
            Session.set 'current_card_id', next_card._id
            $('body').toast({
                class: 'error'
                message: 'marked incorrect'
            })
            Session.set('can_proceed', false)

            # $('.shape').shape('set default side');


    Template.flashcard_session_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'flashcard'
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.flashcard_session_view.onRendered ->
    Template.flashcard_session_view.helpers
        flashcard_session_view: ->
            Docs.find {
                model:'flashcard'
            }, _timestamp:1
    Template.flashcard_session_view.events
        'click .calc_fc_session_stats': ->
            session = Docs.findOne Router.current().params.doc_id
            correct_count = session.correct_card_ids.length
            incorrect_count = session.incorrect_card_ids.length
            answered_count = session.answered_card_ids.length
            correct_percent = (correct_count/answered_count*100).toFixed()
            Docs.update session._id,
                $set:
                    correct_percent: correct_percent
                    answered_count:answered_count
                    correct_count:correct_count
                    incorrect_count:incorrect_count



    Template.card_small.helpers
        card: ->
            Docs.findOne Template.currentData()












    Template.flashcard_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.flashcard_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id





    Template.flashcard_stats.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'flashcard_stats'
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.flashcard_stats.onRendered ->
    Template.flashcard_stats.helpers
        fc_stats_doc: ->
            Docs.findOne {
                model:'flashcard_stats'
                _author_id: Meteor.userId()
            }, _timestamp:1
        ranked_amount_stats: ->
            Docs.find {
                model:'flashcard_stats'
            }, sort: fc_session_count: -1

        ranked_percent_stats: ->
            Docs.find {
                model:'flashcard_stats'
            }, sort: average_correct_percent_amount: -1


    Template.flashcard_stats.events
        'click .recalc_flashcard_stats': ->
            console.log @
            Meteor.call 'recalc_flashcard_stats', Meteor.userId()



if Meteor.isServer
    Meteor.methods
        recalc_flashcard_stats: (user_id)->
            console.log 'calc', user_id
            user = Meteor.users.findOne user_id
            fc_stats = Docs.findOne
                model:'flashcard_stats'
                _author_id: user_id
            unless fc_stats
                new_stats = Docs.insert
                    model:'flashcard_stats'
                fc_stats = Docs.findOne new_stats
            # user_count = Meteor.users.find().count()
            # teacher_count = Meteor.users.find(roles:$in:['teacher']).count()
            # donor_count = Meteor.users.find(roles:$in:['donor']).count()
            fc_sessions =
                Docs.find(
                    model:'flashcard_session'
                    _author_id: user_id
                )

            fc_session_count = fc_sessions.count()
            correct_card_amount = 0
            for session in fc_sessions.fetch()
                correct_card_amount += session.correct_count
            incorrect_card_amount = 0
            for session in fc_sessions.fetch()
                incorrect_card_amount += session.incorrect_count
            answered_card_amount = 0
            for session in fc_sessions.fetch()
                answered_card_amount += session.answered_count

            total_correct_percent_amount = 0
            for session in fc_sessions.fetch()
                total_correct_percent_amount += (session.correct_percent/100)
                # console.log 'correct percent', session.correct_percent
            # console.log 'total percent', total_correct_percent_amount
            average_correct_percent_amount = (total_correct_percent_amount/fc_session_count)*100
            # console.log 'average percent', average_correct_percent_amount

            authored_card_amount =
                Docs.find(
                    model:'flashcard'
                    _author_id: user_id
                ).count()


            Docs.update fc_stats._id,
                $set:
                    fc_session_count:fc_session_count
                    correct_card_amount:correct_card_amount
                    incorrect_card_amount:incorrect_card_amount
                    answered_card_amount:answered_card_amount
                    average_correct_percent_amount:average_correct_percent_amount
                    authored_card_amount:authored_card_amount
                    # incorrect sessions
                    # cards praciced
                    # session # ranking
                    # average session correct %
                    # cards authored
                    # correct tag cloud
                    # incorrect tag cloud
