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
#   hubot блоги топ <N> - get the top N items on hacker news (or your favorite RSS feed)
#   блоги.топ - refer to the top item on hn
#   блоги[i] - refer to the ith item on hn
#
# Author:
#   illotum

NodePie = require("nodepie")

hnFeedUrl = "http://imaginaria.ru/rss"

module.exports = (robot) ->
  robot.respond /блоги топ (\d+)?/i, (msg) ->
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

  robot.hear /блоги(\.топ|\(\d+\))/i, (msg) ->
     msg.http(hnFeedUrl).get() (err, res, body) ->
       if res.statusCode is not 200
         msg.send "Something's gone awry"
       else
         feed = new NodePie(body)
         try
           feed.init()
         catch e
           console.log(e)
           msg.send "Something's gone awry"
         element = msg.match[1]
         if element == "имка.топ"
           idx = 0
         else
           idx = (Number) msg.match[0].replace(/[^0-9]/g, '')
         try
           item = feed.getItems()[idx]
           msg.send item.getTitle() + ": " + item.getPermalink() + " [" + item.getCategories() + "]"
         catch e
           console.log(e)
           msg.send "Something's gone awry"
