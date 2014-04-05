# Description:
#  Imaginaria News
#
# Dependencies:
#   "cheerio": "0.13.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot топ <N> имки - получить топ <N> статей с имаджинарии
#   hubot новинки <N> имки - получить <N> новых статей с имаджинарии
#   hubot <T> на имке - получить первых пять статей с имки по тегу <T>
#
#
# Author:
#   illotum

cheerio = require('cheerio')
base = "http://imaginaria.ru/rss"

getFeed = (msg, location, count, callback) ->
  msg.http(location).get() (error,response, body) ->
    return msg.send "Something went wrong..." if error
    items = getItems body, count
    callback items

getItems = (body, count) ->
  $ = cheerio.load(body, {ignoreWhitespace : true, xmlMode: true})
  items = []
  $('item').slice(0, count - 1).each (idx, item) ->
    items.push
      title: $(this).find('title').text()
      link: $(this).find('link').text()
      categories: []
    $(this).find('category').each (idy, cat) ->
      items[idx].categories.push $(this).text()
  return items

module.exports = (robot) ->
  robot.respond /топ( \d+)? имки/i, (msg) ->
    location = base
    count = msg.match[1] || 5
    getFeed msg, location, count, (items) ->
      msg.send ("\"#{i.title}\" /#{i.categories.join(', ')}/ #{i.link}" for i in items).join("\n")

  robot.respond /новинки( \d+)? имки/i, (msg) ->
    location = base + "/new"
    count = msg.match[1] || 5
    now = new Date
    getFeed msg, location, count, (items) ->
      msg.send ("\"#{i.title}\" /#{i.categories.join(', ')}/ #{i.link}" for i in items).join("\n")

  robot.respond /(.+) на имке/i, (msg) ->
    location = base + "/tag/" + msg.match[1]
    count = 5
    now = new Date
    getFeed msg, location, count, (items) ->
      msg.send ("\"#{i.title}\" /#{i.categories.join(', ')}/ #{i.link}" for i in items).join("\n")
