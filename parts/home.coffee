if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    Router.route '/section/:doc_id/edit', (->
        @layout 'layout'
        @render 'section_edit'
        ), name:'section_edit'
    Router.route '/section/:doc_id/view', (->
        @layout 'layout'
        @render 'section_view'
        ), name:'section_view'

    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id



    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'section'

    Template.home.helpers
        sections: ->
            Docs.find {
                model:'section'
            }, sort:title:1

    Template.home.events
        'click .cancel': ->
            if confirm 'cancal prime'
                Meteor.users.update Meteor.userId(),
                    $inc:credit:1
                    $set:prime:false

        'click .get_prime': ->
            if confirm 'get prime'
                Meteor.users.update Meteor.userId(),
                    $inc:credit:-1
                    $set:prime:true
        'click .add_section': ->
            new_id =
                Docs.insert
                    model:'section'
            Router.go "/section/#{new_id}/edit"



    Template.layout.onCreated ->
        @autorun => Meteor.subscribe 'section_search', Session.get('current_global_query')
        @autorun => Meteor.subscribe 'model_docs', 'section'

    Template.nav.helpers
        results: ->
            search = Session.get('current_global_query')
            found_sections =
                Docs.find(
                    model:'section'
                    title:{$regex:"#{search}", $options: 'i'}
                ).fetch()


    Template.nav.events
        # 'keyup .global_search': _.throttle((e,t)->
        'keyup .global_search': (e,t)->
            # query = $('#search').val()
            search = $('.global_search').val().toLowerCase()
            Session.set('current_global_query', search)
            console.log Session.get('current_global_query')
            found_sections =
                Docs.find(
                    model:'section'
                    title:{$regex:"#{search}", $options: 'i'}
                ).fetch()
            if search.length > 2 and found_sections.length is 1
                # console.log found_sections[0]
                # selection = found_sections[0]
                Router.go "/#{found_sections[0].link}"
        		$('.ui.basic.modal').modal('toggle')
        # , 500)

            # console.log found_sections.fetch()
            # if e.which is 13
            #     if search.length > 0
            #         selected_tags.push search
            #         console.log 'search', search
            #         # Meteor.call 'log_term', search, ->
            #         $('#search').val('')
            #         Session.set('current_query', null)
            #         # # $('#search').val('').blur()
            #         # # $( "p" ).blur();
            #         # Meteor.setTimeout ->
            #         #     Session.set('dummy', !Session.get('dummy'))
            #         # , 10000




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
