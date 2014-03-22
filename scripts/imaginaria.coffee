# Description:
#  Imaginaria News
#
# Dependencies:
#   "nodepie": "0.5.0"
#
# Configuration:
#   None
#
# Commands:
#   топ <N> имки - получить топ <N> статей с имаджинарии
#
# Author:
#   illotum

NodePie = require("nodepie")

FeedUrl = "http://imaginaria.ru/rss"

module.exports = (robot) ->
  robot.respond /топ( \d+)? имки/i, (msg) ->
    msg.http(FeedUrl).get() (err, res, body) ->
      if res.statusCode is not 200
        msg.send "Something's gone awry"
      else
        feed = new NodePie(body)
        try
          feed.init()
          count = msg.match[1] || 5
          items = feed.getItems(0, count)
          msg.send "<a href=" + item.getPermalink() + ">" + item.getTitle() + "</a> [" + item.getCategories() + "]" for item in items
        catch e
          console.log(e)
          msg.send "Something's gone awry"
