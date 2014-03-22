# Description:
#   Calm down
#
# Configuration:
#   HUBOT_LESS_MANATEES
#
# Commands:
#   hubot calm me | manatee me - Reply with Manatee
#   calm down | simmer down | that escalated quickly - Reply with Manatee
#   ALL CAPS | LONGCAPS - Reply with Manatee

module.exports = (robot) ->
  manatee = ->
    num = Math.floor(Math.random() * 30) + 1
    "http://calmingmanatee.com/img/manatee#{ num }.jpg"

  robot.respond /manatee|calm( me)?/i, (msg) -> msg.send manatee()

  robot.hear /calm down|simmer down|that escalated quickly|успокойся|не кипятись|угомонись|остынь/i, (msg) ->
    msg.send manatee()

  unless process.env.HUBOT_LESS_MANATEES
    robot.hear ///
      (\b([A-Z]{2,}\s+)([A-Z]{2,})\b)|
      (\b[A-Z]{6,}\b)|
      (\b([А-ЯЁ]{3,}\s+)([А-ЯЁ]{3,})\b)|
      ([А-ЯЁ]{10,})
    ///, (msg) -> msg.send manatee()
