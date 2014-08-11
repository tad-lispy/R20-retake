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
  } = data

  layout data, =>

    @form
      method: "GET"
      =>
        @div class: "input-group input-group-lg", =>
          @input
            id          : "search"
            type        : "text"
            name        : "search"
            class       : "form-control"
            placeholder : @cede => @translate "Type to search for questions..."
            value       : query.search
            data        :
              shortcut    : "/"
          @div class: "input-group-btn", =>
            @button
              class : "btn btn-primary"
              type  : "submit"
              =>
                @i class: "fa fa-fw fa-search"
                @translate "Search"

            if user?.can 'suggest a new question' then @dropdown items: [
              title : @cede => @translate "new question"
              icon  : "plus-circle"
              data  :
                toggle  : "modal"
                target  : "#question-new-dialog"
                shortcut: "n"
              herf  : "#new-question"
            ]

    do @hr

    if questions.length
      for question in questions
        @div class: "panel panel-default", =>
          @a href: "/questions/#{question._id}", class: "panel-body list-group-item lead", =>
            @markdown question.text
          @div class: "panel-footer", =>
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


    if user?.can 'suggest a new question' then @modal
      title : @cede => @translate "New question"
      id    : "question-new-dialog"
      =>
        @questionForm
          method  : "POST"
          action  : "/questions/"
          csrf    : csrf
