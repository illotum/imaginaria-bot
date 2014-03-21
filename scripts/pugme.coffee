# Description:
#   Pugme is the most important thing in your life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot мопса мне - получить мопса
#   hubot N мопсов мне - получить N мопсов

module.exports = (robot) ->

  robot.respond /(?:pug|мопса)(?: me| мне)?/i, (msg) ->
    msg.http("http://pugme.herokuapp.com/random")
      .get() (err, res, body) ->
        msg.send JSON.parse(body).pug

  robot.respond /( (\d+))?(?:pug|мопсов)(?: me| мне)?/i, (msg) ->
    count = msg.match[2] || 5
    msg.http("http://pugme.herokuapp.com/bomb?count=" + count)
      .get() (err, res, body) ->
        msg.send pug for pug in JSON.parse(body).pugs

  robot.respond /(how many pugs are there|сколько там тех мопсов)/i, (msg) ->
    msg.http("http://pugme.herokuapp.com/count")
      .get() (err, res, body) ->
        msg.send "Я насчитала #{JSON.parse(body).pug_count} мопсов."

