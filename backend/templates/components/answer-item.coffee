View      = require "teacup-view"

module.exports = new View (options = {}, content) ->
  if not options.answer
    throw new Error "No answer provided for answer-item component"

  {
    _id  : id
    text
    basis
    author
    question
  } = options.answer

  @div class: "panel panel-default", id: "answer-#{id}", =>
    @div class: "panel-heading clearfix", =>
      @strong class: "text-muted", =>
        @translate "by %s (%s):",
          author?.name or @cede => @translate "unknown author"
          @cede => @moment id
      @a
        href  : "/questions/#{question}/answers/#{id}"
        class: "btn btn-xs pull-right"
        => @i class: "fa fa-expand"

    @div class: "panel-body clearfix", =>

      @markdown text

      if typeof content is 'function'
        do content
      else
        @text content
