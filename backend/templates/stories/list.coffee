View      = require "teacup-view"

layout    = require "../layouts/default"

_         = require "lodash"
_.string  = require "underscore.string"

module.exports = new View (data) ->
  data.subtitle = "Cases provided by our readers"

  {
    query
    stories
    csrf
  } = data


  layout data, =>

    @form
      method: "GET"
      class : "form"
      =>
        @div class: "input-group input-group-lg", =>
          @input
            id          : "search"
            type        : "text"
            name        : "search"
            class       : "form-control"
            placeholder : @cede => @translate "Type to search for story..."
            value       : query.search
          @div class: "input-group-btn", =>
            @button
              class : "btn btn-primary"
              type  : "submit"
              =>
                @i class: "fa fa-fw fa-search"
                @text "Search"
            @dropdown items: [
              title : @cede => @translate "new story"
              icon  : "plus-circle"
              data  :
                toggle  : "modal"
                target  : "#story-new-dialog"
                shortcut: "n"
              herf  : "#new-story"
            ]

    do @hr

    if stories.length # then @div class: "list-group", =>
      for story in stories
        @div class: "panel panel-default", =>
          @a href: "/stories/#{story._id}", class: "panel-body list-group-item lead", =>
            @markdown story.text
          @div class: "panel-footer", =>
            if story.questions.length
              @ul class: "list-inline", =>
                @strong "%d legal questions:", story.questions.length
                for question in story.questions
                  @li => @a href: "/questions/#{question._id}", question.text
            else @strong => @translate "No questions abstracted yet."

    else @div class: "alert alert-info", => @translate "Nothing like that found. Sorry :P"

    @modal
      title : @cede => @translate "New story"
      id    : "story-new-dialog"
      =>
        @p => @translate "Please tell us your story."
        @storyForm
          method  : "POST"
          action  : "/stories/"
          csrf    : csrf
