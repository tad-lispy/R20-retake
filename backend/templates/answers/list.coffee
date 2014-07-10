View      = require "teacup-view"

layout    = require "../layouts/default"

module.exports = new View (data) ->
  @text "Answers list view not implemented yet"
  # data.subtitle = "Legal questions of interest"

  # {
  #   query
  #   questions
  #   csrf
  # } = data
  
  # layout data, =>
  
  #   @form
  #     method: "GET"
  #     =>
  #       @div class: "input-group input-group-lg", =>
  #         @input
  #           id          : "query"
  #           type        : "text"
  #           name        : "query"
  #           class       : "form-control"
  #           placeholder : "Type to search or create new..."
  #           value       : query
  #           data        :
  #             shortcut    : "/"
  #         @div class: "input-group-btn", =>
  #           @button
  #             class : "btn btn-primary"
  #             type  : "submit"
  #             =>
  #               @i class: "fa fa-search"
  #               @text " Search"

  #           @dropdown items: [
  #             title : "new question"
  #             icon  : "plus-sign"
  #             data  :
  #               toggle  : "modal"
  #               target  : "#question-new-dialog"
  #               shortcut: "n"
  #             herf  : "#new-question"
  #           ]

  #   do @hr
    
  #   if questions.length then @div class: "list-group", =>
  #     for question in questions
  #       @a href: "/questions/#{question._id}", class: "list-group-item", =>
  #         # @span class: "badge", question.answers.length
  #         @h4
  #           class: "list-group-item-heading"
  #           question.text
          
  #         @p "Answers by: Kot Filemon, Katiusza"
      
  #   else @div class: "alert alert-info", "Nothing like that found. Sorry :P"    
    
  #   @modal 
  #     title : "New question"
  #     id    : "question-new-dialog"
  #     =>
  #       @questionForm
  #         method  : "POST"
  #         action  : "/questions/"
  #         csrf    : csrf
