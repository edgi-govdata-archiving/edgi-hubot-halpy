# Description:
#   Hits a Jenkins webhook that kicks off a script to upload Zoom meeting videos to YouTube.
#
#    See: https://github.com/edgi-govdata-archiving/edgi-scripts#zoom-youtube-uploader
#
# Configuration:
#   HUBOT_JENKINS_WEBHOOK_URL - full job webhook url (excluding token)
#   HUBOT_JENKINS_JOB_TOKEN - secret token used to run job
#   HUBOT_JENKINS_USER - bot user for running jobs
#   HUBOT_JENKINS_PASS
#
# Commands:
#   hubot zoom youtube upload - Upload all recorded Zoom meetings to YouTube
#

config =
  webhook_url: process.env.HUBOT_JENKINS_WEBHOOK_URL
  token: process.env.HUBOT_JENKINS_JOB_TOKEN
  user: process.env.HUBOT_JENKINS_USER
  pass: process.env.HUBOT_JENKINS_PASS

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

module.exports = (robot) ->
  robot.respond /zoom youtube upload/i, (res) ->
    res.http(config.webhook_url)
      .query({token: config.token})
      .auth(config.user, config.pass)
      .get() (err, response, body) ->
        if err
          res.reply "Had problem uploading video. Please report here: https://github.com/edgi-govdata-archiving/edgi-hubot/issues/new"
          robot.emit 'error', err, res
          return
        else
          output = "Ok, sure thing!"
          output += " I've just kicked off upload of Zoom videos to YouTube."
          output += " I'll drop a message in #meeting_announcements in EDGI Slack when it's done!"
          res.reply output
