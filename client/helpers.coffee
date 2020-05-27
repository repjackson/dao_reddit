Template.registerHelper 'youtube_id', () ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
    match = @url.match(regExp)
    if (match && match[2].length == 11)
        console.log 'match 2', match[2]
        match[2]
    else
        console.log 'error'



Template.registerHelper 'is_streamable', () ->
    @domain is 'streamable.com'
Template.registerHelper 'is_youtube', () ->
    @domain is 'youtube.com'
