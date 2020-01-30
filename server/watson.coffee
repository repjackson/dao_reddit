NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
ToneAnalyzerV3 = require('ibm-watson/tone-analyzer/v3')
{ IamAuthenticator } = require('ibm-watson/auth')


tone_analyzer = new ToneAnalyzerV3(
    version: '2017-09-21'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.tone.apikey
    })
    url: Meteor.settings.private.tone.url)

natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2019-07-12'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.language.apikey
    })
    url: Meteor.settings.private.language.url)


Meteor.methods
    call_wiki: (query)->
        console.log 'calling wiki', query
        term = query.split(' ').join('_')
        found_doc =
            Docs.findOne
                url: "https://en.wikipedia.org/wiki/#{term}"
        if found_doc
            console.log 'found wiki doc for term', term, found_doc
            Docs.update found_doc._id,
                $addToSet:tags:'wikipedia'
            Meteor.call 'call_watson', found_doc._id, 'url','url', ->
        else
            new_wiki_id = Docs.insert
                title: "wikipedia: #{query}"
                tags:['wikipedia', query]
                url:"https://en.wikipedia.org/wiki/#{term}"
            Meteor.call 'call_watson', new_wiki_id, 'url','url', ->



    # call_tone:
    #     const toneParams = {
    #       toneInput: { 'text': text },
    #       contentType: 'application/json',
    #     };

    # toneAnalyzer.tone(toneParams)
    #   .then(toneAnalysis => {
    #     console.log(JSON.stringify(toneAnalysis, null, 2));
    #   })
    #   .catch(err => {
    #     console.log('error:', err);
    #   });

    call_tone: (doc_id, key, mode)->
        self = @
        doc = Docs.findOne doc_id
        console.log key
        console.log mode
        # if doc.html or doc.body
        #     # stringed = JSON.stringify(doc.html, null, 2)
        if mode is 'html'
            params =
                toneInput:doc["#{key}"]
                content_type:'text/html'
        if mode is 'text'
            params =
                toneInput: { 'text': doc.body }
                contentType: 'application/json'
        console.log 'params', params
        tone_analyzer.tone params, Meteor.bindEnvironment((err, response)->
            if err
                console.log err
            else
                console.dir response
                Docs.update { _id: doc_id},
                    $set:
                        tone: response
                # console.log(JSON.stringify(response, null, 2))
            )
        # else return


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
        # console.log 'value', doc["#{key}"]
        # if doc.skip_watson is true
        #     console.log 'skipping flagged doc', doc.title
        # else
        console.log 'analyzing', doc.title, 'tags', doc.tags
        parameters =
            concepts:
                limit:10
            features:
                entities:
                    emotion: false
                    sentiment: false
                    # limit: 2
                keywords:
                    emotion: false
                    sentiment: false
                    # limit: 2
                concepts: {}
                categories: {}
                emotion: {}
                metadata: {}
                # relations: {}
                # semantic_roles: {}
                sentiment: {}

        switch mode
            when 'html'
                # parameters.html = doc["#{key}"]
                parameters.html = doc.body
            when 'text'
                parameters.text = doc["#{key}"]
            when 'url'
                # parameters.url = doc["#{key}"]
                parameters.url = doc.url
                parameters.returnAnalyzedText = true
                parameters.clean = true
            when 'video'
                parameters.url = "https://www.reddit.com#{doc.permalink}"
                console.log 'calling video'



        # console.log 'parameters', parameters


        natural_language_understanding.analyze parameters, Meteor.bindEnvironment((err, response) ->
            if err
                # console.log 'watson error for', parameters.url
                console.log err
                unless err.code is 403
                    Docs.update doc_id,
                        $set:skip_watson:true
                    console.log 'not html, flaggged doc for future skip', parameters.url
                else
                    console.log '403 error api key'
            else
                # console.log 'analy text', response.analyzed_text
                # console.log(JSON.stringify(response, null, 2));
                # console.log 'adding watson info', doc.title
                response = response.result
                keyword_array = _.pluck(response.keywords, 'text')
                # lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()
                # console.log 'lowered keywords', lowered_keywords
                # if Meteor.isDevelopment
                #     console.log 'categories',response.categories
                adding_tags = []
                if response.categories
                    for category in response.categories
                        # console.log category.label.split('/')[1..]
                        # console.log category.label.split('/')
                        for category in category.label.split('/')
                            if category.length > 0
                                adding_tags.push category
                                Docs.update doc_id,
                                    $addToSet: categories: category
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:adding_tags
                if response.entities and response.entities.length > 0
                    for entity in response.entities
                        # console.log entity.type, entity.text
                        unless entity.type is 'Quantity'
                            # if Meteor.isDevelopment
                            #     console.log('quantity', entity.text)
                            # else
                            Docs.update { _id: doc_id },
                                $addToSet:
                                    "#{entity.type}":entity.text
                                    tags:entity.text.toLowerCase()
                concept_array = _.pluck(response.concepts, 'text')
                # lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                Docs.update { _id: doc_id },
                    $set:
                        body:response.analyzed_text
                        watson: response
                        watson_concepts: concept_array
                        watson_keywords: keyword_array
                        doc_sentiment_score: response.sentiment.document.score
                        doc_sentiment_label: response.sentiment.document.label
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:concept_array
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:keyword_array
                final_doc = Docs.findOne doc_id
                # console.log final_doc
                Meteor.call 'call_tone', doc_id, 'body', 'text', ->
                if Meteor.isDevelopment
                    # console.log 'all tags', final_doc.tags
                    console.log 'final doc tag', final_doc.title, final_doc.tags.length, 'length'
        )
