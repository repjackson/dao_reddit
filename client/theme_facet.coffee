@selected_theme_tags = new ReactiveArray []

Template.tag_facet.helpers
    theme_tags: ->

        doc_count = Docs.find().count()
        # if selected_theme_tags.array().length
        if 0 < doc_count < 3
            Tags.find {
                # type:Template.currentData().type
                count: $lt: doc_count
                }, limit:20
        else
            cursor = Tags.find({}, limit:20)
            # console.log cursor.fetch()
            return cursor

    cloud_tag_class: ->
        button_class = []
        switch
            when @index <= 5 then button_class.push ' '
            when @index <= 10 then button_class.push 'small'
            when @index <= 15 then button_class.push 'tiny '
            when @index <= 20 then button_class.push ' mini'
        return button_class

    selected_theme_tags: -> selected_theme_tags.array()
    settings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Tags
                field: 'name'
                matchAll: false
                template: Template.tag_result
            }
            ]
    }



Template.tag_facet.events
    'click .select_theme_tag': -> selected_theme_tags.push @name
    'click .unselect_theme_tag': -> selected_theme_tags.remove @valueOf()
    'click #clear_theme_tags': -> selected_theme_tags.clear()

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_theme_tags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_theme_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_theme_tags.pop()

    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_theme_tags.push doc.name
        $('#search').val ''
