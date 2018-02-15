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

fs = require 'fs'
mustache = require 'mustache'

module.exports = (robot) ->
  robot.router.get '/', (req, res) ->
    tpl_file = 'templates/homepage.html.mustache'
    view =
      robot: robot

    tpl = fs.readFileSync tpl_file, 'utf8'
    output = mustache.render tpl, view
    res.send output
