if Meteor.isClient
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
