# Description:
#   Give your bot a default home page.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Notes:
#   Visit your hubot at $HOSTNAME:$PORT to see this page.
#
# Author:
#   patcon

module.exports = (robot) ->
  robot.router.get '/', (req, res) ->
    output = "<html>"
    output += "<head>"
    output += "<title>#{robot.name}</title>"
    output += "</head>"
    output += "<body>"
    output += "<h1>Hello, human!</h1>"
    output += "<div>If you're reading this then I, #{robot.name}, am awake and <a href='https://imgur.com/gjOZUwL'>now showing as online (green) in Slack.</a></div>"
    output += "</body>"
    output += "</html>"
    res.send output
