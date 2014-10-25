View      = require "teacup-view"
moment    = require "moment"

layout    = require "../layouts/default"

module.exports = new View (data) ->

  data.subtitle = @cede => @translate "Legal questions matching your query"

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

    else @div class: "alert alert-info", => @translate "No matching questions found."

    @div class: "well", =>
      @p "Would you like to share your story, so we can extract questions from it and try to provide answers?"

      if user?.can 'tell a story'
        @button
          class : 'btn btn-primary btn-lg'
          data  :
            toggle  : "modal"
            target  : "#story-new-dialog"
            shortcut: "n"
          =>
            @i class: "fa fa-fw fa-comment"
            @text "Share a story"

        @modal
          title : @cede => @translate "New story"
          id    : "story-new-dialog"
          =>
            @p => @translate "Please tell us your story."
            @storyForm
              method  : "POST"
              action  : "/stories/"
              text    : query.search
              csrf    : csrf
      else
        @button
          class : "btn btn-primary btn-lg browserid login"
          =>
            @i class: "fa fa-fw fa-check-circle"
            @text "Log in to share a story"
