# Search mongoose plugin
#
# Extends Model with a static search method
# uses elasticsearch.
# It requires ES nodes to have [river-mongodb plugin](https://github.com/richardwilly98/elasticsearch-river-mongodb) enabled.

elasticsearch = require "elasticsearch"
Error2        = require "error2"
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
  es.transport.request
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

  schema.static 'search', (query, callback) ->
