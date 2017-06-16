# Description
#   hubot scripts for diagnosing hubot
#
# Commands:
#   hubot ping - Reply with pong
#   hubot echo <text> - Reply back with <text>
#   hubot time - Reply with current time
#
# Notes:
#   This is adapted from hubot-diagnostic with removals to avoid conflict with timezones.coffee
#
# Author:
#   Josh Nichols <technicalpickles@github.com>
module.exports = (robot) ->
  robot.respond /PING$/i, (msg) ->
    msg.send "PONG"

  robot.respond /ECHO (.*)$/i, (msg) ->
    msg.send msg.match[1]
