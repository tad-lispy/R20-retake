View      = require "teacup-view"
_         = require "lodash"
_.string  = require "underscore.string"

config    = require "config-object"

module.exports = new View (data = {}) ->
  {
    participant    # Profile to display
    show_auth      # Should auth controls be displayed
    class: clss    # HTML element class (renamed to avoid syntax error)
  } = data

  { auth } = config

  show_auth ?= yes
  clss ?= ''

  @div class: "panel panel-default sidebar-nav #{clss}", =>
    @nav class: "panel-body", =>
      if participant?
        @h5 => @a
          href: "/participants/#{participant.id}"
          participant.name
        @ul class: "list-inline", => for role in participant.roles
           @li => @translate role

        if show_auth and not auth.fake
          @form
            class : 'form'
            action: '/authenticate/logout'
            method: 'POST'
            =>
              @button
                type : 'submit'
                class: 'btn btn-link'
                title: @cede => @translate "Log out"
                =>
                  @i class: "fa fa-fw fa-power-off"
                  @translate "Log out"

      # No participant (e.g. user's profile box and user not logged in)
      else if show_auth and not auth.fake
        @button
          class: 'browserid login btn btn-link'
          =>
            @i class: "fa fa-fw fa-check-circle"
            @translate  "Log in"
