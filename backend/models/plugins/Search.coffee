# Search mongoose plugin
#
# Extends Model with a static search method
# uses elasticsearch.
# It requires ES nodes to have [river-mongodb plugin](https://github.com/richardwilly98/elasticsearch-river-mongodb) enabled.

elasticsearch = require "elasticsearch"
Error2        = require "error2"
async         = require "async"
URL           = require "url"
_             = require "lodash"
util          = require "util"

config        = require "config-object"

es = new elasticsearch.Client config.get 'elasticsearch'
es.ping
  requestTimeout: 1000
  (error) -> if error then throw new Error2 "Elasticsearch is not reachable at #{config.get 'elasticsearch/hosts'}"


module.exports = (schema, options = {}) ->
  { collection } = options

  async.waterfall [
    # If index doesn't exist, then create it
    (done) ->
      es.indices.exists
        index: 'r20'
        done

    (exists, status, done) ->
      if not exists then return es.indices.create
        index: 'r20'
        body : settings: index: analysis: analyzer: default: type: "morfologik"
        done
      else setImmediate done

  ], (error) ->
    if error then throw error

  schema.static 'reindex', (callback) ->
    async.waterfall [
      (done) ->
        es.deleteByQuery
          index : 'r20'
          type  : collection
          body  : query: match_all: {}
          (error) -> done error
      (done) =>
        console.log "Looging for #{collection}"
        @find done
      (documents, done) ->
        console.log "Indexing #{documents.length} #{collection}"
        async.eachLimit documents, 16, (document, done) ->
          es.index
            index : 'r20'
            type  : collection
            id    : document.id
            body  : document
            (error) ->
              console.log "done inserting %d", document._id
              done error
    ], callback

  schema.post 'save', (document) ->
    es.index
      index : 'r20'
      type  : collection
      id    : document.id
      body  : document
      (error) -> if error then throw error

  schema.post 'remove', (document) ->
    es.delete
      index : 'r20'
      type  : collection
      id    : document.id
      ignore: 404
      (error) -> if error then throw error

  schema.static 'search', (query, callback) ->
    if typeof query is 'string'
      query = q: query
    else
      query = body: query

    query.index = 'r20'
    query.type  = collection

    async.waterfall [
      (done) -> es.search query, done

      (response, status, done) ->
        done null, response.hits.hits.map (hit) ->
          document: hit._id
          score   : hit._score

      (documents, done) =>
        @populate documents,
          path: 'document'
          done

    ], callback
