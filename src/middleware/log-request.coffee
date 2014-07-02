_     = require 'underscore.string'
cson  = require 'cson'

module.exports = (req, res, next) ->
  console.log "#{_.rpad req.method, 10} #{req.url}"
  console.log cson.stringifySync req.body
  console.log ""

  next()
