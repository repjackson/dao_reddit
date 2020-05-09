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



    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'section'
        @autorun => Meteor.subscribe 'model_docs', 'log'
        @autorun => Meteor.subscribe 'model_docs', 'global_settings'

    Template.home.helpers
        sections: ->
            Docs.find {
                model:'section'
            }, sort:title:1

        tail_log: ->
            Docs.find
                model:'log'

        result: ->
            Docs.findOne
                model:'omega'

    Template.home.events
        'keyup .fin': (e,t)->
            if e.which is 13
                val = t.$('.fin').val().trim()
                console.log val
                o =
                    Docs.findOne
                        model:'omega'
                Meteor.call 'omega', (o)->
                    alert 'omega'



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



    Template.color_changer.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'purchase'
    Template.color_changer.helpers
        color_changes: ->
            Docs.find {
                model:'purchase'
                type:'color_change'
            },
                sort:_timestamp:-1
                limit:5
    Template.choose_nav_color.events
        'click .choose_class': ->
            global_settings = Docs.findOne model:'global_settings'
            Docs.update global_settings._id,
                $set: nav_color:@color
            Docs.insert
                model:'purchase'
                type:'color_change'
                color:@color
                tags: ['nav','settings','global','penny']
            Meteor.users.update Meteor.userId(),
                $inc: credit:-.01


    Template.layout.onCreated ->
        @autorun => Meteor.subscribe 'section_search', Session.get('current_global_query')
        @autorun => Meteor.subscribe 'model_docs', 'section'

    Template.nav.helpers
        current_query: ->
            search = Session.get('current_global_query')
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
            # console.log Session.get('current_global_query')
            found_sections =
                Docs.find(
                    model:'section'
                    title:{$regex:"#{search}", $options: 'i'}
                ).fetch()
            if search.length > 2 and found_sections.length is 1
                # console.log found_sections[0]
                # selection = found_sections[0]
                $('.global_search').val('')
                $('.global_search').blur()
                Session.set('current_global_query', null)
                Router.go "/#{found_sections[0].link}"
        		# $('.ui.basic.modal').modal('toggle')
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




if Meteor.isServer
    Meteor.methods
        fo: (o_doc)->
            console.log o_doc
