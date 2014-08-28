# JournalEntry model
# Journal stores entries that describe changes to the states of documents in other collections. Those states can be used as a history of changes or collection of drafts. They can be applied to documents.

mongoose  = require "mongoose"
async     = require "async"
_         = require "lodash"

Entry = new mongoose.Schema

  action    : # What happened?
    type      : String
    required  : yes
    validate  : (value) -> value in [
      "draft"       # New draft
      "apply"       # Draft applied
      "remove"      # Document removed
      "reference"   # Reference to subdocument proposed
      "unreference" # Drop applied change (only reference ATM)
    ]

  model     : # Where?
    type      : String
    required  : yes

  data      : # What's the effect?
    type      : Object
    required  : yes

  meta      :
    type      : Object

Entry.method "apply", (meta, callback) ->
  if not callback and typeof meta is "function" then callback = meta

  try
    model = @constructor.model @model
  catch error
    return callback error

  switch @action
    when "draft"
      async.waterfall [
        (done) =>
          model.findById @data._id, (error, document) ->
            if error then return done error

            if not document then document = new model

            done null, document

        (document, done) =>
          _(document).extend  @data
          document._draft   = @_id

          done null, document
      ], (error, document) =>
        if error then return callback error

        document.save (error) =>
          if error then return callback error
          entry = new @constructor
            action: "apply"
            model : model.modelName
            data  :
              _id   : document._id
              _entry: @_id
            meta  : meta
          entry.save (error) ->
            if error then callback error
            callback null, document

    when "reference"
      {
        reference
        main
        referenced
      }           = @data
      ref_model   = mongoose.model reference.model

      async.waterfall [
        (done) =>
          ref_model.findById referenced, done

        (referenced, done) =>
          if not referenced then return done Error "Referenced document not found."

          if reference.relation is "has many"
            operation = $addToSet: {}
            operation.$addToSet[reference.path] = referenced._id
            model.findByIdAndUpdate main, operation, done
      ], (error, document) =>
        if error then return callback error
        if not document then return callback Error "Main document not found."

        entry = new @constructor
          action: "apply"
          model : model.modelName
          data  :
            _entry: @_id
          meta  : meta
        entry.save (error) ->
          if error then callback error
          callback null, document

    when "unreference"
      {
        reference
        main
        referenced
      }           = @data
      # TODO: Allow referenced to be either instanceof ObjectID or Document
      # referenced =  referenced.id unless referenced instanceof mongoose.Schema.ObjectID

      if reference.relation is "has many" then async.waterfall [
        (done) =>
          operation = $pull: {}
          operation.$pull[reference.path] = referenced
          model.findByIdAndUpdate main, operation, (error, document) ->
            if error then return done error
            if not document then return done Error "Main document not found"
            done null, document
      ], (error, document) =>
          entry = new @constructor
            action: "apply"
            model : model.modelName
            data  :
              _entry: @_id
            meta  : meta
          entry.save (error) ->
            if error then callback error
            callback null, document

    else return callback Error "Journal entry not applicable"

module.exports = mongoose.model "Journal.Entry", Entry
