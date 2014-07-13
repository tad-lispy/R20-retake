# do require('source-map-support').install

# Initialization and config
console.log 'Charging R20...'

express  = require 'express'
mongoose = require 'mongoose'
config   = require 'config-object'

app     = new express
config.load [
  '../defaults.cson'
  '../package.json'
  '../config.cson'
]

# Configure templates
require('teacup-view').load_components __dirname + '/templates/components'

# Connect to data store
mongoose.connect Array(config.mongo.url).join ','

# Load middleware
app.use require('cookie-parser')()
app.use require('body-parser').json()
app.use require('body-parser').urlencoded()
app.use require('express-session') secret: config.app.secret
app.use require('passport').initialize()
app.use require('passport').session()
app.use require './middleware/log-request'

express.response.serve = require './middleware/serve-response'

# Load routers
app.use '/', require './routers'


# Fire!
app.listen config.port
console.log "Boom! There is something going on at #{config.scheme}://#{config.host}:#{config.port}"
