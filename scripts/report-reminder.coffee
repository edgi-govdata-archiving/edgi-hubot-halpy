# Description:
#   hubot report reminders
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
#   hubot report file
#   hubot report check
#
# Author:
# Matt Price

chrono = require("chrono-node")
util = require('util')
jwt = require('jsonwebtoken')
rp = require('request-promise')
moment = require('moment')
# Import the Slack Developer Kit
{WebClient} = require "@slack/client"

# utility functions
fullObj = (o) ->
  util.inspect o, false, 3, true

quickCut = (s, index, length) ->
  return s.slice(0, index ) + s.slice(index + length)

makeDateString = (d) ->
  date = new Date(d)

# some defaults
base_archive_URL = 'https://edgi.slack.com/archives/'

defaultAnnouncement = "It's that time of the month again, and we need
reports from all of the working groups: Archiving & Data Together,
Web Monitoring (analysts & devs), Interviewing, EDJ, and Development.
Please file reports in the XXXXX channel and maybe there wil lbe some further
instructions, esp if we make a special channel and then scrape the contents as
a way of tracking this stuff. " + """

In your reports please include the following information:
  - hoping for some tips
  - maybe a link out to some google doc that describes our reporting process
  - or a template.

""" +
"You'll keep getting these reminders until you click the :thumbsup: emoji reaction
which should already be visible on this post."


class Report
  constructor: (data) ->
    {@res_envelope, @action, @time, @date} = data




module.exports = (robot) ->

  web = new WebClient robot.adapter.options.token

  # # When the script starts up, there is no notification room
  # notification_room = undefined

  # # Immediately, a request is made to the Slack Web API to translate a default channel name into an ID
  # default_channel_name = "general"
  # web.channels.list()
  #   .then (api_response) ->
  #   # List is searched for the channel with the right name, and the notification_room is updated
  #     room = api_response.channels.find (channel) -> channel.name is default_channel_name
  #     notification_room = room.id if room?

  #   # NOTE: for workspaces with a large number of channels, this result in a timeout error. Use pagination.
  #   .catch (error) -> robot.logger.error error.message

  test_error = (err) -> res.send "your Connectio nto the Slack API failed ;("
  test_success = (payload) -> res.send "your connection to the Slack API is working!"
  robot.respond /report-reminder(.*)?/i, (res) ->
    console.log fullObj res.message.mentions
    res.reply "very basic report reminder"


  # robot.hearReaction (res) ->
  #   console.log fullObj res

  robot.respond /test report/i, (res) ->
    # res.reply defaultAnnouncement
    room = res.message.room
    msgid = res.message.id
    cleanMId = msgid.replace /\./ , ''
    room = res.message.room
    reportText = defaultAnnouncement

    link_url = base_archive_URL + room + '/p' + cleanMId
    # console.log fullObj res.message
    users = []
    # robot.logger.info res.
    for m in res.message.mentions
      users.push m.id unless m.info.slack.is_bot
    usersText = 'Hello '
    for u in users
      usersText += "<@#{u}>, "
    usersText +="\n"
    posted = null
    # web.chat.postMessage({channel: room, text: usersText + reportText})
    web.reactions.add
      name: 'thumbsup'
      channel: room
      timestamp: msgid
    web.chat.postMessage(room, usersText + reportText)
    .then((r2) ->
      console.log "MESSAGE RESPONSE: " + fullObj r2
      posted = r2.message.ts
      web.reactions.add({name: "thumbsup", channel: room, timestamp: posted})
      .then((r3) ->
        console.log "REACTION Response: " + r3
        )
      .catch((err) ->
        console.log fullObj "REACTION Error: " + err
        )
      )
    .catch((err) ->
      console.log "POST ERROR: " + err
      )
    # out = robot.messageRoom(room,usersText + reportText)
    # console.log fullObj out
    # res.reply   " <#" + "#{room}>, " + link_url


  robot.hear /test webapi/i, (res) ->
    console.log fullObj web.api.test()
    web.channels.list()
      .then (result) ->
        console.log fullObj result
      # .then test_success
      # .catch test_error
      # .then (payload) -> res.send "Your connection to the Slack API is working!"
      #   , (error) -> res.send "Your connection to the Slack API failed :("
