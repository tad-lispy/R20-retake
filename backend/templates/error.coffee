View = require "teacup-view"

layout  = require "./layouts/default"

module.exports = new View (error) ->
  layout =>
    @div class : "error jumbotron", =>
      @h1 => @span class: "text-danger", =>
        @i class: "fa fa-fw fa-exclamation-triangle"
        @text " "
        @text "#{error.code} Error: #{error.name}"

      @p error.message
      @pre JSON.stringify error, null, 2
