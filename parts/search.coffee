if Meteor.isClient
    Router.route '/search', (->
        @layout 'layout'
        @render 'search'
        ), name:'search'
    Router.route '/search/:doc_id/edit', (->
        @layout 'layout'
        @render 'search_edit'
        ), name:'search_edit'
    Router.route '/search/:doc_id/view', (->
        @layout 'layout'
        @render 'search_view'
        ), name:'search_view'

    Template.search_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.search_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'answer'
    Template.search_view.helpers
        answers: ->
            search = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'answer'
        answer_doc: ->
            search = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                model:'answer'
                search_id:search._id
        has_answered: ->
            search = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                model:'answer'
                search_id:search._id
    Template.search_view.events
        'click .answer': ->
            search = Docs.findOne Router.current().params.doc_id
            new_id =
                Docs.insert
                    model:'answer'
                    search_id:search._id
            Session.set('editing_id', new_id)



    Template.search.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'search'
        @autorun => Meteor.subscribe 'all_users'

    Template.search.helpers
        past_searches: ->
            Docs.find {
                model:'search'
            }, sort:_timestamp:-1
        current_search: ->
            Docs.findOne Session.get('current_search_id')
    Template.search.events
        'click .run_query': ->
            Meteor.call 'run_search_query', Session.get('current_search_id')
        'click .select_query': ->
            Session.set('current_search_id', @_id)
        'click .add_search': ->
            new_id =
                Docs.insert
                    model:'search'
            Session.set('current_search_id', new_id)
            Router.go "/search/#{new_id}/edit"


if Meteor.isServer
    Meteor.methods
        run_search_query: (search_id)->
            found_query = Docs.findOne search_id
            Docs.update search_id,
                $set:
                    has_results:true

            found_users =
                Meteor.users.find
                    username:{$regex:"#{found_query.title}", $options: 'i'}

            Docs.update search_id,
                $set:
                    user_results:found_users.fetch()

            # total_doc_count = Docs.find({}).count()
            # total_item_count = Docs.find({model:'item'}).count()
            # total_sales_count =
            #     Docs.find(
            #         model:'item'
            #         bought:true
            #         ).count()
            #
            # total_selling_count =
            #     Docs.find(
            #         model:'item'
            #         bought:$ne:true
            #         ).count()
            # total_deposits =
            #     Docs.find(
            #         model:'deposit'
            #     )
            # total_deposit_count =
            #     Docs.find(
            #         model:'deposit'
            #     ).count()
            #
            # total_deposit_amount = 0
            # for deposit in total_deposits.fetch()
            #     total_deposit_amount += deposit.deposit_amount
            #
            # total_withdrawals =
            #     Docs.find(
            #         model:'withdrawal'
            #     )
            # total_withdrawal_count =
            #     Docs.find(
            #         model:'withdrawal'
            #     ).count()
            #
            # total_withdrawal_amount = 0
            # for withdrawal in total_withdrawals.fetch()
            #     total_withdrawal_amount += withdrawal.amount
            #
            # total_site_profit = total_deposit_amount-total_withdrawal_amount
            #
            # Docs.update fsd._id,
            #     $set:
            #         total_doc_count:total_doc_count
            #         total_item_count:total_item_count
            #         total_selling_count:total_selling_count
            #         total_sales_count:total_sales_count
            #         total_deposit_count: total_deposit_count
            #         total_deposit_amount: total_deposit_amount
            #         total_withdrawal_amount: total_withdrawal_amount
            #         total_site_profit: total_site_profit
