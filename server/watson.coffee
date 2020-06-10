NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
{ IamAuthenticator } = require('ibm-watson/auth')

natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2019-07-12'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.language.apikey
    })
    url: Meteor.settings.private.language.url)


Meteor.methods
    call_visual_link: (doc_id, field)->
        self = @
        doc = Docs.findOne doc_id
        link = doc["#{field}"]

        params =
            url:link
            # images_file: images_file
            # classifier_ids: classifier_ids
        visual_recognition.classify params, Meteor.bindEnvironment((err, response)->
            if err
                console.log err
            else
                console.log(JSON.stringify(response, null, 2))
                Docs.update { _id: doc_id},
                    $set:
                        visual_classes: response.images[0].classifiers[0].classes
        )


    call_watson: (doc_id, key, mode) ->
        console.log 'calling watson'
        self = @
        # console.log doc_id
        # console.log key
        # console.log mode
        doc = Docs.findOne doc_id
        console.log 'calling watson on', doc.title, doc
        # if doc.skip_watson is false
        #     console.log 'skipping flagged doc', doc.title
        # else
        # console.log 'analyzing', doc.title, 'tags', doc.tags
        parameters =
            concepts:
                limit:20
            features:
                entities:
                    emotion: false
                    sentiment: false
                    mentions: false
                    limit: 20
                keywords:
                    emotion: false
                    sentiment: false
                    limit: 20
                concepts: {}
                # categories:
                #     explanation:false
                # emotion: {}
                # metadata: {}
                # relations: {}
                # semantic_roles: {}
                # sentiment: {}

        switch mode
            when 'html'
                # parameters.html = doc["#{key}"]
                parameters.html = doc.body
            when 'text'
                parameters.text = doc["#{key}"]
            when 'url'
                # parameters.url = doc["#{key}"]
                parameters.url = doc.url
                parameters.returnAnalyzedText = false
                parameters.clean = true
            when 'video'
                parameters.url = "https://www.reddit.com#{doc.permalink}"
                parameters.returnAnalyzedText = false
                parameters.clean = false
                # console.log 'calling video'
            when 'image'
                parameters.url = "https://www.reddit.com#{doc.permalink}"
                parameters.returnAnalyzedText = false
                parameters.clean = false
                # console.log 'calling image'

        # console.log 'parameters', parameters


        natural_language_understanding.analyze parameters, Meteor.bindEnvironment((err, response)=>
            if err
                # console.log 'watson error for', parameters.url
                # console.log err
                unless err.code is 403
                    Docs.update doc_id,
                        $set:skip_watson:false
                    # console.log 'not html, flaggged doc for future skip', parameters.url
                else
                    console.log '403 error api key'
            else
                # console.log 'analy text', response.analyzed_text
                # console.log(JSON.stringify(response, null, 2));
                # console.log 'adding watson info', doc.title
                response = response.result
                console.log response
                # console.log 'lowered keywords', lowered_keywords
                # if Meteor.isDevelopment
                #     console.log 'categories',response.categories
                # emotions = response.emotion.document.emotion
                #


                # adding_tags = []
                # if response.categories
                #     for category in response.categories
                #         # console.log category.label.split('/')[1..]
                #         # console.log category.label.split('/')
                #         for category in category.label.split('/')
                #             if category.length > 0
                #                 # adding_tags.push category
                #                 Docs.update doc_id,
                #                     $addToSet: categories: category
                # Docs.update { _id: doc_id },
                #     $addToSet:
                #         tags:$each:adding_tags
                if response.entities and response.entities.length > 0
                    for entity in response.entities
                        # console.log entity.type, entity.text
                        unless entity.type is 'Quantity'
                            # if Meteor.isDevelopment
                            #     console.log('quantity', entity.text)
                            # else
                            Docs.update { _id: doc_id },
                                $addToSet:
                                    # "#{entity.type}":entity.text
                                    tags:entity.text.toLowerCase()
                concept_array = _.pluck(response.concepts, 'text')
                lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                keyword_array = _.pluck(response.keywords, 'text')
                lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()

                keywords_concepts = lowered_keywords.concat lowered_keywords
                # Docs.update { _id: doc_id },
                #     $addToSet:
                #         tags:$each:lowered_concepts
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:keywords_concepts
                final_doc = Docs.findOne doc_id
                # console.log final_doc
                # if mode is 'url'
                #     Meteor.call 'call_tone', doc_id, 'body', 'text', ->
                # Meteor.call 'log_doc_terms', doc_id, ->
                Meteor.call 'clear_blocklist_doc', doc_id, ->
                # if Meteor.isDevelopment
                #     console.log 'all tags', final_doc.tags
                    # console.log 'final doc tag', final_doc.title, final_doc.tags.length, 'length'
        )
