# Description:
#   Hubot got privileges!
#
# Commands:
#   hubot ignore me/someone - Hubot will ignore me/someone
#   hubot forgive someone - Hubot will forgive someone
#   hubot privilege - Check the privilege table
#
# Author:
#   dtaniwaki
#   ndaversa

PRIVILEGE_TABLE_KEY = 'hub-privilege-table'

isIgnored = (username) ->
  table = robot.brain.get(PRIVILEGE_TABLE_KEY) || {}
  ignored = false
  if username?
    user = robot.brain.userForName username
    if user
      ignored = table[user.id]
  ignored

module.exports = (robot) ->
  receiveOrg = robot.receive
  robot.receive = (msg)->
    who = msg.user?.name?.trim().toLowerCase()
    action = msg.text?.split(/\s/)[1]?.trim().toLowerCase()

    ignored = isIgnored who
    if /^(help|forgives?|privilege)$/.test(action)
      ignored = false

    if ignored
      s = "Sorry, I ignore #{who}"
      console.log s
      msg.finish()
    else
      receiveOrg.bind(robot)(msg)

  robot.respond /ignores?\s([^\s]*)/i, (msg)->
    who = msg.match[1].trim().toLowerCase()
    if who == 'me'
      who = msg.message.user?.name?.toLowerCase()
    if !isIgnored who
      user = robot.brain.userForName who
      if user
        s = "I will ignore #{who}"
        msg.reply s
        table = robot.brain.get(PRIVILEGE_TABLE_KEY) || {}
        table[user.id] = true
        robot.brain.set PRIVILEGE_TABLE_KEY, table

  robot.respond /forgive\s([^\s]*)/i, (msg)->
    who = msg.match[1].trim().toLowerCase()
    if who == 'me'
      who = msg.message.user?.name?.toLowerCase()

    user = robot.brain.userForName who
    if user
      self = user.id == msg.message.user?.id
      if !isIgnored who
        s = "Nothing to forgive"
      else if self
        s = "Sorry, I cannot forgive you. You must atone."
      else
        s = "I will forgive #{who}"
        table = robot.brain.get(PRIVILEGE_TABLE_KEY) || {}
        delete table[user.id]
        robot.brain.set PRIVILEGE_TABLE_KEY, table
      msg.reply s

  robot.respond /privilege(:?\s([^\s]*))?/i, (msg)->
    who = msg.message.user?.name?.toLowerCase()
    action = msg.match[1]?.trim().toLowerCase()
    response = "Everyone is awesome"

    if action == 'clear' and !isIgnored who
      robot.brain.set PRIVILEGE_TABLE_KEY, {}
    else
      table = robot.brain.get(PRIVILEGE_TABLE_KEY) || {}
      ignored = []
      for id of table
        user = robot.brain.userForId id
        ignored.push user.name if user
      if ignored.length > 0
        response = "I'm unhappy with: #{ignored}. Should I forgive?"

    msg.send response
