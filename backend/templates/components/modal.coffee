_         = require "lodash"
View      = require "teacup-view"

module.exports = new View (options = {}, content) ->
  if not content and typeof options is "function"
    content = options
    options = {}

  {
    id
    title
  } = options

  @div
    class   : "modal fade"
    id      : id
    role    : "dialog"
    =>
      @div class: "modal-dialog #{options.class or ''}", =>
        @div class: "modal-content", =>
          
          @div class: "modal-header", =>
            @button
              type  : "button"
              class : "close"
              data:
                dismiss: "modal"
              aria:
                hidden: true
              => @i class: "fa fa-times fa-2x"
            @h4 title
          
          @div class: "modal-body", =>
            if      typeof content is "function"  then do   content
            else if typeof content is "string"    then @raw content

