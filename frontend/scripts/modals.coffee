jQuery ($) ->
  $(".modal").each (i, modal) ->
    modal = $ modal
    modal.on "show.bs.modal", ->
      console.log "Hiding other modals"
      $ ".modal"
        .modal "hide"
      
    modal.on "shown.bs.modal", ->
      modal
        .find "form"
        .find "textarea, input[type='text']"
        .first()
        .focus()