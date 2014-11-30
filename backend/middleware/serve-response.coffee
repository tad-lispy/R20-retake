cson  = require 'cson'
_     = require 'lodash'

module.exports = (code, data) ->
  if not data then [data, code] = [code, 200]
  data ?= {}

  # Add common properties to served data
  _.extend data, _.pick @, [
    'csrf'
  ]
  _.extend data, _.pick @req, [
    'user'
    'query'
    'tags'
  ]


  console.log "Serving response:"
  console.log cson.stringifySync data
  console.log ""

  @format
    json: =>
      @status code
      @json data
    html: =>
      if not @template
        console.error "[!] View for #{@req.method} #{@req.originalUrl} not implemented."
        console.log   ""

        code       = 501
        @template  = -> "View not implemented yet. Sorry."

      @status code
      @send @template data
