Question = require '../models/Question'

module.exports = (req, res, done) ->
  # Normalize tags as an array (can come encoded as a coma delimeted string)
  if typeof req.body.tags is 'string'
    req.body.tags = req.body.tags.split ','

  if typeof req.query.tags is 'string'
    req.query.tags = req.query.tags.split ','

  # Expose all available tags
  # TODO: Consider own route
  Question.distinct 'tags', (error, tags) ->
    if error then return done error
    req.tags = tags
    do done
