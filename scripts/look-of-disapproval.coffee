# Description:
#   Allows Hubot to give a look of disapproval
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot <name> неправ - смотрит на пользователя как на ...
#
# Author:
#   ajacksified

module.exports = (robot) ->
  robot.respond /(.*) неправ/i, (msg) ->
    response = 'ಠ_ಠ'

    name = msg.match[1].trim()
    response +=
    if name == "я"
      msg.reply response
    else
      msg.send response + " @" + name if name != ""
