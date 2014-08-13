# This view serves as "About us" page

View      = require "teacup-view"
fs        = require "fs"
_         = require "lodash"
_.string  = require "underscore.string"

layout    = require "../layouts/default"


text      = fs.readFileSync __dirname + '/about.md', 'utf-8'

module.exports = new View (data) ->
  data.subtitle = @cede => @translate "About us"

  {
    query
    participants
    csrf
    user
  } = data

  layout data, =>

    @div class: "jumbotron", => @markdown text


    @div class: "row", =>
      @header class: "col-md-12", =>
        @h2 => @translate "Staff"
        do @hr

      for participant in participants when 'editor' in participant.roles
        @div class: "col-md-4 col-sm-12", =>
          @profileBox {participant, show_auth: no}
