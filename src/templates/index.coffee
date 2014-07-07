Template = require 'teacup-view'

config   = require 'config-object'

module.exports = new Template (title) ->
  @h1 title

  @footer """
    #{config.name} #{config.version}.
    This is a free software by #{config.author} distributed under #{config.license}.
  """
