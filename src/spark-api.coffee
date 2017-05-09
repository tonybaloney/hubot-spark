requestPromise = require('request-promise')
Spark = require('csco-spark')

class SparkApi
  person = undefined

  constructor: (@sparkOptions) ->
    @spark = Spark
      uri: @sparkOptions.uri
      token: @sparkOptions.token

  init: () ->
    # Send a call to the API to see who "me" is (to verify credentials and if the person's a bot)
    @getPeopleMe()

  isBot: () ->
    if person
      return person.type == 'bot'
    else
      throw new Error('No person defined, did you initialize the connection?')

  getMessages: (options) ->
    # Bots can only see their own messages, which csco-spark does not support
    if @isBot()
      @getBotMessages(options)
    else
      @spark.getMessages(options)

  sendMessage: (options) ->
    @spark.sendMessage(options)

  getPeopleMe: () ->
    requestOptions =
      uri: "#{@sparkOptions.uri}/people/me"
      headers:
        'Authorization': "Bearer #{@sparkOptions.token}"

    requestPromise(requestOptions).then((response) ->
      person = JSON.parse(response)
    )

  getBotMessages: (options) ->
    requestOptions =
      uri: "#{@sparkOptions.uri}/messages"
      headers:
        'Authorization': "Bearer #{@sparkOptions.token}"
      qs:
        max: 100
        mentionedPeople: 'me'
        roomId: options.roomId

    requestPromise(requestOptions).then((res) ->
      JSON.parse(res).items
    )

module.exports = SparkApi