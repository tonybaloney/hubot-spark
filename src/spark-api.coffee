spark = undefined

class SparkApi
  person = undefined

  constructor: (@sparkOptions) ->
    @uri = @sparkOptions.uri
    @token = @sparkOptions.token

    process.env['CISCOSPARK_ACCESS_TOKEN'] = @token
    process.env['HYDRA_SERVICE_URL'] = @uri
    spark = require('ciscospark')

  init: () ->
    spark.people.get({id: 'me'}).then((response) ->
      person = response
    )

  isBot: () ->
    if person
      return person.type == 'bot'
    else
      throw new Error('No person defined, did you initialize the connection?')

  getMessages: (options) ->
    if @isBot()
      options.mentionedPeople = 'me'
      options.max = 100
    spark.messages.list(options).then((messages) ->
      messages.items
    )

  sendMessage: (options) ->
    spark.messages.create(options)

module.exports = SparkApi
