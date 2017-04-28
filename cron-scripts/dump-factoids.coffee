Url   = require "url"
Redis = require "redis"
request = require "request"

redisUrl = if process.env.REDISTOGO_URL?
             process.env.REDISTOGO_URL
           else if process.env.REDISCLOUD_URL?
             process.env.REDISCLOUD_URL
           else if process.env.BOXEN_REDIS_URL?
             process.env.BOXEN_REDIS_URL
           else if process.env.REDIS_URL?
             process.env.REDIS_URL
           else
             'elseredis://localhost:6379'

info = Url.parse redisUrl, true
client = if info.auth then Redis.createClient(info.port, info.hostname, {no_ready_check: true}) else Redis.createClient(info.port, info.hostname)
prefix = info.path?.replace('/', '') or 'hubot'

if info.auth
  client.auth info.auth.split(":")[1], (err) ->
    if err
      console.log "Failed to authenticate to Redis"
    else
      client.get "#{prefix}:storage", (err, reply) ->
        if err
          throw err
        else
          factoids = JSON.parse(reply.toString()).factoids
          csv_contents = ""
          for key, data of factoids
            csv_contents += "#{key},#{data.value}\n"
          console.log csv_contents
          request
            .put {url: "https://www.ethercalc.org/_/edgi-factoids", body: csv_contents},
              (err, httpResponse, body) ->
                if err
                  console.log err
                else
                  console.log body
                  client.quit()
