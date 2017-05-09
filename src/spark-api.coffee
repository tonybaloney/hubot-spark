Spark = require('csco-spark')

class SparkApi
  constructor: (options) ->
    @spark = Spark
      uri: options.uri
      token: options.token

  getMessages: (options) ->
    @spark.getMessages(options)

  sendMessage: (options) ->
    @spark.sendMessage(arguments)

module.exports = SparkApi