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
      @div class: "form-group", =>
        @textarea
          id          : "search"
          type        : "text"
          name        : "search"
          class       : "form-control input-lg"
          placeholder : @cede => @translate "What seems to be the problem?"
          value       : query.search
          data        :
            shortcut    : "/"

      @div class: "form-group", =>
        @button
          class : "btn btn-primary btn-block btn-lg"
          type  : "submit"
          =>
            @i class: "fa fa-fw fa-question-circle"
            @translate "Search"
