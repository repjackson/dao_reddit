if Meteor.isClient
    Template.test_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 2000
    Template.test_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'act_question'
    Template.test_edit.events
        'click .add_test_item': ->
            new_mi_id = Docs.insert
                model:'test_item'
            Router.go "/test/#{_id}/edit"

        'click .delete_questions': ->
            cursor =
                Docs.find
                    model:'act_question'
                    test_id:Router.current().params.doc_id
            for question in cursor.fetch()
                Docs.remove question._id

        'click .generate_questions': ->
            test = Docs.findOne Router.current().params.doc_id
            for index in [1..test.question_amount]
                # console.log index
                existing =
                    Docs.findOne
                        model:'act_question'
                        test_id:Router.current().params.doc_id
                        number: index
                unless existing
                    Docs.insert
                        model:'act_question'
                        test_id:Router.current().params.doc_id
                        number: index


    Template.test_edit.helpers
        # test_questions: ->
        #     Docs.find {
        #         _id: $in: @question_ids
        #     }, sort: number: -1

        is_odd: -> @number % 2 isnt 0

        test_questions: ->
            Docs.find {
                model:'act_question'
                test_id: Router.current().params.doc_id
            }, sort:number:1
