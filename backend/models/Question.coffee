# Question model

mongoose  = require "mongoose"
_         = require 'lodash'

Story     = require "./Story"
Answer    = require "./Answer"

schema  = new mongoose.Schema
  text      :
    type      : String
    required  : yes
    unique    : yes
    trim      : yes
  tags      : [
    type      : String
    trim      : yes
  ]

schema.pre "validate", (done) ->
  @tags = _.unique @tags
  do done

schema.methods.findStories = (conditions, callback) ->
  if (not callback) and typeof conditions is "function"
    callback = conditions
    conditions = {}

  conditions.questions = @id

  Story.find conditions, callback

schema.methods.findAnswers = (conditions, callback) ->
  if (not callback) and typeof conditions is "function"
    callback = conditions
    conditions = {}

  conditions.question = @id

  Answer
    .find conditions
    .populate 'author'
    .exec callback

schema.plugin (require "./plugins/Journal"),
  populate:
    path  : "meta.author"
    model : "Participant"

# TODO: Enable when Elasticsearch works
# schema.plugin require('./plugins/Search'),
#   collection: 'questions'

module.exports = mongoose.model 'Question', schema
