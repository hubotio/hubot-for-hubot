# Description:
#   Enable hubot to convert timezones for you.
#
# Dependencies:
#   "moment": "^2.10.3"
#
# Commands:
#   hubot time <usernames...> - Show the time for the following users
#   hubot time in <location> - Ask hubot for a time in a location
#   hubot time <parseable time> in <location> - Ask hubot for a time in a location
#
# Notes:
#   Based on https://github.com/ryandao/hubot-timezone with  modifications to be aware of user time zones from Slack

querystring = require('querystring')
moment = require('moment-timezone')

util = require('util')

parseTime = (timeStr) ->
  m = moment.utc(timeStr, [
    'ha', 'h:ma',
    'YYYY-M-D ha', 'YYYY-M-D h:ma',
    'YYYY-D-M ha', 'YYYY-D-M h:ma',
    'M-D-YYYY ha', 'M-D-YYYY h:ma',
    'D-M-YYYY ha', 'D-M-YYYY h:ma'
  ], true)
  return if m.isValid() then m.unix() else null

formatTime = (timestamp) ->
  return timestamp.format('dddd, MMMM Do YYYY, h:mm:ss a')

# Use Google's Geocode and Timezone APIs to get timezone offset for a location.
getTimezoneInfo = (res, timestamp, location, callback) ->
  q = querystring.stringify({ address: location, sensor: false })

  # TODO consider using geocoder module
  res.http('https://maps.googleapis.com/maps/api/geocode/json?' + q)
    .get() (err, httpRes, body) ->
      if err
        callback(err, null)
        return

      json = JSON.parse(body)
      if json.results.length == 0
        callback(new Error('no address found'), null)
        return

      latlong = json.results[0].geometry.location
      formattedAddress = json.results[0].formatted_address
      tzq = querystring.stringify({
        location: latlong.lat + ',' + latlong.lng,
        timestamp: timestamp.unix(),
        sensor: false
      })

      res.http('https://maps.googleapis.com/maps/api/timezone/json?' + tzq)
        .get() (err, httpRes, body) ->
          if err
            callback(err, null)
            return

          json = JSON.parse(body)
          if json.status != 'OK'
            callback(new Error('no timezone found'))
            return

          callback(null, {
            formattedAddress: formattedAddress,
            json: json,
            tz: json.timeZoneId,
          })

# Convert time between 2 locations and send back the results.
# If `fromLocation` is null, send back time in `toLocation`.
convertTime = (res, timestamp, toLocation) ->
  sendLocalTime = (timestamp, location) ->
    getTimezoneInfo res, timestamp, location, (err, result) ->
      if (err)
        res.send("I can't find the time at #{location}: #{err}.")
      else

        localTimestamp = timestamp.tz(result.tz)
        res.send("Time in #{result.formattedAddress} is #{formatTime(localTimestamp)}")

  sendLocalTime(timestamp, toLocation)

sendUserTime = (res, user) ->
  tz = user?.slack?.tz or user?.tz

  unless tz
    res.reply "I don't know nothing about #{user.name}'s timezone"
    return

  timestamp = moment().tz(tz)

  formattedTime = timestamp.format('dddd, MMMM Do YYYY, h:mm:ss a')
  if res.message.user is user
    res.send "It is #{formattedTime} in #{timestamp.zoneName()}"
  else
    res.send "It is #{formattedTime} for #{user.name} in #{timestamp.zoneName()}"

module.exports = (robot) ->
  robot.respond /time(?: (.+))?/i, (res) ->
    subcommand = res.match[1]
    user = res.message.user
    if not subcommand or subcommand is 'me'
      sendUserTime(res, user)
      return

    timeInMatch = subcommand.match(/(?:(\S+) )?in (.*)/)

    if timeInMatch?
      time = timeInMatch[1]
      timestamp = if time?
        moment.tz(user.tz, time)
      else
        moment.tz(user.tz)

      location = timeInMatch[2]
      convertTime(res, timestamp, location)
      return


    userNames = res.match[1].split(/\s/)

    for userName in userNames
      userName = userName.replace(/^@/, '') # FIXME slack adapter should probably handle this detail
      user = robot.brain.userForName(userName)
      sendUserTime(res, user)
