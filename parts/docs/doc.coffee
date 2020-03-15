if Meteor.isClient
    Template.doc_card.onRendered ->
        Meteor.setTimeout ->
            $('.ui.embed').embed();
        , 1000

    Template.doc_card.onCreated ->
        @view_more = new ReactiveVar(false)
    Template.doc_card.events
        'click .collapse': (e,t)-> t.view_more.set(false)
        'click .goto_article': ->
            console.log @
            Meteor.call 'log_view', @_id, ->
            Router.go "/doc/#{@_id}/view"
        'click .expand': (e,t)->
            unless @tone
                Meteor.call 'call_tone', @_id, 'url', 'text', ->
            t.view_more.set(true)
        'click .toggle_tag': ->
            # console.log @
            if @valueOf() in selected_tags.array()
                selected_tags.remove(@valueOf())
            else
                Meteor.call 'call_wiki', @valueOf(), ->
                selected_tags.push(@valueOf())
        'click .call_watson': ->
            Meteor.call 'call_watson', @_id, 'url', 'url', ->
        'click .call_watson_image': ->
            Meteor.call 'call_watson', @_id, 'url', 'image', ->
        'click .pull_tone': ->
            Meteor.call 'call_tone', @_id, 'url', 'text', ->
        'click .print_me': ->
            console.log @
        'click .toggle_more': (e,t)->
            if t.view_more.get()
                t.view_more.set(false)
            else
                unless @tone
                    Meteor.call 'call_tone', @_id, 'url', 'text', ->
                t.view_more.set(true)
    Template.doc_card.helpers
        post_tag_class: ->
            if @valueOf() in selected_tags.array() then 'active' else ''
        view_more: ->
            Template.instance().view_more.get()
        has_thumbnail: ->
            # console.log @thumbnail
            @thumbnail not in ['self','default']

        two_tone: ->
            if @tone
                @tone.result.sentences_tone[..1]



    Template.doc_item.events
        'click .call_watson': ->
            Meteor.call 'call_watson', @_id, 'url', 'url'
        'click .call_watson_image': ->
            Meteor.call 'call_watson', @_id, 'url', 'image'
        'click .print_me': ->
            console.log @
        'click .goto_article': ->
            console.log @
            Meteor.call 'log_view', @_id, ->
            Router.go "/doc/#{@_id}/view"

    Template.doc_item.helpers
        has_thumbnail: ->
            # console.log @thumbnail
            @thumbnail not in ['self','default']

        first_three_tones: ->
            if @tone
                @tone.result.sentences_tone[..3]
