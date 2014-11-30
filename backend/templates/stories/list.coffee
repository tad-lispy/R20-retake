View      = require "teacup-view"
moment    = require "moment"

layout    = require "../layouts/default"

_         = require "lodash"
_.string  = require "underscore.string"

module.exports = new View (data) ->
  data.subtitle = "Cases provided by our readers"

  {
    query
    stories
    unpublished
    csrf
    user
  } = data

  layout data, =>

    # TODO: Search stories by questions' tags
    # @searchForm { query }
    # do @hr

    if stories.length # then @div class: "list-group", =>
      for story in stories
        @div class: "panel panel-default", =>
          @a href: "/stories/#{story._id}", class: "panel-body list-group-item lead", =>
            @markdown story.text
          @div class: "panel-footer", =>
            if story.questions.length
              @ul class: "list-inline", =>
                @strong => @translate "%d legal questions:", story.questions.length
                for question in story.questions
                  @li => @a href: "/questions/#{question._id}", question.text
            else @strong => @translate "No questions abstracted yet."

    else @div class: "alert alert-info", => @translate "Nothing like that found. Sorry :P"

    if unpublished?.length
      @h3 => @translate "Unpublished stories"
      @p class: "text-muted", => @translate "There are drafts for those stories, but none of them is published"
      @ul => for story in unpublished
        @li => @a href:  '/stories/' + story._id, =>
          @translate "The case of %s", moment(story._id.getTimestamp()).format 'LL'


    if user?.can 'tell a story'
      @a
        class : "btn btn-default"
        herf  : "#new-story"
        data  :
          toggle  : "modal"
          target  : "#story-new-dialog"
          shortcut: "n"
        =>
          @i class: "fa fa-fw fa-plus-circle"
          @translate "new story"

      @modal
        title : @cede => @translate "New story"
        id    : "story-new-dialog"
        =>
          @p => @translate "Please tell us your story."
          @storyForm
            method  : "POST"
            action  : "/stories/"
            csrf    : csrf
