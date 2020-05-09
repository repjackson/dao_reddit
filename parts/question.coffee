if Meteor.isClient
    Router.route '/questions', (->
        @layout 'layout'
        @render 'questions'
        ), name:'questions'
    Router.route '/question/:doc_id/edit', (->
        @layout 'layout'
        @render 'question_edit'
        ), name:'question_edit'
    Router.route '/question/:doc_id/view', (->
        @layout 'layout'
        @render 'question_view'
        ), name:'question_view'

    Template.question_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'answer'
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.question_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'choice'
        @autorun => Meteor.subscribe 'model_docs', 'answer'

    Template.question_edit.events
        'click .add_choice': ->
            Docs.insert
                model:'choice'
                question_id:Router.current().params.doc_id
    Template.question_view.events
        'click .choose_choice': ->
            Docs.insert
                model:'answer'
                question_id:Router.current().params.doc_id
                choice_text:@text
                choice_id:@_id
        'click .refresh': ->
            Meteor.call 'calc_question_stats', Router.current().params.doc_id


    Template.question_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:Router.current().params.doc_id


    Template.question_view.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:Router.current().params.doc_id
        your_answer: ->
            Docs.findOne
                model:'answer'
                question_id:Router.current().params.doc_id
                _author_id:Meteor.userId()
        answers: ->
            Docs.find
                model:'answer'
                question_id:Router.current().params.doc_id



    Template.questions.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'question'
        @autorun => Meteor.subscribe 'all_users'

    Template.questions.helpers
        questions: ->
            Docs.find
                model:'question'
        users: ->
            Meteor.users.find({credit:$gt:1},
                sort:credit:-1)

    Template.questions.events
        'click .add_question': ->
            new_id =
                Docs.insert
                    model:'question'
            Router.go "/question/#{new_id}/edit"


# if Meteor.isServer
#     Meteor.methods
        # refresh_global_stats: ->
        #     found_stats = Docs.findOne
        #         model:'stats'
        #     if found_stats
        #         fsd = found_stats
        #     else
        #         new_id =
        #             Docs.insert
        #                 model:'stats'
        #         fsd = Docs.findOne new_id
        #
        #     total_doc_count = Docs.find({}).count()
        #     total_item_count = Docs.find({model:'item'}).count()
        #     total_sales_count =
        #         Docs.find(
        #             model:'item'
        #             bought:true
        #             ).count()
        #
        #     total_selling_count =
        #         Docs.find(
        #             model:'item'
        #             bought:$ne:true
        #             ).count()
        #     total_deposits =
        #         Docs.find(
        #             model:'deposit'
        #         )
        #     total_deposit_count =
        #         Docs.find(
        #             model:'deposit'
        #         ).count()
        #
        #     total_deposit_amount = 0
        #     for deposit in total_deposits.fetch()
        #         total_deposit_amount += deposit.deposit_amount
        #
        #     total_withdrawals =
        #         Docs.find(
        #             model:'withdrawal'
        #         )
        #     total_withdrawal_count =
        #         Docs.find(
        #             model:'withdrawal'
        #         ).count()
        #
        #     total_withdrawal_amount = 0
        #     for withdrawal in total_withdrawals.fetch()
        #         total_withdrawal_amount += withdrawal.amount
        #
        #     total_site_profit = total_deposit_amount-total_withdrawal_amount
        #
        #     Docs.update fsd._id,
        #         $set:
        #             total_doc_count:total_doc_count
        #             total_item_count:total_item_count
        #             total_selling_count:total_selling_count
        #             total_sales_count:total_sales_count
        #             total_deposit_count: total_deposit_count
        #             total_deposit_amount: total_deposit_amount
        #             total_withdrawal_amount: total_withdrawal_amount
        #             total_site_profit: total_site_profit
