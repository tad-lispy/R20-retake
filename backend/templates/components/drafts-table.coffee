View      = require "teacup-view"
_         = require "lodash"

module.exports = new View (options) ->
  {
    drafts
    chosen
    applied
    root
  } = options

  @table class: "table table-hover table-condensed table-striped", =>
    @tr =>
      @th => @span class: "sr-only", "state"
      @th => @translate "author"
      @th => @translate "time"

    for draft in drafts
      isChosen  = chosen?   and draft._id.equals chosen
      isApplied = applied?  and draft._id.equals applied
      if      isChosen  then  icon = "dot-circle-o"
      else if isApplied then  icon = "check"
      else                    icon = "circle-o"

      url     = root + draft.data._id + "/journal/" + draft._id
      time    = @cede => @moment draft
      author  = draft.meta?.author

      @tr class: (if isChosen then "active" else if isApplied then "success"), =>

        @td =>
          @i class: "fa fa-" + icon
          @span class: "sr-only", (
            if isChosen then "chosen"
            else if isApplied then "applied"
          )

        @td =>
          if not isChosen then @a
            href: url
            author?.name or @cede => @translate "unknown author"
          else @strong author?.name or @cede => @translate "unknown author"

        @td =>
          if not isChosen then @a
            href: url
            time
          else @strong time
