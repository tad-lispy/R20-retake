verify = (assertion) ->
  if assertion
    $.post '/authenticate/browserid', {assertion}
      .done -> do location.reload
      .fail -> console.error arguments

jQuery ($) ->
  $('.browserid.login.btn').click ->
    navigator.id.get verify,
      siteName: $('body').data 'title'
      siteLogo: '/icon-large.svg' if window.location.protocol is 'https:'
