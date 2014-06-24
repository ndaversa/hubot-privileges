# Description:
#   Hubot got privileges!
#
# Commands:
#   hubot ignore(s) me/someone - Hubot will ignore me/someone
#   hubot forgive(s) me/someone - Hubot will forgive me/someone
#   hubot privilege - Check the privilege table
#
# Author:
#   dtaniwaki

PRIVILEGE_TABLE_KEY = 'hub-privilege-table'

module.exports = (robot) ->
  receiveOrg = robot.receive
  robot.receive = (msg)->
    username = msg.user?.name?.trim().toLowerCase()
    action = msg.text?.match(/^hubot\s([^\s]*)/)?[1].trim().toLowerCase()
    table = robot.brain.get(PRIVILEGE_TABLE_KEY) || {}

    ignore = true
    if !username? || !table[username]?
      ignore = false
    else if action? && /^(ignores?|forgives?|privilege)$/.test(action)
      ignore = false

    if ignore
      s = "Sorry, I ignore #{username}"
      s += " about #{action}" if action?
      console.log s
    else
      receiveOrg.bind(robot)(msg)

  robot.respond /ignores?\s([^\s]*)(:?\sabout\s([^\s]*))?/i, (msg)->
    who = msg.match[1].trim().toLowerCase()
    action = msg.match[2]?.trim().toLowerCase()
    if who == 'me'
      who = msg.message.user?.name?.toLowerCase()
    s = "I will ignore #{who}"
    s += " about #{action}" if action?
    console.log s
    table = robot.brain.get(PRIVILEGE_TABLE_KEY) || {}
    table[who] = true
    robot.brain.set PRIVILEGE_TABLE_KEY, table

  robot.respond /forgives?\s([^\s]*)(:?\sabout\s([^\s]*))?/i, (msg)->
    who = msg.match[1].trim().toLowerCase()
    action = msg.match[2]?.trim().toLowerCase()
    if who == 'me'
      who = msg.message.user?.name?.toLowerCase()
    s = "I will forgive #{who}"
    s += " about #{action}" if action?
    console.log s
    table = robot.brain.get(PRIVILEGE_TABLE_KEY) || {}
    delete table[who]
    robot.brain.set PRIVILEGE_TABLE_KEY, table

  robot.respond /privilege/i, (msg)->
    table = robot.brain.get(PRIVILEGE_TABLE_KEY) || {}
    msg.send JSON.stringify(table)
