# Story model

mongoose  = require "mongoose"
_         = require "lodash"

Story = new mongoose.Schema
  text        :
    type        : String
    trim        : yes
    required    : yes
  questions : [
    type      : mongoose.Schema.ObjectId
    ref       : 'Question'
    index     : yes
  ]

Story.pre "validate", (done) ->
  @questions = _.unique @questions.map (oid) -> do oid.toString
  do done

Story.plugin (require "./plugins/Journal"),
  omit:
    questions: true
  populate: [
    path  : "meta.author"
    model : "Participant"
  ,
    path  : "data.main_doc"
    model : "Story"
  ,
    path  : "data.referenced_doc"
    model : "Question"
  ]

# TODO: Enable when Elasticsearch works
# Story.plugin require('./plugins/Search'),
#   collection: 'stories'

module.exports = mongoose.model 'Story', Story
