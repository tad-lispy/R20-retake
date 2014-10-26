View      = require "teacup-view"
layout    = require "../layouts/default"
config    = require 'config-object'

moment    = require "moment"

module.exports = new View (data) ->
  {
    story
    journal
    entry
    csrf
    query
    user
  } = data

  data.classes  ?=                []
  data.classes.push               "story draft"

  data.subtitle = @cede => @translate "Draft of a case provided on %s",
    moment(story._id.getTimestamp()).format 'LL'

  layout data, =>

    applied  = Boolean story._draft?.equals entry._id

    @draftAlert
      applied   : applied
      draft     : entry
      actualurl : "/stories/#{story._id}"

    if not user? then @div class: 'alert alert-info', =>
      @translate 'You are not logged in. Please do it in order to edit or approve this draft.'
      @a
        href  : '#'
        class : [
          'btn'
          'btn-default'
          'btn-xs'
          'pull-right'
          'browserid'
          'login'
        ].join ' '
        =>
          @i class: 'fa fa-fw fa-check-circle'
          @translate 'Log in'

    @div class: "jumbotron", =>
      @markdown entry.data.text

      if user?.can 'publish a story' then @form
        action: "/stories/#{story.id}/journal/#{entry.id}/apply"
        method: "POST"
        class : "clearfix"
        =>
          @input type: "hidden", name: "_csrf"    , value: csrf
          @input type: "hidden", name: "_draft"   , value: entry._id

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
              href  : "#edit-story"
              icon  : "edit"
              data  :
                toggle  : "modal"
                target  : "#story-edit-dialog"
                shortcut: "e"
            ]

      else if user?.can 'tell a story' then @form
        action: "/stories/#{story.id}/journal/#{entry.id}/approve"
        method: "POST"
        class : "clearfix"
        =>
          @input type: "hidden", name: "_csrf"    , value: csrf
          @input type: "hidden", name: "_draft"   , value: entry._id

          @div class: "btn-group pull-right", =>
            # TODO:
            # @button
            #   class   : "btn btn-success"
            #   type    : "submit"
            #   disabled: applied
            #   data    : shortcut: "a a enter"
            #   =>
            #     @i class: "fa fa-fw fa-check-square"
            #     @translate "approve this draft"

            # Temporary MVP solution
            @a
              class   : "btn btn-success"
              disabled: applied
              href    : "mailto:#{config.site.email}?title=#{@cede => @translate 'Draft approval'}"
              data    : shortcut: "a a enter"
              =>
                @i class: "fa fa-fw fa-check-square"
                @translate "approve this draft"

            @a
              class : "btn btn-default"
              href  : "#edit-story"
              data  :
                toggle  : "modal"
                target  : "#story-edit-dialog"
                shortcut: "e"
              =>
                @i class: "fa fa-fw fa-edit"
                @translate "make changes"

    @h4 class: "text-muted", =>
      @i class: "fa fa-clock-o fa-fw"
      @translate "Versions"
    @draftsTable
      drafts  : journal.filter (entry) -> entry.action is "draft"
      applied : story?._draft
      chosen  : entry?._id
      root    : "/stories/"

    if user?.can 'tell a story' then @modal
      title : @cede => @translate "Edit story"
      id    : "story-edit-dialog"
      =>
        @p => @translate "Could it be told beter? Make changes if so."
        @storyForm
          method  : "POST"
          action  : "/stories/#{story._id}"
          story   : entry?.data
          csrf    : csrf
