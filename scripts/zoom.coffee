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
#   hubot zoom me [rec] now [<topic>] - start a zoom meeting and return the meeting link
#
# Author:
#   Gad Berger

zoom_meeting_create = "https://api.zoom.us/v1/meeting/create"

zoomHostId = process.env.HUBOT_ZOOM_HOST_ID
landing_disclaimer_url = "https://edgi-video-call-landing-page.herokuapp.com/"

module.exports = (robot) ->

  robot.respond /zoom me( \w+)? now(.+)?$/i, (msg) ->
    is_recorded = /rec/i.test msg.match[1]
    username = msg.message.user.name
    zoom_host_id = zoomHostId
    topic = msg.match[2]

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
    if is_recorded
      params.option_auto_record_type = "cloud"

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
                descriptor = if is_recorded then "recorded" else ""
                join_url = json_body.join_url
                join_url = if is_recorded then landing_disclaimer_url + join_url
                msg.send "#{username} started a #{descriptor} zoom session: #{join_url}"
            else
              msg.send "zoom? more like doom! there was a problem sending the request :("
    catch e then msg.send e
