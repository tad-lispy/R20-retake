# Question model

mongoose  = require "mongoose"

Story     = require "./Story"
Answer    = require "./Answer"

Question  = new mongoose.Schema
  text      :
    type      : String
    required  : yes
    unique    : yes

Question.methods.findStories = (conditions, callback) ->
  if (not callback) and typeof conditions is "function"
    callback = conditions
    conditions = {}

  conditions.questions = @id

  Story.find conditions, callback

Question.methods.findAnswers = (conditions, callback) ->
  if (not callback) and typeof conditions is "function"
    callback = conditions
    conditions = {}

  conditions.question = @id

  Answer.find conditions, callback

Question.plugin (require "./plugins/Journal"),
  populate:
    path  : "meta.author"
    model : "Participant"

Question.plugin require('./plugins/Search'),
  collection: 'questions'

module.exports = mongoose.model 'Question', Question
