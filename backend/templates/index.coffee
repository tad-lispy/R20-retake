View    = require "teacup-view"
fs      = require "fs"

layout  = require "./layouts/default"
text    = fs.readFileSync __dirname + '/welcome.md', 'utf-8'

module.exports = new View (data) ->
  {
    query
    entries
  } = data

  layout data, =>
    @searchForm { query, action: '/search' }
    do @hr
    # @newsFeed { entries }
    @markdown text
