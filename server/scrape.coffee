# cheerio = require('cheerio');
#
# Meteor.methods
#     duck_scrape: (query)->
#         console.log 'query', query
#         result = HTTP.get("https://duckduckgo.com/?q=#{query}");
#         console.log 'result', result
#         $ = cheerio.load(result.content);
#         # duck_results = $
#         duck_results = $('#links').html()
#         return duck_results
#
#     duck_search: (query)->
#         HTTP.get "https://api.duckduckgo.com/?q=#{query}&format=json",(err,res)->
#             console.log res
#         # https://api.duckduckgo.com/?q=x&format=json
#
# # //     getTime: function () {
# # //         result = HTTP.get("http://www.timeanddate.com/worldclock/city.html?n=136");
# # //         $ = cheerio.load(result.content);
# # //         CurrentTime = $('#ct').html();
# # //         return CurrentTime;
# # //     },
# # //       getTweets: function () {
# # //         result = HTTP.get("https://twitter.com/Royal_Arse/status/538330380273979393");
# # //         $ = cheerio.load(result.content);
# # //         var body = $('#stream-items-id > li:nth-child(n) > div > div > p').text();
# # //         return body;
# # //       },
# # //       duck:
# # // https://duckduckgo.com/?q=nanotech&t=h_&ia=web
# # //
# # //
# # // });
