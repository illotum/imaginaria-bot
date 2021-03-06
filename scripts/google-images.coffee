# Description:
#   A way to interact with the Google Images API.
#
# Commands:
#   hubot покажи мне <query> - Ищет <query> через Google Images и возвращает случайный результат.
#   hubot анимируй мне <query> - То же что и 'покажи мне', но пытается сформировать поиск так, чтобы выдало гифку.
#   hubot mustache me <url> - Adds a mustache to the specified URL.
#   hubot mustache me <query> - Searches Google Images for the specified query and mustaches it.

module.exports = (robot) ->
  robot.respond /(?:покажи|image)(?: мне| me)? (.*)/i, (msg) ->
    imageMe msg, msg.match[1], (url) ->
      msg.send url

  robot.respond /(?:анимируй|animate)(?: мне| me)? (.*)/i, (msg) ->
    imageMe msg, msg.match[1], true, (url) ->
      msg.send url

  robot.respond /(?:mo?u)?sta(?:s|c)he?(?: me)? (.*)/i, (msg) ->
    type = Math.floor(Math.random() * 6)
    mustachify = "http://mustachify.me/#{type}?src="
    imagery = msg.match[1]

    if imagery.match /^https?:\/\//i
      msg.send "#{mustachify}#{imagery}"
    else
      imageMe msg, imagery, false, true, (url) ->
        msg.send "#{mustachify}#{url}"

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image  = msg.random images
        cb "#{image.unescapedUrl}#.png"

