cson  = require 'cson'

module.exports = (code, data) ->
  if not data then [data, code] = [code, 200]

  console.log "Serving response:"
  console.log cson.stringifySync data
  console.log ""

  @format
    json: => @json code, data
    html: =>
      if not @template
        console.error "[!] View for #{@req.method} #{@req.originalUrl} not implemented."
        console.log   ""

        code       = 501
        @template  = -> "View not implemented yet. Sorry."

      @send code, @template data
