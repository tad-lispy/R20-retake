View = require "teacup-view"

module.exports = new View (attributes) ->
  {
    query
    action
    tags
    shortcut
    params
  } = attributes

  # TODO: make reusable method of teacup-view, like @required ['tags', 'query']
  if not tags
    throw new Error "No tags provided for search-form component"
  if not query
    throw new Error "No query provided for search-form component"

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
            shortcut    : shortcut or "/"
          =>
            for tag in tags
              @option selected: tag in (query.tags or []), tag

      if params then for key, value of params
        @input
          name        : key
          value       : value
          type        : 'hidden'

      @div class: "form-group", =>
        @button
          class : "btn btn-primary btn-block btn-lg"
          type  : "submit"
          =>
            @i class: "fa fa-fw fa-question-circle"
            @translate "Search"
