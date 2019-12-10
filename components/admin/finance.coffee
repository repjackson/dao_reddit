if Meteor.isClient
    Router.route '/finance', (->
        @layout 'admin_layout'
        @render 'finance'
        ), name:'finance'

    Template.finance.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'budget'
        @autorun -> Meteor.subscribe 'model_docs', 'debt'
        @autorun -> Meteor.subscribe 'model_docs', 'expense'

    Template.finance.helpers
        finance: ->
            Docs.find {
                model:'budget'
            }, _timestamp:1


    Template.expenses_small.helpers
        expenses: ->
            Docs.find {
                model:'expense'
            }, _timestamp:1


    Template.budgets_small.helpers
        budgets: ->
            Docs.find {
                model:'budget'
            }, _timestamp:1
    Template.budgets_small.events
        'click .add_budget': ->
            new_budget_id =
                Docs.insert
                    model:'budget'
            Session.set 'editing', new_budget_id



    Template.debts_small.helpers
        debts: ->
            Docs.find {
                model:'debt'
            }, _timestamp:1
    Template.debts_small.events
        'click .add_debt': ->
            new_debt_id =
                Docs.insert
                    model:'debt'
            Session.set 'editing', new_debt_id

        # 'click .edit': ->
        #     Session.set 'editing_id', @_id
        # 'click .save': ->
        #     Session.set 'editing_id', null
