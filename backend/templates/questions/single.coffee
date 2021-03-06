View      = require "teacup-view"
layout    = require "../layouts/default"

moment    = require "moment"
_         = require "lodash"

module.exports = new View (data) ->
  {
    question
    entry
    stories
    answers
    journal
    user
    csrf
    user_drafted
    tags
  } = data

  data.classes ?= []
  data.classes.push "question"
  if entry then data.classes.push "draft"
  data.scripts = [
    '//cdnjs.cloudflare.com/ajax/libs/select2/3.5.2/select2.min.js'
    '/scripts/tags.js'
  ]

  subtitle =  if draft? then draft.text else
              if not question.isNew then question.text
  if subtitle then data.subtitle = subtitle

  layout data, =>
    if entry?
      applied  = Boolean question._draft?.equals entry._id

      @draftAlert
        applied   : applied
        draft     : entry
        actualurl : "/questions/#{question._id}"

    # The question
    @div class: "jumbotron", =>
      if entry?
        @markdown entry.data.text
        for tag in entry.data.tags or []
          @span class: 'label label-primary', tag
          @text " "

        @form
          action: "/questions/#{question.id}/journal/#{entry.id}/apply"
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

              if user?.can 'suggest a new question' then @dropdown items: [
                title : @cede => @translate "make changes"
                href  : "#edit-question"
                icon  : "edit"
                data  :
                  toggle  : "modal"
                  target  : "#question-edit-dialog"
                  shortcut: "e"
              ]

      else if question.isNew
        @p class: "text-muted", =>
          @i class: "fa fa-info-circle fa-fw"
          @translate "Not published yet."

      else
        @markdown question.text

        for tag in question.tags or []
          @span class: 'label label-primary', tag
          @text " "


        @div class: "clearfix", => @div class: "btn-group pull-right", =>
          @button
            class: "btn btn-default"
            disabled: not Boolean stories?.length
            data:
              toggle:   "modal"
              target:   "#stories-dialog"
              shortcut: "s"
            =>
              @i class: "fa fa-comment fa-fw"
              @text " "
              @translate "sample stories (%d)", stories?.length or 0

          if user?.can 'suggest a new question' then @dropdown items: [
            title : @cede => @translate "make changes"
            href  : "#edit"
            icon  : "edit"
            data  :
              toggle  : "modal"
              target  : "#question-edit-dialog"
              shortcut: "e"
          ,
            title : @cede => @translate "show drafts"
            href  : "#drafts"
            icon  : "clock-o"
            data  :
              toggle  : "modal"
              target  : "#drafts-dialog"
              shortcut: "d"
          ,
            title : @cede => @translate "remove question"
            href  : "#remove"
            icon  : "trash-o"
            data  :
              toggle  : "modal"
              target  : "#remove-dialog"
              shortcut: "del enter"
          ]

    unless question.isNew and not entry?
      @modal
        title : @cede => @translate "Edit this question"
        id    : "question-edit-dialog"
        => @questionForm
          method  : "POST"
          action  : "/questions/#{question.id}"
          csrf    : csrf
          question: entry?.data or question
          tags    : tags

    if entry? or question.isNew
      @h4 class: "text-muted", =>
        @i class: "fa  fa-fw fa-clock"
        @translate "Versions"
      @draftsTable
        drafts  : journal.filter (entry) -> entry.action is "draft"
        applied : question?._draft
        chosen  : entry?._id
        root    : "/questions/"

    else
      @modal
        title : @cede => @translate "Remove this question?"
        id    : "remove-dialog"
        class : "modal-danger"
        =>
          @form
            method: "post"
            =>
              @input type: "hidden", name: "_csrf"   , value: csrf
              @input type: "hidden", name: "_method" , value: "DELETE"

              @div class: "well", =>
                @markdown question.text

              @p => @translate "Removing a question is roughly equivalent to unpublishing it. It can be undone. All drafts will be preserved."

              @div class: "form-group", =>
                @button
                  type  : "submit"
                  class : "btn btn-danger"
                  =>
                    @i class: "fa fa-fw fa-trash-o"
                    @translate "Remove!"

      # Drafts modal is used in published question view only.
      # In other views (drafts or unpublished) drafts table is below text.
      @modal
        title : @cede => @translate "Drafts of this question"
        id    : "drafts-dialog"
        =>
          @draftsTable
            drafts  : journal.filter (entry) -> entry.action is "draft"
            applied : question?._draft
            chosen  : entry?._id
            root    : "/questions/"

      @h4 class: "text-muted", =>
        @i class: "fa fa-puzzle-piece fa-fw"
        @translate "Answers"
      if answers?.length then @answerItem {answer} for answer in answers

      else @div class: "alert alert-info", =>
        @p =>
          @i class: "fa fa-fw fa-frown-o"
          @translate "No answers to this question yet."

      # Display new answer form unless this participant already answered this question
      if user?.can 'answer a question' then unless  (_.any answers, (answer) -> answer.author?._id?.equals user._id)
        if user_drafted? then @div class: "alert alert-info", =>
          @translate "There is at least one draft of your answer to this question"
          @a
            href  : "/questions/#{question._id}/answers/#{user_drafted._id}"
            class: "btn btn-default btn-xs pull-right"
            =>
              @i class: "fa fa-file-o fa-fw"
              @translate "see drafts"

        else @form
          id    : "new-answer"
          method: "POST"
          action: "/questions/#{question._id}/answers"
          =>
            @div class: "form-group", =>
              @label for: "text", => @translate "Answer by %s", user.name
              @textarea
                class       : "form-control"
                name        : "text"
                placeholder : @cede => @translate "Know the answer? Please share it..."
                data        :
                  shortcut    : "a"

            @div class: "form-group", =>
              @button
                type  : "submit"
                class : "btn btn-primary"
                =>
                  @i class: "fa fa-fw fa-check-square"
                  @translate "send"
            @input type: "hidden", name: "_csrf", value: csrf

    if stories?.length then @modal
      title : @cede => @translate "Sample stories"
      id    : "stories-dialog"
      =>
        @div class: "modal-body", =>
          @div
            id      : "stories-carousel"
            class   : "carousel slide"
            data    :
              ride    : "carousel"
              interval: "false"
            =>
              @div class: "carousel-inner", =>
                for story, n in stories
                  @div class: "item #{if n is 0 then 'active' else ''}", =>
                    @div
                      style: """
                        height  : 200px;
                        overflow: hidden;
                        overflow-y: auto;
                        margin-bottom: 10px;
                      """
                      =>
                        @markdown story.text
                    @a
                      class: "btn btn-info"
                      href: "/stories/#{story.id}/"
                      =>
                        @i class: "fa fa-fw fa-eye-open"
                        @translate "got to story"
                        if story.questions.length - 1
                          @text " "
                          @translate "(%d other questions)", story.questions.length - 1

                    if stories?.length > 1 then @div class: "btn-group pull-right", ->
                      @a
                        class: "btn btn-default"
                        href: "#stories-dialog"
                        data: slide: "prev"
                        => @i class: "fa fa-chevron-left"

                      @span
                        disabled: true
                        class   : "btn"
                        "#{n+1} / #{stories?.length}"

                      @a
                        class: "btn btn-default"
                        href: "#stories-carousel"
                        data: slide: "next"
                        => @i class: "fa fa-chevron-right"
