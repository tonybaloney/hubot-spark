/Copyright2016AnthonyShaw,DimensionDataLicensedundertheApacheLicense,Version2.0(the"License");youmaynotusethisfileexceptincompliancewiththeLicense.YoumayobtainacopyoftheLicenseathttp:\/\/www.apache.org\/licenses\/LICENSE-2.0Unlessrequiredbyapplicablelaworagreedtoinwriting,softwaredistributedundertheLicenseisdistributedonan"ASIS"BASIS,WITHOUTWARRANTIESORCONDITIONSOFANYKIND,eitherexpressorimplied.SeetheLicenseforthespecificlanguagegoverningpermissionsandlimitationsundertheLicense./;
var Adapter, EventEmitter, HTTPS, Robot, Spark, SparkAdapter, SparkRealtime, TextMessage;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
}, __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
  for (var i = 0, l = this.length; i < l; i++) {
    if (this[i] === item) return i;
  }
  return -1;
};
Robot = require('hubot').Robot;
Adapter = require('hubot').Adapter;
TextMessage = require('hubot').TextMessage;
HTTPS = require('https');
EventEmitter = require('events').EventEmitter;
Spark = require('csco-spark');
SparkAdapter = (function() {
  __extends(SparkAdapter, Adapter);
  function SparkAdapter(robot) {
    SparkAdapter.__super__.constructor.apply(this, arguments);
  }
  SparkAdapter.prototype.send = function() {
    var envelope, strings, user;
    envelope = arguments[0], strings = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    user = envelope.user ? envelope.user : envelope;
    return strings.forEach(__bind(function(str) {
      return this.prepare_string(str, __bind(function(message) {
        return this.bot.send(user, message);
      }, this));
    }, this));
  };
  SparkAdapter.prototype.reply = function() {
    var envelope, strings, user;
    envelope = arguments[0], strings = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    user = envelope.user ? envelope.user : envelope;
    return strings.forEach(__bind(function(str) {
      return this.prepare_string(str, __bind(function(message) {
        return this.bot.reply(user, message);
      }, this));
    }, this));
  };
  SparkAdapter.prototype.prepare_string = function(str, callback) {
    var messages, text;
    text = str;
    messages = [str];
    return messages.forEach(__bind(function(message) {
      return callback(message);
    }, this));
  };
  SparkAdapter.prototype.run = function() {
    var bot, options, self;
    self = this;
    options = {
      api_uri: process.env.HUBOT_SPARK_API_URI || "https://api.ciscospark.com/v1",
      access_token: process.env.HUBOT_SPARK_ACCESS_TOKEN,
      rooms: process.env.HUBOT_SPARK_ROOMS
    };
    bot = new SparkRealtime(options, this.robot);
    this.robot.logger.debug("Created bot, setting up listeners");
    bot.listen(new Date().toISOString(), __bind(function(messages, room_id, last_date) {
      this.robot.logger.debug("Fired listener callback for " + room_id);
      return messages.forEach(__bind(function(message) {
        var text, user, user_name;
        if (__indexOf.call(bot.room_ids, room_id) >= 0) {
          text = message.text;
          user_name = message.personEmail;
          user = {
            name: message.personEmail,
            id: message.personId,
            room: message.roomId
          };
          this.robot.logger.info("received " + text + " from " + user.name);
          return this.robot.receive(new TextMessage(user, text));
        } else {
          return this.robot.logger.info("received " + text + " from " + room_id + " but not a room we listen to.");
        }
      }, this));
    }, this));
    this.robot.logger.debug("Done with custom bot logic");
    this.bot = bot;
    return this.emit('connected');
  };
  return SparkAdapter;
})();
exports.use = function(robot) {
  return new SparkAdapter(robot);
};
SparkRealtime = (function() {
  var room_ids, self;
  __extends(SparkRealtime, EventEmitter);
  self = SparkRealtime;
  room_ids = [];
  function SparkRealtime(options, robot) {
    if (options.access_token != null) {
      this.robot = robot;
      try {
        this.robot.logger.debug("Trying connection to " + options.api_uri);
        this.spark = Spark({
          uri: options.api_uri,
          token: options.access_token
        });
        this.robot.logger.debug("Created connection instance to spark");
      } catch (e) {
        throw new Error("Failed to connect " + e.message);
      }
      this.room_ids = [];
      options.rooms.split(',').forEach(__bind(function(room_id) {
        return this.room_ids.push(room_id);
      }, this));
      this.robot.logger.debug("Completed adding rooms to list");
    } else {
      throw new Error("Not enough parameters provided. I need an access token");
    }
  }
  SparkRealtime.prototype.listen = function(date, callback) {
    return this.room_ids.forEach(__bind(function(room_id) {
      return this.spark.getMessages({
        roomId: room_id
      }).then(__bind(function(msges) {
        var newDate;
        msges.forEach(__bind(function(msg) {
          if (Date.parse(msg.created) > Date.parse(date)) {
            this.robot.logger.info("Matched new message " + msg.text);
            return callback([msg], room_id);
          }
        }, this));
        newDate = new Date().toISOString();
        return setTimeout((__bind(function() {
          return this.listen(newDate, callback);
        }, this)), 10000);
      }, this));
    }, this));
  };
  SparkRealtime.prototype.send = function(user, message, room) {
    this.robot.logger.debug("Sending message");
    return this.room_ids.forEach(__bind(function(room_id) {
      this.robot.logger.info("send message to room " + room_id + " with text " + message);
      return this.spark.sendMessage({
        roomId: room_id,
        text: message
      });
    }, this));
  };
  SparkRealtime.prototype.reply = function(user, message) {
    this.robot.logger.debug("Replying to message for " + user);
    if (user) {
      this.robot.logger.info("reply message to " + user + " with text " + message);
      return this.spark.sendMessage({
        text: message,
        toPersonEmail: user
      });
    }
  };
  return SparkRealtime;
})();