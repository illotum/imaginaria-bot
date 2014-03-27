# Description
#   The plugin will provide a picture and a link of the daily deal from Steam
#
# Dependencies:
#   "cheerio": "0.13.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot сделка дня - покажет сделку дня по мниению Steam
#
# Author:
#   illotum

cheerio = require('cheerio')
base = "http://store.steampowered.com"

getItems = (msg, location, parser, limit, callback) ->
  msg.http(location).get() (error,response, body) ->
    return msg.send "Something went wrong..." if error
    items = parser body
    callback items

parseDeals = (body, selector) ->
  $ = cheerio.load(body, {ignoreWhitespace: true})
  deal =
    image: $(".dailydeal img").attr('src').replace /[?].*/ , ''
    url: $(".dailydeal a").attr('href').replace /[?].*/ , ''
    discount: $(".dailydeal_content .discount_pct").text()

module.exports = (robot) ->
  location = base
  robot.respond /daily deal|сделка дня/i, (msg) ->
    getItems msg, location, parseDeals, 1, (deal) ->
      if deal.url
        msg.send "#{deal.discount} // #{deal.url} (#{deal.image})"
      else
        msg.send "Сегодня сделки дня нет"

