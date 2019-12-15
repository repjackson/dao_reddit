Template.clear_value.events
    'click .clear_value': ->
        if confirm "Clear #{@title} field?"
            if @direct
                parent = Template.parentData()
            else
                parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1
            else if user
                Meteor.users.update parent._id,
                    $unset:"#{@key}":1



Template.array_edit.events
    'keyup .new_element': (e,t)->
        if e.which is 13
            element_val = t.$('.new_element').val().trim()
            if @direct
                parent = Template.parentData()
            else
                parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $addToSet:"#{@key}":element_val
            else if user
                Meteor.users.update parent._id,
                    $addToSet:"#{@key}":element_val
            t.$('.new_element').val('')

    'click .remove_element': (e,t)->
        element = @valueOf()
        field = Template.currentData()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $pull:"#{field.key}":element
        else if user
            Meteor.users.update parent._id,
                $pull:"#{field.key}":element

        t.$('.new_element').focus()
        t.$('.new_element').val(element)


# Template.textarea.onCreated ->
#     @editing = new ReactiveVar false

# Template.textarea.helpers
#     ising: -> Template.instance().editing.get()


Template.textarea_edit.events
    # 'click .toggle': (e,t)->
    #     t.editing.set !t.editing.get()

    'blur .edit_textarea': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":textarea_val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":textarea_val


Template.text_edit.onRendered ->
    Meteor.setTimeout ->
        $('.info').popup(
            preserve:true;
            hoverable:false;
        )
    , 1000

Template.text_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            if @key
                Docs.update parent._id,
                    $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.boolean_edit.helpers
    boolean_toggle_class: ->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        if parent["#{@key}"] then 'active' else ''


Template.boolean_edit.events
    'click .toggle_boolean': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        # $(e.currentTarget).closest('.button').transition('pulse', 100)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]



Template.textarea_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000
