Meteor.methods
    afum: (alpha_id)->
        alpha = Docs.findOne alpha_id
        # model = Docs.findOne
        #     model:'model'
        #     slug:alpha.model_filter
        built_query = {}

        # fields =
        #     Docs.find
        #         model:'field'
        #         parent_id:model._id
        # if model.collection and model.collection is 'users'
        #     built_query.roles = $in:[alpha.model_filter]
        # else
        #     # unless alpha.model_filter is 'post'
        #     built_query.model = alpha.model_filter

        # if alpha.model_filter is 'model'
        #     unless 'dev' in Meteor.user().roles
        #         built_query.view_roles = $in:Meteor.user().roles

        if not alpha.facets
            # console.log 'no facets'
            Docs.update alpha_id,
                $set:
                    facets: [{
                        key:'_keys'
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



        for facet in alpha.facets
            if facet.filters.length > 0
                built_query["#{facet.key}"] = $all: facet.filters

        total = Docs.find(built_query).count()
        # if model.collection and model.collection is 'users'
        #     total = Meteor.users.find(built_query).count()
        # else
        #     total = Docs.find(built_query).count()
        # console.log 'built query', built_query
        # response
        for facet in alpha.facets
            values = []
            local_return = []

            agg_res = Meteor.call 'agg', built_query, facet.key
            # agg_res = Meteor.call 'agg', built_query, facet.key

            if agg_res
                Docs.update { _id:alpha._id, 'facets.key':facet.key},
                    { $set: 'facets.$.res': agg_res }
        if alpha.sort_key
            # console.log 'found sort key', alpha.sort_key
            sort_by = alpha.sort_key
        else
            sort_by = 'views'

        if alpha.sort_direction
            sort_direction = alpha.sort_direction
        else
            sort_direction = -1
        if alpha.limit
            limit = alpha.limit
        else
            limit = 5
        modifier =
            {
                fields:_id:1
                limit:limit
                sort:"#{sort_by}":sort_direction
            }

        # results_cursor =
        #     Docs.find( built_query, modifier )

        # if model and model.collection and model.collection is 'users'
        #     results_cursor = Meteor.users.find(built_query, modifier)
        #     # else
        #     #     results_cursor = global["#{model.collection}"].find(built_query, modifier)
        # else
        results_cursor = Docs.find built_query, modifier
        # if total is 1
        #     result_ids = results_cursor.fetch()
        # else
        #     result_ids = []
        result_ids = results_cursor.fetch()
        # console.log result_ids

        Docs.update {_id:alpha._id},
            {$set:
                total: total
                result_ids:result_ids
            }, ->
        return true

    count_children: (doc_id)->
        count = Docs.find(parent_id: doc_id).count()
        Docs.update doc_id,
            $set: child_count: count


    crawl: (specific_key)->
        start = Date.now()
        if specific_key
            filter =
                "#{specific_key}": $exists:true
                _keys: $nin: ["#{specific_key}"]
        else
            filter = {}
        found_cursor = Docs.find filter, { fields:{_id:1},limit:10000 }
        count = found_cursor.count()
        current_number = 0
        for found in found_cursor.fetch()
            res = Meteor.call 'detect_fields', found._id
            console.log 'detected',res, current_number, 'of', count
            current_number++
                # console.log Docs.findOne res
        stop = Date.now()
        diff = stop - start
        doc_count = found_cursor.count()
        console.log 'duration', moment(diff).format("HH:mm:ss:SS"), 'for', doc_count, 'docs'

    detect_fields: (doc_id)->
        doc = Docs.findOne doc_id
        keys = _.keys doc
        light_fields = _.reject( keys, (key)-> key.startsWith '_' )
        console.log light_fields
        Docs.update doc._id,
            $set:_keys:light_fields
        for key in light_fields
            value = doc["#{key}"]
            meta = {}
            js_type = typeof value
            console.log 'key type', key, js_type
            if js_type is 'object'
                meta.object = true
                if Array.isArray value
                    meta.array = true
                    meta.length = value.length
                    meta.array_element_type = typeof value[0]
                    meta.field = 'array'
                else
                    if key is 'watson'
                        meta.field = 'object'
                        # meta.field = 'watson'
                    else
                        meta.field = 'object'
            else if js_type is 'boolean'
                meta.boolean = true
                meta.field = 'boolean'
            else if js_type is 'number'
                meta.number = true
                d = Date.parse(value)
                # nan = isNaN d
                # !nan
                if value < 0
                    meta.negative = true
                else if value > 0
                    meta.positive = false

                integer = Number.isInteger(value)
                if integer
                    meta.integer = true
                meta.field = 'number'


            else if js_type is 'string'
                meta.string = true
                meta.length = value.length

                html_check = /<[a-z][\s\S]*>/i
                html_result = html_check.test value

                url_check = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
                url_result = url_check.test value

                youtube_check = /((\w|-){11})(?:\S+)?$/
                youtube_result = youtube_check.test value
                console.log youtube_result

                if key is 'html'
                    meta.html = true
                    meta.field = 'html'
                if key is 'youtube_id'
                    meta.youtube = true
                    meta.field = 'youtube'
                else if html_result
                    meta.html = true
                    meta.field = 'html'
                else if url_result
                    meta.url = true
                    image_check = (/\.(gif|jpg|jpeg|tiff|png)$/i).test value
                    if image_check
                        meta.image = true
                        meta.field = 'image'
                    else
                        meta.field = 'url'
                # else if youtube_result
                #     meta.youtube = true
                #     meta.field = 'youtube'
                else if Meteor.users.findOne value
                    meta.user_id = true
                    meta.field = 'user_ref'
                else if Docs.findOne value
                    meta.doc_id = true
                    meta.field = 'doc_ref'
                else if meta.length is 20
                    meta.field = 'image'
                else if meta.length > 20
                    meta.field = 'textarea'
                else
                    meta.field = 'text'

            Docs.update doc_id,
                $set: "_#{key}": meta

        # Docs.update doc_id,
        #     $set:_detected:1
        # console.log 'detected fields', doc_id

        return doc_id

    keys: (specific_key)->
        start = Date.now()
        if specific_key
            console.log 're-keying docs with', specific_key
            cursor = Docs.find({
                "#{specific_key}":$exists:true
                _keys:$exists:false
                }, { fields:{_id:1} })
            console.log 'found', found, 'docs with', specific_key
        else
            cursor = Docs.find({
                _keys:$exists:false
            }, { fields:{_id:1} })

        # cursor = Docs.find({ "#{specific_key}":$exists:true}, { fields:{_id:1} })

        found = cursor.count()

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

        stop = Date.now()

        diff = stop - start
        # console.log diff
        console.log 'duration', moment(diff).format("HH:mm:ss:SS")

    key: (doc_id)->
        doc = Docs.findOne doc_id

        keys = _.keys doc
        # console.log doc

        light_fields = _.reject( keys, (key)-> key.startsWith '_' )
        # console.log light_fields

        Docs.update doc._id,
            $set:_keys:light_fields

        console.log "keyed #{doc._id}"

    global_remove: (keyname)->
        console.log 'removing', keyname, 'globally'
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})
        console.log result
        console.log 'removed', keyname, 'globally'


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()
        console.log 'key count', count


    rename: (old, newk)->
        console.log 'start renaming', old, 'to', newk

        old_count = Docs.find({"#{old}":$exists:true}).count()
        console.log 'found',old_count,'of',old

        new_count = Docs.find({"#{newk}":$exists:true}).count()
        console.log 'found',new_count,'of',newk

        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})

        console.log 'mongo update call finished:',result

        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

        console.log 'done renaming', old, 'to', newk

        console.log 'result1', result
        console.log 'result2', result2


    remove: ->
        console.log 'start'
        result = Docs.update({}, {
            $unset: tag_count: 1
            }, {multi:true})
        console.log result


    tagify_date_time: (val)->
        console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
        minute = moment(val).minute()
        hour = moment(val).format('h')
        date = moment(val).format('Do')
        ampm = moment(val).format('a')
        weekdaynum = moment(val).isoWeekday()
        weekday = moment().isoWeekday(weekdaynum).format('dddd')

        month = moment(val).format('MMMM')
        year = moment(val).format('YYYY')

        date_array = [hour, minute, ampm, weekday, month, date, year]
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        return date_array
