View      = require "teacup-view"
_         = require "lodash"

module.exports = new View (options = {}) ->
  _.defaults options,
    icon      : "caret-down"
    emphasis  : "default"      # info, danger, link, etc.
    items     : []

    # Each item should be a hash with properties:
    #   title
    #   icon
    #   href
    #   data

  {
    icon
    emphasis
    items
  } = options

  @button
    class : "btn btn-#{emphasis}  dropdown-toggle"
    data  :
      toggle: "dropdown"
    =>
      @i class: "fa fa-#{icon}"
      @span class: "sr-only", "Toggle dropdown"

  @ul class: "dropdown-menu", role: "menu", =>
    for item in items
      @li role  : "presentation", => 
        @a 
          role    : "menuitem"
          tabindex: -1
          href    : item.href
          data    : item.data
          =>
            @i class: "fa fa-" + item.icon or "cog"
            @text " " + item.title
