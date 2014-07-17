View      = require "teacup-view"
fs        = require "fs"
_         = require "lodash"
_.string  = require "underscore.string"

layout    = require "../layouts/default"

module.exports = new View (data) ->
  {
    query
    participant
    csrf
    user
  } = data
  data.subtitle = data.participant.name

  layout data, =>

    @div class: "jumbotron", =>
      @markdown participant.bio or ""
      if user.id is participant.id then @p participant.email

    # List of answers
    # @div class: "row", =>
    #   for participant in participants
    #     @div class: "col-md-4 col-sm-12", =>
    #       @profileBox {participant, show_auth: no}
