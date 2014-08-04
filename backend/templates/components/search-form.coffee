View = require "teacup-view"

module.exports = new View (attributes) ->
  {
    query
    action
  } = attributes

  @form
    method: "get"
    action: action if action
    =>
      @div class: "input-group input-group-lg", =>
        @input
          type        : "query"
          class       : "form-control"
          placeholder : @cede => @translate "What seems to be the problem?"
          name        : "search"
          value       : query.search
          data        :
            shortcut    : "/"
        @span class: "input-group-btn", =>
          @button
            class     : "btn btn-primary"
            type      : "submit"
            => @i class: "fa fa-question-circle"
