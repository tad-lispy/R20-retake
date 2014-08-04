View = require "teacup-view"

layout  = require "./layouts/default"

module.exports = new View (data) ->
  {
    query
    entries
  } = data

  layout data, =>
    @searchForm { query, action: '/search' }
    do @hr
    @newsFeed { entries }
