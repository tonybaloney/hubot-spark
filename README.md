# Hubot Spark Adapter

[![Build Status](https://travis-ci.org/tonybaloney/hubot-spark.svg?branch=master)](https://travis-ci.org/tonybaloney/hubot-spark)

[![npm version](https://badge.fury.io/js/hubot-spark.svg)](https://badge.fury.io/js/hubot-spark)

## Description

This is the [Cisco Spark](https://developer.ciscospark.com) adapter for [Hubot](https://github.com/github/hubot) that allows communication in Spark channels.

## Installation

* Install dependencies with `npm install`
* Set environment variables (below)
* Run hubot with `bin/hubot -a spark -n name`

## Configuration

The following environment variables are required for connecting : 

* `HUBOT_SPARK_API_URI` - (optional, defaults to "https://api.ciscospark.com/v1")
* `HUBOT_SPARK_ACCESS_TOKEN` - Your API access token, generated from the Cisco Spark developer console
* `HUBOT_SPARK_ROOMS` - A list of room IDs that you want your bot to listen to, seperated with commas.

## Thanks

I copied the framework from [hubot-yammer](https://github.com/athieriot/hubot-yammer) who copied it from [hubot-twitter](https://github.com/MathildeLemee/hubot-twitter.git) 
