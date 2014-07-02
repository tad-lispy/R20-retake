# Initialization and config
console.log 'Charging R20...'

express = require 'express'
config  = require 'config-object'

app     = new express
config.load [
  '../defaults.cson'
  '../package.json'
  '../config.cson'
]

# Controllers and other middleware
app.use require('body-parser').json()
app.use require './middleware/log-request'

app.get '/', (req, res) ->
  res.send 'Hello, R20.'

app.listen config.port
console.log "Boom! There is something going on at #{config.scheme}://#{config.host}:#{config.port}"
