View      = require "teacup-view"
url       = require "url"

module.exports = new View (options = {}) ->
  {
    applied   # Boolean
    draft     # JournalEntry
    actualurl # string (url to actual document)
    type      # string (question, answer, etc)
  } = options # All options except type are required

  type ?= draft.model.toLowerCase()

  author    = draft.meta?.author

  @div class: "alert alert-#{if applied then 'success' else 'info'} clearfix", =>
    @translate "This is a draft proposed %s by %s.",
      @cede => @moment draft
      author?.name or @cede => @translate "unknown author"

    if applied
      @text " "
      @translate "It is currently applied."

    @a
      href  : actualurl
      class : "btn btn-default btn-xs pull-right"
      =>
        @i class: "fa fa-fw fa-arrow-left"
        @translate "See actual #{type}"
