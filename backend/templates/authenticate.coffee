View = require "teacup-view"

layout  = require "./layouts/default"

module.exports = new View (data) ->
  layout data, =>
    @h1 data.user?.name or 'Not authenticated'
    @form
      method: 'POST'
      class : 'autenticate form-horizontal', =>
        @div class: 'form-group', =>
          @label
            for  : 'email'
            class: 'control-label col-sm-3'
            'e-mail:'
          @div class: 'col-sm-9', => @input
            type : 'email'
            name : 'email'
            id   : 'email'
            class: 'form-control'
        @div class: 'form-group', =>
          @label
            for: 'password'
            class: 'control-label col-sm-3'
            'password:'
          @div class: 'col-sm-9', => @input
            type : 'password'
            name : 'password'
            id   : 'password'
            class: 'form-control'
        @div class: 'form-group', =>
          @div class: 'col-sm-9 col-sm-offset-3', => @button
            type : 'submit'
            class: 'submit btn btn-primary btn-block'
            "Authenticate"
