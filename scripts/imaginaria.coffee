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
#   топ <N> имки - get the top N items on hacker news (or your favorite RSS feed)
#
# Author:
#   illotum

NodePie = require("nodepie")

hnFeedUrl = "http://imaginaria.ru/rss"

module.exports = (robot) ->
  robot.hear /топ[ ]?(\d+)? имки/i, (msg) ->
    msg.http(hnFeedUrl).get() (err, res, body) ->
      if res.statusCode is not 200
        msg.send "Something's gone awry"
      else
        feed = new NodePie(body)
        try
          feed.init()
          count = msg.match[1] || 5
          items = feed.getItems(0, count)
          msg.send item.getTitle() + ": " + item.getPermalink() + " [" + item.getCategories() + "]" for item in items
        catch e
          console.log(e)
          msg.send "Something's gone awry"
