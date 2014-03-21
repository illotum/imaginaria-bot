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
    response += " @" + name if name != ""

    msg.send(response)
