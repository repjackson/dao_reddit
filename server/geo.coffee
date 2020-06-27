Meteor.methods
    tag_coordinates: (doc_id, lat,long)->
        # HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=#{lat}%2C#{long}&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1",(err,response)=>
        HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=24.77701%2C%20121.02189&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1",(err,response)=>
            console.log response.data
            if err then console.log err
            else
                console.log 'working'

        # https://api.opencagedata.com/geocode/v1/json?q=24.77701%2C%20121.02189&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1
        # https://api.opencagedata.com/geocode/v1/json?q=Dhumbarahi%2C%20Kathmandu&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1
