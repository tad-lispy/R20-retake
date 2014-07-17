View      = require "teacup-view"

module.exports = new View (options = {}) ->
  items = [
    title   : "Start"
    url     : "/"
    icon    : "home"
    shortcut: "g h"
  ,
    title   : "Stories"
    url     : "/stories"
    icon    : "comment"
    shortcut: "g s"
  ,
    title   : "Questions"
    url     : "/questions"
    icon    : "question-circle"
    shortcut: "g q"
  ,
    title   : "Answers"
    url     : "/answers"
    icon    : "puzzle-piece"
    shortcut: "g a"
  ,
    title   : "About us"
    url     : "/participants"
    icon    : "group"
    shortcut: "g i"

  ]

  @div class: "panel panel-default sidebar-nav", =>
    @nav class: "panel-body", =>
      @ul class: "nav nav-pills nav-stacked", =>
        for item in items
          @li class: ("active" if item.url is options.url), =>
            @a
              href: "#{item.url}"
              data: shortcut: item.shortcut
              =>
                @i class: "fa fa-fw fa-#{item.icon}"
                @text " "
                @translate item.title
