{ 
  renderable, tag
  doctype, html, head, body
  title, meta, link, script, style
  header, main, footer, main, aside, div
  h1, h2, p
  button, i, a
}       = require "teacup"
stylus  = (code) ->
  style type: "text/css", "\n" + (require "stylus").render code

module.exports = renderable (content) ->  
  doctype 5
  html =>
    head =>
      title @settings.name
      meta charset: "utf-8"
      meta name: "viewport", content: "width=device-width, initial-scale=1.0"

      link rel: "stylesheet", href: url for url in [
        "//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css"
        "//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.min.css"
      ]
      stylus """
        body
          padding-top 60px
          background silver
      """
        

    body =>
      header class: "container", =>
        a 
          class: "btn btn-default btn-lg pull-right"
          style: "background: none"
          data: shortcut: "g h"
          href: "/"
          ->
            i class: "fa fa-remove fa-3x"
        
        h1 @settings.name 
        h2 @settings.motto

      div class: "container", id: "content", =>
        div class: "row", =>
          tag "main", class: "col-xs-12", =>
            do content

      footer class: "container", =>
        p "powered by #{@settings.engine} V. #{@settings.version}."

      script type: "text/javascript", src: url for url in [
        "//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"
        "//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"
        "//cdnjs.cloudflare.com/ajax/libs/mousetrap/1.4.5/mousetrap.min.js"
        "/js/keyboard-shortcuts.js"
      ]
