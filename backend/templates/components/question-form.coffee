View      = require "teacup-view"
module.exports = new View
  components: __dirname
  (options = {}) ->

    {
      action
      method
      csrf
      question
    } = options
    
    if method is "PUT"
      @p => @translate "Doesn't suit your legal taste? Please make adjustments as you see fit."
    else
      @p => @translate "You are about to add a new legal question. Are you sure it's not already there?"


    @form
      method: "post"
      action: action
      =>
        @input
          type  : "hidden"
          name  : "_csrf"
          value : csrf
        if options.method? then @input
          type  : "hidden"
          name  : "_method"
          value : method

        @div class: "form-group", =>
          @label for: "text", class: "sr-only", => @translate "Question text:"
          @div class: "input-group", =>
            @input
              type        : "text"
              name        : "text"
              class       : "form-control"
              value       : question?.text
              placeholder : @cede => @translate "Enter the text of a question..."
            @div class: "input-group-btn", =>
              @button
                type        : "submit"
                class       : "btn btn-primary"
                => @translate "ok"
