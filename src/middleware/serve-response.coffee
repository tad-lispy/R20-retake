cson  = require 'cson'

module.exports = (code, data) ->
  if not data then [data, code] = [code, 200]

  console.log "Serving response:"
  console.log cson.stringifySync data
  console.log ""

  @format
    json: => @json code, data
    html: => @send code, "Not supported yet." # @template @data
