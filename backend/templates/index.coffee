View    = require "teacup-view"
fs      = require "fs"

layout  = require "./layouts/default"
text    = fs.readFileSync __dirname + '/welcome.md', 'utf-8'

module.exports = new View (data) ->
  {
    query
    entries
    tags
  } = data

  layout data, =>
    @searchForm { query, tags, action: '/questions' }
    do @hr
    # @newsFeed { entries }
    @markdown text
