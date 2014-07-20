jQuery ($) ->
  $("[data-shortcut]").each (i, element) ->
    shortcut  = ($ element).data "shortcut"
    Mousetrap.bind shortcut, (event) ->
      switch element.tagName
        when "INPUT", "TEXTAREA"
          do element.focus
          do event.preventDefault
        when "A"      then do element.click # TODO: supposedly not working in safari. Check!
        when "BUTTON" then do element.click
        else console.error "Shortcuts not implemented yet for #{element.tagName}"
