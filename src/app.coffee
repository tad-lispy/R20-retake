console.log 'Charging R20...'

express = require 'express'
config  = require 'config-object'

app     = new express
config.load [
  '../defaults.cson'
  '../package.json'
  '../config.cson'
]

app.get '/', (req, res) ->
  res.send 'Hello, R20.'

app.listen config.port
console.log "There is something going on at #{config.scheme}://#{config.host}:#{config.port}"
