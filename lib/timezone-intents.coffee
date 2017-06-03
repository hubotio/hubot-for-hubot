querystring = require('querystring')
moment = require('moment-timezone')

util = require('util')

parseTime = (tz, timeStr) ->
  m = moment.tz(timeStr, [
    'ha', 'h:ma',
    'YYYY-M-D ha', 'YYYY-M-D h:ma',
    'YYYY-D-M ha', 'YYYY-D-M h:ma',
    'M-D-YYYY ha', 'M-D-YYYY h:ma',
    'D-M-YYYY ha', 'D-M-YYYY h:ma'
  ], tz)
  return if m.isValid() then m else null

formatTime = (timestamp) ->
  timestamp.format('dddd, MMMM Do YYYY, h:mm:ss a')

# Use Google's Geocode and Timezone APIs to get timezone offset for a location.
getTimezoneInfo = (res, timestamp, location, callback) ->
  q = querystring.stringify(address: location, sensor: false)

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

sendUserTime = (res, user) ->
  tz = user?.slack?.tz or user?.tz

  unless tz
    res.reply "I don't know #{user.name}'s timezone"
    return

  timestamp = moment().tz(tz)

  formattedTime = formatTime(timestamp)
  if res.message.user is user
    res.send "It is #{formattedTime} in #{timestamp.zoneName()}"
  else
    res.send "It is #{formattedTime} for #{user.name} in #{timestamp.zoneName()}"


sendTimeInLocation = (res, user, time, location) ->
  timestamp = if time?
    parseTime(user.tz, time)
  else
    moment.tz(user.tz)

  sendLocalTime = (timestamp, location) ->
    getTimezoneInfo res, timestamp, location, (err, result) ->
      if (err)
        res.send("I can't find the time at #{location}: #{err}.")
      else

        localTimestamp = timestamp.tz(result.tz)
        res.send("Time in #{result.formattedAddress} is #{formatTime(localTimestamp)}")

  sendLocalTime(timestamp, location)

module.exports =
  sendUserTime: sendUserTime
  sendTimeInLocation: sendTimeInLocation
