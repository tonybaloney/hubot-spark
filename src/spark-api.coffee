
Webex = require('webex')
webex = undefined

class SparkApi
  person = undefined

  constructor: (@sparkOptions) ->
    @uri = @sparkOptions.uri
    @token = @sparkOptions.token

    process.env['CISCOSPARK_ACCESS_TOKEN'] = @token
    process.env['HYDRA_SERVICE_URL'] = @uri
    webex = Webex.init({
      credentials: {
        access_token: @token
      }
    })


  init: () ->
    webex.people.get('me').then((response) ->
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
    webex.messages.list(options).then((messages) ->
      messages.items
    )

  sendMessage: (options) ->
    webex.messages.create(options)
  
  getRooms: (options) ->
    webex.rooms.list(options).then((rooms) ->
      rooms.items
    )


module.exports = SparkApi
