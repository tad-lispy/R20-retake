config   = require 'config-object'
path     = require 'path'

dirname  = process.cwd()

module.exports = ->
  try
    config.load [
      path.resolve dirname, 'defaults.cson'
      path.resolve dirname, 'package.json'
    ], required: yes
  catch error
    if error.message is 'File not found' then error.message = """
      Can't load required configuration file (#{error.filename}).

      Make sure you start process from project root (where package.json is). It expects it's configuration files to be in process.cwd().

      If using PM2, you probabily have to use .json configuration file and set cwd option there.
    """
    throw error

  # User provided configuration is optional
  config.load path.resolve dirname, 'config.cson'

  # Configure templates
  require('teacup-view').load_components __dirname + '/templates/components'
