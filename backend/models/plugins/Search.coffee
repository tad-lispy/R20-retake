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
  debugger

  async.series [
    (done) -> es.transport.request
      method: 'DELETE'
      path  : 'r20'
      ignore: 404
      done

    (done) -> es.transport.request
      method: 'DELETE'
      path  : "_river/r20-#{collection}"
      ignore: 404
      done

    (done) -> es.transport.request
      method: 'PUT'
      path  : 'r20'
      body  : settings: index: analysis: analyzer: default: type: "morfologik"

    (done) -> es.transport.request
      method: 'PUT'
      path  : "_river/r20-#{collection}/_meta"
      body  :
        type: "mongodb"
        mongodb:
          servers: [
            host: 'mongo' # TODO: smarter
          ]
          db: "r20"
          collection: collection
        index:
          name: "r20"
          type: collection
      done
  ], (error) ->
    if error then throw error

  schema.static 'search', (query, callback) ->
    es.search
      index: 'r20'
      type : collection
      body : "kot"
