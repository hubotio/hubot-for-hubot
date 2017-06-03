# Description:
#   Enable hubot to convert timezones for you.
#
# Commands:
#   hubot time <usernames...> - Show the time for the following users
#   hubot time in <location> - Ask hubot for a time in a location
#   hubot time <parseable time> in <location> - Ask hubot for a time in a location
#
# Notes:
#   Based on https://github.com/ryandao/hubot-timezone with  modifications to be aware of user time zones from Slack

timezoneIntents = require('../lib/timezone-intents')


module.exports = (robot) ->
  robot.respond /time(?:\s+(.+))?/i, (res) ->
    subcommand = res.match[1] or ''
    subcommand = subcommand.replace(/^me( |$)/, '')

    if subcommand is ''
      user = res.message.user # FIXME this is just an Object, not a hubot User
      timezoneIntents.sendUserTime(res, user)
      return

    # Match things like:
    # 1:58 in Savannah, GA
    # in San Francisco
    timeInMatch = subcommand.match(/(?:(\S+) )?in (.*)/)

    if timeInMatch?
      user = res.message.user # FIXME this is just an Object, not a hubot User

      time = timeInMatch[1]
      location = timeInMatch[2]

      timezoneIntents.sendTimeInLocation(res, user, timeInMatch[1], timeInMatch[2])
      return

    userNames = res.match[1].split(/\s/)
    for userName in userNames
      userName = userName.replace(/^@/, '') # FIXME slack adapter should probably handle this detail
      user = robot.brain.userForName(userName)
      timezoneIntents.sendUserTime(res, user)
