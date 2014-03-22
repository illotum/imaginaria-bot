#
# Description:
#   Last (or current) played song by a user in Last.fm
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_LASTFM_APIKEY
#
# Commands:
#   hubot что слушает <last FM user> - Возвращает текущий трек с ласт-фм
#   hubot что я слушаю - работает только если ваш ник совпадает с ником на ласт-фм
#
# Author:
#   guilleiguaran
#   sn0opy

getSong = (msg, user) ->
  apiKey = process.env.HUBOT_LASTFM_APIKEY
  msg.http('http://ws.audioscrobbler.com/2.0/?')
    .query(method: 'user.getrecenttracks', user: user, api_key: apiKey, format: 'json', limit: 1)
    .get() (err, res, body) ->
      results = JSON.parse(body)
      if results.error
        msg.send results.message
        return
      song = results.recenttracks.track[0]
      if song["@attr"].nowplaying
        msg.send "#{song.name} by #{song.artist['#text']}"
      else
        msg.send "Сейчас #{user} ничего не слушает"

module.exports = (robot) ->
  robot.respond /что слушает (.*)/i, (msg) ->
    name = msg.match[1].trim()
    getSong(msg, name)
  robot.respond /что я слушаю/i, (msg) ->
    getSong(msg, msg.message.user.name)
