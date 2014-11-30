$ ->
  $('.tags.form-control').each ->
    element = $ @
    switch element.prop 'tagName'
      when 'INPUT'
        tags = element
          .data 'options'
          .split ','
        element.select2
          tags        : tags
          openOnEnter : false
      when 'SELECT'
        element.select2
          openOnEnter : false
