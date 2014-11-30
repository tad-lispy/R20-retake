View = require "teacup-view"

module.exports = new View (attributes) ->
  {
    query
    action
    tags
  } = attributes

  @form
    id    : "search"
    method: "get"
    action: action if action
    =>
      @div class: "form-group", =>
        @select
          name        : "tags"
          class       : "form-control tags"
          multiple    : yes
          placeholder : @cede =>
            @translate "Select tags to view corresponding questions."
          data        :
            shortcut    : "/"
          =>
            for tag in tags
              @option selected: tag in (query.tags or []), tag

      @div class: "form-group", =>
        @button
          class : "btn btn-primary btn-block btn-lg"
          type  : "submit"
          =>
            @i class: "fa fa-fw fa-question-circle"
            @translate "Search"
