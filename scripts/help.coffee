# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   hubot справка - Показывает все известные боту команды.
#   hubot справка <query> - Показывает все команды совпадающие с <query>.
#
# URLS:
#   /hubot/help
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.

helpContents = (name, commands) ->

  """
<!DOCTYPE html>
<html>
  <head>
  <meta charset="utf-8">
  <title>#{name} Help</title>
  <style type="text/css">
    body {
      background: #d3d6d9;
      color: #636c75;
      text-shadow: 0 1px 1px rgba(255, 255, 255, .5);
      font-family: Helvetica, Arial, sans-serif;
    }
    h1 {
      margin: 8px 0;
      padding: 0;
    }
    .commands {
      font-size: 13px;
    }
    p {
      border-bottom: 1px solid #eee;
      margin: 6px 0 0 0;
      padding-bottom: 5px;
    }
    p:last-child {
      border: 0;
    }
  </style>
  </head>
  <body>
    <h1>#{name} Help</h1>
    <div class="commands">
      #{commands}
    </div>
  </body>
</html>
  """

module.exports = (robot) ->
  robot.respond /(?:справка|help)\s*(.*)?$/i, (msg) ->
    cmds = robot.helpCommands()
    filter = msg.match[1]

    if filter
      cmds = cmds.filter (cmd) ->
        cmd.match new RegExp(filter, 'i')
      if cmds.length == 0
        msg.send "Нет команды совпадающей с #{filter}"
        return

    prefix = robot.alias or robot.name
    cmds = cmds.map (cmd) ->
      cmd = cmd.replace /^hubot/, prefix
      cmd.replace /hubot/ig, robot.name

    emit = cmds.join "\n"

    msg.send emit

  robot.router.get "/#{robot.name}/help", (req, res) ->
    cmds = robot.helpCommands().map (cmd) ->
      cmd.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')

    emit = "<p>#{cmds.join '</p><p>'}</p>"

    emit = emit.replace /hubot/ig, "<b>#{robot.name}</b>"

    res.setHeader 'content-type', 'text/html'
    res.end helpContents robot.name, emit
