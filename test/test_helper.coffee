mock_robot =
  logger:
    error: (msg) ->
      mock_robot.logs.error.push msg
      mock_robot.onError(msg) if mock_robot.onError?
    debug: (msg) ->
      mock_robot.logs.debug.push msg
    info: (msg) ->
      mock_robot.logs.debug.push msg
  clean: ->
    mock_robot.onError = null
    mock_robot.logs = { error: [], debug: [] }

mock_realtime = 
  send: (user, message) ->
     return

sparkbot = require("../src/spark")
spark = sparkbot.use mock_robot
nock = require("nock")
module.exports = [ spark, require("assert"), nock, mock_robot, mock_realtime ]

beforeEach ->
  nock.cleanAll()
  mock_robot.clean()
  process.env.HUBOT_SPARK_ACCESS_TOKEN='test'
  # spark.run()