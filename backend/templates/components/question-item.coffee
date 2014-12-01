View      = require "teacup-view"

module.exports = new View (options = {}, content) ->
  if not options.question
    throw new Error "No question provided for question-item component"

  {
    _id  : id
    text
    tags
    answers
  } = options.question
  @div class: 'panel', =>
    @a
      href  : "/questions/#{id}"
      class : "panel-body list-group-item"
      =>
        @div class : "lead", => @markdown text

        @ul class: "list-inline tags", =>
          for tag in tags or []
            @li => @span class: 'label label-primary', tag

          if answers?.length then for answer in answers
            @li => @span
              class: "label label-success"
              answer.author?.name or @cede => @translate "unknown author"

          else
            @li => @span
              class: 'label label-default', =>
              @cede => @translate "No answers yet."

        if typeof content is 'function'
          do content
        else
          @text content
