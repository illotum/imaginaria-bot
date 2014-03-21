# Description:
#   javabot style factoid support for your hubot. Build a factoid library
#   and save yourself typing out answers to similar questions
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   ~<factoid> это <some phrase, link, whatever> - создает факт
#   ~<factoid> это также <some phrase, link, whatever> - обновляет факт
#   ~<factoid> - выдает факт, если тот существует; иначе отвечает что его нет
#   ~скажи <user> про <factoid> - рассказывает пользователю о факте
#   ~~<user> <factoid> - аналог `скажи`, но меньше набирать
#   <factoid>? - аналог ~<factiod>, но молчит если такого факта нет
#   hubot нет, <factoid> это <some phrase, link, whatever> - заменяет факт целиком
#   hubot список фактов - показывает полный список фактов
#   hubot удали факт "<factoid>" - удаляет факт
#
# Author:
#   arthurkalm

class Factoids
  constructor: (@robot) ->
    @robot.brain.on 'loaded', =>
      @cache = @robot.brain.data.factoids
      @cache = {} unless @cache

  add: (key, val) ->
    if @cache[key]
      "Я лучше знаю."
    else
      this.setFactoid key, val

  append: (key, val) ->
    if @cache[key]
      @cache[key] = @cache[key] + ", " + val
      @robot.brain.data.factoids = @cache
      "ОК. #{key} это также #{val} "
    else
      "Мне неизвестно про #{key}."

  setFactoid: (key, val) ->
    @cache[key] = val
    @robot.brain.data.factoids = @cache
    "ОК. #{key} это #{val} "

  delFactoid: (key) ->
    delete @cache[key]
    @robot.brain.data.factoids = @cache
    "ОК. Я забыла про #{key}"

  niceGet: (key) ->
    @cache[key] or "Мне неизвестно про #{key}"

  get: (key) ->
    @cache[key]

  list: ->
    Object.keys(@cache)

  tell: (person, key) ->
    factoid = this.get key
    if @cache[key]
      "#{person}, #{key} это #{factoid}"
    else
      factoid

  handleFactoid: (text) ->
    if match = /^~(.+?) это также (.+)/i.exec text
      this.append match[1], match[2]
    else if match = /^~(.+?) это (.+)/i.exec text
      this.add match[1], match[2]
    else if match = (/^~скажи (.+?) про (.+)/i.exec text) or (/^~~(.+) (.+)/.exec text)
      this.tell match[1], match[2]
    else if match = /^~(.+)/i.exec text
      this.niceGet match[1]

module.exports = (robot) ->
  factoids = new Factoids robot

  robot.hear /^~(.+)/i, (msg) ->
    if match = (/^~(рас)?скажи (.+) про (.+)/i.exec msg.match) or (/^~~(.+) (.+)/.exec msg.match)
      msg.send factoids.handleFactoid msg.message.text
    else
      msg.reply factoids.handleFactoid msg.message.text

  robot.hear /(.+)\?/i, (msg) ->
    factoid = factoids.get msg.match[1]
    if factoid
      msg.reply msg.match[1] + " is " + factoid

  robot.respond /нет, (.+) это (.+)/i, (msg) ->
    msg.reply factoids.setFactoid msg.match[1], msg.match[2]

  robot.respond /список фактов/i, (msg) ->
    msg.send factoids.list().join('\n')

  robot.respond /удали факт "(.*)"$/i, (msg) ->
    msg.reply factoids.delFactoid msg.match[1]
