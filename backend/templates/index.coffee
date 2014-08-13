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
    @searchForm
      query   : query
      action  : '/search'
      popover :
        title   : @cede => @translate "Enter your legal question here."
        content : @cede => @translate "e.g. Can I return a thing I bought on the Internet?"
    do @hr
    # @newsFeed { entries }
    @markdown text
