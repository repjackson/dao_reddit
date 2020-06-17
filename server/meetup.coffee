Meteor.methods
    find_groups: (query)->
        # console.log 'searching reddit for', query
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=0",(err,response)=>
        HTTP.get "https://api.meetup.com/find/groups?q=#{query}&nsfw=0&limit=10",(err,response)=>
            console.log response.data
            if err then console.log err
            # else if response.data.data.dist > 1
            #     # console.log 'found data'
            #     # console.log 'data length', response.data.data.children.length
            #     _.each(response.data.data.children, (item)=>

    find_topics: (query)->
        # console.log 'searching reddit for', query
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=0",(err,response)=>
        HTTP.get "https://api.meetup.com/find/topics?query=#{query}&page=10",(err,response)=>
            console.log response.data
            if err then console.log err
            # else if response.data.data.dist > 1
            #     # console.log 'found data'
            #     # console.log 'data length', response.data.data.children.length
            #     _.each(response.data.data.children, (item)=>
