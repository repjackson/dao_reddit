NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
ToneAnalyzerV3 = require('ibm-watson/tone-analyzer/v3')
VisualRecognitionV3 = require('ibm-watson/visual-recognition/v3')
# PersonalityInsightsV3 = require('ibm-watson/personality-insights/v3')
# TextToSpeechV1 = require('ibm-watson/text-to-speech/v1')

{ IamAuthenticator } = require('ibm-watson/auth')



# textToSpeech = new TextToSpeechV1({
#   authenticator: new IamAuthenticator({
#     apikey: Meteor.settings.private.tts.apikey,
#   }),
#   url: Meteor.settings.private.tts.url,
# });




natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2019-07-12'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.language.apikey
    })
    url: Meteor.settings.private.language.url)

tone_analyzer = new ToneAnalyzerV3(
    version: '2017-09-21'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.tone.apikey
    })
    url: Meteor.settings.private.tone.url)


visual_recognition = new VisualRecognitionV3({
  version: '2018-03-19',
  authenticator: new IamAuthenticator({
    apikey: Meteor.settings.private.visual.apikey,
  }),
  url: Meteor.settings.private.visual.url,
});

# const classify_params = {
#   url: 'https://ibm.biz/BdzLPG',
# };


Meteor.methods
    call_tone: (doc_id, key, mode)->
        self = @
        doc = Docs.findOne doc_id
        # console.log key
        # console.log mode
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
        # console.log 'params', params
        tone_analyzer.tone params, Meteor.bindEnvironment((err, response)->
            if err
                console.log err
            else
                # console.dir response
                Docs.update { _id: doc_id},
                    $set:
                        tone: response
                # console.log(JSON.stringify(response, null, 2))
            )
        # else return

    call_visual: (doc_id, field)->
        self = @
        doc = Docs.findOne doc_id
        # link = doc["#{field}"]
        # visual_recognition.classify(classify_params)
        #   .then(response => {
        #     const classifiedImages = response.result;
        #     console.log(JSON.stringify(classifiedImages, null, 2));
        #   })
        #   .catch(err => {
        #     console.log('error:', err);
        #   });
        if doc.watson
            if doc.watson.metadata.image
                params =
                    url:doc.watson.metadata.image
        else
            params =
                url:doc.thumbnail
                # url:doc.url
            # images_file: images_file
            # classifier_ids: classifier_ids
        visual_recognition.classify params, Meteor.bindEnvironment((err, response)->
            if err
                console.log err
            else
                visual_tags = []
                for tag in response.result.images[0].classifiers[0].classes
                    visual_tags.push tag.class.toLowerCase()
                # console.log(JSON.stringify(response, null, 2))
                # console.log visual_tags
                Docs.update { _id: doc_id},
                    $set:
                        visual_classes: response.result.images[0].classifiers[0].classes
                        visual_tags:visual_tags
                    $addToSet:
                        tags:$each:visual_tags
        )

    call_watson: (doc_id, key, mode) ->
        # console.log 'calling watson'
        self = @
        # console.log doc_id
        # console.log key
        # console.log mode
        doc = Docs.findOne doc_id
        # console.log 'calling watson on', doc.title
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
                categories:
                    explanation:true
                # emotion: {}
                metadata: {}
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
                parameters.returnAnalyzedText = true
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
                console.log 'calling image'

        # console.log 'parameters', parameters


        natural_language_understanding.analyze parameters, Meteor.bindEnvironment((err, response)=>
            if err
                console.log 'watson error for', parameters.url
                # console.log err
                if err.code is 400
                    console.log 'sniff rejected by server'
                unless err.code is 403
                    Docs.update doc_id,
                        $set:skip_watson:false
                    console.log 'not html, flaggged doc for future skip', parameters.url
                else
                    console.log '403 error api key'
            else
                # console.log 'analy text', response.analyzed_text
                # console.log(JSON.stringify(response, null, 2));
                # console.log 'adding watson info', doc.title
                response = response.result
                # console.log response
                # console.log 'lowered keywords', lowered_keywords
                # if Meteor.isDevelopment
                #     console.log 'categories',response.categories
                # emotions = response.emotion.document.emotion

                # emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
                # # main_emotions = []
                # max_emotion_percent = 0
                # max_emotion_name = ''
                #
                # for emotion in emotion_list
                #     if emotions["#{emotion}"] > max_emotion_percent
                #         if emotions["#{emotion}"] > .5
                #             max_emotion_percent = emotions["#{emotion}"]
                #             max_emotion_name = emotion
                #             # console.log emotion_doc["#{emotion}_percent"]
                #             # main_emotions.push emotion
                #
                # console.log 'emotions', emotions
                # sadness_percent = emotions.sadness
                # joy_percent = emotions.joy
                # fear_percent = emotions.fear
                # anger_percent = emotions.anger
                # disgust_percent = emotions.disgust
                # console.log 'main_emotion', max_emotion_name
                # console.log 'max_emotion_percent', max_emotion_percent
                if mode is 'url'
                    Docs.update { _id: doc_id },
                        $set:
                            body:response.analyzed_text
                            watson: response
                            # max_emotion_name:max_emotion_name
                            # max_emotion_percent:max_emotion_percent
                            # sadness_percent: sadness_percent
                            # joy_percent: joy_percent
                            # fear_percent: fear_percent
                            # anger_percent: anger_percent
                            # disgust_percent: disgust_percent
                            watson_concepts: concept_array
                            watson_keywords: keyword_array
                            # doc_sentiment_score: response.sentiment.document.score
                            # doc_sentiment_label: response.sentiment.document.label



                adding_tags = []
                if response.categories
                    for category in response.categories
                        # console.log category.label.split('/')[1..]
                        # console.log category.label.split('/')
                        for category in category.label.split('/')
                            if category.length > 0
                                # adding_tags.push category
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
                if mode is 'url'
                    Meteor.call 'call_tone', doc_id, 'body', 'text', ->
                # Meteor.call 'log_doc_terms', doc_id, ->
                Meteor.call 'clear_blocklist_doc', doc_id, ->
                # if Meteor.isDevelopment
                #     console.log 'all tags', final_doc.tags
                    # console.log 'final doc tag', final_doc.title, final_doc.tags.length, 'length'
        )
