Meteor.methods
    get_ph_video_by_id: (id)->
        # console.log id
        HTTP.get "http://www.pornhub.com/webmasters/video_by_id?id=#{id}&thumbsize=medium", (err,res)->
            if err then console.error err
            else
                vid = res.data.video
                console.log vid

                found_vid =
                    Docs.findOne
                        model:'ph'
                        video_id:id
                if found_vid
                    console.log 'found vid', found_vid
                    return "/ph/#{found_vid._id}/view"
                else
                    new_ph =
                        Docs.insert
                            model:'ph'
                            duration:vid.duration
                            views:vid.views
                            video_id:vid.video_id
                            rating:vid.rating
                            ratings:vid.ratings
                            title:vid.title
                            url:vid.url
                            default_thumb:vid.default_thumb
                            thumb:vid.thumb
                            publish_date:vid.publish_date
                    return "/ph/#{new_ph}/view"

      #
      #                 "duration": "5:12",
      #                 "views": "58571",
      #                 "video_id": "965909603",
      #                 "rating": "84.62",
      #                 "ratings": 65,
      #                 "title": "Horny Valerie Shows Her Ass And Pussy In Public",
      #                 "url": "http://www.pornhub.com/view_video.php?viewkey=965909603",
      #                 "default_thumb": "http://i0.cdn2a.image.pornhub.phncdn.com/m=eGcE8daaaa/videos/201308/15/16162042/original/12.jpg",
      #                 "thumb": "http://i0.cdn2a.image.pornhub.phncdn.com/m=eGcE8daaaa/videos/201308/15/16162042/original/7.jpg",
      #                 "publish_date": "2013-08-20 14:45:06",
      # "thumbs": [
      #   {
      #     "size": "medium",
      #     "width": "240",
      #     "height": "180",
      #     "src": "http://i0.cdn2a.image.pornhub.phncdn.com/m=eGcE8daaaa/mh=plcUt4NpSn0JLzDq/videos/201308/15/16162042/original/1.jpg"
      #   }
      # ],
      # "tags": [
      #   {
      #     "tag_name": "outdoors"
      #   },
      #   {
      #     "tag_name": "public"
      #   }
      # ],
      # "pornstars": [
      #
      # ]









    search_ph: (query)->
        # console.log id
        HTTP.get "http://www.pornhub.com/webmasters/search?search=#{query}&tags[]=Teen&thumbsize=medium", (err,res)->
            if err then console.error err
            else
                # rd = res.data.data.children[0].data
                console.log res
