{
  renderable, tag, text
  div, main, aside, nav
  ul, li
  h3, h4, p
  i, span
  a
  form, button, input
  hr
} = require "teacup"
template  = require "./templates/default"

module.exports = renderable (data) ->
  template.call @, =>   
    @helper "search-form"
    @helper "search-results"



