View      = require "teacup-view"
fs        = require "fs"
_         = require "lodash"
_.string  = require "underscore.string"
config    = require "config-object"

layout    = require "../layouts/default"

module.exports = new View (data) ->
  {
    query
    participant
    csrf
    user
  } = data
  data.title = data.participant.name
  data.subtitle = config.get 'site/title'

  can_edit = user?.id is participant.id or user?.can 'edit others profiles'

  layout data, =>

    @div class: "jumbotron", =>
      @markdown participant.bio or "*no bio provided*"
      if can_edit then @div class: 'clearfix', =>
          @button
            class   : "btn btn-default pull-right"
            type    : "button"
            data    :
              toggle  : "modal"
              target  : "#profile-edit-dialog"
              shortcut: "e"
            =>
              @i class: "fa fa-fw fa-edit"
              @translate "edit profile"

    if can_edit then @modal
      title : @cede => @translate "Edit profile"
      id    : "profile-edit-dialog"
      =>
        @p => @translate "What can you tell us about %s?", participant.name
        @profileForm {
          participant
          user
          csrf
          method: 'PUT'
          action: "/participants/#{participant.id}"
        }

          # @storyForm
          #   method  : "POST"
          #   action  : "/stories/#{story._id}/drafts"
          #   story   : draft?.data or story
          #   csrf    : csrf

    # List of answers
    # @div class: "row", =>
    #   for participant in participants
    #     @div class: "col-md-4 col-sm-12", =>
    #       @profileBox {participant, show_auth: no}
