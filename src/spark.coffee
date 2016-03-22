///
Copyright 2016 Anthony Shaw, Dimension Data

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
///

Robot   = require('hubot').Robot
Adapter = require('hubot').Adapter
TextMessage = require('hubot').TextMessage

HTTPS        = require 'https'
EventEmitter = require('events').EventEmitter
Spark       = require('csco-spark')

class SparkAdapter extends Adapter
  constructor: (robot) ->
    super

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
    bot = new SparkRealtime(options, @robot)
    @robot.logger.debug "Created bot, setting up listeners"
    bot.listen (messages, room_id) =>
      @robot.logger.debug "Fired listener callback for #{room_id}"
      messages.forEach (message) =>
        # checking message is received from valid group
        if room_id in bot.room_ids
          text = message.text
          user_name = message.personEmail
          @robot.logger.info "received #{text} from #{user_name}"
          @robot.receive new TextMessage user_name, text
        else
          @robot.logger.info "received #{text} from #{room_id} but not a room we listen to."
    @robot.logger.debug "Done with custom bot logic"
    @bot = bot
    @emit 'connected'

exports.use = (robot) ->
  new SparkAdapter robot

class SparkRealtime extends EventEmitter
  self = @
  room_ids = []
  constructor: (options, robot) ->
    if options.access_token?
      @robot = robot
      try
        @robot.logger.debug "Trying connection to #{options.api_uri}"
        @spark = Spark
          uri: options.api_uri
          token: options.access_token
        @robot.logger.debug "Created connection instance to spark"
      catch e
        throw new Error "Failed to connect #{e.message}"
      @room_ids = []
      options.rooms.split(',').forEach (room_id) =>
        @room_ids.push room_id
        
      @robot.logger.debug "Completed adding rooms to list"
     else
       throw new Error "Not enough parameters provided. I need an access token"
 
  ## Spark API call methods
  listen: (callback) ->
    @robot.logger.debug "Creating callbacks"
    # Create a callback hook for each room
    @room_ids.forEach (room_id) =>
      @robot.logger.debug "Creating callback for #{room_id}"
      listMsges = @spark.listItemEvt(
        item: 'messages'
        roomId: room_id
        max: '1')
      @robot.logger.debug "Set callback for #{room_id}"
      listMsges.on 'messages', (msges) ->
        callback msges, room_id
    @robot.logger.debug "Finished listener callbacks"
 
  send: (user, message, room) ->
    @robot.logger.debug "Sending message"
    @room_ids.forEach (room_id) =>
      @robot.logger.info "send message to room #{room_id} with text #{message}"
      @spark.sendMessage
        roomId: room_id
        text: message
 
  reply: (user, message) ->
    @robot.logger.debug "Replying to message for #{user}"
    if user
      @robot.logger.info "reply message to #{user} with text #{message}"
      @spark.sendMessage
        text: message
        toPersonEmail: user
