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
      else unless auth.fake
        @form
          method: 'POST'
          action: '/authenticate/login'
          class : 'autenticate form', =>
            @div class: 'form-group', =>
              @label
                for  : 'email'
                class: 'control-label sr-only'
                'e-mail'
              @div class: 'input-group', =>
                @span class: 'input-group-addon', => @i class: 'fa fa-fw fa-envelope-o'
                @input
                  type : 'email'
                  name : 'email'
                  id   : 'email'
                  placeholder: 'email address'
                  class: 'form-control'
            @div class: 'form-group', =>
              @label
                for: 'password'
                class: 'control-label sr-only'
                'password:'
              @div class: 'input-group', =>
                @span class: 'input-group-addon', => @i class: 'fa fa-fw fa-lock'
                @input
                  type : 'password'
                  name : 'password'
                  id   : 'password'
                  placeholder: 'password'
                  class: 'form-control'
            @div class: 'form-group', =>
              @button
                type : 'submit'
                class: 'submit btn btn-link'
                =>
                  @i class: "fa fa-fw fa-check-circle"
                  @translate  "Log in"
