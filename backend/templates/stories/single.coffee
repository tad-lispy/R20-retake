View      = require "teacup-view"
layout    = require "../layouts/default"

moment    = require "moment"

module.exports = new View (data) ->
  {
    story
    journal
    entry
    csrf
    query
    user
    tags
    questions # questions suggested for assignment, assigned ones are in story.questions
  } = data
  data.classes  ?=                []
  data.classes.push               "story"
  if entry then data.classes.push "draft"

  data.subtitle = @cede => @translate "The case of %s", moment(story._id.getTimestamp()).format 'LL'

  layout data, =>

    # The story
    if story.isNew
      @div class: 'alert alert-info', =>
        @i class: "fa fa-fw fa-info-circle"
        @translate "Not published yet"

      @h4 class: "text-muted", =>
        @i class: "fa fa-clock-o fa-fw"
        @translate "Versions"
      @draftsTable
        drafts  : journal.filter (entry) -> entry.action is "draft"
        applied : story?._draft
        root    : "/stories/"

    else
      @div class: "jumbotron", =>
        @markdown story.text

        ###
        Technically it's enough to have 'tell a story' capability to view or to post a draft, but we do not expose this functions to readers. If they know an URL then ok, but there is no need to display buttons to them.
        ###
        if user?.can 'review drafts of a story' then @div class: "clearfix", =>
          @div class: "btn-group pull-right", =>
            @button
              class: "btn btn-default"
              data:
                toggle  : "modal"
                target  : "#story-edit-dialog"
                shortcut: "e"
              =>
                @i class: "fa fa-edit fa-fw"
                @translate "make changes"

            items = [
              title : @cede => @translate "show drafts"
              href  : "#show-drafts"
              icon  : "folder"
              data  :
                toggle  : "modal"
                target  : "#drafts-dialog"
                shortcut: "d"
            ]
            # TODO: Consider: If can publish then can remove - right?
            if user?.can 'publish a story' then items.push
              title : @cede => @translate "remove story"
              href  : "#remove"
              icon  : "trash-o"
              data  :
                toggle  : "modal"
                target  : "#remove-dialog"
                shortcut: "del enter"

            @dropdown {items}

      if user?.can 'review drafts of a story' then @modal
        title : @cede => @translate "Edit story"
        id    : "story-edit-dialog"
        =>
          @p => @translate "Could it be told beter? Make changes if so."
          @storyForm
            method  : "POST"
            action  : "/stories/#{story._id}"
            story   : story
            csrf    : csrf

      if user?.can 'review drafts of a story' then @modal
        title : @cede => @translate "Drafts of this story"
        id    : "drafts-dialog"
        =>
          @draftsTable
            drafts  : journal.filter (entry) -> entry.action is "draft"
            applied : story?._draft
            chosen  : entry?._id
            root    : "/stories/"

      if user?.can 'remove a story' then @modal
        title : @cede => @translate "Remove this story?"
        id    : "remove-dialog"
        class : "modal-danger"
        =>
          @form
            method: "post"
            =>
              @input type: "hidden", name: "_csrf"   , value: csrf
              @input type: "hidden", name: "_method" , value: "DELETE"

              @div class: "well", =>
                @markdown story.text

              @p => @translate "Removing a story is roughly equivalent to unpublishing it. It can be undone. All drafts will be preserved."

              @div class: "form-group", =>
                @button
                  type  : "submit"
                  class : "btn btn-danger"
                  =>
                    @i class: "fa fa-trash-o fa-fw"
                    @translate "Remove!"

      # The questions
      @h4 class: 'text-muted', =>
        @i class: 'fa fa-fw fa-question-circle'
        @translate "Legal questions abstracted from this story"

      if story.questions?.length then for question in story.questions
        @questionItem {question}, =>
          if user?.can 'assign question to a story'
            @form
              class : "form pull-right"
              action: "/stories/#{story._id}/questions/#{question._id}"
              method: "post"
              =>
                @input
                  type  : "hidden"
                  name  : "_csrf"
                  value : csrf
                @input
                  type  : "hidden"
                  name  : "_method"
                  value : "DELETE"
                @button
                  type  : "submit"
                  class : "btn btn-danger btn-xs"
                  =>
                    @i class: "fa fa-fw fa-unlink"
                    @translate "unassign"

      else
        @div class: 'alert alert-info', =>
          @translate 'No questions abstracted yet.'

      # The assign form
      @h4 class: 'text-muted', =>
        @i class: 'fa fa-fw fa-plus-circle'
        @translate "Assign new questions to this story"

      if user?.can 'assign question to a story'
        @div class: "panel panel-primary", =>
          @div class: "panel-body", =>
            @searchForm {
              query
              tags
              params:
                action: 'assign'
            }
            if questions
              if questions.length then for question in questions
                @questionItem {question}, =>
                  @form
                    class : "form pull-right"
                    action: "/stories/#{story._id}/questions/"
                    method: "post"
                    =>
                      @input
                        type  : "hidden"
                        name  : "_id"
                        value : question._id
                      @input
                        type  : "hidden"
                        name  : "_csrf"
                        value : csrf
                      @button
                        type  : "submit"
                        class : "btn btn-success btn-xs"
                        =>
                          @i class: "fa fa-fw fa-link"
                          @translate "assign"
              else
                @div class: "alert alert-info", =>
                  @translate "No questions like that found. Sorry :P"
