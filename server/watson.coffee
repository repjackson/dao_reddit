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
    call_watson: (doc_id, key, mode) ->
        # console.log 'calling watson'
        self = @
        # console.log doc_id
        # console.log key
        # console.log mode
        doc = Docs.findOne doc_id
        # console.log 'value', doc["#{key}"]
        # if doc.skip_watson is true
        #     console.log 'skipping flagged doc', doc.title
        # else
        # console.log 'analyzing', doc.title, 'tags', doc.tags
        parameters =
            concepts:
                limit:10
            features:
                entities:
                    emotion: false
                    sentiment: false
                    mentions: false
                    # limit: 2
                keywords:
                    emotion: false
                    sentiment: false
                    # limit: 2
                concepts: {}
                categories:
                    explanation:false
                # emotion: {}
                # metadata: {}
                # relations: {}
                # semantic_roles: {}
                # sentiment: {}

        if doc.is_video or doc.is_image or doc.is_twitter
            console.log 'lookup comments'
            parameters.url = "https://www.reddit.com#{doc.permalink}"
            parameters.returnAnalyzedText = true
            parameters.clean = true

        else
            console.log 'lookup site'
            parameters.url = doc.url
            parameters.returnAnalyzedText = true
            parameters.clean = true

            # when 'html'
            #     # parameters.html = doc["#{key}"]
            #     parameters.html = doc.body
            # when 'text'
            #     parameters.text = doc["#{key}"]
            # when 'url'
            #     # parameters.url = doc["#{key}"]
            #     # parameters.url = doc.url
            #     parameters.url = "https://www.reddit.com#{doc.permalink}"
            #     parameters.returnAnalyzedText = true
            #     parameters.clean = true
            # when 'video'
            #     parameters.url = "https://www.reddit.com#{doc.permalink}"
            #     parameters.returnAnalyzedText = true
            #     parameters.clean = true
            #     console.log 'calling video'
            # when 'image'
            #     parameters.url = "https://www.reddit.com#{doc.permalink}"
            #     parameters.returnAnalyzedText = true
            #     parameters.clean = true
            #     console.log 'calling image'

        # switch mode
        #     when 'html'
        #         # parameters.html = doc["#{key}"]
        #         parameters.html = doc.body
        #     when 'text'
        #         parameters.text = doc["#{key}"]
        #     when 'url'
        #         # parameters.url = doc["#{key}"]
        #         # parameters.url = doc.url
        #         parameters.url = "https://www.reddit.com#{doc.permalink}"
        #         parameters.returnAnalyzedText = true
        #         parameters.clean = true
        #     when 'video'
        #         parameters.url = "https://www.reddit.com#{doc.permalink}"
        #         parameters.returnAnalyzedText = true
        #         parameters.clean = true
        #         console.log 'calling video'
        #     when 'image'
        #         parameters.url = "https://www.reddit.com#{doc.permalink}"
        #         parameters.returnAnalyzedText = true
        #         parameters.clean = true
        #         console.log 'calling image'
        #
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
                lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()
                # console.log 'lowered keywords', lowered_keywords
                # if Meteor.isDevelopment
                #     console.log 'categories',response.categories
                # emotions = response.emotion.document.emotion

                # emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
                # main_emotions = []
                # for emotion in emotion_list
                #     if emotions["#{emotion}"] > .5
                #         # console.log emotion_doc["#{emotion}_percent"]
                #         main_emotions.push emotion

                # console.log 'emotions', emotions
                # sadness_percent = emotions.sadness
                # joy_percent = emotions.joy
                # fear_percent = emotions.fear
                # anger_percent = emotions.anger
                # disgust_percent = emotions.disgust
                # console.log 'main_emotions', main_emotions


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
                lowered_adding_tags = []
                for tag in adding_tags
                    lowered_adding_tags.push tag.toLowerCase()

                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:lowered_adding_tags
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
                lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                # Docs.update { _id: doc_id },
                #     $set:
                #         body:response.analyzed_text
                #         watson: response
                #         # sadness_percent: sadness_percent
                #         # joy_percent: joy_percent
                #         # fear_percent: fear_percent
                #         # anger_percent: anger_percent
                #         # disgust_percent: disgust_percent
                #         # concepts: concept_array
                #         # keywords: keyword_array
                #         # doc_sentiment_score: response.sentiment.document.score
                #         # doc_sentiment_label: response.sentiment.document.label
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:lowered_concepts
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:lowered_keywords

                # lowered_tags = []
                # for tag in doc.tags
                #     lowered_tags.push tag.toLowerCase()
                #
                # Docs.update { _id: doc_id },
                #     $set:
                #         tags:lowered_tags

                final_doc = Docs.findOne doc_id
                console.log 'final doc', final_doc.tags
                # Meteor.call 'call_tone', doc_id, 'body', 'text', ->
                # if Meteor.isDevelopment
                    # console.log 'all tags', final_doc.tags
                    # console.log 'final doc tag', final_doc.title, final_doc.tags.length, 'length'
        )


    analyze_entities: (doc_id, key) ->
        console.log 'analyzing entities'
        self = @
        # console.log doc_id
        # console.log key
        # console.log mode
        doc = Docs.findOne doc_id
        # console.log 'value', doc["#{key}"]
        # console.log 'analyzing', doc.title, 'tags', doc.tags

        if doc.body
            parameters =
                text: doc.body
                features:
                    entities:
                        emotion: true
                        sentiment: true
                        mentions: true
                        # limit: 2

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
                    # emotions = response.emotion.document.emotion

                    adding_tags = []
                    if response.entities and response.entities.length > 0
                        for entity in response.entities
                            # console.log entity.type, entity.text
                            Docs.update { _id: doc_id },
                                $set:
                                    watson: response
                                $addToSet:
                                    "#{entity.type}":entity.text
                                    tags:entity.text.toLowerCase()
                    final_doc = Docs.findOne doc_id
                    console.log 'analyzed entities', doc.watson.entities
                    # if Meteor.isDevelopment
                        # console.log 'all tags', final_doc.tags
                        # console.log 'final doc tag', final_doc.title, final_doc.tags.length, 'length'
            )

        else
            console.log 'no body found'
