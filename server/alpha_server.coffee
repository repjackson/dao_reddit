Meteor.methods
    set_afacets: (model_slug)->
        if Meteor.userId()
            alpha = Docs.findOne
                model:'alpha_session'
                _author_id:Meteor.userId()
        else
            alpha = Docs.findOne
                model:'alpha_session'
                _author_id:null
        # console.log 'alpha doc', alpha

        # if model_slug is alpha.model_filter
        #     return
        # else
        # fields =
        #     Docs.find
        #         model:'field'
        #         parent_id:model._id

        # Docs.update model._id,
        #     $inc: views: 1

        # console.log 'fields', fields.fetch()

        Docs.update alpha._id,
            $set:model_filter:'alpha'

        # Docs.update alpha._id,
        #     $set:facets:[
        #         {
        #             key:'_timestamp_tags'
        #             filters:[]
        #             res:[]
        #         }
        #     ]
        Docs.update alpha._id,
            $set:facets:[{
                title:'keys'
                icon:'key'
                key:'keys'
                rank:1
                field_type:'array'
                filters:[]
                res:[]
            }]
        # for field in fields.fetch()
        #     if field.faceted is true
        #         # console.log field
        #         # if Meteor.user()
        #         # console.log _.intersection(Meteor.user().roles,field.view_roles)
        #         # if _.intersection(Meteor.user().roles,field.view_roles).length > 0
        #         Docs.update alpha._id,
        #             $addToSet:
        #                 facets: {
        #                     title:field.title
        #                     icon:field.icon
        #                     key:field.key
        #                     rank:field.rank
        #                     field_type:field.field_type
        #                     filters:[]
        #                     res:[]
        #                 }

        # field_ids = _.pluck(fields.fetch(), '_id')

        # Docs.update alpha._id,
        #     $set:
        #         viewable_fields: field_ids
        Meteor.call 'afum', alpha._id


    afum: (alpha_id)->
        alpha_session = Docs.findOne alpha_id

        # model = Docs.findOne
        #     model:'alpha'
        #     slug:alpha.model_filter

        # console.log 'running fum,', alpha, model
        built_query = {}
        if alpha_session.search_query
            built_query.title = {$regex:"#{alpha_session.search_query}", $options: 'i'}

        # fields =
        #     Docs.find
        #         model:'field'
        #         parent_id:model._id
        built_query.model = 'alpha'

        # if alpha.model_filter is 'model'
        #     unless 'dev' in Meteor.user().roles
        #         built_query.view_roles = $in:Meteor.user().roles

        if not alpha_session.facets
            console.log 'no facets'
            Docs.update alpha_id,
                $set:
                    facets: [{
                        key:'keys'
                        filters:[]
                        res:[]
                    }
                    # {
                    #     key:'_timestamp_tags'
                    #     filters:[]
                    #     res:[]
                    # }
                    ]

            alpha.facets = [
                key:'_keys'
                filters:[]
                res:[]
            ]



        for facet in alpha_session.facets
            if facet.filters.length > 0
                built_query["#{facet.key}"] = $all: facet.filters

        total = Docs.find(built_query).count()
        # console.log 'built query', built_query
        # response
        for facet in alpha_session.facets
            values = []
            local_return = []

            agg_res = Meteor.call 'aagg', built_query, facet.key
            # agg_res = Meteor.call 'aagg', built_query, facet.key

            if agg_res
                Docs.update { _id:alpha_session._id, 'facets.key':facet.key},
                    { $set: 'facets.$.res': agg_res }
        # if alpha.sort_key
        #     # console.log 'found sort key', alpha.sort_key
        #     sort_by = alpha.sort_key
        # else
        #     sort_by = 'views'
        #
        # if alpha.sort_direction
        #     sort_direction = alpha.sort_direction
        # else
        #     sort_direction = -1
        # if alpha.limit
        #     limit = alpha.limit
        # else
        #     limit = 10
        modifier =
            {
                fields:_id:1
                limit:10
                # sort:"#{sort_by}":sort_direction
            }

        # results_cursor =
        #     Docs.find( built_query, modifier )

        results_cursor = Docs.find built_query, modifier


        # if total is 1
        #     result_ids = results_cursor.fetch()
        # else
        #     result_ids = []
        result_ids = results_cursor.fetch()
        # console.log result_ids

        Docs.update {_id:alpha_session._id},
            {$set:
                total: total
                result_ids:result_ids
            }, ->
        return true


        # alpha = Docs.findOne alpha_id

    aagg: (query, key)->
        # console.log 'running agg', query
        limit=20
        options = { explain:false }
        pipe =  [
            { $match: query }
            { $project: "#{key}": 1 }
            { $unwind: "$#{key}" }
            { $group: _id: "$#{key}", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
        else
            return null
