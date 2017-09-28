# Description:
#   hubot Rebrandly link shortening integration!
#
# Dependencies:
#   request-promise
#
# Configuration:
#   REBRANDLY_API_KEY
#
# Commands:
#   hubot shortlink set <name> <url> - update an existing shortlink (no new shortlinks yet)
#
# Author:
#   @patcon

rp = require 'request-promise'

module.exports = (robot) ->
  robot.respond /shortlink set (\S+) (\S+)/i, (res) ->
    [_, slug, url, _...] = res.match

    opts =
      method: 'GET'
      uri: 'https://api.rebrandly.com/v1/links'
      json: true
      headers:
        apikey: process.env.REBRANDLY_API_KEY
        'Content-Type': 'application/json'

    rp(opts)
      .then (response) ->
        [link] = (link for link in response when link.slashtag == slug)

        if link
          link.destination = url
          opts.method = 'POST'
          opts.body = link
          opts.uri = "https://api.rebrandly.com/v1/links/#{link.id}"

          rp(opts)
            .then (response) ->
              res.send "Link updated!"
        else
          res.send "No existing shortlink found to update. We can currently only update existing shortlinks."
