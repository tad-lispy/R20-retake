View = require "teacup-view"

module.exports = new View (attributes) ->
  {
    query
    action
  } = attributes
  @form
    method: "get"
    action: action if action
    id          : "search"
    =>
      @div class: "form-group", =>
        @textarea
          type        : "text"
          name        : "search"
          class       : "form-control input-lg"
          placeholder : @cede => @translate "What seems to be the problem?"
          data        :
            shortcut    : "/"
          query.search

      @div class: "form-group", =>
        @button
          class : "btn btn-primary btn-block btn-lg"
          type  : "submit"
          =>
            @i class: "fa fa-fw fa-question-circle"
            @translate "Search"
