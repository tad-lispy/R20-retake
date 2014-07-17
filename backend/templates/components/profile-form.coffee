View      = require "teacup-view"
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
            placeholder : @cede => @translate "Come on, everybody has a name..."
            value       : participant.name

        @div class: "form-group", =>
          @button
            type        : "submit"
            class       : "btn btn-primary"
            =>
              @i class: "fa fa-fw fa-check"
              @translate  "That's it"
