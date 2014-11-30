View      = require "teacup-view"
moment    = require "moment"

layout    = require "../layouts/default"

module.exports = new View (data) ->

  data.subtitle = @cede => @translate "Legal questions of interest"

  {
    query
    questions
    unpublished
    user
    csrf
    tags
  } = data

  layout data, =>

    @searchForm { query, tags }

    do @hr

    if questions.length
      for question in questions
        @div class: "panel panel-default", =>
          @a href: "/questions/#{question._id}", class: "panel-body list-group-item lead", =>
            @markdown question.text
          @div class: "panel-footer", =>
            for tag in question.tags or []
              @span class: 'label label-primary', tag
              @text " "
            if question.answers?.length
              @ul class: "list-inline", =>
                @strong => @translate "%d answers by:", question.answers.length
                for answer in question.answers
                  @li => @a href: "/questions/#{question._id}/##{answer._id}", answer.author?.name or @cede => @translate "unknown author"

            else @strong => @translate "No answers yet."

    else @div class: "alert alert-info", => @translate "No questions like that found. Sorry :P"

    if unpublished?.length
      @h3 => @translate "Unpublished questions"
      @p class: "text-muted", => @translate "There are drafts for those questions, but none of them is published"
      @ul => for question in unpublished
        @li => @a href:  '/questions/' + question._id, =>
          @translate "The question of %s", moment(question._id.getTimestamp()).format 'LL'


    if user?.can 'suggest a new question'
      @questionForm
        method  : "POST"
        action  : "/questions/"
        csrf    : csrf
        tags    : tags
      # @a
      #   class : "btn btn-default"
      #   herf  : "#new-question"
      #   data  :
      #     toggle  : "modal"
      #     target  : "#question-new-dialog"
      #     shortcut: "n"
      #   =>
      #     @i class: "fa fa-fw fa-plus-circle"
      #     @translate "new question"
      #
      # @modal
      #   title : @cede => @translate "New question"
      #   id    : "question-new-dialog"
      #   =>
      #     @questionForm
      #       method  : "POST"
      #       action  : "/questions/"
      #       csrf    : csrf
      #       tags    : tags
