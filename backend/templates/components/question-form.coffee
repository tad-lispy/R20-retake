View      = require "teacup-view"
module.exports = new View
  components: __dirname
  (options = {}) ->

    {
      action
      method
      csrf
      question
      tags
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
          @input
            type        : "text"
            name        : "text"
            class       : "form-control"
            value       : question?.text
            required    : yes
            placeholder : @cede => @translate "Enter the text of a question..."
        @div class: "form-group", =>
          @label for: "tags", class: "sr-only", => @translate "Question tags:"
          @input
            name        : "tags"
            class       : "tags form-control"
            value       : question?.tags
            data        :
              placeholder : @cede => @translate "Provide some tags to make it searchable..."
              options     : tags
              select      : yes

        @div class: "form-group", =>
          @button
            type        : "submit"
            class       : "btn btn-primary btn-block"
            => @translate "ok"
