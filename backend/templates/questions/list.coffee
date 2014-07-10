View      = require "teacup-view"

layout    = require "../layouts/default"

module.exports = new View (data) ->
  
  data.subtitle = @cede => @translate "Legal questions of interest"

  {
    query
    questions
    csrf
  } = data
  
  layout data, =>
  
    @form
      method: "GET"
      =>
        @div class: "input-group input-group-lg", =>
          @input
            id          : "query"
            type        : "text"
            name        : "query"
            class       : "form-control"
            placeholder : @cede => @translate "Type to search or create new..."
            value       : query
            data        :
              shortcut    : "/"
          @div class: "input-group-btn", =>
            @button
              class : "btn btn-primary"
              type  : "submit"
              =>
                @i class: "fa fa-fw fa-search"
                @translate "Search"

            @dropdown items: [
              title : @cede => @translate "new question"
              icon  : "plus-circle"
              data  :
                toggle  : "modal"
                target  : "#question-new-dialog"
                shortcut: "n"
              herf  : "#new-question"
            ]

    do @hr
    
    if questions.length
      for question in questions
        @div class: "panel panel-default", =>
          @a href: "/questions/#{question._id}", class: "panel-body list-group-item lead", =>
            @markdown question.text
          @div class: "panel-footer", =>
            if question.answers.length 
              @ul class: "list-inline", =>
                @strong => @translate "%d answers by:", question.answers.length
                for answer in question.answers
                  @li => @a href: "/questions/#{question._id}/##{answer._id}", answer.author?.name or @cede => @translate "unknown author"
    
            else @strong => @translate "No answers yet."
        
    @modal 
      title : @cede => @translate "New question"
      id    : "question-new-dialog"
      =>
        @questionForm
          method  : "POST"
          action  : "/questions/"
          csrf    : csrf
