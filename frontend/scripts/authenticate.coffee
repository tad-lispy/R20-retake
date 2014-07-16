jQuery ($) ->
  $('.browserid.login.btn').click ->
    navigator.id.get (assertion) ->
      if assertion
        $.post '/authenticate/browserid', {assertion}
          .done -> do location.reload
          .fail -> console.error arguments
