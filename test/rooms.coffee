[ spark, assert, nock, mock_robot, mock_realtime ] = require "./test_helper"

describe "spark adapter", ->
    it "accepts a simple message", (done) ->
        spark.bot = mock_realtime
        spark.send "test", ["test"]
        done()