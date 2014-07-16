do require('source-map-support').install unless process.argv[0] is 'coffee'

# Initialization and config
console.log 'Charging R20...'

express  = require 'express'
mongoose = require 'mongoose'
path     = require "path"
config   = require 'config-object'

# Load configuration into config-object and do some other setup stuff
do require './setup'

# Connect to data store
mongoose.connect Array(config.mongo.url).join ','

# Load middleware
app      = new express

session  = require 'express-session'
Store    = require('connect-mongo') session

app.use require('cookie-parser')()
app.use require('body-parser').json()
app.use require('body-parser').urlencoded()
app.use session
  cookie: maxAge: 24 * 60 * 60 * 1000
  secret: config.app.secret
  store : new Store db: mongoose.connections[0].db
app.use require('passport').initialize()
app.use require('passport').session()
app.use require './middleware/log-request'
app.use require './middleware/secure-request'

# Serve static files
app.use "/", express.static path.resolve process.cwd(), "build/frontend/"

# Add useful serve method to response object protorype
express.response.serve = require './middleware/serve-response'

# Load routers
app.use '/', require './routers'

# Contrary to Express guide, error middleware MUST be declared last
# Otherwise it wont work be triggered if error is passed to req.next of later middleware (eg. routers)
app.use require './middleware/error'

# Fire!
app.listen config.port
console.log "Boom! There is something going on at #{config.scheme}://#{config.host}:#{config.port}"
