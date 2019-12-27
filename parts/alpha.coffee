if Meteor.isClient
    Router.route '/alpha', (->
        @layout 'layout'
        @render 'alpha'
        ), name:'alpha'

    Template.alpha.onCreated ->
        @autorun -> Meteor.subscribe 'my_alpha'


    Template.alpha.helpers
        selected_tags: -> selected_tags.list()

        current_alpha: ->
            Docs.findOne
                model:'alpha'
                # _author_id:Meteor.userId()


        global_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        single_doc: ->
            alpha = Docs.findOne model:'alpha'
            count = alpha.result_ids.length
            if count is 1 then true else false




    Template.alpha.events
        'click .create_alpha': (e,t)->
            Docs.insert
                model:'alpha'

        'click .print_alpha': (e,t)->
            alpha = Docs.findOne model:'alpha'
            console.log alpha

        'click .reset': ->
            alpha = Docs.findOne model:'alpha'
            Meteor.call 'fum', alpha._id, (err,res)->

        'click .delete_alpha': (e,t)->
            alpha = Docs.findOne model:'alpha'
            if alpha
                if confirm "delete  #{alpha._id}?"
                    Docs.remove alpha._id



        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()

        'keyup #search': (e)->
            switch e.which
                when 13
                    if e.target.value is 'clear'
                        selected_tags.clear()
                        $('#search').val('')
                    else
                        selected_tags.push e.target.value.toLowerCase().trim()
                        $('#search').val('')
                when 8
                    if e.target.value is ''
                        selected_tags.pop()


if Meteor.isServer
    Meteor.publish 'my_alpha', ->
        if Meteor.userId()
            Docs.find
                _author_id:Meteor.userId()
                model:'alpha'
        else
            Docs.find
                _author_id:null
                model:'alpha'
