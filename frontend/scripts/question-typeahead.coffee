$ ->
  $('[data-typeahead]').each ->
    element = $ @
    collection = element.data "typeahead"
    element.typeahead
      name    : collection
      valueKey: "text"
      remote  : "/#{collection}"

    # Bootstrap 3 style fix:
    if element.hasClass "input-lg" then control.prev(".tt-hint").addClass "hint-lg"
    if element.hasClass "input-sm" then control.prev(".tt-hint").addClass "hint-sm"

    if (element.data "target") and (element.data "source")
      element.bind "typeahead:selected typeahead:autocompleted", (event, datum) ->
        source      = $ element.data "source"
        target      = $ element.data "target"
        attachment  = do source.clone

        for key of datum
          console.log attachment.find("[name='#{key}']").val datum[key]

        attachment.appendTo target
        attachment.removeClass "hide"




  # control.bind "typeahead:selected typeahead:autocompleted", (event, datum) ->
  #   # TODO: this is just plain ugly.
  #   unless ($ "#question-" + datum._id).length
  #     question = do ($ "#question-template").clone
  #     console.dir question
  #     question.removeClass "hide"
  #     question.attr "id", "question-" + datum._id
  #     question.find("input").val datum._id
  #     question.find("p a").text(datum.text).attr "href", "/questions/#{datum._id}"
  #     question.find("button").bind "click", -> do question.remove

  #     $("#questions").append question

  #     control.typeahead "setQuery", ""
  #   # TODO: notify if duplicate


  # control.bind "keypress", (event) ->
  #   if event.keyCode is 13 
  #     do event.preventDefault
  #     ($ "#new-question-dialog input[name=text]").val control.val()
  #     do ($ "#new-question-dialog").modal


