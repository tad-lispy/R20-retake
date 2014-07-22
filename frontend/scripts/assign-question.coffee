$ ->
  $('[data-search]').each ->
    element     = $ @
    collection  = element.data "search"
    element.prop "action", "/#{collection}"
    element.prop "method", "get"

    # Make sure  submit is enabled
    element.find("[type='submit']").prop "disabled", false

    if (element.data "target") and (element.data "source")
      source = $ element.data "source"
      target = $ element.data "target"
      # search = element.find "input[name='query']"

      element.submit (event) ->
        do target.empty

      element.ajaxForm (data) ->
        console.dir data
        for doc in data[collection]
          item = do source.clone
          for key, value of doc
            item.find("[name='#{key}']").val value
            item.find("[data-fill='#{key}']").html value

          target.append item.removeClass "hide"

      do element.submit
