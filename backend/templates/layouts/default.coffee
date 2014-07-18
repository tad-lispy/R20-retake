View    = require "teacup-view"
_       = require "lodash"

config  = require 'config-object'

module.exports = new View (options = {}, content) ->
    if not content and typeof options is "function"
      content = options
      options = {}

    _(options).defaults
      scripts : []
      styles  : []
      classes : []
      title   : config.site.title
      subtitle: config.site.motto

    {
      scripts
      styles
      classes
      title
      subtitle
      csrf
      user
    } = options

    @doctype 5
    @html =>
      @head =>
        @title "#{title} | #{subtitle}"
        @meta charset: "utf-8"
        @meta name: "viewport", content: "width=device-width, initial-scale=1.0"

        @link rel: "stylesheet", href: url for url in [
          "//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css"
          "//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.min.css"
          "/styles/R20.css"
        ]

      @body data: { csrf }, class: (classes.join " "), =>
        @div class: "container", id: "content", =>
          @header class : "page-header", =>
            @h1 =>
              @raw title + " "
              @br class: "visible-xs visible-sm"
              @small => @raw subtitle

          @div class: "row", =>
            @tag "main", class: "col-xs-12 col-sm-9", =>
              do content

            @aside
              id    : "sidebar"
              class : "col-xs-12 col-sm-3"
              =>
                do @navigation
                @profileBox participant: user

        @footer class: "container", =>
          @small =>
            @i class: "fa fa-bolt"
            @text " powered by "
            @a
              href  : config.repo
              target: "_blank"
              config.name
            @text " v. #{config.version}. "
            do @wbr
            @text "#{config.name} is "
            @a
              href: "/license",
              "a free software"
            @text " by "
            # TODO: split config.author into fields (a'la R20-legacy)
            @a href: '#', "Good People of CLIT"
            # @a href: config.author?.website, settings.author?.name
            @text ". "
            do @wbr
            @text "Thank you :)"

        # views and controllers can set @styles and @scripts to be appended here
        @script type: "text/javascript", src: url for url in [
          "//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"
          "//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"
          "//cdnjs.cloudflare.com/ajax/libs/typeahead.js/0.9.3/typeahead.min.js"
          "//cdnjs.cloudflare.com/ajax/libs/mousetrap/1.4.5/mousetrap.min.js"
          "/scripts/keyboard-shortcuts.js"
          "//cdn.jsdelivr.net/jquery.cookie/1.4.0/jquery.cookie.min.js"
          "https://login.persona.org/include.js"
          "/scripts/authenticate.js"
          "/scripts/modals.js"
        ].concat scripts or []

        if styles? then @link rel: "stylesheet", href: url for url in styles
