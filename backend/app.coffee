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

# Configure templates
Template = require 'teacup-view'
Template.load_components 'templates/components'

# Controllers and other middleware
app.use require('body-parser').json()
app.use require './middleware/log-request'

express.response.serve = require './middleware/serve-response'

app.get '/', (req, res) ->
  res.template = require './templates/home'
  res.serve 'Hello, R20.'

# Load routers
app.use "/#{route}", require "./routers/#{route}" for route in [
  'stories'
  # TODO:
  # 'questions'
  # 'answers'
  # 'participants'
]

app.listen config.port
console.log "Boom! There is something going on at #{config.scheme}://#{config.host}:#{config.port}"
