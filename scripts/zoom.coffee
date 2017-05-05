# Description:
#   hubot zoom integration!
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_ZOOM_API_KEY
#   HUBOT_ZOOM_API_SECRET
#   HUBOT_ZOOM_HOST_ID - id of user attached to account
#
# Commands:
#   hubot zoom me now [<topic>] - start a zoom meeting and return the meeting link
#
# Author:
#   Gad Berger

zoom_meeting_create = "https://api.zoom.us/v1/meeting/create"

zoomHostId = process.env.HUBOT_ZOOM_HOST_ID

module.exports = (robot) ->

  robot.respond /zoom me now(.+)?$/i, (msg) ->
    username = msg.message.user.name
    zoom_host_id = zoomHostId
    topic = msg.match[1]

    # according to zoom support, only scheduled and recurring
    # meetings can have the join before host option set to true

    params = {}
    params.api_key = process.env.HUBOT_ZOOM_API_KEY
    params.api_secret = process.env.HUBOT_ZOOM_API_SECRET
    params.data_type = "JSON"
    params.host_id = zoom_host_id
    params.start_time = Date().toString('yyyy-MM-ddTHH:mm:ssZ')
    params.duration = 60
    params.timezone = "GMT-5:00"
    params.type = 2
    params.option_start_type = "video"
    params.option_jbh = true

    params.topic = topic || "Insta-meeting via chatbot"

    try
      msg.http(zoom_meeting_create)
        .header("content-type", "application/x-www-form-urlencoded")
        .query(params)
        .post() (error, response, body) ->
          switch response.statusCode
            when 200
              json_body = JSON.parse(body)
              if json_body.error?
                msg.send "zoom error: #{json_body.error.message}"
              else
                msg.send "#{username} started a zoom session: #{json_body.join_url}"
            else
              msg.send "zoom? more like doom! there was a problem sending the request :("
    catch e then msg.send e
