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

# Try to read mongodb servers from river configuration.
# Upon failure, try to guess them from mongo configuration.
# The later is default behaviour.
mongoservers = config.get "elasticsearch/river/mongo/servers" or config.get "mongo/url"

# Normalize whatever we got from config
mongoservers = [ mongoservers ] unless util.isArray mongoservers
mongoservers = mongoservers.map (url) ->
  if 'host' of url then return url
  url = URL.parse url
  return {
    host: url.hostname
    port: url.port
  }

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
      if not exists then es.indices.create
        index: 'r20'
        body : settings: index: analysis: analyzer: default: type: "morfologik"
        done
      else process.nextTick -> done null, null, true

    # Remove river if exists
    (response, status, done) -> es.transport.request
      method: 'DELETE'
      path  : "_river/r20-#{collection}"
      ignore: [404]
      done

    # Remove all documents from this collection
    (response, status, done) -> es.transport.request
      method: 'DELETE'
      path  : "r20/#{collection}"
      ignore: [404]
      done

    # Recreate river
    (response, status, done) ->
      es.transport.request
        method: 'PUT'
        path  : "_river/r20-#{collection}/_meta"
        body  :
          type: "mongodb"
          mongodb:
            servers: mongoservers # See beggining of file
            db: "R20"
            collection: collection
          index:
            name: "r20"
            type: collection
        done
  ], (error) ->
    if error then throw error

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
