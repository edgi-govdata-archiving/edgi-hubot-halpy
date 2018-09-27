# Description:
#   hubot zoom integration!
#
# Dependencies:
#   jsonwebtoken, chrono-node, request-promise
#
# Configuration:
#   HUBOT_ZOOM_API_KEY
#   HUBOT_ZOOM_API_SECRET
#   HUBOT_ZOOM_HOST_ID - id of user attached to account
#
# Commands:
#   hubot zoom me [-r|record] (now|date-time descriptor) [for NUMBER minutes|hours] [-t <topic>] -  a zoom meeting and return the meeting link
#
# Author:
#   Gad Berger, Patrick Connolly, Matt Price


chrono = require("chrono-node")
util = require('util')
jwt = require('jsonwebtoken')
rp = require('request-promise')
moment = require('moment')

cmd_name = "zoom-test"
recordedRE = /\s(recorded|-r)/i
topicRE = /-t (.*)( -)?/i

# use dotenv in a dev env
if  process.env.NODE_ENV isnt 'production'
  dotenv = require('dotenv')
  dotenv.load()



# console.log chrono.parseDate "zoom me next Friday 15:00 EDT until 16:00 recorded -t Testing"
# console.log ""

# constants
zoom_meeting_base = "https://api.zoom.us/v2/users/" + process.env.HUBOT_ZOOM_HOST_ID + "/meetings"
zoom_meeting_create = "https://api.zoom.us/v2/users/" + process.env.HUBOT_ZOOM_HOST_ID + "/meetings"
zoomHostId = process.env.HUBOT_ZOOM_HOST_ID
landing_disclaimer_url = "https://edgi-video-call-landing-page.herokuapp.com/"

# utility functions
fullObj = (o) ->
  util.inspect o, false, 2, true

quickCut = (s, index, length) ->
  return s.slice(0, index ) + s.slice(index + length)

makeDateString = (d) ->
  date = new Date(d)


# token creator, still not working
createToken = () ->
  tokenPayload = {
    iss: process.env.HUBOT_ZOOM_API_KEY,
    exp: Date.now() + 100000
    }
  # console.log tokenPayload.exp
  # token = jwt.sign {}, process.env.HUBOT_ZOOM_API_KEY, {expiresIn: '10s'}
  token = jwt.sign tokenPayload, process.env.HUBOT_ZOOM_API_SECRET
  return token

# main time parsing function
parseZoom  = (instructions) ->

  date = chrono.parse instructions
  duration = 60
  topic = "No Topic Assigned"
  remainder = instructions
  start_time = Date().toString('yyyy-MM-ddTHH:mmssZ')
  if date
    start_time = chrono.parseDate date[0].text
    i = date[0].index
    l = date[0].text.length + 1
    remainder = quickCut(instructions, i, l)
    is_recorded = remainder.match recordedRE
    if is_recorded
      remainder = quickCut(remainder, is_recorded.index, is_recorded[0].length)

    dstring = remainder.match /.*for ([\d\.]+) (minutes|hour[s]?)/i
    if dstring
      # console.log fullObj dstring
      remainder = quickCut(remainder, dstring.index, dstring[0].length)
      if dstring[2].includes "hour"
        duration = dstring[1] * 60
      else
        duration = dstring[1]
  topic = remainder.match topicRE
  if topic
    remainder=quickCut(remainder,topic.index,topic[0].length)
    topic = topic[1]
    if ((topic[0] is topic[topic.length-1]) and (topic[0] is '"'))
      topic = topic.slice(1,-1)
  else
    topic = "No Topic Assigned"
  o = {type: 2, start_time: start_time, remainder: remainder, duration: duration, topic: topic, is_recorded: Boolean is_recorded}
  return o


module.exports = (robot) ->

  robot.respond /parse me( .+)?$/i, (res) ->
    myResponse = parseZoom res.match[1]
    robot.logger.info fullObj myResponse
    robot.send myResponse

  robot.respond /zoom-test (list|ls)( .+)?/i, (res) ->
    daysRE = /([0-9]+|all)/i
    days = 8
    span = res.match[2].match(daysRE) if res.match[2]

    if span
      if (span[1] is 'all')
        days = 2000
      else
        days = span[1]
    zoom_list_meetings = zoom_meeting_base
    t = createToken()
    options = {
      method: 'GET',
      uri: zoom_list_meetings,
      auth: {'bearer': t} ,
      json: true,
      qs: {'type': 'upcoming', 'page_size': 300 }
      }
    now = moment()

    rp(options)
      .then (response) ->
        # console.log fullObj response.meetings[0]
        # robot.logger.info fullObj response
        # res.send fullObj response
        text = "Here's a quick list of all our upcoming meetings for the next #{days - 1} days.\n"
        for m in response.meetings
          if (moment(m.start_time).diff(now, 'days') < days)
            friendlyDate = moment(m.start_time).format('MM-DD, hh:mm')
            text += "- *#{friendlyDate} (#{m.duration} mins):* #{m.topic} [Join: #{m.join_url}]\n"
        res.send text
      .then null, (err) ->
        robot.logger.info fullObj err


  robot.respond /zoom-test me (.+)?$/i, (res) ->

    zoomHostId = process.env.HUBOT_ZOOM_HOST_ID

    username = res.message.user.name
    zoom_host_id = zoomHostId
    body = parseZoom res.match[1]
    if res.match[1] is " now"
      body.type = 1

    headers = {
      "content-type": "application/json",
      "Accept": "application/json"
      }
    t = createToken()
    options = {
      method: 'POST',
      uri: zoom_meeting_create,
      auth: {'bearer': t} ,
      headers: {'content-type': 'application/json', 'Accept': 'application/json'},
      json: true,
      body: body,
      settings: {
        'host_video': true,
        'participant_video': true
        }
      }

    # according to zoom support, only scheduled and recurring
    # meetings can have the join before host option set to true
    if body.is_recorded
      options.settions.auto_recording = true
      options.settings.auto_record_type = "cloud"


    rp(options)
      .then (response) ->
        robot.logger.info fullObj response
        res.send "#{username} created a zoom session about #{response.topic}, which will start at #{response.start_time} and last for #{response.duration} minutes. Follow this link to join:  #{response.join_url}"
      .then null, (err) ->
        robot.logger.info fullObj err
