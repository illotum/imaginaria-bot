# Description:
#   Allows Hubot to roll dice
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   =<x>d<y>+<z> - бросить <x> <y>-гранников и добавить <z>. ПОЛОМАНО
#
# Author:
#   ab9

module.exports = (robot) ->
  robot.hear /\=(\d+)d(\d+)([-+*\/])(\d+)/i, (msg) ->
    dice = parseInt msg.match[1]
    sides = parseInt msg.match[2]
    op = parseInt msg.match[3]
    mod = parseInt msg.match[4]
    answer = if sides < 2
      "Сложно покатить что-то одностороннее."
    else if dice > 100
      "Я не собираюсь бросать больше ста костей."
    else if dice < 1
      "Нечего бросать."
    else
      report roll dice, sides
    msg.reply answer

report = (results) ->
  if results?
    switch results.length
      when 0
        "На столе пусто."
      when 1
        "Я выбросила #{results[0]}."
      else
        total = results.reduce (x, y) -> x + y
        finalComma = if (results.length > 2) then "," else ""
        last = results.pop()
        "Я выбросила #{results.join(", ")}#{finalComma} и #{last}, в сумме #{total}."

roll = (dice, sides) ->
  rollOne(sides) for i in [0...dice]

rollOne = (sides) ->
  1 + Math.floor(Math.random() * sides)
