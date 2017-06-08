# Commands:
#   hubot sandwish - make a sandwich
#
module.exports = (robot) ->

 robot.respond /sandwish/i, (res) ->
   res.reply ":sandwich:"

