# Journal plugin

_         = require "lodash"
mongoose  = require "mongoose"
async     = require "async"
util      = require "util"

Entry     = require "./JournalEntry"

deepOmit = (object, omit) ->
  for key, value of omit
    if object[key]? then switch typeof value
      when "object"
        if typeof object[key] is "object"
          # Go deeper
          object[key] = deepOmit object[key], value

      when "function"
        # Do callback and delete if returns true
        if value object[key] then delete object[key]
      else
        # Something else - if it's truthy then delete
        if value then delete object[key]

  return object


plugin = (schema, options = {}) ->
  options = _.defaults options,
    omit  : {}

  schema.plugin require './FindOrCreate'

  # _draft field points to currently applied draft
  schema.add
    "_draft":
      type: mongoose.Schema.ObjectId
      ref : "Journal.Entry"

  # Discover paths with references
  schema.statics.references = {}

  schema.eachPath (path, description) ->
    { type } = description.options
    if not type then return
    if util.isArray type
      relation = "has many"
      options  = type[0]
    else
      relation = "has one"
      options  = description.options

    if options.ref?
      model = options.ref
      reference = { path, relation, model }
      schema.statics.references[path] = reference

  schema.methods.saveDraft = (meta, callback) ->
    if not callback and typeof meta is "function" then callback = meta

    draft = do @.toObject
    model = @constructor.modelName


    # Don't store references and such.
    draft = deepOmit draft, options.omit

    entry = new Entry
      action: "draft"
      model : model
      data  : draft
      meta  : meta

    entry.save (error) ->
      callback error, entry

  schema.static 'findUnpublished', (query, callback) ->
    # Find all documents that have drafts, but are not stored (i.e. published)
    if not callback and typeof query is 'function' then [callback, query] = [query, {}]
    query.action = 'draft'
    query.model  = @modelName

    output = 'journal.unpublished.' + @collection.name # Output collection name

    async.waterfall [
      (done) => Entry.count done
      (count, done) =>
        if count then Entry.mapReduce
          map: -> emit @data._id, 0
          reduce: (id, published) -> Array.sum published
          query : query
          out: replace: output
          done
        else do done

      (result, stats, done) => @count done
      (count, done) =>
        if count then @mapReduce
          map: -> emit @_id, 1
          reduce: (id, published) -> Array.sum published
          out: reduce: output
          done
        else done null, undefined, 'collection doesnt exist'

      (result, stats, done) =>
        mongoose.connection.db.collection output, done
      (collection, done) => collection.find(value: 0).toArray(done)
    ], callback


  schema.methods.saveReference = (path, document, meta, callback) ->
    if not callback and typeof meta is "function"
      callback  = meta
      meta      = {}

    reference = @constructor.references[path]
    ref_model = document.constructor
    if ref_model.modelName isnt reference.model
      return callback Error "Reference model doesn't match document"

    entry = new Entry
      action: "reference"
      model : @constructor.modelName
      data  :
        reference : reference
        main      : @_id
        referenced: document._id
      meta  : meta

    entry.save (error) ->
      if error then return callback error
      callback null, entry

  schema.methods.removeReference = (path, document, meta, callback) ->
    if not callback and typeof meta is "function"
      callback  = meta
      meta      = {}

    reference = @constructor.references[path]

    entry = new Entry
      action: "unreference"
      model : @constructor.modelName
      data  :
        reference : reference
        main      : @_id
        referenced: document
      meta  : meta

    entry.save (error) ->
      if error then return callback error
      callback null, entry


  schema.methods.removeDocument = (meta, callback) ->
    # Remove document from collection while preserving all drafts.
    # Snapshot of the document will be stored in a journal.

    entry = new Entry
      action: "remove"
      model : @constructor.modelName
      data  : do @toObject
      meta  : meta

    entry.save (error) =>
      if error then return callback error

      @remove (error) ->
        if error then return entry.remove (entry_error) ->
          if entry_error then throw entry_error # Shit!
          return callback error

        callback null, entry

  schema.methods.findEntries = (conditions, callback) ->
    if not callback and typeof conditions is "function"
      callback    = conditions
      conditions  = {}

    _(conditions).extend conditions,
      model     : @constructor.modelName
      "data._id": @_id

    query = Entry
      .find(conditions)
      .sort(_id: -1)

    { populate } = options
    if populate?
      if typeof populate isnt "array" then populate = [ populate ]
      for spec in populate
        query.populate spec

    query.exec callback

module.exports = plugin
