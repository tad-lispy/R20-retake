# Tutorials and help messages

jQuery ($) ->
  pops = $('form input[title]').popover
    placement: 'auto bottom'
    delay    : show: 500, hide: 0
    trigger  : 'focus'
    container: 'body'

  pops.popover 'show'
