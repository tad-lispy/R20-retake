View      = require "teacup-view"
layout    = require "../layouts/default"

module.exports = new View (data) ->
  debugger
  {
    answer
    entry
    csrf
    journal
    question
  } = data

  data.classes ?= []
  data.classes.push "answer"
  if entry then data.classes.push "draft"

  if entry then question ?= entry.data.question
  else          question ?= answer.question

  unless answer.isNew
    author = entry?.data.author or answer.author
    data.subtitle = @cede => @translate "%s answers: %s", author.name, question.text

  layout data, =>
    if entry?
      applied = Boolean answer._draft?.equals entry._id

      @draftAlert
        applied   : applied
        draft     : entry
        actualurl : "/questions/#{question._id}/answers/#{answer?._id or entry?.data._id}"

    # The answer
    @div class: "jumbotron", =>
      if entry?
        @markdown entry.data.text

        # Apply form
        @form
          action: "/questions/#{question._id}/answers/#{entry.data._id}/journal/#{entry.id}/apply"
          method: "POST"
          class : "clearfix"
          =>
            @input type: "hidden", name: "_csrf"  , value: data.csrf

            @div class: "btn-group pull-right", =>
              @button
                class   : "btn btn-success"
                type    : "submit"
                disabled: applied
                data    : shortcut: "a a enter"
                =>
                  @i class: "fa fa-fw fa-check-square"
                  @translate "apply this draft"

              @dropdown items: [
                title : @cede => @translate "make changes"
                href  : "#edit-answer"
                icon  : "edit"
                data  :
                  toggle  : "modal"
                  target  : "#answer-edit-dialog"
                  shortcut: "e"
              ]

      else if answer.isNew
        @p class: "text-muted", =>
          @i class: "fa fa-fw fa-info-circle"
          @translate "Not published yet."
        @div class: "clearfix", => @div class: "btn-group pull-right", =>
          @a
            class : "btn btn-default"
            href  : "/questions/#{question._id}"
            =>
              @i class: "fa fa-arrow-left fa-fw"
              @translate "Back to question"

      else
        @markdown answer.text

        @div class: "clearfix", => @div class: "btn-group pull-right", =>
          @a
            class : "btn btn-default"
            href  : "/questions/#{question._id}"
            =>
              @i class: "fa fa-arrow-left fa-fw"
              @translate "Back to question"
          @dropdown items: [
            title : @cede => @translate "make changes"
            href  : "#edit"
            icon  : "edit"
            data  :
              toggle  : "modal"
              target  : "#answer-edit-dialog"
              shortcut: "e"
          ,
            title : @cede => @translate "remove answer"
            href  : "#remove"
            icon  : "times-circle"
            data  :
              toggle  : "modal"
              target  : "#remove-dialog"
              shortcut: "del enter"
          ]

    unless answer.isNew and not entry?
      @modal
        title : question.text
        id    : "answer-edit-dialog"
        =>
          @answerForm
            method  : "POST"
            action  : "/questions/#{question._id}/answers/#{answer._id}"
            csrf    : csrf
            answer  : entry?.data or answer
            question: question

    unless answer.isNew or entry?
      @modal
        title : @cede => @translate "Remove this answer?"
        id    : "remove-dialog"
        class : "modal-danger"
        =>
          @form
            method: "post"
            =>
              @input type: "hidden", name: "_csrf"   , value: csrf
              @input type: "hidden", name: "_method" , value: "DELETE"

              @div class: "well", =>
                @markdown answer.text

              @p => @translate "Removing an answer is roughly equivalent to unpublishing it. It can be undone. All drafts will be preserved."

              @div class: "form-group", =>
                @button
                  type  : "submit"
                  class : "btn btn-danger"
                  =>
                    @i class: "fa fa-fw fa-times-circle"
                    @translate "Remove!"

    @h4 class: "text-muted", =>
      @i class: "fa fa-time fa-fw"
      @translate "Versions"
    @draftsTable
      drafts  : journal.filter (entry) -> entry.action is "draft"
      applied : answer?._draft
      chosen  : entry?._id
      root    : "/questions/#{question._id}/answers/"
