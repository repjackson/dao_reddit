if Meteor.isClient
    Router.route '/tasks', (->
        @layout 'admin_layout'
        @render 'tasks'
        ), name:'tasks'
    Router.route '/task/:doc_id/view', (->
        @layout 'admin_layout'
        @render 'task_view'
        ), name:'task_view'
    Router.route '/task/:doc_id/edit', (->
        @layout 'admin_layout'
        @render 'task_edit'
        ), name:'task_edit'

    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe('task_facet_docs',
            selected_task_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'users_by_role', 'admin'

    Template.tasks.helpers
        tasks: ->
            Docs.find {
                model:'task'
            }, _timestamp:1


    Template.tasks.events
        'click .add_task': ->
            new_task_id =
                Docs.insert
                    model:'task'
            Session.set 'editing', new_task_id

        'click .edit': ->
            Session.set 'editing_id', @_id
        'click .save': ->
            Session.set 'editing_id', null





if Meteor.isClient
    Template.task_cloud.onCreated ->
        @autorun -> Meteor.subscribe('task_tags',
            selected_task_tags.array()
            Session.get('selected_target_id')
            )
        # @autorun -> Meteor.subscribe('model_docs', 'target')

    Template.task_cloud.helpers
        targets: ->
            Meteor.users.find
                admin:true
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: ->
            Docs.findOne Session.get('selected_target_id')
        all_task_tags: ->
            task_count = Docs.find(model:'task').count()
            if 0 < task_count < 3 then Task_tags.find { count: $lt: task_count } else Task_tags.find({},{limit:42})
        selected_task_tags: -> selected_task_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key

    Template.task_cloud.events
        'click .unselect_target': -> Session.set('selected_target_id',null)
        'click .select_target': -> Session.set('selected_target_id',@_id)
        'click .select_task_tag': -> selected_task_tags.push @name
        'click .unselect_task_tag': -> selected_task_tags.remove @valueOf()
        'click #clear_task_tags': -> selected_task_tags.clear()

if Meteor.isServer
    Meteor.publish 'task_tags', (selected_task_tags, selected_target_id)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd
        self = @
        match = {}

        if selected_target_id
            match.target_id = selected_target_id
        # selected_task_tags.push current_herd

        if selected_task_tags.length > 0 then match.tags = $all: selected_task_tags
        match.model = 'task'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_task_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'task_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'task_facet_docs', (selected_task_tags, selected_target_id)->
        # user = Meteor.users.findOne @userId
        console.log selected_task_tags
        # console.log filter
        self = @
        match = {}
        if selected_target_id
            match.target_id = selected_target_id


        # if filter is 'shop'
        #     match.active = true
        if selected_task_tags.length > 0 then match.tags = $all: selected_task_tags
        match.model = 'task'
        Docs.find match, sort:_timestamp:-1
