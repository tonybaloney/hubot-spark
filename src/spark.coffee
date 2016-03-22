Robot   = require('hubot').Robot
Adapter = require('hubot').Adapter
TextMessage = require('hubot').TextMessage

HTTPS        = require 'https'
EventEmitter = require('events').EventEmitter
Spark       = require('csco-spark')

class SparkAdapter extends Adapter
 send: (envelope, strings...) ->
   user = if envelope.user then envelope.user else envelope
   strings.forEach (str) =>
      @prepare_string str, (message) =>
         @bot.send user,message

 reply: (envelope, strings...) ->
   user = if envelope.user then envelope.user else envelope
   strings.forEach (str) =>
      @prepare_string str,(message) =>
         @bot.reply user,message

 prepare_string: (str, callback) ->
     text = str
     messages = [str]
     messages.forEach (message) =>
        callback message

 run: ->
   self = @
   options =
    api_uri: process.env.HUBOT_SPARK_API_URI or "https://api.ciscospark.com/v1"
    access_token: process.env.HUBOT_SPARK_ACCESS_TOKEN
    rooms      : process.env.HUBOT_SPARK_ROOMS
   bot = new SparkRealtime(options)

   bot.listen (messages, room_id) ->
      data.forEach (message) =>
         # checking message is received from valid group
         if room_id in bot.room_ids
             text = message.text
             user_name = message.personEmail
             console.log "received #{text} from #{user_name}"
             self.receive new TextMessage user_name, text

   @bot = bot
   self.emit 'connected'

exports.use = (robot) ->
 new SparkAdapter robot

class SparkRealtime extends EventEmitter
 self = @
 room_ids = []
 constructor: (options) ->
    if options.access_token?
      @spark = new Spark
         uri: options.api_uri
         access_token: options.access_token

      @room_ids = options.rooms
    else
      throw new Error "Not enough parameters provided. I need an access token"

 ## Spark API call methods
 listen: (callback) ->
  # Create a callback hook for each room
  @room_ids.forEach (room_id) =>
    listMsges = @spark.listItemEvt(
      item: 'messages'
      roomId: room_id
      max: '15')
    listMsges.on 'messages', (msges) ->
      callback msges room_id

 send: (user, message, room) ->
   if user
     @reply user, message
   else
     room_ids.forEach (room_id) =>
       console.log "send message to room #{room_id} with text #{message}"
       spark.sendMessage
        roomId: room_id
        text: message

 reply: (user, message) ->
   if user
     console.log "reply message to #{user} with text #{message}"
     spark.sendMessage
        roomId: room_id
        text: message
        toPersonEmail: user

