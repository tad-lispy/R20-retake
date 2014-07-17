View      = require "teacup-view"
fs        = require "fs"
_         = require "lodash"
_.string  = require "underscore.string"

layout    = require "../layouts/default"


text      = fs.readFileSync __dirname + '/about.md', 'utf-8'

module.exports = new View (data) ->
  data.subtitle = "About us"

  {
    query
    participants
    csrf
    user
  } = data

  layout data, =>

    @div class: "jumbotron", => @markdown text


    @div class: "row", =>
      for participant in participants
        @div class: "col-md-4 col-sm-12", =>
          @profileBox {participant, show_auth: no}
