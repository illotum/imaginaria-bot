# Description
#   Generates a poll.
#   Hubot will automatically end the poll when everyone has answered.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot опрос <вопрос> -a <варианты> - создать опрос с вариантами ответа через запятую
#   hubot завершить опрос - прекратить опрос
#   hubot я за <number> - проголосовать
#   hubot предыдущий опрос - показывает результат предыдущего опроса
#
# Notes:
#   $ hubot poll How cool is that? -a Amazeballz, Very Nice, Nice, Boring
#   $ hubot vote 1
#   $ hubot end vote
#   $ hubot previous poll
#
# Author:
#   EtienneLem, illotum

class Poll

  constructor: (@robot) ->
    @poll = null
    @previousPoll = null

    @robot.respond /опрос (.*) -a (.*)/i, this.createPoll
    @robot.respond /(завершить|закончить|остановить|прекратить) опрос/i, this.endPoll
    @robot.respond /я за ([0-9]*)/i, this.vote
    @robot.respond /предыдущий опрос/i, this.showPreviousPoll

  getUser: (msg) ->
    msg.message.user

  # Poll management
  createPoll: (msg) =>
    answers = this.createAnswers(msg.match[2])
    return msg.send('Опрос, это когда больше чем один вариант ответа') if answers.length <= 1

    user = this.getUser(msg)
    @poll = { user: user, question: msg.match[1], answers: answers, cancelled: 0, voters: {} }

    msg.send """#{user.name} интересуется: #{@poll.question}
    0. [Отменить мой голос]
    #{this.printAnswers()}
    """

  endPoll: (msg) =>
    return msg.send('Я не провожу сейчас опрос') unless @poll

    msg.send """Результаты опроса на тему “#{@poll.question}”:
    #{this.printResults(@poll)}
    Этот опрос был создан #{@poll.user.name}
    """

    @previousPoll = @poll
    @poll = null

  showPreviousPoll: (msg) =>
    return msg.send('Я не помню предыдущего опроса') unless @previousPoll

    msg.send """Результаты опроса на тему “#{@previousPoll.question}”:
    #{this.printResults(@previousPoll)}
    Этот опрос был создан #{@previousPoll.user.name}
    """

  # Ansers management
  createAnswers: (answers) ->
    { text: answer, votes: 0 } for answer in answers.split(/\s?,\s?/)

  printAnswers: ->
    ("#{i+1}. #{answer.text}" for answer, i in @poll.answers).join("\n")

  printResults: (poll) ->
    poll.answers.sort (a, b) ->
      return 1 if (a.votes < b.votes)
      return -1 if (a.votes > b.votes)
      0

    results = ''
    results += ("#{answer.text} (#{answer.votes})" for answer in poll.answers).join("\n")
    results += "\n\nИз #{Object.keys(poll.voters).length} проголосовавших, #{poll.cancelled} свой голос отменили."

  # Vote management
  vote: (msg) =>
    number = parseInt(msg.match[1])
    user = this.getUser(msg)

    # Errors
    return msg.send('Извини, никакого опроса сейчас не ведется.') unless @poll
    return msg.send("Я насчитала всего лишь #{@poll.answers.length} ответов.") if number > @poll.answers.length

    # User already voted
    if (userAnswer = @poll.voters[user.name]) != undefined
      sorry = "Извини, #{user.name}, но ты уже "
      if userAnswer is 0
        sorry += 'отозвал свой голос.'
      else
        sorry += "проголосовал за “#{userAnswer}. #{@poll.answers[userAnswer - 1].text}” в этом опросе."

      return msg.send(sorry)

    # Save user vote
    @poll.voters[user.name] = number
    votersCount = Object.keys(@poll.voters).length

    # Cancel vote
    if number is 0
      @poll.cancelled++
      msg.send("#{user.name} решил не голосовать.")

    # Cast vote
    else
      votedAnswer = @poll.answers[number - 1]
      votedAnswer.votes++
      msg.send "#{user.name} проголосовал за “#{votedAnswer.text}”"

    # Close poll if all users have voted
    # return if votersCount < @robot.brain.data.users.length - 1
    # msg.send "It looks like all users casted their vote. Automatically closing this poll."
    # this.endPoll(msg)

module.exports = (robot) ->
  new Poll(robot)
