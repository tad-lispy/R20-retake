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

  conditions.questions = @._id

  Story.find conditions, callback

Question.methods.findAnswers = (conditions, callback) ->
  if (not callback) and typeof conditions is "function"
    callback = conditions
    conditions = {}

  conditions.question = @._id

  Answer.find conditions, callback

Question.plugin (require "./plugins/Journal"),
  populate:
    path  : "meta.author"
    model : "Participant"


module.exports = mongoose.model 'Question', Question
