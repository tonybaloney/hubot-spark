[ spark, assert, nock, mock_robot, mock_realtime ] = require "./test_helper"

describe "spark adapter", ->
    before ->
        bot =
            send: (user, message) ->
                assert.equal(message, "test")
                return true
        spark.bot = bot

    it "accepts a simple message", (done) ->
        resp = spark.send "test", ["test"]
        done()