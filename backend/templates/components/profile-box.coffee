View      = require "teacup-view"
_         = require "lodash"
_.string  = require "underscore.string"

config    = require "config-object"

module.exports = new View (data = {}) ->
  { user } = data
  { auth } = config

  @div class: "panel panel-default sidebar-nav", =>
    @nav class: "panel-body", =>
      if user?
        @h5 user.name
        @h6 user.roles.join ", "
        unless auth.fake
          @ul class: "nav nav-pills nav-stacked", =>
            @li => @a
              href: "/logout"
              title: @cede => @translate "Log out"
              =>
                @i class: "fa fa-fw fa-power-off"
                @translate "Log out"
      else
        unless auth.fake
          @ul class: "nav nav-pills nav-stacked", =>
            @li => @a
              href: "/authenticate"
              title: @cede => @translate "Log in"
              =>
                @i class: "fa fa-fw fa-check-circle"
                @translate  "Log in"
