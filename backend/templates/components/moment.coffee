View      = require "teacup-view"
moment    = require "moment"
moment.lang "pl"

module.exports = new View (given, locale = 'pl') ->
  if      typeof given.getTimestamp       is "function" then given = do given.getTimestamp
  else if typeof given._id?.getTimestamp  is "function" then given = do given._id.getTimestamp

  @raw moment(given).fromNow()