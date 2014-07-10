View      = require "teacup-view"

module.exports = new View
  components: __dirname
  (options = {}) ->

    {
      action
      method
      csrf
      answer
      question
    } = options
    
    @form
      method: "post"
      action: action
      =>
        @input
          type  : "hidden"
          name  : "_csrf"
          value : csrf
        # TODO: See above
        if options.method? then @input
          type  : "hidden"
          name  : "_method"
          value : method

        @div class: "form-group", =>
          @label for: "text", class: "sr-only", => @translate "What's the correct answer?"
          @textarea
            name        : "text"
            class       : "form-control"
            rows        : 8
            style       : "resize: none"
            placeholder : @cede => @translate "Here goes some serious legal knowledge..."
            answer?.text

        @div class: "form-group", =>
          @button
            type        : "submit"
            class       : "btn btn-primary"
            =>
              @i class: "fa fa-fw fa-check-square"
              @translate "Ok"