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

Bluebird = require('bluebird')
Adapter = require('hubot').Adapter
TextMessage = require('hubot').TextMessage

EventEmitter = require('events').EventEmitter
SparkApi = require('./spark-api')

class SparkAdapter extends Adapter
  constructor: (robot) ->
    super

  send: (envelope, strings...) ->
    user = if envelope.user then envelope.user else envelope
    strings.forEach (str) =>
      @prepare_string str, (message) =>
        @bot.send user, message

  reply: (envelope, strings...) ->
    user = if envelope.user then envelope.user else envelope
    strings.forEach (str) =>
      @prepare_string str,(message) =>
        @bot.reply user, message

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
    bot.init(options, @robot).then((roomIds) ->
      self.robot.logger.debug "Created bot, setting up listeners"
      roomIds.forEach((roomId) ->
        bot.listen roomId, new Date().toISOString(), (messages, roomId) =>
          self.robot.logger.debug "Fired listener callback for #{roomId}"
          messages.forEach (message) =>
            text = message.text
            user =
              name: message.personEmail
              id: message.personId
              room: message.roomId
            self.robot.logger.debug "Received #{text} from #{user.name}"
            self.robot.receive new TextMessage user, text
      )
      self.robot.logger.debug "Done with custom bot logic"
      self.bot = bot
      self.emit 'connected'
    )

class SparkRealtime extends EventEmitter
  self = @
  logger = undefined
  spark = undefined

  constructor: (options, robot) ->
    @room_ids = []
    if not options.access_token?
      throw new Error "Not enough parameters provided. I need an access token"

  init: (options, robot) ->
    @robot = robot
    logger = @robot.logger
    logger.info "Trying connection to #{options.api_uri}"
    spark = new SparkApi
      uri: options.api_uri
      token: options.access_token
    return spark.init().then(() ->
      logger.debug "Connected as a bot? #{spark.isBot()}"
      logger.info "Created connection instance to Spark"
      roomIds = []
      options.rooms.split(',').forEach (roomId) =>
        roomIds.push roomId
      logger.debug "Completed adding rooms to list"
      Bluebird.resolve(roomIds)
    ).catch((err) ->
      throw new Error "Failed to connect to Spark: #{err}"
    )

  ## Spark API call methods
  listen: (roomId, date, callback) ->
    spark.getMessages(roomId: roomId).then (msges) =>
      msges.forEach((msg) =>
        if Date.parse(msg.created) > Date.parse(date)
          @robot.logger.debug "Matched new message #{msg.text}"
          callback [msg], roomId
      )
      newDate = new Date().toISOString()
      setTimeout (=>
        @listen roomId, newDate, callback
      ), 10000

  send: (user, message) ->
    @robot.logger.debug "Send message to room #{user.room} with text #{message}"
    spark.sendMessage
      roomId: user.room
      text: message

  reply: (user, message) ->
    @robot.logger.debug "Replying to message for #{user}"
    if user
      @robot.logger.debug "reply message to #{user} with text #{message}"
      spark.sendMessage
        text: message
        toPersonEmail: user

exports.use = (robot) ->
  new SparkAdapter robot
