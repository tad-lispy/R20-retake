View      = require "teacup-view"
config    = require "config-object"

module.exports = new View (options = {}) ->
    {
      action
      method
      csrf
      participant
      user
    } = options

    @form
      method: "post"
      action: action
      =>
        @input
          type  : "hidden"
          name  : "_csrf"
          value : csrf

        if method? then @input
          type  : "hidden"
          name  : "_method"
          value : method

        @div class: "form-group", =>
          @label for: "name", => @translate "Name"
          @input
            name        : "name"
            class       : "form-control"
            placeholder : @cede => @translate "Come on, everybody has at least one name..."
            value       : participant.name

        @div class: "form-group", =>
          @label for: "bio", => @translate "About"
          @textarea
            name        : "bio"
            class       : "form-control"
            placeholder : @cede => @translate "Few words about #{if user?.id is participant.id then 'you' else '%s'}", participant.name
            value       : participant.bio


        @fieldset =>
          @legend => @translate "Roles in #{config.site.title}"
          for own role of config.participants.roles
            @div class: 'checkbox-inline', =>
              @label =>
                @input
                  type: 'checkbox'
                  name: 'roles'
                  value: role
                  checked: role in participant.roles
                  disabled: not user?.can 'assign roles'
                @translate role

          if not user?.can 'assign roles'
            @p =>
              @translate "Feel like you belong to one of theese roles?"
              @text " "
              @a href: 'mailto:' + config.site.email, => @translate "Contact us to get invitation."


        @div class: "form-group", =>
          @button
            type        : "submit"
            class       : "btn btn-primary"
            =>
              @i class: "fa fa-fw fa-check"
              @translate  "That's it"
