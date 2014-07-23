# Search mongoose plugin
#
# Extends Model with a static search method
# uses elasticsearch.
# It requires ES nodes to have [river-mongodb plugin](https://github.com/richardwilly98/elasticsearch-river-mongodb) enabled.

elasticsearch = require "elasticsearch"
Error2        = require "error2"
async         = require "async"

config        = require "config-object"

esconfig = config.get 'elasticsearch'
esconfig.apiVersion = '1.2'
es = new elasticsearch.Client esconfig
es.ping
  requestTimeout: 1000
  (error) -> if error then throw new Error2 "Elasticsearch is not reachable at #{config.get 'elasticsearch/host'}"


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
    (response, status, done) -> es.transport.request
      method: 'PUT'
      path  : "_river/r20-#{collection}/_meta"
      body  :
        type: "mongodb"
        mongodb:
          servers: [
            host: 'mongo' # TODO: smarter
          ]
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
          score   : hit.score

      (documents, done) =>
        @populate documents,
          path: 'document'
          done

    ], callback
