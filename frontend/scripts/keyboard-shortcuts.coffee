jQuery ($) ->
  $("[data-shortcut]").each (i, element) ->
    shortcut  = ($ element).data "shortcut"
    Mousetrap.bind shortcut, (event) ->
      switch element.tagName
        when "INPUT", "TEXTAREA", "SELECT"
          do element.focus
          do event.preventDefault
        when "A"      then do element.click # TODO: supposedly not working in safari. Check!
        when "BUTTON" then do element.click
        else console.error "Shortcuts not implemented yet for #{element.tagName}"

    # Other keybord tweaks
    $('form#search textarea').keypress (e) ->
      if e.which is 13
        # TODO: consider if it's really such a good solution
        do e.preventDefault
        do $('form#search').submit
