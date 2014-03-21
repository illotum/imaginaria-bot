# Description:
#   Messing around with the YouTube API.
#
# Commands:
#   hubot видео мне <query> - Возвращает линк на топовый результат поиска <query> на YouTube
module.exports = (robot) ->
  robot.respond /(youtube|yt|видео)( мне)? (.*)/i, (msg) ->
    query = msg.match[3]
    robot.http("http://gdata.youtube.com/feeds/api/videos")
      .query({
        orderBy: "relevance"
        'max-results': 15
        alt: 'json'
        q: query
      })
      .get() (err, res, body) ->
        videos = JSON.parse(body)
        videos = videos.feed.entry

        unless videos?
          msg.send "Не нашлось роликов по запросу \"#{query}\""
          return

        video  = msg.random videos
        video.link.forEach (link) ->
          if link.rel is "alternate" and link.type is "text/html"
            msg.send link.href

